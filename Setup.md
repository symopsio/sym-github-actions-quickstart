# Setup Guide

This setup guide walks you through everything you need to get a Sym Okta workflow configured!

1. A GitHub AWS OIDC role that lets you run AWS operations from GitHub without access keys
2. A GitHub action to create a Terraform state bucket to manage your Sym resource state
3. A GitHub workflow to manage changes through sandbox and prod environments.

You can mix and match from these components if you want to manage Terraform state differently, don't want to use GitHub actions, or don't want to use the OIDC role.

## Step 1: Environnment setup

You need to run the same environment setup as in the basic [Okta Quickstart](https://okta.tutorials.symops.com/):

* Set up [symflow](https://okta.tutorials.symops.com/#3)
* Install the [Slack app](https://okta.tutorials.symops.com/#4)

## Step 2: Configure the GitHub repo

In order to run GitHub actions to deploy your flows, you should make a copy of the `sym-github-actions-quickstart` repo in your org. Once you have the repo copied, we'll use `symflow` to configure a bot token that lets Sym authenticate from your GitHub action:

```
$ symflow bots create github
$ symflow tokens issue --username github --label "GitHub Actions" --expiry 365d
<token output here>
```

Configure a [repository secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) with the token value. Set the `SYM_JWT` key to the bot token value.

## Step 3: Set up the Bootstrap IAM Role

In order to deploy and run Sym, you'll need to provide AWS credentials to create Sym's dependencies in your infrastructure.

We provide you an AWS IAM Policy that includes all the permissions required to set up this repo, along with a few ways to configure these permissions:

### Option 1: Use Terraform

If you have an existing Terraform pipeline you can include the [environments/bootstrap](environments/bootstrap) configurations to create the required GitHub OIDC provider and IAM policy.

```
$ cd environments/bootstrap
$ terraform apply
```

### Option 2: Provision with the AWS CLI or with other tooling

We have a [gist](https://gist.github.com/jon918/ed09ef173aefcd01e917155210fec572) with all the requirements you need to provision Sym's policies using your own tooling.

#### Create the Sym AWS IAM Policy

We'll create the policy that lets you provision Sym dependencies first, and then attach this to a role, group, or user as needed.

1. Grab [`access-policy.json`](https://gist.github.com/jon918/ed09ef173aefcd01e917155210fec572).

2. Edit `access-policy.json`, replacing AWS_ACCOUNT_ID with the AWS Account ID you'll be provisioning into.

3. Provision the policy:

```
$ aws iam create-policy --policy-name SymGitHubActionAccess \
  file://access-policy.json
```

#### GitHub Actions OIDC (Optional): Attach the policy to a GitHub Actions OIDC Role

GitHub Actions lets you [configure an AWS IAM Role](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) that Actions can assume, so you don't have to configure and/or rotate AWS Access Keys in your GitHub account.

In order to set this up, you need to create an AWS IAM Identity Provider and an AWS IAM Role that can assume this Identity Provider.

1. Grab [`create-open-id-connect-provider.json`](https://gist.github.com/jon918/ed09ef173aefcd01e917155210fec572) and then run the following to create a GitHub OIDC Identity Provider in your account:

```
$ aws iam create-open-id-connect-provider --cli-input-json file://create-open-id-connect-provider.json
```

2. Grab [`assume-role-policy-document.json`](https://gist.github.com/jon918/ed09ef173aefcd01e917155210fec572) and edit the following three values:
   - ACCOUNT_ID: Set the AWS Account ID where you're provisioning this Role
   - GITHUB_ORG: Set to the GitHub organization where your GitHub action will run
   - GITHUB_REPO: Set to the name of the GitHub repo where your GitHub action will run

3. Provision the IAM Role with the edited `assume-role-policy-document.json`:

```
$ aws iam create-role --role-name SymGitHubActionAccess \
  --asume-role-policy-document file://assume-role-policy-document.json
```

4. Attach the Sym access policy to your GitHub Actions role:

```
$ aws iam attach-role-policy --role-name SymGitHubActionAccess \
  --policy-arn arn:aws:iam::AWS_ACCOUNT_ID:policy/SymGitHubActionAccess
```

5. Update the `AWS_ROLE_ARN` value in the GitHub actions [in this repo](.github/workflows) to use the ARN of the role you just created.

#### No GitHub Actions OIDC: Create an AWS IAM User

If setting up the GitHub AWS OIDC connection is not for you, then you can simply create an AWS IAM user that can bootstrap Sym workflows, or attach the required permissions to an existing users.

If you're taking this path, you should update the GitHub actions [in this repo](.github/workflows) to not use `AWS_ROLE_ARN` and instead rely on an AWS Access Key and Secret.

## Step 4: Bootstrap Terraform State and Set Up Prod

This repo includes a [bootstrap workflow](.github/workflows/terraform-bootstrap.yml) that you can use to set up Terraform state management directly from GitHub actions.

To run the bootstrap workflow, make sure you've edited the `AWS_ROLE_ARN` value in `main.yml` and `terraform-bootstrap.yml` to the right value, or that you've removed it entirely if you plan to use an AWS Access Key and Secret.

1. Manually trigger the bootstrap workflow from the GitHub Actions console
2. The bootstrap workflow will create a Pull Request with the updates to use S3 to manage your Terraform state.
3. When you merge the workflow, your prod e2e flow will be provisioned!

## Step 5: Set up Sandbox

Now that the prod workflow is set up, lets finishing configuring flows so that we have a sandbox flow where we can test stuff out!

1. From your local console, create a `sandbox` branch and push it to remote

```
$ git checkout -b sandbox
$ git push -u sandbox
```

2. This will trigger a GitHub action to set up your sandbox flow! If you go back to Slack, you'll now see a "Show all environments" option that lets you run your sandbox flow.

3. Recommended: Add branch protection rules for your `main` branch!

## Step 6: Set up your Okta API Token

We have our flows running but we don't have an Okta API key to let us actually modify Okta groups yet!

1. Create an Okta API token using our [Okta Setup Instructions](https://docs.symops.com/docs/okta).

2. Now you'll need to configure the API token in AWS Secrets Manager so that your prod and sandbox Sym flows can use it:

```
$ OKTA_API_TOKEN=xxx
$ aws secretsmanager put-secret-value \
  --secret-id /symops.com/prod \
  --secret-string "{\"okta_api_token\": \"$OKTA_API_TOKEN\"}"
$ aws secretsmanager put-secret-value \
  --secret-id /symops.com/sandbox \
  --secret-string "{\"okta_api_token\": \"$OKTA_API_TOKEN\"}"
```

## Step 7: Set up your Okta Targets

Use the standard [Okta Quickstart](https://okta.tutorials.symops.com/#8) to set up your Okta targets. The only difference here is, that we've got two `terraform.tfvars` files to configure, one for each environment:

1. `environments/prod/terraform.tfvars`
2. `environments/sandbox/terraform.tfvars`

## Step 8: E2E Testing

We've included a placeholder Cypress test that will run when you open a PR against the `main` branch.

1. Update your `tfvar` configurations in step 7 and push the changes to the sandbox branch.
2. You should see that your changes get updated in the sandbox environment.
3. Now open a PR against `main`. You should see a `plan` of your changes against the `prod` environment, as well as a `cypress` run that you can use to test the sandbox version of the flow!

## Step 9: What's next?

Lots more you can opt into, refer to the [Okta Quickstart](https://okta.tutorials.symops.com/#9) for more ideas!

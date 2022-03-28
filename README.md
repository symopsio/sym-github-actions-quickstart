# Sym GitHub Actions Quickstart

A starter template to get an Okta-based Sym Flow provisioned and managed entirely with GitHub Actions. By implementing this template, you'll have the ability to provision, test and validate Sym Flows in a sandbox environment and then push the Flows to prod, all from GitHub Actions.

## Tutorial

Check out a step-by-step tutorial [here](https://github-actions.tutorials.symops.com).

## Data Flow

When an End-User approves an escalation request, the Sym Platform does the following:

1. Assumes your [Runtime Connector](https://docs.symops.com/docs/runtime-connector) IAM role. This role lives in your AWS account, and has access to tagged secrets within your AWS Secrets Manager instance.
2. Grabs the Okta API Token that [you've configured for Sym](https://docs.symops.com/docs/okta) from AWS Secrets Manager.
3. Adds or removes the user from the appropriate group in Okta.

![Data Flow](docs/SymDataFlow.jpg)

### Security Considerations

Sym's Runtime Connector IAM Role has a trust relationship with Sym's production AWS account. This trust relationship allows the Sym platform to securely assume your Runtime Connector IAM role without a password. This is called a "role chaining" type of trust relationship.

The RuntimeConnector module ensures that we use an [external id](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) when assuming your IAM Role per AWS best practices.

## Modules

Your engineers provision resources in both AWS and Sym. You can mix and match your Terraform resources in whatever way works best for your organization. Our default setup puts shared configurations in the `sym-runtime` module and makes it easy to add new modules for specific Flows.

![Provisioning Flow](docs/SymProvisioningFlow.jpg)

### sym-runtime module

The [`sym-runtime`](modules/sym-runtime) creates a shared Runtime that executes all your Flows.

### okta-access-flow

The [`okta-access-flow`](modules/okta-access-flow) module defines the workflow that your engineers will use to get temporary IAM access.

## About Sym

This workflow is just one example of how [Sym Implementers](https://docs.symops.com/docs/deploy-sym-platform) use the [Sym SDK](https://docs.symops.com/docs) to create [Sym Flows](https://docs.symops.com/docs/flows) that use the [Sym Approval](https://docs.symops.com/docs/sym-approval) Template.

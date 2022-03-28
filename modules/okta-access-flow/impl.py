from sym.sdk.annotations import hook, reducer
from sym.sdk.integrations import slack, okta
from sym.sdk.templates import ApprovalTemplate


# Reducers fill in the blanks that your workflow needs in order to run.
@reducer
def get_approvers(evt):
    """
    Post to shared channel to ask for access approval, allowing
    self-approval
    """
    fvars = evt.flow.vars

    # Request approval in channel
    return slack.channel(fvars["request_channel"], allow_self=True)


# Hooks let you change the control flow of your workflow.
# @hook Uncomment me to enable authz based on an approvers group!
def on_approve(evt):
    """
    Only let members of the approver group approve requests
    """
    fvars = evt.flow.vars
    if not okta.is_user_in_group(evt.user, group_id=fvars["approver_group"]):
        return ApprovalTemplate.ignore(
            message="You are not authorized to approve this request."
        )

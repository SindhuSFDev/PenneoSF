({
	 deleteVotingHelper: function (component, event, helper) {
        component.find("service").callApex(component, helper,
                "c.resetGuestVoting",
                { "recordId": component.get("v.recordId")}, this.deleteVotingHelperSuccess);
    },

    deleteVotingHelperSuccess: function (component, returnValue, helper) {
        if (returnValue == 'success') {
            helper.showToast(component, helper, returnValue, 'Voting Count Reset');
        } else {
            helper.showToast(component, helper, 'Error', 'Some error occured. Please try again.');
        }
    },
    showToast: function (component, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type,
            "message": message,
            "type": type,

        });
        toastEvent.fire();
    },
})
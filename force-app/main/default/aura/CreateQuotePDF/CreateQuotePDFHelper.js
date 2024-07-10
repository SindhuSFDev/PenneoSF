({
    doInit : function (cmp, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.init");
        action.setParams({
            recordID : cmp.get("v.recordId")
        });

        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned
                // from the server
                var syncStatus = response.getReturnValue();
                if (syncStatus == 'valid') {
                    cmp.set("v.canCreateQuotePDF", true);
                    cmp.set("v.isLoaded", true);
                } else if (syncStatus == 'invalid') {
                    cmp.set("v.canCreateQuotePDF", false);
                    cmp.set("v.isLoaded", true);
                } else {
                    helper.showToast("Error", "Something went wrong while saving the Quote PDF. Please contact System Administrator.");
                }
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                helper.showToast("Error", "Something went wrong while saving the Quote PDF. Please contact System Administrator.");
                $A.get("e.force:closeQuickAction").fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

	saveAsPDFHelper : function (cmp, event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.createQuotePDF");
        action.setParams({
            recordID : cmp.get("v.recordId")
        });

        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned
                // from the server
                var syncStatus = response.getReturnValue();
                if (syncStatus == 'success') {
                    helper.showToast("Success", "Quote PDF Saved successfully.");
                } else if (syncStatus.startsWith('Error')) {
                    helper.showToast("Error", syncStatus);
                } else {
                    helper.showToast("Error", "Something went wrong while saving the Quote PDF. Please contact System Administrator.");
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get("e.force:refreshView").fire();
                    }), 2000
                );
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                helper.showToast("Error", "Something went wrong while saving the Quote PDF. Please contact System Administrator.");
                $A.get("e.force:closeQuickAction").fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})
({
    doInitHelper : function(component, event, helper) {
        component.find("service").callApex(component, helper,
                                           "c.getComments",
                                           {
                                               'recordId': component.get("v.articleName"),
                                           }, this.doInitHelperSuccess);
    },
    
    doInitHelperSuccess: function(component, returnValue, helper) {
        component.set('v.Comment', returnValue);
        console.log('returnValue: ', returnValue);
    },
    
    handleSaveCommentHelper: function(component, event, helper) {
        component.find("service").callApex(component,helper,
                                           "c.saveComment",
                                           {
                                               'recordId': component.get('v.articleName'),
                                               'Comment' : component.get('v.NewComment'),
                                           }, this.handleSaveCommentHelperSuccess);
        
    },
    handleSaveCommentHelperSuccess: function(component, returnValue, helper){
        var toastEventSuccess = $A.get("e.force:showToast");
        toastEventSuccess.setParams({
            "title": "Success!",
            "message": "The record has been created successfully.",
            "type" : "success"
        });
        
        var toastEventFailure = $A.get("e.force:showToast");
        toastEventFailure.setParams({
            "title": "Error!",
            "message": "Error Occured",
            "type": "Error"
        });
        if(returnValue){
            toastEventSuccess.fire();
            
        } else {
            toastEventFailure.fire();
        }
        $A.get('e.force:refreshView').fire();
        
    },
})
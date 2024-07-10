/**
 * Created by ayushi.d@cloudroute.in on 26-10-2020.
 */
({
    getCaseId : function(component, event, helper){
      var queryString = window.location.search;
      console.log('queryString: ',queryString);
      var urlParams = new URLSearchParams(queryString);
      var caseId = urlParams.get('caseId')
      console.log('caseId: ',caseId);
      component.set('v.caseId', caseId);
      component.find("service").callApex(component, helper, "c.getCaseDetails", {
                  caseId : caseId
              }, this.getCaseIdSuccess);
    },

    getCaseIdSuccess : function(component, returnValue, helper){
        component.set('v.spinner', false);
        if(returnValue.isSuccess){
            component.set('v.showButtons', true);
        }else{
            component.set('v.showMessage', true);
            if(returnValue.errorMsg != null){
                component.set('v.message', returnValue.errorMsg);
            }
        }
    },

    saveResponseOnCase : function (component, event, helper){
      var responseClicked = component.get('v.responseClicked');
      var recordId = component.get('v.caseId');
      var comments = component.get('v.comments');
       component.find("service").callApex(component, helper, "c.saveCaseResponse", {
                         response : responseClicked,
                         caseId : recordId,
                         comment : comments
                     }, this.saveResponseSuccess);
    },

    saveResponseSuccess : function (component, returnValue, helper){
        component.set('v.spinner', false);
        component.set('v.showButtons', false);
        component.set('v.showMessage', true);
        var msg = returnValue.errorMsg;
        if(returnValue.isSuccess){
            component.set('v.message', returnValue.errorMsg);
            helper.showToast("Success", msg);
        }else{
            component.set('v.message', returnValue.errorMsg);
            helper.showToast("Error", msg);
        }
    },

    showToast: function (type, message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": type,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        },
})
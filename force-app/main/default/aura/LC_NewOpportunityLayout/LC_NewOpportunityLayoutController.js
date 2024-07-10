({
    handleSubmit: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        console.log('sURLVariables: ',sURLVariables);
        var sParameterName;
        var recordTypeId;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'recordTypeId') { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                component.set('v.recordTypeId', sParameterName[1]);
                recordTypeId = sParameterName[1];
            }
        }
        console.log('Param value', recordTypeId);
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        if(sParameterName[1] != null && sParameterName[1] != 'undefined' && sParameterName[1] != 'Not found'){
            fields.RecordTypeId = component.get('v.recordTypeId');
        }
        component.find('newOpportunity').submit(fields);
    },
    
    handleSuccess: function(component, event, helper) {
        var successMsg = $A.get("$Label.c.LC_NewOpportunityLayout_Success_Msg");
        var recordId = event.getParam("response").id;  
        console.log(recordId);
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        component.set('v.showSpinner', false);
        helper.showToast("Success", successMsg);
    },
    
    handleLeadSourceChange: function(component, event) {
        var leadSource = event.getParam("value");
        if(leadSource === 'Inbound'){
            component.set('v.showInboundLead', true);
        } else{
            component.set('v.showInboundLead', false);
        }
        if(leadSource === 'Outbound'){
            component.set('v.showOutboundLead', true);
        } else{
            component.set('v.showOutboundLead', false);
        }
    },
    
    handleReset: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Opportunity"
        });
        homeEvent.fire();
        $A.get('e.force:refreshView').fire();
        component.set('v.showSpinner', false);
    },
    
    handleError: function(component, event, helper) {
        component.set('v.showSpinner', false);
        var errorMessage = event.getParam("message");
        helper.showToast("Error", errorMessage);
    },   
    
    handleCreateLoad: function (cmp, event, helper) {
        var nameFieldValue = cmp.find("stageField").set("v.value", "Preparation");
        var nameFieldValue = cmp.find("accId").set("v.value", cmp.get('v.accountId'));
    },
    
    doInit: function (component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        console.log('sURLVariables: ',sURLVariables);
        console.log('component.get("v.sObjectName"): ',component.get("v.sObjectName"));
        console.log('test: ', window.location.search.substring(1));
        console.log('recId: ',component.get("v.recordId"));
        //Get Parent Id from URL start 
        //
        //
        var pageReference = component.get("v.pageReference");
        console.log('###RecordId : '+pageReference.state.recordTypeId);
        var getAccId = pageReference.state.additionalParams;
        if(typeof getAccId !== 'undefined') {
            console.log('###GetAccID : '+getAccId);
            getAccId = getAccId.replace('accid=','');
            getAccId = getAccId.substring(0,15);
            console.log('###AccId : '+getAccId);
            component.set("v.accId", getAccId);
        }
        //
        //
        //Get Parent ID from URL end
        //
        //
        //Get Parent ID from URL in Salesforce1 App Start
        //
        //
        //
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        console.log('###Value='+value);
        var context = JSON.parse(window.atob(value));
        console.log('###context='+context);
        var newContext = JSON.stringify(context);
        console.log('###newContext : '+newContext);
        var attrVar = JSON.parse(newContext);
        console.log('###attrVar : '+JSON.stringify(attrVar));
        var accId = attrVar.attributes.recordId;
        console.log('accId : ',accId);
        component.set('v.accountId',accId);
    },
})
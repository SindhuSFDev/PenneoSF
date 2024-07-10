({
	doInit : function(component, event, helper){
        helper.doInit(component, event, helper);
    },

    saveAsPDF : function(component, event, helper){
        helper.saveAsPDFHelper(component,event,helper);
    },

    cancel : function(component, event, helper){
        /*Close the Action*/
        $A.get("e.force:closeQuickAction").fire();
    },
})
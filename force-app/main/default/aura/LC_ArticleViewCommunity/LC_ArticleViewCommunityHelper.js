({
	doInitHelper : function(component, event, helper) {
		component.find("service").callApex(component, helper,
			"c.getArticleDetails",
			{
				'recordId': component.get("v.articleName"),
				'Lang': component.get("v.language")
			}, this.doInitHelperSuccess);
	},
    
    doInitHelperSuccess: function(component, returnValue, helper) {
        component.set('v.articles', returnValue);
		console.log('Return value - ',returnValue);
		if((component.get('v.articleName') == 'How-to-activate-find-and-create-API-keys' || component.get('v.articleName') == 'How-to-use-Penneo-through-API' 
			|| component.get('v.articleName') == 'Documentation-for-developers') && returnValue.length > 0){
            component.set("v.showComponent", true);
        }
		console.log('returnValue: ', returnValue);
    }
})
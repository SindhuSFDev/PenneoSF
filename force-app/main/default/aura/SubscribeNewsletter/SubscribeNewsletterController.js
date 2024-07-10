({
	doInit : function(component, event, helper) {
        if(component.get('v.language') == 'en_US'){
             component.set('v.showEngNewsletter',true);
        }
	}
})
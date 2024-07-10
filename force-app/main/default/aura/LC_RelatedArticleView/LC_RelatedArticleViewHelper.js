/**
 * Created by CloudRoute on 13-12-2021.
 */
({

    doInitHelper : function(component, event, helper) {
        		component.find("service").callApex(component, helper,
        			"c.getRelatedArticle",
        			{
        				'recordId': component.get("v.articleName"),
        				'Lang': component.get("v.language")
        			}, this.doInitHelperSuccess);
        	},

            doInitHelperSuccess: function(component, returnValue, helper) {
                console.log('returnValue: ', JSON.stringify(returnValue));
                component.set('v.relatedArticle', returnValue);

            },

             TitleSelect : function(component,event) {
                    var url = event.currentTarget.getAttribute("data-value");
                    console.log('url' , url);
            		window.location = url + '&showAll=true';
                },
})
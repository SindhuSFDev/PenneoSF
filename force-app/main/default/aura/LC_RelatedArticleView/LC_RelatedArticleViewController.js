/**
 * Created by CloudRoute on 13-12-2021.
 */
({

    doInit : function(component, event, helper) {
                var sPageURL = window.location.href; //You get the whole decoded URL of the page.
                var url = new URL(sPageURL);
                var lang = url.searchParams.get("language");
                console.log(lang);
                    		if (lang != null) {
                    			component.set("v.language", lang);
                    		} else {
                    			component.set("v.language", 'en_US');
                    		}
                var urlDomain = window.location.href;
                        urlDomain = urlDomain.split('s/');
                        urlDomain = urlDomain[0] + 's/article/';
                        component.set("v.redirectUrl", urlDomain);
                var sURLVariables = sPageURL.split('/article/'); //Split by & so that you get the key value pairs separately in a list
                        var sParameterName = sURLVariables[1];
                        if(sParameterName.includes('?')){
                            var langArticles = sParameterName.split('?');
                            sParameterName = langArticles[0];
                        }
                component.set('v.articleName', sParameterName);
                helper.doInitHelper(component, event, helper);
            },
            TitleSelect : function(component, event, helper) {
                    helper.TitleSelect(component, event, helper);
                }
																																							

})
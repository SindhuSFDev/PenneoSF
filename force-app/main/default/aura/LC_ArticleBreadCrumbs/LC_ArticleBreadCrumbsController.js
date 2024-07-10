/**
 * Created by CloudRoute on 14-12-2021.
 */
({
    doInit: function (component, event, helper) {
            var sPageURL = window.location.href; //You get the whole decoded URL of the page.
            var urlDomain = window.location.href;
            var url = new URL(sPageURL);
    		var lang = url.searchParams.get("language");
    		console.log(lang);
    		if (lang != null) {
    			component.set("v.language", lang);
    		} else {
    			component.set("v.language", 'en_US');
    		}
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
               helper.doinithelper(component, event, helper);

        },

    navigateTo: function (cmp, event, helper) {
            var name = event.getSource().get('v.name');
            var lang = cmp.get('v.language');
//            if(name == 'Penneo_KYC' || name == 'Penneo_Sign'){
//                window.location = window.location.origin + '/support/s';
//            }else{
//                var selectedItem = event.currentTarget;
//                var index = selectedItem.dataset.record;
//                if(index){
                    var redirectUrl = window.location.origin + '/support/s/all-articles?language='+lang+'&article='+name+'&showAll=true';
                    window.location = redirectUrl;
//                }else{
//                    window.location = name;
//                }
            //}

        },

    returnToHome: function (component, event, helper) {
    		window.location = window.location.origin + '/support/s';
    	}


})
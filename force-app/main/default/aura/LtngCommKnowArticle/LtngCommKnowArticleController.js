({
	doInit: function (component, event, helper) {
		var showStr =  '&showAll=true';
        component.set('v.showAllTrue', showStr);
		component.set("v.redirectUrl", window.location.origin + '/support/s/all-articles?article=');
		let windowWidth = window.innerWidth;
		/* if (windowWidth <= 786) {
			component.find('articles_hide').remove();
			
		} */
		var seeMore = $A.get("$Label.c.See_more_guides");
		component.set("v.seeMoreGuides", seeMore);

		var url_string = window.location.href;
		var url = new URL(url_string);
		var lang = url.searchParams.get("language");
		console.log(lang);
		if (lang != null) {
			component.set("v.language", lang);
		} else {
			component.set("v.language", 'en_US');
		}
		var showAll = url.searchParams.get("showAll");
		if (showAll != null) {
			component.set("v.showAll", showAll);
		}
		helper.helperInit(component, event, helper);
	},

	navigateToNew: function (component, event, helper) {
		var url = event.currentTarget.getAttribute("data-value");
        if(component.get('v.language') != 'en_US'){
           window.location = url + '&language='+ component.get('v.language') + '&showAll=true'; 	
        }else{
           window.location = url + '&showAll=true';
        }
		//window.location = url + '&showAll=true';
	}
})
({
	doInit: function (component, event, helper) {
		var label = $A.get("$Label.c.Back_to_home_button_label");
		component.set("v.buttonLabel", label);
		component.set("v.redirectUrl", window.location.origin + '/support/s/all-articles?article=');
		var url_string = window.location.href;
		var url = new URL(url_string);
		var lang = url.searchParams.get("language");
		console.log(lang);
		if (lang != null) {
			component.set("v.language", lang);
		} else {
			component.set("v.language", 'en_US');
		}
		var article = url.searchParams.get("article");
		component.set("v.topicID", article);
		var showAll = url.searchParams.get("showAll");
        console.log('ShowALL - '+showAll);
		if (showAll != null) {
			component.set("v.showAll", showAll);
		}
		helper.helperInit(component, event, helper);
	},

	navigateToNew: function (component, event, helper) {
        debugger;
		var url = event.currentTarget.getAttribute("data-value");
		window.location = url + '&showAll=true';
	},

	returnToHome: function (component, event, helper) {
		window.location = window.location.origin + '/support/s';
	}
})
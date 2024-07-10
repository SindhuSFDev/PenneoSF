({
	doInit: function (component, event, helper) {
		helper.helperInit(component, event, helper);
	},

	returnToHome: function (component, event, helper) {
		window.location = window.location.origin + '/support/s';
	}
})
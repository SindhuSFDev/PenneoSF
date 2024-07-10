({
	helperInit: function (component, event, helper) {
		var label = $A.get("$Label.c.Back_to_home_button_label");
		component.set("v.buttonLabel", label);
	}
})
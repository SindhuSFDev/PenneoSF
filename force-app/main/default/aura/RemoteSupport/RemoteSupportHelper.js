({
	helperInit: function (component, event, helper) {
		var label = $A.get("$Label.c.Back_to_home_button_label");
		component.set("v.buttonLabel", label);
		var body = $A.get("$Label.c.Remote_Support1") + $A.get("$Label.c.Remote_Support2") + $A.get("$Label.c.Remote_Support3");
		component.set("v.body", body);
	}
})
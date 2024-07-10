({
	helperInit: function (component, event, helper) {
		console.log('language' , component.get("v.language"));
		component.find("service").callApex(component, helper,
			"c.displayArticlesCategoryWise",
			{
				'categoryName': component.get("v.topicID"),
				'language': component.get("v.language")
			}, this.helperInitSuccess);
	},

	helperInitSuccess: function (component, returnValue, helper) {
		try {
			component.set("v.listOfKnowArticles", JSON.parse(returnValue));
			component.set("v.showSpinner", false);
		} catch (err) {
			console.log(err);
		}
	},
})
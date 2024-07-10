({
	helperInit: function (component, event, helper) {
		component.find("service").callApex(component, helper,
			"c.displayArticlesCategoryWise",
			{
				'categoryName': component.get("v.topicID"),
				'language': component.get("v.language")
			}, this.helperInitSuccess);
	},

	helperInitSuccess: function (component, returnValue, helper) {
		try {
			var articles = JSON.parse(returnValue);
			component.set("v.listOfKnowArticles", articles);
			component.set("v.showSpinner", false);
            console.log('Knowledge artciles all - ',component.get('v.listOfKnowArticles'));
            
            if(component.get('v.language') != 'en_US'){
                var getArticles = component.get('v.listOfKnowArticles');
            	getArticles[0].innerClass[0].knowledgeArticles.forEach(art=>{
                    art.UrlName = art.UrlName + '?language='+component.get('v.language');
                    console.log('Article Name - '+art.UrlName);
            	})
                component.set("v.listOfKnowArticles", getArticles);
            }
		} catch (err) {
			console.log(err);
		}
	},
})
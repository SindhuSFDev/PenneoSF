({
    doInit : function(component, event, helper) {
        var urlDomain = window.location.href;
        var url = new URL(urlDomain);
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
        console.log('Url -- '+urlDomain);
        var articles = component.get('v.articles');
        console.log('Artciles - ',articles);
    },
    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        var action = component.get("c.FindByTitle");
        action.setParams({
            "searchKey": searchKey,
            "language":component.get('v.language')
        });
        action.setCallback(this, function(a) {
            component.set("v.articles", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },  
    
    TitleSelect : function(component, event, helper) {
        helper.TitleSelect(component, event, helper);
    },
    
    showSearchArticlePage : function(component, event, helper) {
        if(event.which == 13){
            var searchKey = component.find("searchKey").get("v.value");
            var urlDomain = window.location.href;
            urlDomain = urlDomain.split('s/');
            urlDomain = urlDomain[0] + 's/global-search/' + searchKey;
            window.open(urlDomain);
        }
    },
})
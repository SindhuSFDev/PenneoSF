({
    doInit : function(component, event, helper) {
        var sPageURL = window.location.href; //You get the whole decoded URL of the page.
        var url = new URL(sPageURL);
        var lang = url.searchParams.get("language");
        if (lang != null) {
            component.set("v.language", lang);
        } else {
            component.set("v.language", 'en_US');
        }
        var sURLVariables = sPageURL.split('/article/'); //Split by & so that you get the key value pairs separately in a list
        
        var sParameterName = sURLVariables[1];
        
        if(sParameterName.includes('?')){
            var langArticles = sParameterName.split('?');
            sParameterName = langArticles[0];
            /*
            if(langArticles[1].includes('#')){
                var newsletterAnchor = langArticles[1].split('#');
                //var scrollToTag = '#'+newsletterAnchor[1];
                
                console.log('document by id - ',document);
                const els = document.getElementsByName("newsletter-v1");
                els.scrollIntoView();
            }
            */
        }
        component.set('v.articleName', sParameterName);
        helper.doInitHelper(component, event, helper);
    }
})
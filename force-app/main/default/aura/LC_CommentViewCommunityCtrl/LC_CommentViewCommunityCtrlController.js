({
    doInit : function(component, event, helper) {
        var sPageURL = window.location.href; //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('/article/'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName = sURLVariables[1];
        if(sParameterName.includes('?')){
            var langArticles = sParameterName.split('?');
            sParameterName = langArticles[0];
        }
        component.set('v.articleName', sParameterName);
        helper.doInitHelper(component, event, helper);
    },
    
    handleSaveComment : function (component, event, helper) {
        
        helper.handleSaveCommentHelper(component, event, helper);
    }
})
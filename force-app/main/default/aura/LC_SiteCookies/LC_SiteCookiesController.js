({
    doInit: function(component, event, helper) {
        component.set('v.showCookie', true);
        let cookie_consent = helper.getCookie(component, event, helper, "user_cookie_consent");
        if(cookie_consent != ""){
            var cmpTarget = component.find('cookieNotice');
            $A.util.addClass(cmpTarget, 'hideBox');
            $A.util.removeClass(cmpTarget, 'showBox');
            component.set('v.showCookie', false);
            // document.getElementById("cookieNotice").style.display = "none";
        }else{
            var cmpTarget = component.find('cookieNotice');
            $A.util.addClass(cmpTarget, 'showBox');
            $A.util.removeClass(cmpTarget, 'hideBox');
            //  document.getElementById("cookieNotice").style.display = "block";
        }
    },
    
    hideCookieSection: function (component, event, helper) {
        component.set('v.showCookie', false);
    },
    
    // Set cookie consent
    acceptCookieConsent: function(component, event, helper) {
        helper.deleteCookie(component, event, helper, 'user_cookie_consent');
        helper.setCookie(component, event, helper, 'user_cookie_consent', 1, 30);
        var cmpTarget = component.find('cookieNotice');
        $A.util.addClass(cmpTarget, 'hideBox');
        $A.util.removeClass(cmpTarget, 'showBox');
        component.set('v.showCookie', false);
        //document.getElementById("cookieNotice").style.display = "none";
    },
})
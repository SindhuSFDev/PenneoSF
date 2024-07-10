({
	afterRender: function(component, helper) {
        this.superAfterRender();

        const sitekey = component.get('v.reCaptchaSiteKey');
        const hostURL = component.get('v.approvedHost');

        const iframe = component.find('vfFrame').getElement()
        const vfWindow = iframe.contentWindow;
        iframe.onload = function() {
            vfWindow.postMessage({type: 'CAPTCHA-SITEKEY', key: sitekey, hostURL}, hostURL);
        }
    }
})
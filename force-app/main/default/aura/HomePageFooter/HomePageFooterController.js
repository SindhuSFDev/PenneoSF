({
    doInit: function(component, event, helper) {
        var urlImg = $A.get('$Resource.HomePageFooterBAckgroundIMG');//FooterBackgroundCommunity_2 //	FooterBackgroundCommunity_1
        component.set('v.backgroundImageURL', urlImg);
        var urlImg1 = $A.get('$Resource.FooterBackgroundCommunity_1');
        component.set('v.backgroundImageURL_1', urlImg1);
        var urlImg2 = $A.get('$Resource.FooterBackgroundCommunity_2');
        component.set('v.backgroundImageURL_2', urlImg2);
        var url_string = window.location.href;
        var url = new URL(url_string);
        var lang = url.searchParams.get("language");
        console.log(lang);
        if (lang != null) {
            component.set("v.language", lang);
        } else {
            component.set("v.language", 'en_US');
        }
        component.set("v.redirectUrl", window.location.origin + '/support/s/all-articles?article=');
        
        component.set('v.getStartedSetting', 'https://penneo.force.com/support/s/all-articles?article=Getting_Started_Settings&showAll=true');
        component.set('v.sendCaseFiles', 'https://penneo.force.com/support/s/all-articles?article=Send_out_Case_Files&showAll=true');
        component.set('v.manageFiles', 'https://penneo.force.com/support/s/all-articles?article=Manage_Case_Files&showAll=true');
        component.set('v.signing', 'https://penneo.force.com/support/s/all-articles?article=Signing&showAll=true');
        component.set('v.formaValidation', 'https://penneo.force.com/support/s/all-articles?article=Forms_Identity_Validation&showAll=true');
        component.set('v.applicationIntegration', 'https://penneo.force.com/support/s/all-articles?article=Applications_Integrations_and_API&showAll=true');
        component.set('v.getStart', 'https://penneo.force.com/support/s/all-articles?article=Getting_Started&showAll=true');
        component.set('v.clients', 'https://penneo.force.com/support/s/all-articles?article=Clients&showAll=true');
        component.set('v.docCollection', 'https://penneo.force.com/support/s/all-articles?article=Document_Collection&showAll=true');
        component.set('v.riskAssesment', 'https://penneo.force.com/support/s/all-articles?article=Risk_Assessment&showAll=true');
        component.set('v.securityData', 'https://penneo.force.com/support/s/all-articles?article=Security_data_retention&showAll=true');
        component.set('v.integration', 'https://penneo.force.com/support/s/all-articles?article=Integrations&showAll=true');
        component.set('v.troubleshooting', 'https://penneo.force.com/support/s/all-articles?article=Troubleshooting&showAll=true');
        component.set('v.glossary', 'https://penneo.force.com/support/s/all-articles?article=Glossary&showAll=true');
        component.set('v.securityFrame', 'https://penneo.force.com/support/s/all-articles?article=Security_Framework&showAll=true');
        
        helper.helperInit(component, event, helper);
    },
    
    navigateToNew: function (component, event, helper) {
        var url = event.currentTarget.getAttribute("data-value");
        window.location = url;
    }
})
({
    helperInit: function (component, event, helper) {
        component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'Role__c' }, this.getRoleSuccess);
        component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'Type' }, this.getTypeSuccess);
        /* component.find("service").callApex(component, helper,
            "c.getPicklistValues",
            { "fieldName": 'Priority' }, this.getPrioritySuccess); */
        component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'Country__c' }, this.getCountrySuccess);
        component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'SubmittedCountry__c' }, this.getSubmittedCountryValuesSuccess);
        component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'SubmittedSolution__c' }, this.getSolutionValuesSuccess);
       /* component.find("service").callApex(component, helper,
                                           "c.getPicklistValues",
                                           { "fieldName": 'Languages_Supported__c' }, this.getLanguagesValuesSuccess); */      
    },
    
    getRoleSuccess: function (component, returnValue, helper) {
        component.set("v.roleList", returnValue)
    },
    
    getSubmittedCountryValuesSuccess: function (component, returnValue, helper) {
        component.set("v.submittedCountryList", returnValue)
    },
    
    getSolutionValuesSuccess: function (component, returnValue, helper) {
        component.set("v.solutionList", returnValue)
    },
    
    getTypeSuccess: function (component, returnValue, helper) {
        component.set("v.typeList", returnValue);
    },
    
    getPrioritySuccess: function (component, returnValue, helper) {
        component.set("v.priorityList", returnValue)
    },
    
    getCountrySuccess: function (component, returnValue, helper) {
        component.set("v.countryList", returnValue)
    },
    getLanguagesValuesSuccess : function (component, returnValue, helper) {
        component.set("v.langList", returnValue);
        
        let preSelectedValues = [];
        
        for (let x in returnValue) {
            if(returnValue[x].value == 'English'){
                preSelectedValues.push(returnValue[x].value);	
            }
        }
        console.log('preSelectedValues - ',preSelectedValues);
        component.set('v.langVals',preSelectedValues);
        //component.set('v.langSelected',preSelectedValues);
    },
    
    showToast: function (component, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": type,
            "message": message,
            "type": type,
            
        });
        toastEvent.fire();
    },
    
    saveCaseHelper: function (component, event, helper) {
        var randomStringTemp = component.get("v.randomString");
        console.log('Language selected - ',component.find('SelectLang').get('v.value'));
        var langSelected = component.get('v.defaultLanguage') == 'en_US'? 'English' : component.get('v.defaultLanguage') == 'da' ? 'Danish' : component.get('v.defaultLanguage');
        component.set('v.caseObj.Case_Language__c',langSelected);
        //console.log('Case Language - ',component.get('v.caseObj'));
        if (helper.validateContactForm(component)) {
            console.log('Validated');
            var caseObj = component.get("v.caseObj");
            if(caseObj.Subject != null && typeof caseObj.Subject != 'undefined' && caseObj.Subject != ''){
                component.find("service").callApex(component, helper,
                                                   "c.addContAndAccToCommunityCase",
                                                   { "currentCase": caseObj, "randomString": randomStringTemp, "fileIds": component.get('v.fileIds') }, this.getCaseInsertSuccess);
            }else{
                /*var allValid = component.find('caseField2').reduce(
                    function(validSoFar, inputCmp) 
                    {
                        inputCmp.showHelpMessageIfInvalid();
                        return validSoFar && inputCmp.get('v.validity').valid;
                    }, true);*/
                helper.showToast(component, helper, 'Error', 'Please select subject.');
                component.set('v.showSpinner', false);
            }
        }
        else{
            component.set('v.showSpinner', false);
        }
    },
    
    getCaseInsertSuccess: function (component, returnValue, helper) {
        if (returnValue == 'Success') {
            helper.showToast(component, helper, returnValue, 'Case created');
            helper.generateRandomStringTemp(component, helper, returnValue);
        } else {
            helper.showToast(component, helper, 'Error', 'Some error occured. Please try again.');
        }
        component.set('v.showSpinner', false);
        helper.resetForm(component, helper);
        helper.getPrefillValues(component, helper);
    },
    
    validateContactForm: function (component) {
        var validContact = true;
        // Show error messages if required fields are blank
        var allValid = component.find('caseField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid){
            return allValid;
        }
        else {
            validContact = false;
        }
        return (validContact);
    },
    
    resetForm: function (component, helper) {
        component.find('caseField').forEach(function (f) {
            f.set("v.value", "");
        });
        component.find('caseField2').set("v.value", "");
        component.set("v.showSuggestedArticles", false);
        component.set("v.showSuggestions", false);
        component.set("v.showFileNames", false);
        component.set("v.showDocKey", false);
        component.set("v.fileNames", []);
        component.set("v.fileIds", []);
        component.find('enter-search').set("v.value", "");
        component.set('v.articlesList', []);
    },
    
    generateRandomStringTemp: function (component, event, helper) {
        component.find("service").callApex(component, helper,
                                           "c.generateRandomString", null, this.generateRandomStringSuccess);
    },
    
    generateRandomStringSuccess: function (component, returnValue, helper) {
        console.log('#--returnValue--#', returnValue);
        component.set("v.randomString", returnValue)
    },
    
    getPrefillValues: function (component, helper) {
        component.find("service").callApex(
            component,
            helper,
            "c.getPrefillValues",
            null,
            this.getPrefillValuesSuccess);
    },
    
    getPrefillValuesSuccess: function (component, returnValue, helper) {
        console.log('#--returnValue--#', returnValue);
        if (returnValue != null) {
            component.set("v.disableForInternal", true);
            var caseValues = JSON.parse(returnValue);
            var caseObj = component.get("v.caseObj");
            caseObj.First_Name__c = caseValues.FirstName;
            caseObj.Last_Name__c = caseValues.LastName;
            caseObj.Role__c = caseValues.Role__c;
            caseObj.SuppliedCompany = caseValues.Account.Website;
            caseObj.SuppliedEmail = caseValues.Email;
            component.set("v.caseObj", caseObj);
        }
    },
    
    getSuggestedArticles: function (component, event, helper) {
        component.find("service").callApex(
            component,
            helper,
            "c.getSuggestedArticles",
            {
                "keySearch": component.get("v.keySearch"),
                "language": component.get("v.language")
            },
            this.getSuggestedArticlesSuccess);
    },
    
    getSuggestedArticlesSuccess: function (component, returnValue, helper) {
        var listOfKnowArticles = JSON.parse(returnValue);
        if (listOfKnowArticles.length > 0) {
            component.set("v.showSuggestedArticles", true);
            component.set("v.listOfKnowArticles", listOfKnowArticles);
        } else {
            component.set("v.showSuggestedArticles", false);
        }
    },
    doRecaptchaVerification: function(component, event, helper, token) {
        const action = component.get('c.verifyResponse');
        
        action.setParams({response: token});
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            
            if (state === 'SUCCESS') {
                const valid = response.getReturnValue();
                if (!valid) {
                    component.set('v.formMessage', 'Sorry, we could not verify you.');
                } else if (valid) {
                    component.set('v.formMessage', '');
                    
                    // reCaptcha validated! Here is where we'll submit the form.
                }
            } else {
                const errors = response.getError();
                component.set('v.formMessage', 'Sorry, an error occured.');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showArticlesHelper: function(component, event, helper) {
        component.find("service").callApex(
            component,
            helper,
            "c.getSuggestedArticlesSubject",
            {
                "keySearch": component.get("v.subjectSuggestion"),
                "language": component.get("v.language"),
                "offsetCount":component.get('v.offsetNumber')
            },
            this.showArticlesHelperSuccess);
    },
    
    showArticlesHelperSuccess: function (component, returnValue, helper) {
        var empOptions = [];
        for(var e of returnValue){
            var opt = {'label': e.label, 'value': e.value};
            empOptions.push(opt);
        }
        component.set('v.articlesList', empOptions);
        component.set('v.showSuggestions', true);
    },
    
    deleteFiles: function (component, returnValue, helper, quoteLineItemsListToBeDeleted) {
        component.find("service").callApex(component, helper, "c.deleteContentDocuments",
                                           {
                                               "fileIds": quoteLineItemsListToBeDeleted
                                           },
                                           this.deleteFilesSuccess);
    },
    
    deleteFilesSuccess: function (component, returnValue, helper) {
        console.log('result-> ', returnValue);
    },
    
    onLangChangeHelper : function (component, event, helper){
        var getLangMap = new Map();
        getLangMap = component.get('v.langMap');
        var langObj = getLangMap[component.find('SelectLang').get('v.value')];
        component.set('v.langSelected',langObj);
        
        
        try{
            var allValid = component.find('caseField').reduce(function (validFields, inputCmp) {
                var checkVal;
                if(inputCmp.get('v.value') == ''){
                    checkVal = true;
                }
                else{
                    checkVal = false;
                }
                return validFields && checkVal;
            }, true);
            allValid = component.find('caseField2').get('v.value') == '' && allValid;
            if (!allValid){
                var comps = component.find('caseField');
                comps.forEach(cmp =>{
                    cmp.reportValidity();
                }) 
                    component.find('caseField2').reportValidity();    
            } 
                    
        }catch(e){
            console.log('Exc: ',e);
        }
    },

    /*
    handleSelectedLanguagesHelper : function (component, event, helper) {
        var PicklistValue = event.getParam('value');
        var text = '';
        if (PicklistValue.length > 0) {
            for (var i = 0; i < PicklistValue.length; i++) {
                if (i == 0) {
                    text = PicklistValue[i];
                }
                else {
                    text = text + ';' + PicklistValue[i];
                }
            }
        }
        component.get('v.caseObj').Languages_Supported__c = text;
        console.log('Case Obj - ',component.get('v.caseObj'));
        //ObjectAtrribute.picklistfieldApiName = text;
        component.set("v.caseObj", component.get('v.caseObj')); 
    },
    */
})
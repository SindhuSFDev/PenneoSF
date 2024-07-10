({
    doInit: function (component, event, helper) {
        //recaptcha
        console.log('Init called');
        const vfOrigin = 'https://penneo.my.site.com';
        //component.set("v.isDisable",false);
        
        /*
     *  Registering an event to listen for messages from the VisualForce recaptcha page.
     *  This event will tell us if the recaptcha has been completed or not.
     */
        window.addEventListener("message", function(event) {
            console.log('#----#',JSON.stringify(event.origin));
            console.log('#----#',JSON.stringify(event.data));
            if (event.origin !== vfOrigin) {
                console.log('1');
                return;
            } else if (event.data =='Unlock') {
                console.log('#----#')
                //const token = event.data.response;
                component.set("v.isDisable",false);
            } else if (event.data.captchaVisible) {
                console.log('3');
                let captchEl = document.getElementById('vfFrame');
                console.log('#---event.data.captchaVisible-#',event.data.captchaVisible);
                if(event.data.captchaVisible === 'visible'){
                    captchEl.height = 500;
                } else {
                    captchEl.height = 100;
                }
            } else{
                console.log('4');
                component.set("v.isDisable",true);
            }
        }, false);
        //Recaptcha End
        var url_string = window.location.href;
        var url = new URL(url_string);
        console.log('url : ', url);
        var lang = url.searchParams.get("language");
        console.log('Language - ',lang);
        if (lang != null) {
            component.set("v.language", lang);
            component.set('v.defaultLanguage',lang);
        } else {
            component.set("v.language", 'en_US');
            component.set('v.defaultLanguage','en_US');
        }
        
        
        var getLangMap = component.get('v.langMap');
        var langObj = getLangMap[component.get('v.defaultLanguage')];
        component.set('v.langSelected',langObj);
	    console.log('window Object - ',window.location.origin);
        component.set("v.redirectUrl", window.location.origin + '/support/s/article/');
        helper.helperInit(component, event, helper);
        helper.generateRandomStringTemp(component, event, helper);
        helper.getPrefillValues(component, event, helper);

    },
    
    saveCase: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        helper.saveCaseHelper(cmp, event, helper);
    },
    
    handleUploadFinished: function (cmp, event) {
        /*// Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        // Get the file id
        var documentId = uploadedFiles[0].documentId;*/
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        console.log("Files uploaded : ", JSON.stringify(uploadedFiles));
        /*if(uploadedFiles.length > 0){
             var alldocIds = component.get("v.uploadedDocuments");
             var oldIds = component.get("v.uploadedDocumentIds");
            uploadedFiles.forEach(function(element) {
                console.log("Name : " + element.name);
                console.log("Document Id : " + element.documentId);
                oldIds.push(element.documentId);
                var fileVar = {
                                'documentId': element.documentId,
                                'name': element.name
                            };
                alldocIds.push(fileVar);
            });
            console.log('#--alldocIds---#',alldocIds);
            console.log('#--oldIds---#',oldIds); 
            console.log('#--alldocIds.length---#',alldocIds.length);
            component.set('v.uploadedDocuments',alldocIds);
            component.set('v.uploadedDocumentIds',oldIds);
            component.set('v.totalFiles',alldocIds.length);
        } */
        cmp.set('v.showFileNames', true);
        var fNames = cmp.get('v.fileNames');
        var fileIds = cmp.get('v.fileIds');
        for(var f of uploadedFiles){
            fNames.push(f.name);
            fileIds.push(f.contentVersionId);
        }
        cmp.set('v.fileNames', fNames);
        cmp.set('v.fileIds', fileIds);
    },
    
    handleSearchKeyUp: function (component, event, helper) {
        var search = component.find('enter-search').get('v.value');
        component.set("v.keySearch", search);
        helper.getSuggestedArticles(component, event, helper);
    },
    
    navigateToNew: function (component, event, helper) {
        var url = event.currentTarget.getAttribute("data-value");
        window.open(url) ;
    },
    afterScriptsLoaded: function (component, event, helper) {
        console.log('#--Script Loaded-#');
    },
    
    showArticles: function(component, event, helper){
        var inputval = component.find('caseField2').get('v.value');
        console.log('value: ', inputval);
        component.set('v.subjectSuggestion', inputval);
        helper.showArticlesHelper(component, event, helper);
    },
    
    handleChangeArticle: function(component, event, helper){
        var currval = event.currentTarget.dataset.value;
        var currLabel = event.currentTarget.innerHTML;
        component.set('v.caseObj.Subject', currLabel);
        var redirecturl = window.location.origin + '/support/s/article/' + currval;
        window.open(redirecturl, '_blank');
        component.set('v.showSuggestions', false);
    },
    
    showDocKey: function(component, event, helper){
        var prod = event.getParam('value');
        if(prod == 'Penneo Sign'){
            component.set('v.showDocKey', true);
        } else{
            component.set('v.showDocKey', false);
        }
    },
    
    removeRow: function(component, event, helper) {
        var quoteLineItemsList = component.get("v.fileNames");
        var quoteLineItemsList2 = component.get("v.fileIds");
        var quoteLineItemsListToBeDeleted = [];
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var quoteLineItemRecord = quoteLineItemsList2[index];
        quoteLineItemsListToBeDeleted.push(quoteLineItemRecord);
        quoteLineItemsList.splice(index, 1);
        quoteLineItemsList2.splice(index, 1);
        component.set('v.fileNames', quoteLineItemsList);
        component.set('v.fileIds', quoteLineItemsList2);
        helper.deleteFiles(component, event, helper, quoteLineItemsListToBeDeleted);
    },
    
    disableautocomplete: function(component, event, helper) {
        component.find('enter-search').set('v.autocomplete','off');
    },
    
    showMoreSuggestions: function(component, event, helper) {
        var offset = component.get('v.offsetNumber');
        offset++;
        component.set('v.offsetNumber',offset);
        helper.showArticlesHelper(component, event, helper);
    },
    
    showHelpTextJS: function(component, event, helper) {
        component.set('v.showHelpText', true);
    },
    
    /*
    handleSelectedLanguages : function(component, event, helper){
        helper.handleSelectedLanguagesHelper(component, event, helper);
    },
    */

    onLangChange : function(component, event, helper){
        helper.onLangChangeHelper(component, event, helper);
    },
})
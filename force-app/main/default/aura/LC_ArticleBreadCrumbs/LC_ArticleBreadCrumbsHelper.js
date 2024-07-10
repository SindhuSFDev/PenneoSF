/**
 * Created by CloudRoute on 14-12-2021.
 */
({
    doinithelper : function (component, event, helper){
        component.find("service").callApex(component, helper,
        "c.getRecordpath",
        {
            'recordId': component.get("v.articleName"),
            'Language': component.get("v.language")
        },this.doInitHelperSuccess);
    },

    doInitHelperSuccess: function(component, returnValue, helper){
//        component.set('v.breadcrumbCollection',retunValue);
        console.log('returnValue :',returnValue);
        var wrapperList = [];
        if(returnValue.isSuccess){
            if(returnValue.articlesList != null && returnValue.articlesList.length > 0){
                for(var art of returnValue.articlesList){
                    var wrap = {'label': art.articleLabel, 'name': art.articleName, 'isParent': art.isParent};
                    wrapperList.push(wrap);
                }
            }
        }
        component.set('v.articlesList', wrapperList);
    }
})
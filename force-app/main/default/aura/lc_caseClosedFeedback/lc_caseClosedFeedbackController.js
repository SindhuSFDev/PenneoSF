/**
 * Created by ayushi.d@cloudroute.in on 26-10-2020.
 */
({
    doInit : function(component, event, helper){
      helper.getCaseId(component, event, helper);
      component.set('v.spinner', true);
    },

    saveGoodResponse : function(component, event, helper){
        component.set('v.responseClicked', 'Good');
        var btn = component.find('goodBtn');
        $A.util.addClass(btn, 'btnClsFilter');
    },

    saveBadResponse : function(component, event, helper){
        component.set('v.responseClicked', 'Bad');
        var btn = component.find('badBtn');
        $A.util.addClass(btn, 'btnClsFilter');
    },

    saveResponse : function(component, event, helper){
        component.set('v.spinner', true);
        helper.saveResponseOnCase(component, event, helper);
    },
})
({
    TitleSelect : function(component,event) {
        var url = event.currentTarget.getAttribute("data-value");
        console.log('url' , url);
        window.location = url + '&showAll=true';
    },
})
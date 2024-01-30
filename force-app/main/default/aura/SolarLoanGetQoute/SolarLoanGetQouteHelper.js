({
	showSection: function (component, event) {
       
    },
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})
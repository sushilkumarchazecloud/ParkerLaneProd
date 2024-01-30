({
	// Your renderer method overrides go here
    afterRender: function (cmp, helper) {
        this.superAfterRender();
        helper.callDom(cmp);
    },
    rerender : function(component, helper){
        this.superRerender();
        console.log('XXXXX rerender - title');
        helper.callDom(component);
    },
    unrender: function () { 
        this.superUnrender();
        console.log('XXXXX unrender');
    }
})
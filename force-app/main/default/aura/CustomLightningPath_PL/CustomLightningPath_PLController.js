({
    doInit : function(component, event, helper) {
        window.addEventListener('resize', $A.getCallback(function() {
            if(component.isValid()) {
                var ele = document.getElementById("path__scroller_inner");
                //ele.style.marginLeft = 0;
            }
        }));
    },
    
    
    
	moveLeft : function(component, event, helper) {
        var ele = document.getElementById("path__scroller_inner");
        var currentLeft = ele.style.marginLeft;
        currentLeft = parseInt(currentLeft) + 20;
        ele.style.marginLeft = currentLeft +'px';
        ele.style.marginRight = (-(currentLeft)) +'px';
        ele.style.width = 'calc( 100% - ' +  (currentLeft +70)  + 'px)';
	},
	moveRight : function(component, event, helper) {
        var ele = document.getElementById("path__scroller_inner");
        var currentLeft = ele.style.marginLeft;
        currentLeft = parseInt(currentLeft) - 20;
        ele.style.marginLeft = currentLeft +'px';
        ele.style.marginRight = (-(currentLeft)) +'px';
        ele.style.width = 'calc( 100% - ' + (currentLeft +70) + 'px)';
	}
})
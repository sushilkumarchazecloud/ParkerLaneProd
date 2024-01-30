({
	getValue : function(component, event, helper) {

        var slider = component.get("v.sliderValue"); 
        var price = 0;
        if(slider<=20){
            price = slider * 20/4;
        } else if(slider<=40){
            price = 100 + (((slider/4) - 5)* 30);
        } else if(slider<=60){
            price = 250 + (((slider/4) - 10)* 50);
        } else if(slider<=80){
            price = 500 + (((slider/4) - 15)* 100);
        }else if(slider<=100){
            price = 1000 + (((slider/4) - 20)* 300);
        }
		component.set("v.val", price);
	},
    
    changeInputValue : function(component, event, helper) {
		console.log('>>>>');
        var slider = component.get("v.val");  
        if($A.util.isUndefinedOrNull(slider)){
            slider = 0;
        }
        var price = 0;
        if(slider<=100){
            price = slider * 4/20;
        } else if(slider<=250){
            price = (((slider-100)/ 30)+5)*4;
        } else if(slider<=500){
            price = (((slider-250)/ 50)+10)*4;
        } else if(slider<=1000){
            price = (((slider-500)/ 100)+15)*4;
        }else if(slider<=2500){
            price = (((slider-1000)/ 300)+20)*4;
        }else{
            price = 100;
        }
        price = price -(price % 4);
        component.set("v.sliderValue", price);
        
	},
    
    checkExpenses : function(component, event, helper){
        var allValid = true;
        var inputValue =0;
        allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            inputValue = component.get("v.val");
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        if(allValid){
            if(inputValue == 0){
                component.set("v.checkError",true);
                return !allValid;
            }
            else{
                component.set("v.checkError",false);
                return allValid;
            }
        }
        else{
            component.set("v.checkError",false);
            return allValid;
        }
		//component.set("v.showError",!allValid);
    }
    
})
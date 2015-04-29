$(document).ready(function(){
  
//Dropdown login menu
var loginbutton = $('#login-button');
var loginform = $('#login-form');
    
loginform.hide();
loginbutton.removeAttr('href');
loginbutton.css('cursor', 'pointer');

loginbutton.click(function(){
    $(this).toggleClass('active');
    loginform.toggle();
});
   
$(this).click(function(login) {
    if(!($(login.target).parent(loginbutton).length > 0)) {
        loginbutton.removeClass('active');
        loginform.hide();
    }
});

//Toggle search form from Revise Search button and "search" in menu
var searchbutton = $('#search-button');
var searchform = $('#search-form');
var revise = $('#reviseSearch');
    
revise.show();
searchform.hide();
searchbutton.removeAttr('href');
searchbutton.css('cursor', 'pointer');
    
revise.click(function() {
    searchbutton.toggleClass('active');
    searchform.toggle();
});
searchbutton.click(function(){
    $(this).toggleClass('active');
    searchform.toggle();
})


//Registration Form lightbox
var overlay = $('#overlay');
var link = $('#regLink');
var regForm = $('#regForm');
var close = $('#close-button');


link.removeAttr('href');
link.css('cursor', 'pointer');
link.click(function() {
    overlay.toggle();
});

close.click(function() {
    overlay.toggle();
});

    
});
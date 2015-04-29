$(document).ready(function(){
  
//Dropdown login menu
var loginbutton = $('#loginButton');
var box = $('#loginBox');
var loginform = $('#loginForm');
loginbutton.removeAttr('href');
loginbutton.click(function(login) {
    console.log('hi');
    $(this).toggleClass('active');
    box.toggle();
});
loginform.click(function() { 
    return false;
});
$(this).click(function(goaway) {
    if(!($(goaway.target).parent(loginbutton).length > 0)) {
        loginbutton.removeClass('active');
        box.hide();
    }
    if(!($(goaway.target).parent(searchbutton).length > 0)) {
        searchbutton.removeClass('active');
        box.hide();
    }
    if(!($(goaway.target).parent($('#register')).length > 0)) {
        $('#register').removeClass('active');
        box.hide();
    }
});

$(this).click(function(){
    console.log('good job');
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
    
link.removeAttr('href');
link.css('cursor', 'pointer');
link.click(function() {
    overlay.toggle();
});

    
});
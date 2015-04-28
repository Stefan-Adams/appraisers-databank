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
$(this).click(function(login) {
    if(!($(login.target).parent(loginbutton).length > 0)) {
        loginbutton.removeClass('active');
        box.hide();
    }
});


//Toggle search form from Revise Search button and "search" in menu
var searchbutton = $('#search-button');
var searchform = $('#search-form');
var revise = $('#reviseSearch');
    
revise.show();
searchform.hide();
button.removeAttr('href');
button.css('cursor', 'pointer');
    
revise.click(function() {
    button.toggleClass('active');
    searchform.toggle();
});
button.click(function(){
    $(this).toggleClass('active');
    searchform.toggle();
})
$(this).click(function(search) {
    if(!($(search.target).parent(searchbutton).length > 0)) {
        searchbutton.removeClass('active');
        box.hide();
    }
});


//Registration Form lightbox
var overlay = $('<div id="overlay"></div>');
var link = $('#regLink');
var regForm = $('#regForm');
    
    
$("body").append(overlay);
overlay.append(regForm);

link.removeAttr('href');
link.css('cursor', 'pointer');
link.click(function() {
    overlay.toggle();
});

    
});
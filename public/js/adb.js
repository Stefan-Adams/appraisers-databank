$(document).ready(function(){
  
//Dropdown login menu
var button = $('#loginButton');
var box = $('#loginBox');
var form = $('#loginForm');
button.removeAttr('href');
button.click(function(login) {
    box.toggle();
    console.log('hi');
    button.addClass('active');
});
form.click(function() { 
    return false;
});
$(this).click(function(login) {
    if(!($(login.target).parent('#loginButton').length > 0)) {
        button.removeClass('active');
        box.hide();
    }
});


//Toggle search form from Revise Search button and "search" in menu
var button = $('#search-button');
var form = $('#search-form');
var revise = $('#reviseSearch');
    
revise.show();
form.hide();
button.removeAttr('href');
button.css('cursor', 'pointer');
    
revise.click(function() {
    button.addClass('active');
    form.toggle();
});
button.click(function(){
    $(this).addClass('active');
    form.toggle();
})


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
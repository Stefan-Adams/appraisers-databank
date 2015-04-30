$(document).ready(function(){
var loginbutton = $('#login-button');
var loginform = $('#login-form');
var searchbutton = $('#search-button');
var searchform = $('#search-form');
var revise = $('#reviseSearch');
var overlay = $('#overlay');
var link = $('#regLink');
var regForm = $('#regForm');
var close = $('#close-button');
    
//Dropdown login menu   
loginform.hide();
loginbutton.removeAttr('href');
loginbutton.css('cursor', 'pointer');

loginbutton.click(function(){
    $(this).toggleClass('active');
    loginform.toggle();
});
    
//Closes the form if the document is clicked anywhere except the form - not currently working.
   
/*$(this).click(function(login) {
    if(!($(login.target).parent(loginbutton).length > 0)) {
        loginbutton.removeClass('active');
        loginform.hide();
    }
});*/
    
    
//Toggle search form from Revise Search button and "search" in menu    
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

//Closes the form if the document is clicked anywhere except the form - not currently working.

/*$(this).click(function(search) {
    if(!($(search.target).parent(searchbutton).length > 0)) {
        searchbutton.removeClass('active');
        box.hide();
    }
});*/

//Registration Form lightbox
link.removeAttr('href');
link.css('cursor', 'pointer');
link.click(function() {
    overlay.toggle();
});

close.click(function() {
    overlay.toggle();
});
 
    
    
});
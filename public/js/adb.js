//Dropdown login menu
$(function() {
    var button = $('#loginButton');
    var box = $('#loginBox');
    var form = $('#loginForm');
    button.removeAttr('href');
    button.mouseup(function(login) {
        box.toggle();
        button.toggleClass('active');
    });
    form.mouseup(function() { 
        return false;
    });
    $(this).mouseup(function(login) {
        if(!($(login.target).parent('#loginButton').length > 0)) {
            button.removeClass('active');
            box.hide();
        }
    });
});

//Toggle search form from Revise Search button and "search" in menu
$(function() {
    var button = $('#search-button');
    $('#reviseSearch').show();
    $('.search-form').hide();
    button.removeAttr('href');
    button.css('cursor', 'pointer');
})

$(function() {
    var button = $('#search-button');
    var form = $('#search-form');
    $('#reviseSearch').click(function() {
        button.toggleClass('active');
        form.toggle();
    });
    button.click(function(){
        $(this).toggleClass('active');
        form.toggle();
    })
});

//Registration Form lightbox
var $overlay = $('<div id="overlay"></div>');
$(function() {
    $("body").append($overlay);
    $overlay.append($('#regForm'));
});

 
$(function() {
    var link = $('#regLink');
    $('#regForm').hide();
    link.removeAttr('href');
    link.css('cursor', 'pointer');
    link.click(function() {
        $overlay.toggle();
        $('#regForm').show();
    });

});
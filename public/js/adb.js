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

//Dropdown search menu
$(function() {
    var button = $('#searchButton');
    var box = $('#searchBox');
    var form = $('#searchForm');
    button.removeAttr('href');
    button.mouseup(function(login) {
        box.toggle();
        button.toggleClass('active');
    });
    form.mouseup(function() { 
        return false;
    });
    $(this).mouseup(function(login) {
        if(!($(login.target).parent('#searchButton').length > 0)) {
            button.removeClass('active');
            box.hide();
        }
    });
});

//Toggle search menu when Revise Search button is clicked
$(function(){
    var button = $('#searchButton');
    var box = $('#searchBox');
    var form = $('#searchForm');
    $('#reviseSearch').mouseup(function(login) {
        box.toggle();
        button.toggleClass('active');
    });
    form.mouseup(function() { 
        return false;
    });
    $(this).mouseup(function(login) {
        if(!($(login.target).parent('#searchButton').length > 0)) {
            button.removeClass('active');
            box.hide();
        }
    });
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
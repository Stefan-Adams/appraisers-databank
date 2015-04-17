;(function($) {
  $(document).ready(function() {
    var referrer = $('body').attr('data-referrer');
    if (referrer && location.host.indexOf(referrer) == 0 && $('body').scrollTop() < 40) {
      $('html, body').animate({
        scrollTop: $('.content-wrapper').offset().top - 40
      }, 150);
    }
  });
})(jQuery);

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
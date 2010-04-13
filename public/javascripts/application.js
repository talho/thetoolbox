(function($) {
  $(function() {
    $(document).ready(function() {
      $('#reset_password').click(function(e){
        $('#reset_password_container').toggle();
        return false;
      });
      $('#set_fwd_address').click(function(e){
        $('#set_fwd_add_container').toggle();
        return false;
      });
      $('#set_oor').click(function(e){
        $('#set_oor_container').toggle();
        return false;
      });
      $('#create_new_user').click(function(e){
        $('#create_new_user_container').toggle();
        return false;
      });
    });
  });
})(jQuery);
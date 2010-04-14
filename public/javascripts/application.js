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
      $("#reset_password_submit").click(validate_pass_form);
      $("#create_new_user_submit").click(validate_create_user_form);
      $("#user_first_name").keyup(write_to_full_name);
      $("#user_last_name").keyup(write_to_full_name);
    });
  });
})(jQuery);

function write_to_full_name(){
  $("#user_full_name").val($("#user_first_name").val() + " " + $("#user_last_name").val());  
}

function validate_pass_form(){
  if($('#reset_pwd').val() == '' || $('#reset_pwd_confirm').val() == ''){
    alert("Please make sure that both fields are not empty.");
    return false;
  }
  if($('#reset_pwd').val() != $('#reset_pwd_confirm').val()){
    alert("Please make sure that both passwords match.");
    return false;
  }
  return true;
}

function validate_create_user_form(){
  var error_list = '';
  if($("#user_first_name").val() == ''){
    error_list += "Please enter a first name.\t\n";
  }
  if($("#user_last_name").val() == ''){
    error_list += "Please enter a last name.\t\n";
  }
  if($("#user_full_name").val() == ''){
    error_list += "Please enter a full name.\t\n";
  }
  if($("#user_logon_name").val() == ''){
    error_list += "Please enter a logon name.\t\n";
  }
  if($("#user_password").val() == ''){
    error_list += "Please enter a valid password.\t\n";
  }
  if($("#user_confirm_password").val() == '' || ($("#user_password").val() != $("#user_confirm_password").val())){
    error_list += "Please confirm password.\t\n";
  }
  if(error_list != ''){
    alert("Please correct the following items and try again.\t\n"+error_list);
    return false;
  }
  return true;
}
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
        $('#white_list_panel').hide();
        $('#create_new_user_container').dialog({height: 400,width: 500,modal: true});
        return false;
      });
      $('#add_white_list_entry').click(function(e){
        $('#create_new_user_container').hide();
        $('#white_list_panel').dialog({modal: true});
      });
      $("#reset_password_submit").click(validate_pass_form);
      $("#create_new_user_submit").click(validate_create_user_form);
      $("#user_first_name").keyup(write_to_full_name);
      $("#user_last_name").keyup(write_to_full_name);
      
      $('#wl_email_submit').click(function(e){
        var filter = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;;
        if (!filter.test($('#wl_email_email').val())) {
          alert('Please provide a valid email address');
          return false;
        }
      });
      $('#dummy_scope').change(function(e){
        $("#dummy_scope option").each(function(){
          var id = '#wl_';
          id += $(this).text().toLowerCase();
          id += '_container';
          $(id).toggle();
        });
        
      });
    });
  });
})(jQuery);

function write_to_full_name(){
  $("#user_full_name").val($("#user_first_name").val() + " " + $("#user_last_name").val());  
}

function validate_pass_form(){
  if($('#ldap_user_new_password').val() == '' || $('#ldap_user_confirm_password').val() == ''){
    alert("Please make sure that both fields are not empty.");
    return false;
  }
  if($('#ldap_user_new_password').val() != $('#ldap_user_confirm_password').val()){
    alert("Please make sure that both passwords match.");
    return false;
  }
  return true;
}

function validate_create_user_form(){
  var error_list = '';
  if($("#user_first_name").val() == ''){
    error_list += "- Please enter a first name.\t\n";
  }
  if($("#user_last_name").val() == ''){
    error_list += "- Please enter a last name.\t\n";
  }
  if($("#user_full_name").val() == ''){
    error_list += "- Please enter a full name.\t\n";
  }
  if($("#user_logon_name").val() == ''){
    error_list += "- Please enter a logon name.\t\n";
  }
  if($("#user_password").val() == ''){
    error_list += "- Please enter a valid password.\t\n";
  }
  if($("#user_confirm_password").val() == '' || ($("#user_password").val() != $("#user_confirm_password").val())){
    error_list += "- Please confirm password.\t\n";
  }
  if(error_list != ''){
    alert("Please correct the following items and try again.\t\n"+error_list);
    return false;
  }
  return true;
}
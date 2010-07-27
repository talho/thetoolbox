var cacti_call = false;

$(document).ready(function() {
  $('#reset_password').click(function(e){
    $('#reset_password_container').dialog({width: 300,modal: true});
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
    $('#create_new_user_container').dialog({modal: true});
    return false;
  });
  $('#add_white_list_entry').click(function(e){
    $('#create_new_user_container').hide();
    $('#white_list_panel').dialog({modal: true});
  });
  $('#create_new_distro').click(function(e){
    $('#create_distribution_list').dialog({modal: true});
  });
  $("#reset_password_submit").click(validate_pass_form);
  $("#create_new_user_submit").click(validate_create_user_form);
  $("#user_first_name").keyup(write_to_full_name);
  $("#user_last_name").keyup(write_to_full_name);
  $('#wl_email_submit').click(function(e){
    var filter = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (!filter.test($('#wl_email_email').val())) {
      alert('Please provide a valid email address');
      return false;
    }
  });
  $('#create_distribution_submit').click(function(e){
    var filter = /^[a-zA-Z0-9.-]/;
    if(!filter.test($("#distribution_list_name_title").val())){
      alert("Please enter a valid name for your distribution group.");
      return false;
    }
  });
  $('#wl_domain_submit').click(function(e){
    var filter = /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if(!filter.test($('#wl_domain_domain').val())){
      alert('Please provide a valid domain name in the following format:\t\n   example.com');
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
  $("#log_out").click(function(e){
    cacti_log_out();
  });
  /*
  if(window.location.href.indexOf('user_session/new') != -1){
    document.getElementById("cacti_form_login_container").setAttribute('src', "https://cacti.thetoolbox.com/cacti/logout.php")
    document.getElementById("cacti_form_login_container").src = document.getElementById("cacti_form_login_container").src
    if(document.all)
      parent.frames["cacti_form_login"].window.location.reload();
    setTimeout("window.location='/'", 3000)
  }*/

});

function begin_cacti_login()
{
  build_cacti_cred_form();
  $("#cacti_cred_container").dialog({modal:true});
}

function build_cacti_cred_form()
{
  div_container = document.createElement("div");
  div_container.setAttribute("id", "cacti_cred_container");
  div_container.setAttribute("class", "cacti_cred_container");
  p_elem1 = document.createElement("p");
  p_elem1.setAttribute("class", "cacti_desc");
  p_elem1.innerHTML ="It seems that you have not yet taken the time to fill in your Cacti Credentials."
  p_elem2 = document.createElement("p");
  p_elem2.setAttribute("class", "cacti_desc");
  p_elem2.innerHTML = "In order to get access to Cacti graphs, please fill in your credentials below."
  label_elem1 = document.createElement("label");
  label_elem1.innerHTML = "Cacti User Name:";
  label_elem1.setAttribute("for", "cacti_user_name_cred")
  input_elem1 = document.createElement("input");
  input_elem1.setAttribute("type", "text");
  input_elem1.setAttribute("id", "cacti_user_name_cred");
  label_elem2 = document.createElement("label");
  label_elem2.innerHTML = "Cacti User Password:";
  label_elem2.setAttribute("for", "cacti_user_pass_cred");
  input_elem2 = document.createElement("input");
  input_elem2.setAttribute("type", "password");
  input_elem2.setAttribute("id", "cacti_user_pass_cred");
  button_elem = document.createElement("button");
  button_elem.setAttribute("id", "cacti_submit_button");
  button_elem.innerHTML = "Submit";
  break_elem = document.createElement("br");

  div_container.appendChild(p_elem1);
  div_container.appendChild(p_elem2);
  div_container.appendChild(label_elem1);
  div_container.appendChild(input_elem1);

  div_container.appendChild(label_elem2);
  div_container.appendChild(input_elem2);

  div_container.appendChild(button_elem);
  document.getElementById("content").appendChild(div_container);
  cacti_form_events();
}


function cacti_form_events()
{
  $("#cacti_submit_button").click(function(e){
    $.ajax({
      type: "POST",
      url: 'users/cacti_save',
      data: {cacti_username: $("#cacti_user_name_cred").val(), cacti_password: $("#cacti_user_pass_cred").val()},
      success: function(data, textStatus) {
        cacti_login();
        $("#cacti_cred_container").dialog("close");
        $("#cacti_graphs_link").show();
      },
      error: function(data){
        alert("Please enter a valid username and password.")
      }
    });
  })
}

function cacti_login()
{
   var cacti_username = '';
   var cacti_password = '';
  if(arguments.length != 0){
    cacti_username = arguments[0];
    cacti_password = arguments[1];
  }else{
    cacti_username = $("#cacti_user_name_cred").val();
    cacti_password = $("#cacti_user_pass_cred").val();
  }

  $('iframe').contents().find('#login_username').val(cacti_username);
  $('iframe').contents().find('#login_password').val(cacti_password);
  $('iframe').contents().find('form').submit();
  cacti_set_login()
}

function cacti_set_login()
{
  $.ajax({
    url: '/users/cacti_log_in',
    success: function(data, textStatus, XMLHttpRequest){
      if(textStatus == "success"){

      }else{

      }
    }
  });
}

function cacti_log_out()
{
  $.ajax({
    url: '/users/cacti_log_out',
    success: function(data, textStatus, XMLHttpRequest){
      if(textStatus == "success"){
        toolbox_log_out();
      }else{
        
      }
    }
  });
}

function toolbox_log_out()
{
  window.location = "/user_sessions/destroy";  
}

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
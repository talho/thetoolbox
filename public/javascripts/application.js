var cacti_call = false;

$(document).ready(function() {

  //Add onclick event for Reset Password
  $('#reset_password').click(function(e){
    $('#reset_password_container').dialog({width: 300,modal: true, title: "Reset Password"});
    return false;
  });

  //Add onclick events for Reset Password for individual users
  $('span.reset_user_password a').click(function(e){
    $("#reset_password_container").load("/reset_password_form/"+$(e.target).attr("user"));
    $('#reset_password_container').dialog({width: 300, modal: true, draggable: true, resizable: true});
    return false;
  });

  //Onclick events for "Manage Distribution List" per user
  $("span.add_user_to_distro a").click(function(obj){
    try{
      $("#add_to_group_form_container").dialog("destroy");
      $("#add_to_group_form_container").remove();
    }
    catch(err){}
    $('#add_to_distro_container').dialog({modal: true, draggable: true, resizable: true, title: "Manage Distribution Groups"});
    $(".distro_loader").show();
    $("#add_to_distro_internal_container").html('');
    $("#add_to_distro_internal_container").load("/distribution_group", function(){
      manage_distribution_groups();
      add_to_group_button();
    });
  });

  //Onclick events for "Manage Distribution List" on admin panel
  $('#add_to_distro').click(function(e){
    try{
      $("#add_to_group_form_container").dialog("destroy");
      $("#add_to_group_form_container").remove();
    }
    catch(err){}
    $('#add_to_distro_container').dialog({modal: true, title: "Manage Distribution Groups"});
    $(".distro_loader").show();
    $("#add_to_distro_internal_container").empty();
    /*
    $("#add_to_distro_internal_container").load("/distribution_group", function(response, status, xhr){
      manage_distribution_groups(response);
      //add_to_group_form();
      $(".distro_loader").height($("#distribution_list").height()-29);
      $("#add_to_distro_container").width($("#add_to_distro_container").width()+25);
    });*/
    $.ajax({
      url: "/distribution_group",
      dataType: "json",
      success: function(response, status, xhr) {
        manage_distribution_groups(response);
        //add_to_group_form();
        $(".distro_loader").height($("#distribution_list").height()-29);
        $("#add_to_distro_container").width($("#add_to_distro_container").width()+25);
      }
    });
  });

  //Onclick events for Create User
  $('#create_new_user').click(function(e){
    $('#white_list_panel').hide();
    $('#create_new_user_container').dialog({modal: true, title: "Create User"});
    return false;
  });
  //Onclick events for the "Create Distribution Group" link
  $('#create_new_distro').click(function(e){
    $('#create_distribution_list').dialog({modal: true, title: "Create Distribution Group"});
  });

  //Validate user input on submit within the reset password form
  $("#reset_password_submit").click(validate_pass_form);

  //Validate user input on submit within the create user form
  $("#create_new_user_submit").click(validate_create_user_form);

  //Add on key press events on user first name field
  $("#user_first_name").keyup(write_to_full_name);

  //Add on key press events on user last name field
  $("#user_last_name").keyup(write_to_full_name);

  //Validate email entry within white list form
  $('#wl_email_submit').click(function(e){
    var filter = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (!filter.test($('#wl_email_email').val())) {
      alert('Please provide a valid email address');
      return false;
    }
  });

  //Quick validate function onclick on create distribution form
  $('#create_distribution_submit').click(function(e){
    var filter = /^[a-zA-Z0-9.-]/;
    if(!filter.test($("#distribution_list_name").val())){
      alert("Please enter a valid name for your distribution group.");
      return false;
    }
  });

  //Domain name validate within white list entry form
  $('#wl_domain_submit').click(function(e){
    var filter = /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if(!filter.test($('#wl_domain_domain').val())){
      alert('Please provide a valid domain name in the following format:\t\n   example.com');
      return false;
    }
  });

  //Toggle White List entries in form
  $('#dummy_scope').change(function(e){
    $("#dummy_scope option").each(function(){
      var id = '#wl_';
      id += $(this).text().toLowerCase();
      id += '_container';
      $(id).toggle();
    });

  });

  //Onclick event for log out link
  $("#log_out").click(function(e){
    cacti_log_out();
  });
});

function jaxify_pagination()
{
  $(" span, a", "#distribution_list .pagination").button();
	$("a", "#distribution_list .pagination").click(function() {
    $(".distro_loader").show();
    $("#add_to_distro_internal_container").empty();
    $("#add_to_distro_internal_container").load($(this).attr("href"), function(){
      manage_distribution_groups();
      add_to_group_form();
    });
    return false;
  });
}

function manage_distribution_groups(response)
{
  build_distribution_view(response);
  //var distribution_obj = jQuery.parseJSON(json_obj.distribution_groups);

  //alert( distribution_obj[0].displayName )
  
  $(".distro_loader").hide();
  $("#accordion").accordion({change: function(event, ui){
    toggle_distro_users(ui, $(ui.newHeader).find("a").html().replace(/ /g, "_"))
  }});


  jaxify_pagination();
}

function build_distribution_view(json_obj)
{
  distribution_obj = jQuery.parseJSON(json_obj.distribution_groups);
  distribution_list = document.createElement("div");
  distribution_list.setAttribute("id", "distribution_list");
  accordion_div = document.createElement("div");
  accordion_div.setAttribute("id", "accordion");
  for(i = 0; i < distribution_obj.length; i++){
    h3_element = document.createElement("h3");
    anchor_element = document.createElement("a");
    anchor_element.setAttribute("href", "#");
    anchor_element.innerHTML = distribution_obj[i].displayName;
    h3_element.appendChild(anchor_element);
    div_element1 = document.createElement("div");
    div_element1.className = "accordion_user_container user_display_list "+distribution_obj[i].displayName.replace(/ /g, "_");
    p_element1 = document.createElement("p");
    p_element1.className = "accordion_content";
    div_element2 = document.createElement("div");
    div_element2.className = "distro_user_overlay";
    div_element3 = document.createElement("div");
    div_element3.className = "distro_user_overlay_ajax";
    p_element2 = document.createElement("p");
    p_element2.className = "distro_user_overlay_msg"
    p_element2.innerHTML = "Please wait while we load user list."

    div_element2.appendChild(div_element3);
    div_element2.appendChild(p_element2); 
    p_element1.appendChild(div_element2);
    div_element1.appendChild(p_element1);

    accordion_div.appendChild(h3_element);
    accordion_div.appendChild(div_element1);
  }
  distribution_list.appendChild(accordion_div);
  $("#add_to_distro_internal_container").append($(distribution_list));

}

function add_to_group_form()
{
  $("#add_to_group_button").click(function(e){
    $("#add_to_group_form_container form").each(function(){
      this.reset();
    });
    $("#add_to_group_form_container").dialog({modal: true, title: "Add to Distribution Group"});
  });
  $("#add_to_group_form_container form #add_to_group_submit").click(function(e){
    if(!validate_add_to_group_form()){
      return false;
    }
    $(".distro_overlay_msg").html("Please wait while we add contact to distribution group.")
    $(".distro_overlay").toggle();
    $.ajax({
      type: "POST",
      url: "/add_to_distribution_group",
      data: {contact_name: $("#contact_name").val(), contact_smtp_address: $("#contact_smtp_address").val(), add_to_group_hidden: $("#add_to_group_hidden").val()},
      success: function() {
        class_string = $(".distribution_list_display ul li.selected span.displayName").html();
        class_string = class_string.replace(/ /g, "_");
        $("."+class_string).load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
          $(".distro_overlay").toggle();
        });
      },
      error: function(req, status, text)
      {
          alert(req.responseText);
          $(".distro_overlay").toggle();
      }
    });
    $("#add_to_group_form_container").dialog("close");
    return false;
  });  
}

function add_to_group_button()
{
  $("#add_to_group_button").click(function(e){
    $(".distro_overlay_msg").html("Please wait while we add user to distribution group.")
    $(".distro_overlay").toggle();
    $.ajax({
      type: "POST",
      url: "/add_to_distribution_group",
      data: {contact_name: $(obj.target).attr("alias"), contact_smtp_address: $(obj.target).attr("email"), add_to_group_hidden: $(".distribution_list_display ul li.selected span.displayName").html(), contact_type: "UserMailbox"},
      success: function() {
        class_string = $(".distribution_list_display ul li.selected span.displayName").html();
        class_string = class_string.replace(/ /g, "_");
        $("."+class_string).load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
          $(".distro_overlay").toggle();
        });
      }
    });
  });  
}

function toggle_distro_users(el, class_string)
{
  /*
  el = $(el);
  $('#distribution_list .distribution_list_display li').removeClass('selected');
  el.addClass('selected');
  // hide all of the user list items so they don't show when they aren't really there
  $('#distribution_list .distribution_list_user_display .user_display_list').hide();
  $("."+class_string).toggle();
  $(".distro_overlay_msg").html("Loading distribution group members.")
  $(".distro_overlay").toggle();
  $("."+class_string).load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
    $(".distro_overlay").toggle();
  });
  $("#add_to_group_button").show();
  $("#add_to_group_hidden").val(el.children("span.displayName").html())
  $(".remove_from_group_button").hide();*/
  $("."+class_string+" .accordion_content").load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
    $(".distro_user_overlay").hide();
    $("."+class_string).height("auto");
    $(".distro_loader").height($("#distribution_list").height()-29);

  });
}

function toggle_distro_user(el, member_alias, groupId, class_string)
{
  el = $(el)
  $('#distribution_list .distribution_list_user_display ul li ul li').removeClass('selected');
  el.toggleClass('selected')
  $(".remove_from_group_button").show();
  $(".remove_from_group_button").click(function(e){
    $(".distro_overlay_msg").html("Please wait while we remove member from distribution group.")
    $(".distro_overlay").toggle();
    $("."+class_string).load("/distribution_group_users_remove", {group_name: groupId, member_alias: member_alias}, function(){
      $(".distro_overlay").toggle();
    });
  })
}

function begin_cacti_login()
{
  build_cacti_cred_form();
  $("#cacti_cred_container").dialog({modal:true, title: "Cacti Login"});
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
  label_elem2.innerHTML = "Cacti Password:";
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
    submit_cacti_login_form();
  });
  $("#cacti_user_name_cred").keypress(function(event){
    if (event.keyCode == '13') {
      submit_cacti_login_form();
    }
  });
  $("#cacti_user_pass_cred").keypress(function(event){
    if (event.keyCode == '13') {
      submit_cacti_login_form();
    }
  });
}

function submit_cacti_login_form()
{
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

function validate_add_to_group_form(){
  var error_list = '';
  var filter = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
  var contact_name = $.trim($("#contact_name").val());
  var contact_smtp_address = $.trim($("#contact_smtp_address").val());

  if(contact_name == '' || contact_name <= 2){
    error_list += "- Please enter a valid contact name.\t\n";
  }

  if (contact_smtp_address == '' || !filter.test(contact_smtp_address)) {
    error_list += "- Please provide a valid email address.\t\n";
  }
  if(error_list != ''){
    alert("Please correct the following items and try again.\t\n"+error_list);
    return false;
  }
  return true;
}
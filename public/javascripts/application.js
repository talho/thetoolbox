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
    $('#add_to_distro_container').dialog({modal: true, resizable: false, title: "Manage Distribution Groups"});
    $(".distro_loader").show();
    $("#add_to_distro_internal_container").empty();
    $.ajax({
      url: "/distribution_group",
      dataType: "json",
      success: function(response, status, xhr) {
        manage_distribution_groups(response);
        $(".distro_loader").height($("#accordion").height()-39);
        $("#add_to_distro_container").width($("#add_to_distro_container").width()+3);
        $("#contact_name").val($(obj.target).attr("alias"));
        $("#contact_smtp_address").val($(obj.target).attr("email"));
        $("#contact_type").val("UserMailbox")
      }
    });
  });

  //Onclick events for "Manage Distribution List" on admin panel
  $('#add_to_distro').click(function(e){
    try{
      $("#add_to_group_form_container").dialog("destroy");
      $("#add_to_group_form_container").remove();
    }
    catch(err){}
    $('#add_to_distro_container').dialog({modal: true, resizable: false, title: "Manage Distribution Groups"});
    $(".distro_loader").show();
    $("#add_to_distro_internal_container").empty();
    $.ajax({
      url: "/distribution_group",
      dataType: "json",
      success: function(response, status, xhr) {
        manage_distribution_groups(response);
        $(".distro_loader").height($("#accordion").height()-39);
        $("#add_to_distro_container").width($("#add_to_distro_container").width()+3);
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
  //$("> span, a", "#distribution_list .pagination").button();
  $("#distribution_list .pagination > span").button();
  $("#distribution_list .pagination > a").button();
	$("a", "#distribution_list .pagination").click(function() {
    $(".distro_loader").show();
    $("#accordion").remove();
    $.ajax({
      url: $(this).attr("href"),
      dataType: "json",
      success: function(response, status, xhr) {
        manage_distribution_groups(response);
        //add_to_group_form();
        $(".distro_loader").height($("#accordion").height()-39);
        $("#add_to_distro_container").width($("#add_to_distro_container").width());
      }
    });
    return false;
  });
}

function manage_distribution_groups(response)
{
  build_distribution_view(response);
  $(".distro_loader").hide();
  $(document.getElementById("accordion")).accordion({change: function(event, ui){
    $(".distro_user_overlay").show();
    try{
      toggle_distro_users($(ui.newHeader).find("a").html().replace(/ /g, "_"));
    }catch(err){
      toggle_distro_users($(ui.oldHeader).find("a").html().replace(/ /g, "_"));
    }
  }, active: false, collapsible: true});
  jaxify_pagination();
}

function build_distribution_view(json_obj)
{
  distribution_obj = jQuery.parseJSON(json_obj.distribution_groups);
  if(document.getElementById("distribution_list")){
    distribution_list = document.getElementById("distribution_list");
  }else{
    distribution_list = document.createElement("div");
    distribution_list.setAttribute("id", "distribution_list");
  }
  accordion_div = document.createElement("div");
  accordion_div.setAttribute("id", "accordion");

  for(i = 0; i < distribution_obj.length; i++){
    h3_element               = document.createElement("h3");
    anchor_element           = document.createElement("a");
    div_element1             = document.createElement("div");
    div_element2             = document.createElement("div");
    div_element3             = document.createElement("div");
    div_element4             = document.createElement("div");
    //p_element2               = document.createElement("p");
    div_element1.className   = "accordion_user_container user_display_list "+distribution_obj[i].displayName.replace(/ /g, "_");
    div_element4.className   = "accordion_content";
    div_element2.className   = "distro_user_overlay";
    div_element3.className   = "distro_user_overlay_ajax";
    //p_element2.className     = "distro_user_overlay_msg";
    //p_element2.innerHTML     = "Please wait while we load user list."
    anchor_element.innerHTML = distribution_obj[i].displayName;
    anchor_element.setAttribute("href", "#");
    h3_element.appendChild(anchor_element);
    div_element2.appendChild(div_element3);
    //div_element2.appendChild(p_element2);
    div_element4.appendChild(div_element2);
    div_element1.appendChild(div_element4);
    accordion_div.appendChild(h3_element);
    accordion_div.appendChild(div_element1);
  }
  number_of_pages = Math.floor(json_obj.total_entries/json_obj.per_page);
  if(json_obj.total_entries%json_obj.per_page != 0){
    number_of_pages++;
  }

  if(json_obj.current_page == 1){
    traverse_prev           = document.createElement("span");
    traverse_next           = document.createElement("a");
    traverse_prev.className = "disabled prev_page";
    traverse_next.className = "next_page";
    traverse_prev.innerHTML = "&lt;&lt; Previous";
    traverse_next.innerHTML = "Next &gt;&gt;";
    traverse_next.setAttribute("href", "/distribution_group?page="+(json_obj.current_page+1))
  }else if(json_obj.current_page == number_of_pages){
    traverse_next           = document.createElement("span");
    traverse_prev           = document.createElement("a");
    traverse_next.className = "disabled next_page";
    traverse_prev.className = "prev_page";
    traverse_next.innerHTML = "Next &gt;&gt;";
    traverse_prev.innerHTML = "&lt;&lt; Previous";
    traverse_prev.setAttribute("href", "/distribution_group?page="+(json_obj.current_page-1))
  }else{
    traverse_prev           = document.createElement("a");
    traverse_next           = document.createElement("a");
    traverse_prev.className = "prev_page";
    traverse_next.className = "next_page";
    traverse_prev.innerHTML = "&lt;&lt; Previous";
    traverse_next.innerHTML = "Next &gt;&gt;";
    traverse_prev.setAttribute("rel", "prev");
    traverse_prev.setAttribute("href", "/distribution_group?page="+(json_obj.current_page-1));
    traverse_next.setAttribute("rel", "next");
    traverse_next.setAttribute("href", "/distribution_group?page="+(json_obj.current_page+1));
  }
  if(document.getElementById("pagination")){
    pagination_div = document.getElementById("pagination");
    $(pagination_div).empty();
  }else{
    pagination_div           = document.createElement("div");
    pagination_div.className = "pagination";
    pagination_div.setAttribute("id", "pagination");
  }

  if(document.getElementById("dialog-confirm")){
    dialog_confirm = document.getElementById("dialog-confirm");
    $(dialog_confirm).find("p span:last").html("This distribution group member will be permanently deleted and cannot be recovered. Are you sure?")
  }else{
    dialog_confirm = document.createElement("div");
    dialog_confirm.setAttribute("id", "dialog-confirm");
    dialog_confirm.setAttribute("title", "Delete Distribution Group Member?");
    dialog_confirm_p = document.createElement("p");
    dialog_confirm_span = document.createElement("span");
    dialog_confirm_span.className = "ui-icon ui-icon-alert";
    dialog_confirm_span_msg = document.createElement("span");
    dialog_confirm_span_msg.innerHTML = "This distribution group member will be permanently deleted and cannot be recovered. Are you sure?";
    dialog_confirm_p.appendChild(dialog_confirm_span);
    dialog_confirm_p.appendChild(dialog_confirm_span_msg);
    dialog_confirm.appendChild(dialog_confirm_p);
  }
  /*
    <div id="add_to_group_form_container" class="add_to_group_form_container">
    <form method="post" action="/add_to_distribution_group">
      <input type="hidden" name="add_to_group_hidden" id="add_to_group_hidden">
      <input type="hidden" name="contact_type" id="contact_type">
      <label for="contact_name">Contact Name:</label><br>
      <input type="text" name="contact_name" id="contact_name"><br>
      <label for="contact_smtp_address">Contact Address:</label><br>
      <input type="text" name="contact_smtp_address" id="contact_smtp_address"><br>
      <input type="submit" value="Submit" name="commit" id="add_to_group_submit">
    </form>
  </div>
   */
  if(document.getElementById("add_to_group_form_container")){
    add_to_group_form_container = document.getElementById("dd_to_group_form_container");
  }else{
    add_to_group_form_container = document.createElement("div");
    add_to_group_form_container.setAttribute("id", "add_to_group_form_container");
    add_to_group_form_container.className = "add_to_group_form_container";
    add_to_group_form_elem = document.createElement("form");
    add_to_group_form_elem.setAttribute("method", "post");
    add_to_group_form_elem.setAttribute("action", "/add_to_distribution_group");
    input_elem_1 = document.createElement("input");
    input_elem_1.setAttribute("type", "hidden");
    input_elem_1.setAttribute("name", "add_to_group_hidden");
    input_elem_1.setAttribute("id", "add_to_group_hidden");
    input_elem_2 = document.createElement("input");
    input_elem_2.setAttribute("type", "hidden");
    input_elem_2.setAttribute("name", "contact_type");
    input_elem_2.setAttribute("id", "contact_type");
    label_elem_1 = document.createElement("label");
    label_elem_1.setAttribute("for", "contact_name");
    label_elem_1.innerHTML = "Contact Name:";
    input_elem_3 = document.createElement("input");
    input_elem_3.setAttribute("type", "text");
    input_elem_3.setAttribute("name", "contact_name");
    input_elem_3.setAttribute("id", "contact_name");
    label_elem_2 = document.createElement("label");
    label_elem_2.setAttribute("for", "contact_smtp_address");
    label_elem_2.innerHTML = "Contact Address:";
    input_elem_4 = document.createElement("input");
    input_elem_4.setAttribute("type", "text");
    input_elem_4.setAttribute("name", "contact_smtp_address");
    input_elem_4.setAttribute("id", "contact_smtp_address");
    input_elem_5 = document.createElement("input");
    input_elem_5.setAttribute("type", "submit");
    input_elem_5.setAttribute("name", "commit");
    input_elem_5.setAttribute("id", "add_to_group_submit");
    input_elem_5.setAttribute("value", "Submit");
    add_to_group_form_elem.appendChild(input_elem_1);
    add_to_group_form_elem.appendChild(input_elem_2);
    add_to_group_form_elem.appendChild(label_elem_1);
    add_to_group_form_elem.appendChild(document.createElement("br"));
    add_to_group_form_elem.appendChild(input_elem_3);
    add_to_group_form_elem.appendChild(document.createElement("br"));
    add_to_group_form_elem.appendChild(label_elem_2);
    add_to_group_form_elem.appendChild(document.createElement("br"));
    add_to_group_form_elem.appendChild(input_elem_4);
    add_to_group_form_elem.appendChild(document.createElement("br"));
    add_to_group_form_elem.appendChild(input_elem_5);
    add_to_group_form_container.appendChild(add_to_group_form_elem);
  }
  pagination_div.appendChild(traverse_prev);
  for(x=1;x<=number_of_pages;x++){
    if(x == json_obj.current_page){
      current_span           = document.createElement("span");
      current_span.className = "current";
      current_span.innerHTML = x;
      pagination_div.appendChild(current_span);
    }else{
      page_link           = document.createElement("a");
      page_link.innerHTML = x;
      page_link.setAttribute("href", "/distribution_group?page="+x);
      if((x+1) == json_obj.current_page){
        page_link.setAttribute("rel", "prev")
      }else if((x-1) == json_obj.current_page){
        page_link.setAttribute("rel", "next");
      }
      pagination_div.appendChild(page_link);
    }
  }
  pagination_div.appendChild(traverse_next);

  if(!document.getElementById("pagination")){
    distribution_list.appendChild(accordion_div);
    distribution_list.appendChild(pagination_div);
  }else{
    distribution_list.insertBefore(accordion_div, pagination_div);  
  }
  if(!document.getElementById("dialog-confirm")){
    distribution_list.appendChild(dialog_confirm);
  }
  if(!document.getElementById("add_to_group_form_container")){
    distribution_list.appendChild(add_to_group_form_container);
  }
  document.getElementById("add_to_distro_internal_container").appendChild(distribution_list);

}

function add_to_group_form()
{
  $("#add_to_group_form_container form #add_to_group_submit").unbind();
  $("#add_to_group_form_container form #add_to_group_submit").click(function(e){
    if(!validate_add_to_group_form()){
      return false;
    }
    class_string = $("#add_to_group_hidden").val();
    class_string = class_string.replace(/ /g, "_");
    html_string = "<div class=\"distro_user_overlay\" style=\"display:block;\">"+
                  "<div class=\"distro_user_overlay_ajax\"></div>"+
                  "Please wait while we add user."+
                  "</div><br/>" + $("."+class_string+" .accordion_content").html();
    $("."+class_string+" .accordion_content").html(html_string)
    $.ajax({
      type: "POST",
      url: "/add_to_distribution_group",
      data: {contact_name: $("#contact_name").val(), contact_smtp_address: $("#contact_smtp_address").val(), add_to_group_hidden: $("#add_to_group_hidden").val()},
      success: function() {
        $("."+class_string+" .accordion_content").load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
          toggle_distro_users(class_string)
        });
      },
      error: function(req, status, text)
      {
        alert(req.responseText);
        $("."+class_string+" .accordion_content").load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
          toggle_distro_users(class_string)
        });
      }
    });
    $("#add_to_group_form_container").dialog("close");
    return false;
  });  
}

function add_to_group_button()
{
  /*
  $("#add_to_group_button").click(function(e){
    $(".distro_user_overlay").show();
    $.ajax({
      type: "POST",
      url: "/add_to_distribution_group",
      data: {contact_name: $(e.target).attr("alias"), contact_smtp_address: $(e.target).attr("email"), add_to_group_hidden: $(".distribution_list_display ul li.selected span.displayName").html(), contact_type: "UserMailbox"},
      success: function() {
        class_string = $(".distribution_list_display ul li.selected span.displayName").html();
        class_string = class_string.replace(/ /g, "_");
        $("."+class_string).load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(){
          $(".distro_overlay").toggle();
        });
      }
    });
  }); */ 
}

function toggle_distro_users(class_string)
{
  var argv = toggle_distro_users.arguments;
  if(typeof(argv[1]) != "undefined"){
    group_uri = argv[1];
  }else{
    group_uri = "/distribution_group_users"
  }

  $("."+class_string+" .accordion_content").load(group_uri, {group_name: class_string.replace(/_/g, " ")}, function(){
    accordion_content = this;
    $("."+class_string+" .distro_user_overlay").hide();
    $("."+class_string).height("auto");
    $(".distro_loader").height($("#accordion").height()-39);
    $("."+class_string+" .add_contact").click(function(e){
      //$("#add_to_group_form_container form #contact_type").reset();
      $("#add_to_group_form_container form #add_to_group_hidden").val($(e.target).attr("rel"));
      if($("#contact_type").val() == "UserMailbox"){
        add_to_group_form();
        $("#add_to_group_form_container form #add_to_group_submit").click();
      }else{
        $("#add_to_group_form_container form").each(function(){
          this.reset();
        });
        $("#add_to_group_form_container").dialog({modal: true, title: "Add to Distribution Group"});
        add_to_group_form();
      }
      return false;
    });
    $("."+class_string+" .ucn_del a").click(function(e){
      $(".ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix").show();
      $("#dialog-confirm").find("p span:last").html("This distribution group member will be permanently deleted and cannot be recovered. Are you sure?");
      $("#dialog-confirm").dialog({
        resizable: false,
        height:140,
        modal: true,
        buttons: {
          'Delete': function() {
            $(".ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix").hide();
            $(this).find("p:first").width($(this).find("p:first").width());
            $(this).find("p span:last").html("Please wait while we remove the user.<div class='distro_user_overlay_ajax'></div>");
            $("."+class_string).load("/distribution_group_users_remove", {group_name: class_string.replace(/_/g, " "), member_alias: $(e.target).attr('rel')}, function(){
              $("#dialog-confirm").dialog('close');
            });  
          },
          Cancel: function() {
            $(this).dialog('close');
          }
        }
      });
      return false;
    });
    $("."+class_string+" .pagination a").click(function(obj){
      toggle_distro_users(class_string, $(obj.target).attr("href"));
      return false;
    });
  });
}

function begin_cacti_login()
{
  build_cacti_cred_form();
  $("#cacti_cred_container").dialog({modal:true, title: "Cacti Login"});
}

function build_cacti_cred_form()
{
  div_container         = document.createElement("div");
  p_elem1               = document.createElement("p");
  p_elem2               = document.createElement("p");
  input_elem1           = document.createElement("input");
  label_elem1           = document.createElement("label");
  label_elem2           = document.createElement("label");
  label_elem2           = document.createElement("label");
  input_elem2           = document.createElement("input");
  button_elem           = document.createElement("button");
  break_elem            = document.createElement("br");
  p_elem1.innerHTML     = "It seems that you have not yet taken the time to fill in your Cacti Credentials."
  p_elem2.innerHTML     = "In order to get access to Cacti graphs, please fill in your credentials below."
  label_elem1.innerHTML = "Cacti User Name:";
  label_elem2.innerHTML = "Cacti Password:";
  button_elem.innerHTML = "Submit";
  div_container.setAttribute("id", "cacti_cred_container");
  div_container.setAttribute("class", "cacti_cred_container");
  p_elem1.setAttribute("class", "cacti_desc");
  p_elem2.setAttribute("class", "cacti_desc");
  label_elem1.setAttribute("for", "cacti_user_name_cred")
  input_elem1.setAttribute("type", "text");
  input_elem1.setAttribute("id", "cacti_user_name_cred");
  label_elem2.setAttribute("for", "cacti_user_pass_cred");
  input_elem2.setAttribute("type", "password");
  input_elem2.setAttribute("id", "cacti_user_pass_cred");
  button_elem.setAttribute("id", "cacti_submit_button");
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

function write_to_full_name()
{
  $("#user_full_name").val($("#user_first_name").val() + " " + $("#user_last_name").val());  
}

function validate_pass_form()
{
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

function validate_create_user_form()
{
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

function validate_add_to_group_form()
{
  var error_list           = '';
  var filter               = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
  var contact_name         = $.trim($("#contact_name").val());
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
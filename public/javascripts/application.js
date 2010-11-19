var thetoolbox = {

  _RESET_PASSWORD_CONTAINER_WIDTH: 300,
  _MODAL_TOP_POSITION:             130,
  _MODAL_CONFIRM_HEIGHT:           140,
  _DISTRO_LOADER_ADJUSTMENT:       31,
  _VPN_LOADER_ADJUSTMENT:          26,
  _DISTRO_CONTAINER_ADJUSTMENT:    90,
  _LOADER_DIVIDE_BY:               2,
  _EMAIL_FILTER:                   /^([\w+\W])+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/,
  _DISTRO_NAME_FILTER:             /^[a-zA-Z0-9.-]/,
  _DOMAIN_NAME_FILTER:             /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/,
  _PASSWORD_FILTER_ALPHA_LOWER:    /^.*[a-z]/,
  _PASSWORD_FILTER_ALPHA_UPPER:    /^.*[A-Z]/,
  _PASSWORD_FILTER_NUMERIC:        /^.*[0-9]/,
  _PASSWORD_FILTER_CHAR:           /^.*[\W]/,
  _PASSWORD_LENGTH:                8,
  _LOGIN_LENGTH:                   20,
  _VPN_LOGIN_LENGTH:               16,
  _USER_VPN_CH_PWD_FLAG:           false,
  _USER_VPN_PWD_EXP_FLAG:          false,
  cacti_call:                      false,

  toolBoxInit: function() {
    /**
     * Add onclick event for Reset Password
     */
    $('#reset_password').click(function(e){
      $("#reset_password_container form").attr("action", encodeURI($("#reset_password_container form").attr("action").replace(/\./g, "%2E")));
      $('#reset_password_container').dialog({width: thetoolbox._RESET_PASSWORD_CONTAINER_WIDTH, modal: true, title: "Reset Password", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      $('#reset_pass_user_name_validate').val($(e.target).attr("user"));
      return false;
    });

    /**
     * Add onclick events for Reset Password for individual users
     */
    $('span.reset_user_password a').click(function(e){
      $("#reset_password_container").load("/reset_password_form/"+encodeURI($(e.target).attr("user").replace(/\./g, "%2E")), function(response, status, xhr){
        if(status == "error"){
          msg  = "Sorry but there was an error: "+ xhr.status + " " + xhr.statusText+"<br/>";
          msg += "On user: "+$(e.target).attr("user")+"<br/>";
          msg += "Please contact your administrator.";
          thetoolbox.display_msg("error", msg);
        }else{
          $("#reset_password_container form").attr("action", encodeURI($("#reset_password_container form").attr("action").replace(/\./g, "%2E")));
          $("#reset_password_container form").form();
          $("#reset_password_container form").submit(function(submit_event){
            return thetoolbox.validate_pass_form($(e.target).attr("user"),$("#reset_pass_name_validate").val());
          });
          $('#reset_password_container').dialog({width: thetoolbox._RESET_PASSWORD_CONTAINER_WIDTH, modal: true, draggable: true, resizable: true, position: ['center', thetoolbox._MODAL_TOP_POSITION]});
        }
      });
      return false;
    });

    /**
     * Onclick events for "Add to Distribution List" per user
     */
    $("span.add_user_to_distro a").click(function(obj){
      try{
        $("#add_to_group_form_container").dialog("destroy");
        $("#add_to_group_form_container").remove();
      }
      catch(err){}
      $('#add_to_distro_container').dialog({modal: true, resizable: false, title: "Add \""+$(obj.target).attr("rel")+"\" to Distribution List", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      $(".distro_loader").show();
      $("#add_to_distro_internal_container").empty();
      $.ajax({
        url: "/distribution_group",
        dataType: "json",
        success: function(response, status, xhr) {
          thetoolbox.manage_distribution_groups(response);
          $(".distro_loader").css("margin-top", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $(".distro_loader").css("margin-bottom", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $("#add_to_distro_container").width($("#add_to_distro_container").width()+thetoolbox._DISTRO_CONTAINER_ADJUSTMENT);
          $("#contact_name").val($(obj.target).attr("alias"));
          $("#contact_smtp_address").val($(obj.target).attr("email"));
          $("#contact_type").val("UserMailbox")
        }
      });
    });

    /**
     * Onclick events for "Manage Distribution List" on admin panel
     */
    $('#add_to_distro').click(function(e){
      try{
        $("#add_to_group_form_container").dialog("destroy");
        $("#add_to_group_form_container").remove();
      }
      catch(err){}
      $('#add_to_distro_container').dialog({modal: true, resizable: false, title: "Manage Distribution List", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      $(".distro_loader").show();
      $("#add_to_distro_internal_container").empty();
      $.ajax({
        url: "/distribution_group",
        dataType: "json",
        success: function(response, status, xhr) {
          thetoolbox.manage_distribution_groups(response);
          $(".distro_loader").css("margin-top", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY  - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $(".distro_loader").css("margin-bottom", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY  - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $("#add_to_distro_container").width($("#add_to_distro_container").width()+thetoolbox._DISTRO_CONTAINER_ADJUSTMENT);
        }
      });
    });

    /**
     * Onclick events for "VPN Users" on admin panel
     */
     $("#vpn_users").click(function(e){
      $("#vpn_users_container").dialog({modal: true, resizable: false, title: "VPN Users", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      $("#vpn_users_container div.flash").hide();
      $(".vpn_loader").html("Please wait while we retrieve VPN users.")
      $(".vpn_loader").show();
      $("#vpn_users_internal_container").empty();
      $("#vpn_users_internal_container").load("/vpn_users", {vpn_only: true}, function(response, status, xhr){
        $(".vpn_loader").hide();
        thetoolbox.create_vpn_user_events();
        thetoolbox.jaxify_vpn_user_pagination();
        thetoolbox.manage_vpn_users();
      });
     });

    /**
     * Onclick events for Create User
     */
    $('#create_new_user').click(function(e){
      $('#create_new_user_container').dialog({modal: true, title: "Create User", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      return false;
    });

    /**
     * Onclick events for the "Create Distribution Group" link
     */
    $('#create_new_distro').click(function(e){
      $('#create_distribution_list').dialog({modal: true, title: "Create Distribution List", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
    });

    /**
     * Validate user input on submit within the reset password form
     */
    $("#reset_password_container form").submit(function(e){
      return thetoolbox.validate_pass_form($('#reset_pass_user_name_validate').val(),$("#reset_pass_name_validate").val());
    });

    /**
     * Validate user input on submit within the create user form
     */
    $("#create_new_user_submit").click(function(e){
      return thetoolbox.validate_create_user_form();
    });

    /**
     * Validate user input on submit within the create vpn user form
     * and submit form.
     */
    $("#create_vpn_user_container form").submit(function(e){
      if (thetoolbox.validate_create_vpn_user_form()){
        $("#vpn_users_container div.flash").hide();
        $("#create_vpn_user_container").dialog("close");
        $(".vpn_loader").html("Creating VPN user. Please wait.");
        $(".vpn_loader").show();
        $("#vpn_users_internal_container").empty();
        $.ajax({
          type: "POST",
          url: "/users",
          data: $("#create_vpn_user_container form.new_user").serialize(),
          success: function() {
            $("#vpn_users_container div.flash").html("<p class=\"completed\">User added</p>");
          },
          error: function(req, status, text)
          {
            $("#vpn_users_container div.flash").html("<p class=\"error\">"+req.responseText+"</p>");
          },
          complete: function(req, status)
          {
            $("#create_vpn_user_container form.new_user").each(function(){
              this.reset();
            });
            $("#vpn_users_internal_container").load("/vpn_users", {vpn_only: true}, function(response, status, xhr){
              $(".vpn_loader").hide();
              $("#vpn_users_container div.flash").show();
              thetoolbox.create_vpn_user_events();
              thetoolbox.jaxify_vpn_user_pagination();
              thetoolbox.manage_vpn_users();
            });
          }
        });
      }
      return false;
    });

    /**
     * Add on key press events on user first name field
     */
    $("#user_first_name").keyup(this.write_to_full_name);

    /**
     * Add on key press events on user last name field
     */
    $("#user_last_name").keyup(this.write_to_full_name);

    /**
     * Add on key press events on user first name field
     */
    $("#user_vpn_first_name").keyup(this.write_to_full_vpn_name);

    /**
     * Add on key press events on user last name field
     */
    $("#user_vpn_last_name").keyup(this.write_to_full_vpn_name);

    /**
     * Validate email entry within white list form
     */
    $('#wl_email_submit').click(function(e){
      if (!thetoolbox._EMAIL_FILTER.test($('#wl_email_email').val())) {
        alert('Please provide a valid email address');
        return false;
      }
    });

    /**
     * Quick validate function onclick on create distribution form
     */
    $('#create_distribution_submit').click(function(e){
      if(!thetoolbox._DISTRO_NAME_FILTER.test($("#distribution_group_distribution_list_name").val())){
        alert("Please enter a valid name for your distribution group.");
        return false;
      }
    });

    /**
     * Domain name validate within white list entry form
     */
    $('#wl_domain_submit').click(function(e){
      if(!thetoolbox._DOMAIN_NAME_FILTER.test($('#wl_domain_domain').val())){
        alert('Please provide a valid domain name in the following format:\t\n   example.com');
        return false;
      }
    });

    /**
     * Toggle White List entries in form
     */
//    $('#dummy_scope').change(function(e){
//      $("#dummy_scope option").each(function(){
//        var id = '#wl_';
//        id += $(this).text().toLowerCase();
//        id += '_container';
//        $(id).toggle();
//      });
//
//    });

    /**
     * Onclick event for log out link
     */
    $("#log_out").click(function(e){
      thetoolbox.cacti_log_out();
    });

    /**
     * URIencode the delete user URL
     */
    $("td.delete > a").each(function(){
      $(this).attr('href', encodeURI($(this).attr('href').replace(/\./g, "%2E")));
    });
  
    $("form.new_user").form();
    $("#create_distribution_list form").form();
    // Set checkbox to checked by default
    $("#_distribution_group_sender_auth_enabled span").addClass('ui-icon ui-icon-check');
    $("#reset_password_container form").form();
    $("form#new_user_session").form();
    this.clean_up_pagination('body');
    $("div.pagination span, div.pagination a").button();
  },

  get_url_vars: function()
  {
    var vars   = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++){
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars; 
  },

  clean_up_pagination: function(scope_string)
  {
    if($(scope_string + " .current").prev().attr("class") == "disabled prev_page" ||
      $(scope_string + " .current").prev().attr("class") == "prev_page"){
      $(scope_string + " .current").prev().remove();
    }
    if($(scope_string + " .current").next().attr("class") == "disabled next_page" ||
      $(scope_string + " .current").next().attr("class") == "next_page"){
      $(scope_string + " .current").next().remove();
    }
  },
  
  jaxify_vpn_user_pagination: function()
  {

    this.clean_up_pagination("#vpn_users_internal_container");
    $('#create_vpn_user').click(function(e){
      $("#create_vpn_user_container form").each(function(){
        this.reset();
      });
      $('#create_vpn_user_container').dialog({modal: true, title: "Create VPN User", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      return false;
    });
    $("#vpn_users_internal_container .pagination > span").button();
    $("#vpn_users_internal_container .pagination > a").button();
    $("a", "#vpn_users_internal_container .pagination").click(function() {
      $("#vpn_users_container div.flash").hide();
      $(".vpn_loader").css("margin-top", Math.floor($("ul.vpn_user_list").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._VPN_LOADER_ADJUSTMENT)+"px");
      $(".vpn_loader").css("margin-bottom", Math.floor($("ul.vpn_user_list").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._VPN_LOADER_ADJUSTMENT)+"px");
      $("ul.vpn_user_list").hide();
      $(".vpn_loader").html("Please wait while we retrieve VPN users.");
      $(".vpn_loader").show();
      $("#vpn_users_internal_container").load($(this).attr("href"), function(response, status, xhr){
        $("ul.vpn_user_list").show();
        $(".vpn_loader").hide();
        thetoolbox.create_vpn_user_events();
        thetoolbox.jaxify_vpn_user_pagination();
        thetoolbox.manage_vpn_users();
      });
      return false;
    });
  },

  jaxify_distro_pagination: function()
  {
    this.clean_up_pagination("#distribution_list");
    $("#distribution_list .pagination > span").button();
    $("#distribution_list .pagination > a").button();
    $("a", "#distribution_list .pagination").click(function() {
      $(".distro_loader").show();
      $("#accordion").remove();
      $.ajax({
        url: $(this).attr("href"),
        dataType: "json",
        success: function(response, status, xhr) {
          thetoolbox.manage_distribution_groups(response);
          $(".distro_loader").css("margin-top", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $(".distro_loader").css("margin-bottom", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
          $("#add_to_distro_container").width($("#add_to_distro_container").width());
        }
      });
      return false;
    });
  },

  create_vpn_user_events: function()
  {
    $('#create_vpn_user').click(function(e){
      $("#create_vpn_user_container form").each(function(){
        this.reset();
      });
      $('#create_vpn_user_container').dialog({modal: true, title: "Create VPN User", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
      return false;
    });
  },

  manage_vpn_users: function()
  {
    $("a.vpn_del").each(function(){
      $(this).click(function(e){
        $(".vpn_user_overlay_ajax").hide();
        $("#vpn-confirm").find("p span:last").html("This VPN user will be permanently deleted and cannot be recovered. Are you sure?");
        $("#vpn_confirm").dialog({
          resizable: false,
          height: thetoolbox._MODAL_CONFIRM_HEIGHT,
          modal: true,
          position: ['center', thetoolbox._MODAL_TOP_POSITION],
          buttons: {
            'Delete': function() {
              $(".ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix").hide();
              $(this).find("p:first").width($(this).find("p:first").width());
              $(this).find("p span:last").html("Please wait while we remove the user.<div class='vpn_user_overlay_ajax'></div>");
              dialog_obj = this;
              $.ajax({
                type: "GET",
                url: "/users/delete/"+encodeURI($(e.target).attr('rel').replace(/\./g, "%2E")),
                success: function(req, status, text){
                  $("#vpn_users_container div.flash").html("<p class=\"completed\">User Deleted</p>");
                },
                error: function(req, status, text){
                  $("#vpn_users_container div.flash").html("<p class=\"completed\">"+req.responseText+"</p>");
                },
                complete: function(reg, status){
                  $(dialog_obj).dialog('close');
                  $(".vpn_loader").html("Please wait while we retrieve VPN users.")
                  $(".vpn_loader").show();
                  $("#vpn_users_internal_container").empty();
                  $("#vpn_users_internal_container").load("/vpn_users", {vpn_only: true}, function(response, status, xhr){
                    $(".vpn_loader").hide();
                    $("#vpn_users_container div.flash").show();
                    thetoolbox.create_vpn_user_events();
                    thetoolbox.jaxify_vpn_user_pagination();
                    thetoolbox.manage_vpn_users();
                  });
                }
              });
            },
            Cancel: function() {
              $(this).dialog('close');
            }
          }
        });
        return false;
      });
    });
  },

  manage_distribution_groups: function(response)
  {
    build_result = this.build_distribution_view(response);
    if(build_result){
      $(".distro_loader").hide();
      $(document.getElementById("accordion")).accordion({change: function(event, ui){
        $(".distro_user_overlay").show();
        try{
          thetoolbox.toggle_distro_users($(ui.newHeader).find("a").html().replace(/ /g, "_"));
        }catch(err){
          thetoolbox.toggle_distro_users($(ui.oldHeader).find("a").html().replace(/ /g, "_"));
        }
      }, active: false, collapsible: true});
      this.jaxify_distro_pagination();
    }
  },

  build_distribution_view: function(json_obj)
  {
    distribution_obj = jQuery.parseJSON(json_obj.distribution_groups);
    if(document.getElementById("distribution_list")){
      distribution_list = document.getElementById("distribution_list");
    }else{
      distribution_list = document.createElement("div");
      distribution_list.setAttribute("id", "distribution_list");
    }
    if(json_obj.total_entries != 0){
      accordion_div = document.createElement("div");
      accordion_div.setAttribute("id", "accordion");

      for(i = 0; i < distribution_obj.length; i++){
        h3_element               = document.createElement("h3");
        anchor_element           = document.createElement("a");
        div_element1             = document.createElement("div");
        div_element2             = document.createElement("div");
        div_element3             = document.createElement("div");
        div_element4             = document.createElement("div");
        div_element1.className   = "accordion_user_container user_display_list "+distribution_obj[i].displayName.replace(/ /g, "_");
        div_element4.className   = "accordion_content";
        div_element2.className   = "distro_user_overlay";
        div_element3.className   = "distro_user_overlay_ajax";
        anchor_element.innerHTML = distribution_obj[i].displayName;
        anchor_element.setAttribute("href", "#");
        h3_element.appendChild(anchor_element);
        div_element2.appendChild(div_element3);
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
        if(number_of_pages != 1){
          traverse_next = document.createElement("a");
        }else{
          traverse_next = document.createElement("span");
        }
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
        dialog_confirm                    = document.createElement("div");
        dialog_confirm_p                  = document.createElement("p");
        dialog_confirm_span               = document.createElement("span");
        dialog_confirm_span_msg           = document.createElement("span");
        dialog_confirm_span.className     = "ui-icon ui-icon-alert";
        dialog_confirm_span_msg.innerHTML = "This distribution group member will be permanently deleted and cannot be recovered. Are you sure?";
        dialog_confirm.setAttribute("id", "dialog-confirm");
        dialog_confirm.setAttribute("title", "Delete Distribution Group Member?");
        dialog_confirm_p.appendChild(dialog_confirm_span);
        dialog_confirm_p.appendChild(dialog_confirm_span_msg);
        dialog_confirm.appendChild(dialog_confirm_p);
      }
      if(document.getElementById("add_to_group_form_container")){
        add_to_group_form_container = document.getElementById("dd_to_group_form_container");
      }else{
        add_to_group_form_container           = document.createElement("div");
        add_to_group_form_elem                = document.createElement("form");
        input_elem_1                          = document.createElement("input");
        input_elem_2                          = document.createElement("input");
        label_elem_1                          = document.createElement("label");
        input_elem_3                          = document.createElement("input");
        label_elem_2                          = document.createElement("label");
        input_elem_4                          = document.createElement("input");
        input_elem_5                          = document.createElement("input");
        add_to_group_form_container.className = "add_to_group_form_container";
        label_elem_1.innerHTML                = "Contact Name:";
        label_elem_2.innerHTML                = "Contact Address:";
        add_to_group_form_container.setAttribute("id", "add_to_group_form_container");
        add_to_group_form_elem.setAttribute("method", "post");
        add_to_group_form_elem.setAttribute("action", "/add_to_distribution_group");
        input_elem_1.setAttribute("type", "hidden");
        input_elem_1.setAttribute("name", "add_to_group_hidden");
        input_elem_1.setAttribute("id", "add_to_group_hidden");
        input_elem_2.setAttribute("type", "hidden");
        input_elem_2.setAttribute("name", "contact_type");
        input_elem_2.setAttribute("id", "contact_type");
        label_elem_1.setAttribute("for", "contact_name");
        input_elem_3.setAttribute("type", "text");
        input_elem_3.setAttribute("name", "contact_name");
        input_elem_3.setAttribute("id", "contact_name");
        label_elem_2.setAttribute("for", "contact_smtp_address");
        input_elem_4.setAttribute("type", "text");
        input_elem_4.setAttribute("name", "contact_smtp_address");
        input_elem_4.setAttribute("id", "contact_smtp_address");
        input_elem_5.setAttribute("type", "submit");
        input_elem_5.setAttribute("name", "commit");
        input_elem_5.setAttribute("id", "add_to_group_submit");
        input_elem_5.setAttribute("value", "Submit");
        add_to_group_form_elem.appendChild(input_elem_1);
        add_to_group_form_elem.appendChild(input_elem_2);
        add_to_group_form_elem.appendChild(label_elem_1);
        add_to_group_form_elem.appendChild(input_elem_3);
        add_to_group_form_elem.appendChild(label_elem_2);
        add_to_group_form_elem.appendChild(input_elem_4);
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
      $("#add_to_distro_internal_container form").form();
    }else{
      document.getElementById("add_to_distro_internal_container").innerHTML = "<div>There are no Distribution Groups.</div>";
    }

    return true;
  },

  add_to_group_form: function()
  {
    $("#add_to_group_form_container form #add_to_group_submit").unbind();
    $("#add_to_group_form_container form #add_to_group_submit").click(function(e){
      if(!thetoolbox.validate_add_to_group_form()){
        return false;
      }
      class_string = $("#add_to_group_hidden").val();
      class_string = class_string.replace(/ /g, "_");
      html_string  = "<div class=\"distro_user_overlay\" style=\"display:block;\">"+
                     "<div class=\"distro_user_overlay_ajax\"></div>"+
                     "Please wait while we add user."+
                     "</div><br/>" + $("."+class_string+" .accordion_content").html();
      $("."+class_string+" .accordion_content").html(html_string)
      $.ajax({
        type: "POST",
        url: "/add_to_distribution_group",
        data: {contact_name: $("#contact_name").val(), contact_smtp_address: $("#contact_smtp_address").val(), add_to_group_hidden: $("#add_to_group_hidden").val()},
        success: function() {
          $("."+class_string+" .accordion_content").load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(response, status, xhr){
            thetoolbox.toggle_distro_users(class_string)
          });
        },
        error: function(req, status, text)
        {
          alert(req.responseText);
          $("."+class_string+" .accordion_content").load("/distribution_group_users", {group_name: class_string.replace(/_/g, " ")}, function(response, status, xhr){
            thetoolbox.toggle_distro_users(class_string)
          });
        }
      });
      $("#add_to_group_form_container").dialog("close");
      return false;
    });
  },

  toggle_distro_users: function(class_string)
  {
    var argv = this.toggle_distro_users.arguments;
    if(typeof(argv[1]) != "undefined"){
      group_uri = argv[1];
    }else{
      group_uri = "/distribution_group_users";
    }

    $("."+class_string+" .accordion_content").load(group_uri, {
      group_name: class_string.replace(/_/g, " ")},
      function(response, status, xhr){
        accordion_content = this;
        $("."+class_string+" .distro_user_overlay").hide();
        $("."+class_string).height("auto");
        $(".distro_loader").css("margin-top", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
        $(".distro_loader").css("margin-bottom", Math.floor($("#accordion").height()/thetoolbox._LOADER_DIVIDE_BY - thetoolbox._DISTRO_LOADER_ADJUSTMENT )+"px");
        $("."+class_string+" .add_contact").click(function(e){
          $("#add_to_group_form_container form #add_to_group_hidden").val($(e.target).attr("rel"));
          if($("#contact_type").val() == "UserMailbox"){
            thetoolbox.add_to_group_form();
            $("#add_to_group_form_container form #add_to_group_submit").click();
          }else{
            $("#add_to_group_form_container form").each(function(){
              this.reset();
            });
            $("#add_to_group_form_container").dialog({modal: true, title: "Add to Distribution Group", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
            thetoolbox.add_to_group_form();
          }
          return false;
        });
        $("."+class_string+" .ucn_del a").click(function(e){
          $(".ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix").show();
          $("#dialog-confirm").find("p span:last").html("This distribution group member will be permanently deleted and cannot be recovered. Are you sure?");
          $("#dialog-confirm").dialog({
            resizable: false,
            height: thetoolbox._MODAL_CONFIRM_HEIGHT,
            modal: true,
            position: ['center', thetoolbox._MODAL_TOP_POSITION],
            buttons: {
              'Delete': function() {
                $(".ui-dialog-buttonpane.ui-widget-content.ui-helper-clearfix").hide();
                $(this).find("p:first").width($(this).find("p:first").width());
                $(this).find("p span:last").html("Please wait while we remove the user.<div class='distro_user_overlay_ajax'></div>");
                $("."+class_string+" .accordion_content").load("/distribution_group_users_remove",
                {group_name: class_string.replace(/_/g, " "),
                  member_alias: $(e.target).attr('rel')}, function(response, status, xhr){
                  $("#dialog-confirm").dialog('close');
                  setTimeout(function(){thetoolbox.toggle_distro_users(class_string)}, 500);
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
          try{
            thetoolbox.toggle_distro_users(class_string, $(obj.target).parent("a").attr("href"));
          }catch(err){
            thetoolbox.toggle_distro_users(class_string, $(obj.target).attr("href"));
          }
          return false;
        });
        if($("."+class_string+" .pagination").length){
          $("#add_to_distro_container").width("auto");
          $("."+class_string+" .pagination span, ."+class_string+" .pagination a").button();
          $("#add_to_distro_container").width($("#add_to_distro_container").width()+thetoolbox._DISTRO_CONTAINER_ADJUSTMENT);
        }
      }
    );
  },

  begin_cacti_login: function()
  {
    this.build_cacti_cred_form();
    $("#cacti_cred_container").dialog({modal:true, title: "Cacti Login", position: ['center', thetoolbox._MODAL_TOP_POSITION]});
  },

  build_cacti_cred_form: function()
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
    p_elem1.innerHTML     = "It seems that you have not yet taken the time to fill in your Cacti Credentials.";
    p_elem2.innerHTML     = "In order to get access to Cacti graphs, please fill in your credentials below.";
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
    this.cacti_form_events();
  },

  cacti_form_events: function()
  {
    $("#cacti_submit_button").click(function(e){
      thetoolbox.submit_cacti_login_form();
    });
    $("#cacti_user_name_cred").keypress(function(event){
      if (event.keyCode == '13') {
        thetoolbox.submit_cacti_login_form();
      }
    });
    $("#cacti_user_pass_cred").keypress(function(event){
      if (event.keyCode == '13') {
        thetoolbox.submit_cacti_login_form();
      }
    });
    $("#cacti_cred_container").form();
  },

  submit_cacti_login_form: function()
  {
    $.ajax({
      type: "POST",
      url: 'users/cacti_save',
      data: {cacti_username: $("#cacti_user_name_cred").val(), cacti_password: $("#cacti_user_pass_cred").val()},
      success: function(data, textStatus) {
        thetoolbox.cacti_login();
        $("#cacti_cred_container").dialog("close");
        $("#cacti_graphs_link").show();
      },
      error: function(data){
        alert("Please enter a valid username and password.")
      }
    });
  },

  cacti_login: function()
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
    this.cacti_set_login();
  },

  cacti_set_login: function()
  {
    $.ajax({
      url: '/users/cacti_log_in',
      success: function(data, textStatus, XMLHttpRequest){
        if(textStatus == "success"){

        }else{
          alert("The Cacti service is currently down.  Please contact your administrator.");
        }
      }
    });
  },

  cacti_log_out: function()
  {
    $.ajax({
      url: '/users/cacti_log_out',
      success: function(data, textStatus, XMLHttpRequest){
        if(textStatus == "success"){
          thetoolbox.toolbox_log_out();
        }else{

        }
      }
    });
  },

  toolbox_log_out: function()
  {
    window.location = "/user_sessions/destroy";
  },

  write_to_full_name: function()
  {
    $("#user_full_name").val($("#user_first_name").val() + " " + $("#user_last_name").val());
  },

  write_to_full_vpn_name: function()
  {
    $("#user_vpn_full_name").val($("#user_vpn_first_name").val() + " " + $("#user_vpn_last_name").val());
  },

  validate_pass_form: function(user_handle,user_names)
  {
    if($('#ldap_user_new_password').val() == '' || $('#ldap_user_confirm_password').val() == ''){
      alert("Please make sure that both fields are not empty.");
      return false;
    }
    if($('#ldap_user_new_password').val() != $('#ldap_user_confirm_password').val()){
      alert("Please make sure that both passwords match.");
      return false;
    }
    if($('#ldap_user_new_password').val().toLowerCase().indexOf(user_handle.toLowerCase()) != -1){
      alert("Please make sure your password does not contain your login name.");
      return false;
    }

    pass_valid = true
    $.each(user_names.split(" "), function(index, value){
      if($('#ldap_user_new_password').val().toLowerCase().indexOf(value.toLowerCase()) != -1){
        alert("Please make sure your password does not contain part of your first or last name.");
        pass_valid = false
        return false;
      }
    });
    if(!pass_valid) return false;

    pass_valid = this.validate_password($('#ldap_user_new_password').val());
    if(pass_valid.length != 0){
      alert(pass_valid);
      return false;
    }
    return true;
  },

  validate_create_user_form: function()
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
    if($("#user_logon_name").val().length > thetoolbox._LOGIN_LENGTH){
      error_list += "- Please make sure your logon name is equal to or less than 20 characters.\t\n";
    }
    if($("#user_password").val() == ''){
      error_list += "- Please enter a valid password.\t\n";
    }
    if($("#user_confirm_password").val() == '' || ($("#user_password").val() != $("#user_confirm_password").val())){
      error_list += "- Please confirm password.\t\n";
    }
    if($('#user_password').val().toLowerCase().indexOf($("#user_logon_name").val().toLowerCase()) != -1){
      error_list += "Please make sure your password does not contain your login name.";
    }
    $.each($("#user_full_name").val().split(" "), function(index, value){
      if($('#user_password').val().toLowerCase().indexOf(value.toLowerCase()) != -1){
        error_list += "Please make sure your password does not contain part of your first or last name.";
        return false;
      }
    });
    pass_valid = this.validate_password($("#user_password").val());
    if(pass_valid.length != 0){
      error_list += "- "+pass_valid+"\t\n";
    }
    if(error_list != ''){
      alert("Please correct the following items and try again.\t\n"+error_list);
      return false;
    }
    return true;
  },

  validate_create_vpn_user_form: function()
  {
    var error_list = '';
    if($("#user_vpn_first_name").val() == ''){
      error_list += "- Please enter a first name.\t\n";
    }
    if($("#user_vpn_last_name").val() == ''){
      error_list += "- Please enter a last name.\t\n";
    }
    if($("#user_vpn_full_name").val() == ''){
      error_list += "- Please enter a full name.\t\n";
    }
    if($("#user_vpn_logon_name").val() == ''){
      error_list += "- Please enter a logon name.\t\n";
    }
    if($("#user_vpn_logon_name").val().length > thetoolbox._VPN_LOGIN_LENGTH){
      error_list += "- Please make sure your logon name is equal to or less than 16 characters.\t\n";
    }
    if($("#user_vpn_password").val() == ''){
      error_list += "- Please enter a valid password.\t\n";
    }
    if($("#user_vpn_confirm_password").val() == '' || ($("#user_vpn_password").val() != $("#user_vpn_confirm_password").val())){
      error_list += "- Please confirm password.\t\n";
    }
    if($('#user_vpn_password').val().toLowerCase().indexOf($("#user_vpn_logon_name").val().toLowerCase()) != -1){
      error_list += "Please make sure your password does not contain your login name.";
    }
    $.each($("#user_vpn_full_name").val().split(" "), function(index, value){
      if($('#user_vpn_password').val().toLowerCase().indexOf(value.toLowerCase()) != -1){
        error_list += "Please make sure your password does not contain part of your first or last name.";
        return false;
      }
    });
    pass_valid = this.validate_password($("#user_vpn_password").val());
    if(pass_valid.length != 0){
      error_list += pass_valid+"\t\n";
    }
    if(error_list != ''){
      alert("Please correct the following items and try again.\t\n"+error_list);
      return false;
    }
    return true;
  },

  validate_add_to_group_form: function()
  {
    var error_list           = '';
    var contact_name         = $.trim($("#contact_name").val());
    var contact_smtp_address = $.trim($("#contact_smtp_address").val());
    if(contact_name == '' || contact_name <= 2){
      error_list += "- Please enter a valid contact name.\t\n";
    }
    if (contact_smtp_address == '' || !this._EMAIL_FILTER.test(contact_smtp_address)) {
      error_list += "- Please provide a valid email address.\t\n";
    }
    if(error_list != ''){
      alert("Please correct the following items and try again.\t\n"+error_list);
      return false;
    }
    return true;
  },

  validate_password: function(value){
    var password_check_requirement = 0;
    var msg = '';
    if(value.length < this._PASSWORD_LENGTH){
      msg += "- Please make sure that your password is at least eight characters in length.\t\n";
    }
    if(this._PASSWORD_FILTER_ALPHA_LOWER.test(value)){
      password_check_requirement++;
    }
    if(this._PASSWORD_FILTER_ALPHA_UPPER.test(value)){
      password_check_requirement++;
    }
    if(this._PASSWORD_FILTER_CHAR.test(value)){
      password_check_requirement++;
    }
    if(this._PASSWORD_FILTER_NUMERIC.test(value)){
      password_check_requirement++;
    }
    if(password_check_requirement <= 2){
      msg += "The password did not meet password complexity requirements. Please make sure that your password contains "+
            "at least three of the following requirements:\t\n one upper-case letter, one lower-case letter, one number, and one special character.";
    }
    return msg;
  },

  display_msg: function(msg_type, msg)
  {
    $("div.flash").html("<p class='"+msg_type+"'>"+msg+"</p>");
  }

};

$(document).ready(function() {
  thetoolbox.toolBoxInit();
});
class DistributionGroupController < ApplicationController

  def index
    user = User.find_by_login(current_user[:login])
    if user.is_admin?
      options            = {}
      options[:page]     = params[:page] || 1
      options[:per_page] = params[:per_page] || 5
      @distribution_results = DistributionGroup.find(:all)
      @distribution_results.each do |f|
        f.attributes.delete("xmlns:i")
        f.attributes.delete("error")
        f.attributes.delete("xmlns")
      end
      render :partial => "users/add_to_distribution"
    else
      redirect_to user_path(current_user)
    end
  end
  
  def create_distribution_group
    unless params[:ldap_user][:distribution_list_name].blank?
      begin
        g = DistributionGroup.new
        g.group_name = params[:ldap_user][:distribution_list_name]
        g.ou = current_user.ou
        g.save
        flash[:completed] = "Distribution Group created successfully."
      rescue Exception => exc
        flash[:error] = "Unable to create distribution group, please contact your administrator. Error: #{exc.message}"
      end
    end
    redirect_to users_path
  end

  def add
    unless params[:contact_name].blank?
      begin
        unless params[:contact_type].blank?
          e = ExchangeUser.find(params[:contact_name])         
        else
          e = ExchangeUser.new :cn => params[:contact_name], :alias => params[:contact_name].gsub(" ", ""), :type => "MailContact", :ou => current_user.ou, :email => params[:contact_smtp_address]
        end
        d = DistributionGroup.find(params[:add_to_group_hidden])
        d.ExchangeUsers.push(e)
        d.update
        flash[:completed] = "Contact Added Successfully. "
      rescue
        flash[:error] = "Unable to add contact, please contact your administrator. "
      end
    end
    redirect_to users_path
  end

  def get_distribution_group
    begin
        
    rescue

    end
  end

end
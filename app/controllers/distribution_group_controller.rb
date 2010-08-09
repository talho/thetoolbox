class DistributionGroupController < ApplicationController

  def index
    user = User.find_by_login(current_user[:login])
    if user.is_admin?
      options            = {}
      options[:page]     = params[:page] || 1
      options[:per_page] = params[:per_page] || 5
      @distribution_results = DistributionGroup.find(:all, :params => options)
      
#      respond_to do |format|
#        #format.html {render :partial => "users/add_to_distribution"}
#        format.json {render :json => @distribution_results}
#      end
#      #render :partial => "users/add_to_distribution"
#      #render :json => @distribution_results
      render :json => {
        :distribution_groups => @distribution_results.to_json(),
        :current_page        => @distribution_results.current_page,
        :per_page            => @distribution_results.per_page,
        :total_entries       => @distribution_results.total_entries
      }
    else
      redirect_to user_path(current_user)
    end
  end
  
  def create_distribution_group
    unless params[:distribution_group][:distribution_list_name].blank?
      begin
        g = DistributionGroup.new
        g.group_name = params[:distribution_group][:distribution_list_name]
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
    if validate_params
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
          render :text => "Contact Added Successfully" #redirect_to users_path
        rescue ActiveResource::ResourceConflict
          render :text => "A contact with name " + params[:contact_name] + " with a different email was found on the server. Please provide a unique contact name.", :status => 409
        rescue Exception => e
          render :text => "An unknown error occurred, please contact your administrator" #flash[:error] = "Unable to add contact, please contact your administrator. "
        end
      end
    else
      render :text => flash[:error]
    end
  end

  def users
    if !params[:group_name].blank?
      @distribution_results = DistributionGroup.find(params[:group_name])
      render :partial => "users/distribution_group_users"
    else
      flash[:error] = "Invalid group name."
    end
  end

  def remove_user
    if !params[:group_name].blank?
      @distribution_results = DistributionGroup.find(params[:group_name])
      @distribution_results.ExchangeUsers.delete_if{|e| e.alias == params[:member_alias]}
      @distribution_results.update
      render :partial => "users/distribution_group_users"
    else
      flash[:error] = "Invalid group name."
    end
  end

  def delete
    begin
      group = DistributionGroup.find(params[:distribution_group_name])
      group.delete
      flash[:completed] = "Distribution Group Removed."  
    rescue
      flash[:error] = "Unable to delete Distribution Group, please contact your administrator."
    end
  end
  

  protected

  def validate_params
    errors = ''
    params[:contact_name].strip!
    params[:contact_smtp_address].strip! 
    if params[:contact_name].blank?
      errors = errors + "- Please enter a valid Contact Name.<br/>"
    end
    if params[:contact_smtp_address].blank?
      errors = errors + "- Please enter a valid email address.<br/>"
    end
    if !errors.blank?
      flash[:error] = "Please correct the following items:<br/>"+errors
      return false
    end
    return true
  end
end
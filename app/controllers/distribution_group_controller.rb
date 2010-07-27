class DistributionGroupController < ApplicationController

  def create_distribution_group
    unless params[:ldap_user][:distribution_list_name].blank?
      begin
        g = DistributionGroup.new
        g.group_name = params[:ldap_user][:distribution_list_name]
        g.ou = current_user.ou
        g.create_group()
        flash[:completed] = "Distribution Group created successfully."
      rescue
        flash[:error] = "Unable to create distribution group, please contact your administrator."
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
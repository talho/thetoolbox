class WhiteListsController < ApplicationController

  def index
    unless current_user.email.blank?
      options = {:page => params[:user_page] || 1, :per_page => 10, :scope => "Domain"}
      options[:user] = current_user.email

      @personal_white_lists = WhiteList.find(:all, :params => options)
      options.delete("user")
      if current_user.is_admin?
        options[:domain] = domainize(current_user.email)
        options[:page] = params[:domain_page] || 1
        @domain_white_lists = WhiteList.find(:all, :params => options)
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @white_lists }
      end
    else
      flash[:error] = "You do not have access to this record or there was an error processing your request."
    end
  end

  def show
    
  end

  def create
    pref = nil
    unless (params[:wl_domain].blank? && params[:wl_email].blank?) || current_user.email.blank?
      if !params[:wl_domain].blank? && !params[:wl_domain][:domain].blank?
        begin
          username = ((!params[:wl_domain][:chck_global].blank? && params[:wl_domain][:chck_global] == "1") && current_user.is_admin?) ? domainize(current_user.email) : current_user.email
          pref = WhiteList.create :username => username, :value => params[:wl_domain][:domain]
          flash[:notice] = "Domain added to White List"
        rescue
          flash[:error] = "Unable to add white list entry."
        end
      elsif !params[:wl_email].blank? && !params[:wl_email][:email].blank?
        begin
          username = ((!params[:wl_email][:chck_global].blank? && params[:wl_email][:chck_global] == "1") && current_user.is_admin?) ? domainize(current_user.email) : current_user.email
          pref = WhiteList.create :username => username, :value => params[:wl_email][:email]
          flash[:notice] = "Email added to White List"
        rescue
          flash[:error] = "Unable to add white list entry."
        end
      else
        flash[:error] = "You do not have access to this record or there was an error processing your request."
      end
    end
    redirect_to white_lists_path
  end

  def destroy
    unless params[:id].blank?
      white_list = WhiteList.find(params[:id])
      white_list.destroy
      flash[:notice] = "Entry Deleted"
    else
      flash[:error] = "You do not have access to this record or there was an error processing your request."
    end
    redirect_to white_lists_path
  end

  def domainize(email)
    email.split('@').last
  end
end

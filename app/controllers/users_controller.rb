class UsersController < ApplicationController
  def index
    #@return_results = User.ous
  end
  
  def show
    #user_ou = Hash[*current_user[:dn].scan(/(.*)=(.*),/).to_a.flatten]
    lines = current_user[:dn].split(",")
    user_ou = Hash.new
    user = User.find_by_login(current_user[:login])
    lines.each{|i| user_ou[i.split("=")[0]] = i.split("=")[1]}
    if user.is_admin?
      @return_results = User.ous(user_ou['OU'])
    else
      @return_results = false
    end
  end
end
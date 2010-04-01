class UsersController < ApplicationController
  def index
    @return_results = User.ous
  end
  
  def show
    #@return_results = User.get_from_ldap(current_user[:login])
    user_ou = Hash[*current_user[:dn].scan(/(.*)=(.*),/).to_a.flatten]
    #user_ou = current_user[:dn].split(",")

    lines = current_user[:dn].split(",")
    user_ou = Hash.new
    lines.each{|i| user_ou[i.split("=")[0]] = i.split("=")[1]}

    @return_results = User.ous(user_ou['OU'])

  end
end
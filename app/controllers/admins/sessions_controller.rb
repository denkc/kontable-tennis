class Admins::SessionsController < Devise::OmniauthCallbacksController

  def callback
    email = request.env['omniauth.auth'].info.to_hash['email'].downcase
    if email =~ /@kontagent.com\Z/
      @admin = Admin.find_or_create_by_email(email)
      @admin.ensure_authentication_token!
      sign_in @admin

      flash.notice = "Authorized as #{email}"
    else
      flash.alert = "#{email} not authorized!"
    end
    redirect_to request.env['omniauth.origin'] || root_path
  end

end

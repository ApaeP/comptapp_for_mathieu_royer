class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :validate_profile_complete, unless: :authorized_pages_for_incomplete_users

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: user_params)
    devise_parameter_sanitizer.permit(:account_update, keys: user_params)
    devise_parameter_sanitizer.permit(:sign_in, keys: user_params)
    devise_parameter_sanitizer.permit(:accept_invitation, keys: user_params)
  end

  def user_params
    %i[ first_name last_name provider uid github_name avatar_url business_name business_address business_country siret logo iban bic ].freeze
  end

  def validate_profile_complete
    return if %i[ first_name last_name business_address business_country siret iban bic ].all? { |e| current_user.send e }

    redirect_to root_path, alert: "Profil incomplet <a href=\"#{edit_user_registration_path}\" class=\"btn btn-gray\">Compléter</a>"
  end

  def authorized_pages_for_incomplete_users
    devise_controller? ||
    (controller_name == 'pages' && authorized_actions_for_incomplete_users.include?(action_name)) ||
    params[:controller] =~ /(public$)/
  end

  def authorized_actions_for_incomplete_users
    %w[ home ]
  end

end

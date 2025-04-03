class Api::V1::BaseController < ActionController::API
  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: :not_found
  end

protected

  def authenticate_sender!
    setting = GithubAppSetting.where(key: "app_id").take

    if setting.nil?
      raise_404("There is no record with key='app_id' in the 'github_app_settings' table! Please insert it first.")
    end

    if request.headers["X-GitHub-Hook-Installation-Target-ID"] != setting.value
      raise_404("The 'app_id' value is not equal to the value of request header 'X-GitHub-Hook-Installation-Target-ID'. They should be the same！")
    end

    if request.headers["X-GitHub-Event"] != "push"
      raise_404("The system only handles GitHub 'push' events!")
    end
  end

  def raise_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end
end

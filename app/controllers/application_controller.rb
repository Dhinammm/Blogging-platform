class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  def not_found_method
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: true
  end
end

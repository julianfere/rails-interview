class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end

  private

  def toast_stream(message, type: :success)
    turbo_stream.append("toast_container",
      partial: "shared/toast",
      locals: { message: message, type: type })
  end
end

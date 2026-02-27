class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale

  rescue_from ActionController::UnknownFormat, with: :raise_not_found

  def raise_not_found
    raise ActionController::RoutingError.new('Not supported format')
  end

  private

  def set_locale
    locale = extract_locale_from_params || extract_locale_from_accept_language_header
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def extract_locale_from_params
    locale = params[:locale]&.to_sym
    I18n.available_locales.include?(locale) ? locale : nil
  end

  def extract_locale_from_accept_language_header
    header = request.env['HTTP_ACCEPT_LANGUAGE']
    return nil if header.blank?

    header.scan(/([a-zA-Z]{2})(?:-[a-zA-Z0-9]+)*(?:;q=([\d.]+))?/)
          .map  { |lang, q| [lang.downcase.to_sym, (q || "1").to_f] }
          .sort_by { |_, q| -q }
          .find { |lang, _| I18n.available_locales.include?(lang) }
          &.first
  end

  def toast_stream(message, type: :success)
    turbo_stream.append("toast_container",
      partial: "shared/toast",
      locals: { message: message, type: type })
  end
end

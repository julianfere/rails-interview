class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  around_enqueue do |job, block|
    job.locale = I18n.locale
    block.call
  end

  around_perform do |job, block|
    I18n.with_locale(job.locale) { block.call }
  end

  attr_accessor :locale
end

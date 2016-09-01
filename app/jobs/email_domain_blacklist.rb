class EmailDomainBlacklistJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.update(actived: false)
  end
end
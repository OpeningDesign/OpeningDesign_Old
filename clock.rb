require 'clockwork'
require 'stalker'

module Clockwork
  handler { |job| Stalker.enqueue(job) }
  every 30.minutes, 'digest-email.prepare-and-send'
  every 5.minutes, 'node.update-popularity-scores'
  every 15.seconds, 'node.update-images'
end

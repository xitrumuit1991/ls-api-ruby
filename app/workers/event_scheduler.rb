class EventScheduler
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { daily.hour_of_day(2).minute_of_hour(20) }
	def perform()
		Schedule.destroy_all("end < '#{DateTime.now}'")
	end
end
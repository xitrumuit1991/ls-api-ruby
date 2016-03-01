class EventScheduler
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { daily(1).hour_of_day(2) }
	def perform()
		Schedule.destroy_all("end < '#{DateTime.now}'")
	end
end
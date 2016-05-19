class Acp::IndexController < Acp::ApplicationController
	# load_and_authorize_resource :class => Index
	def index
		# @cards = Card.all
  	# authorize! :index, @cards
		# puts '==================='
		# puts root_url


		# controllers = Dir.new("#{Rails.root}/app/controllers/acp").entries
  #   controllers.each do |controller|
  #     if controller =~ /_controller/
  #       foo_bar = controller.camelize.gsub(".rb","")
  #     	puts '==================='
  #     	puts foo_bar
  #     end
  #   end
  # 	puts '==================='

		

		Acp::ApplicationController.subclasses.each do |controller|
			controller.action_methods.each do |action|
    #     puts '==================='
				# puts action
				# puts '==================='
      end
      puts '==================='
			puts controller
			puts '==================='
    end


	end
end
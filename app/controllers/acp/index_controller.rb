class Acp::IndexController < Acp::ApplicationController

	def index
		# write_resource("Manage All", "Manage All", "all", "all", "manage")
    controllers = Dir.new("#{Rails.root}/app/controllers/acp").entries
    controllers.each do |controller|
      if controller =~ /_controller/
        class_name = "Acp::#{controller.camelize.gsub(".rb","")}".classify.constantize
        # class_name = controller.camelize.gsub(".rb","").classify
        next if class_name.controller_name == 'application'
        puts '================'
        puts class_name.controller_name.classify
        puts class_name.controller_name.classify.constantize rescue nil
        puts '================'
        # class_name.action_methods.each do |action|
        #   name = action
        #   description = action
        #   controller_name = class_name.controller_name
        #   action_name = action
        #   can = eval_cancan_action(action)
        #   write_resource(name, description, controller_name, action_name, can)
        # end
      end
    end
	end

end
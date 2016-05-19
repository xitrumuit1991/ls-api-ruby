class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    puts '++++++++++++=adeasd'
    user ||= Admin.new # guest user (not logged in)
    if user.id == 3
      can :manage, :all
      # can :read, :all
      # can :update, Room
      # can :create, Gift
    else
      can :read, :all
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    # can do |action, subject_class, subject|
    #   user.permissions.find_all_by_action(aliases_for_action(action)).any? do |permission|
    #     permission.subject_class == subject_class.to_s && (subject.nil? || permission.subject_id.nil? || permission.subject_id == subject.id)
    #   end
    # end    

  end

  def setup_actions_controllers_db
    write_permission("all", "manage", "Everything", "All operations", true)

    controllers = Dir.new("#{Rails.root}/app/controllers").entries
    controllers.each do |controller|
      if controller =~ /_controller/
        foo_bar = controller.camelize.gsub(".rb","").constantize.new
      end
    end
    # You can change ApplicationController for a super-class used by your restricted controllers
    ApplicationController.subclasses.each do |controller|
      if controller.respond_to?(:permission)  
        clazz, description = controller.permission
        write_permission(clazz, "manage", description, "All operations")
        controller.action_methods.each do |action|
          if action.to_s.index("_callback").nil?
            action_desc, cancan_action = eval_cancan_action(action)
            write_permission(clazz, cancan_action, description, action_desc)
          end
        end
      end
    end

  end


  def eval_cancan_action(action)
    case action.to_s
    when "index", "show", "search"
      cancan_action = "read"
      action_desc = I18n.t :read
    when "create", "new"
      cancan_action = "create"
      action_desc = I18n.t :create
    when "edit", "update"
      cancan_action = "update"
      action_desc = I18n.t :edit
    when "delete", "destroy"
      cancan_action = "delete"
      action_desc = I18n.t :delete
    else
      cancan_action = action.to_s
      action_desc = "Other: " << cancan_action
    end
    return action_desc, cancan_action
  end

  def write_permission(class_name, cancan_action, name, description, force_id_1 = false)
    permission  = Permission.find(:first, :conditions => ["subject_class = ? and action = ?", class_name, cancan_action]) 
    if not permission
      permission = Permission.new
      permission.id = 1 if force_id_1
      permission.subject_class =  class_name
      permission.action = cancan_action
      permission.name = name
      permission.description = description
      permission.save
    else
      permission.name = name
      permission.description = description
      permission.save
    end
  end

end

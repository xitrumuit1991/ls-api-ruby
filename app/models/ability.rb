class Ability
  include CanCan::Ability

  def initialize(admin)
    # Define abilities for the passed in user here. For example:
    admin ||= Admin.new # guest user (not logged in)
    can :manage, :all

    # admin.role.acls.each do |acl|
    #   if acl.resource.class_name == 'all'
    #     can :manage, :all
    #     break
    #   else
    #     model = acl.resource.class_name.constantize rescue nil
    #     if model.nil?
    #       can acl.resource.can.to_sym, acl.resource.class_name.downcase.to_sym
    #     else
    #       can acl.resource.can.to_sym, acl.resource.class_name.constantize
    #     end
    #   end
    # end
  end

end

class Ability
  include CanCan::Ability

  def initialize(admin)
    # Define abilities for the passed in user here. For example:
    admin ||= Admin.new # guest user (not logged in)

    admin.role.acls.each do |acl|
      if acl.resource.controller == 'all'
        can :manage, :all
      else
        can acl.resource.can.to_sym, acl.resource.controller.classify.constantize
      end
    end
  end

end

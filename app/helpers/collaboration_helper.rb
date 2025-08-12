module CollaborationHelper
  def collaborator_role_options
    Collaboration::Collaborator.roles.map do |_, value|
      [ value.humanize, value ]
    end
  end
end

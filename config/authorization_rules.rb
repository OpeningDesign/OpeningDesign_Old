authorization do

  role :anonymous do
    has_permission_on [ :nodes, :projects, :documents, :document_versions, :sketchspaces ] do
      to :index, :show, :download
      if_attribute :is_open_source => is { true }
    end
    has_permission_on [ :sketchspaces ] do
      to :authorized, :cloned, :submitted
    end
  end

  role :user do
    has_permission_on [ :sketchspaces ] do
      to :authorized, :cloned, :submitted
    end
    has_permission_on [ :nodes, :projects, :documents, :document_versions, :sketchspaces ] do
      to :delete, :edit, :index, :show, :update, :destroy, :download, :upload, :subscribe, :unsubscribe, :move, :submitmove, :delete_tag
      if_attribute :collaborating_users => contains { user }
      if_attribute :is_open_source => is { true }
    end
    has_permission_on [ :nodes, :projects, :documents, :document_versions, :sketchspaces ] do
      to :new, :create
    end
  end

  role :operator do
    has_permission_on :authorization_rules, :to => :read
  end

end

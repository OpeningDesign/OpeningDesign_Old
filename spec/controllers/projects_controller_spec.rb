require 'spec_helper'

describe ProjectsController do

  before(:each) do
    Authorization.ignore_access_control(true)
  end

  include SocialActivityHelpers

  def valid_attributes
    FactoryGirl.attributes_for(:project)
  end

  describe "when not signed in, certain actions" do
    it "redirect to the sign in" do
      subjects =
        lambda { get :new },
        lambda { post :create },
        lambda { get :edit, :id => FactoryGirl.create(:project).id },
        lambda { delete :destroy, :id => FactoryGirl.create(:project).id }
      subjects.each do |subject|
        subject.call.should redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET index" do
    it "assigns all projects as @projects" do
      project = FactoryGirl.create(:project)
      get :index
      assigns(:projects).should eq([project])
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = FactoryGirl.create(:project)
      get :show, :id => project.id.to_s
      assigns(:project).should eq(project)
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    describe "GET new" do
      it "assigns a new project as @project" do
        get :new
        response.should be_success
        assigns(:project).should be_a_new(Project)
      end
      describe "when there is a parent" do
        before(:each) do
          @parent = FactoryGirl.create(:project, :owner_id => @user.id)
        end
        it "assigns the parent to the new project" do
          get :new, :node_id => @parent.id
          response.should be_success
          assigns(:project).should be_a_new(Project)
          assigns(:project).parent.should eq(@parent)
        end
      end
    end

    describe "and user created a project" do
      before(:each) do
        user_signs_in_and_creates_project
      end
      describe "GET edit" do
        it "assigns the requested project as @project" do
          get :edit, :id => @project.id.to_s
          assigns(:project).should eq(@project)
        end
      end
      describe "PUT update" do
        describe "with valid params" do
          it "updates the requested project" do
            Project.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => @project.id, :project => {'these' => 'params'}
          end

          it "assigns the requested project as @project" do
            put :update, :id => @project.id, :project => valid_attributes
            assigns(:project).should eq(@project)
          end

          it "redirects to the project" do
            put :update, :id => @project.id, :project => valid_attributes
            response.should redirect_to(@project)
          end
        end

        describe "with invalid params" do
          it "assigns the project as @project" do
            # Trigger the behavior that occurs when invalid params are submitted
            Project.any_instance.stub(:save).and_return(false)
            put :update, :id => @project.id.to_s, :project => {}
            assigns(:project).should eq(@project)
          end

          it "re-renders the 'edit' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Project.any_instance.stub(:save).and_return(false)
            put :update, :id => @project.id.to_s, :project => {}
            response.should render_template("edit")
          end
        end

        describe "when user is not the owner" do
          it "fails if another user tries to access the project" do
            sign_in FactoryGirl.create(:user) # signs in a different user, i.e. not the owner of 'project'
            expect {
              put :update, :id => @project.id.to_s
            }.to raise_exception
          end
          it "prohibits the user deleting the project" do
            sign_in FactoryGirl.create(:user) # signs in a different user
            expect {
              delete :destroy, id: @project.id.to_s
            }.to raise_exception
          end
        end
      end
      describe "DELETE destroy" do
        it "destroys the requested project" do
          expect {
            delete :destroy, :id => @project.id.to_s
          }.to change(Project, :count).by(-1)
        end

        it "redirects to the projects list" do
          delete :destroy, :id => @project.id.to_s
          response.should redirect_to(projects_url)
        end
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Project" do
          expect {
            post :create, :project => valid_attributes
          }.to change(Project, :count).by(1)
        end
        describe "when there is a parent" do
          before(:each) do
            @parent = FactoryGirl.create(:project, :owner_id => @user.id)
          end
          it "creates project as a sub project" do
            expect {
              post :create, :project => valid_attributes.merge(:parent_id => @parent.id)
              assigns(:project).parent.should eq(@parent)
            }.to change(Project, :count).by(1)
          end
        end

        it "assigns a newly created project as @project" do
          post :create, :project => valid_attributes
          assigns(:project).should be_a(Project)
          assigns(:project).should be_persisted
        end

        it "redirects to the created project" do
          post :create, :project => valid_attributes
          response.should redirect_to(Project.last)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved project as @project" do
          # Trigger the behavior that occurs when invalid params are submitted
          Project.any_instance.stub(:save).and_return(false)
          post :create, :project => {}
          assigns(:project).should be_a_new(Project)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Project.any_instance.stub(:save).and_return(false)
          post :create, :project => {}
          response.should render_template("new")
        end
      end
    end

  end

  describe "generates social activities" do
    before(:each) do
      @project = FactoryGirl.create(:project)
      Activities.instance.connect_to(@project) # TODO: a bit ugly: this is
      # normally done via the controller's create, couldn't the factory do it
      # for us?
      @owner = @project.owner
      sign_in @owner
    end
    let(:project) { @project }
    let(:owner) { @owner }
    describe "for everyone" do
      it "ensures activities for project updates" do
        Activities.clear
        Activities.aggregated.count.should eq(0)
        put :update, :id => project.id, :project => valid_attributes
        Activities.aggregated.count.should eq(1)
        a = Activities.aggregated[0]
        a.should equal_social_activity( target: assigns(:project), subject: @owner, verb: 'updates')
      end
      it "ensures activities for new projects" do
        Activities.clear
        post :create, :project => valid_attributes
        Activities.aggregated.count.should eq(1)
        a = Activities.aggregated[0]
        a.should equal_social_activity( target: assigns(:project), subject: @owner, verb: 'creates')
      end
    end
    describe "for those connected to the project" do
      before(:each) do
        @ben = FactoryGirl.create(:user, first_name: 'Ben')
        @ben.connect_to(@project)
        SocialConnections.aggregate(@ben).activities.each {|a| a.consume }
      end
      it "creates activities for project updates" do
        post :update, :id => @project.id, :project => valid_attributes
        feed = SocialConnections.aggregate(@ben)
        feed.activities.count.should eq(1)
        a = feed.activities[0]
        a.should equal_social_activity( target: assigns(:project), subject: @owner, verb: 'updates')
      end
    end
    describe "for those connected to the creator of a project" do
      let!(:mark) do
        mark = FactoryGirl.create(:user, first_name: 'Mark')
        mark.connect_to(@owner) # remember that the owner is signed in...
        SocialConnections.aggregate(mark).activities.each {|a| a.consume }
        mark
      end
      it "creates activities when new project created" do
        post :create, :project => valid_attributes
        SocialConnections.aggregate(mark).activities.count.should eq(1)
        a = SocialConnections.aggregate(mark).activities[0]
        a.should equal_social_activity( target: assigns(:project), subject: @owner, verb: 'creates')
      end
      describe "activities when project updated" do
        before(:each) do
          post :update, :id => @project.id, :project => valid_attributes
        end
        it "creates an activity for Mark" do
          SocialConnections.aggregate(mark).activities.count.should eq(1)
          a = SocialConnections.aggregate(mark).activities[0]
          a.should equal_social_activity(target: assigns(:project), subject: @owner, verb: 'updates')
        end
      end
#     describe "activities when child of project updated" do # TODO: this 'describe' should go, it's double to the next one
#       before(:each) do
#         @child_of_project = FactoryGirl.create(:project,
#                                                :description => "child of project",
#                                                :parent => @project,
#                                                :owner => @owner)
#         mark.disconnect_from(@owner) # otherwise mark gets an activity bec. connected to owner
#         mark.connect_to(@project)
#         post :update, :id => @child_of_project, :project => valid_attributes
#       end
#       it "creates an activity for Mark, too" do
#         activities = SocialConnections.aggregate(mark).activities
#         activities.count.should eq(1)
#       end
#     end
    end
    describe "for those connected to the parent of a node" do
      before(:each) do
        @child_of_project = FactoryGirl.create(:project,
                                              :description => "project with parent",
                                              :parent => @project,
                                              :owner => @owner)
        @niel = FactoryGirl.create(:user, :first_name => 'Niel')
        @niel.connect_to(@project)
        SocialConnections.aggregate(@niel).activities.each {|a| a.consume }
      end
      describe "when changing the child" do
        it "generates an activity for Niel, who is connected to the parent project" do
          post :update, :id => @child_of_project, :project => valid_attributes
          activities = SocialConnections.aggregate(@niel).activities
          activities.count.should eq(1)
          activities[0].subject.to_param.should eq(@owner.to_param)
          activities[0].target.to_param.should eq(@child_of_project.to_param)
        end
      end

    end

    describe "for those not connected to the project" do
      let!(:ben) {
        ben = FactoryGirl.create(:user, first_name: 'Ben')
        SocialConnections.aggregate(ben).activities.each {|a| a.consume }
        ben
      }

      it "does not create activities for project being created" do
        post :create, :project => valid_attributes
        SocialConnections.aggregate(ben).activities.count.should eq(0)
      end
      it "does not create activities for project being updated" do
        post :update, :id => @project.id, :project => valid_attributes
        SocialConnections.aggregate(ben).activities.count.should eq(0)
      end
    end
  end
end

describe ProjectsController do

  describe "when user is anonymous" do
    it "then is prohibited to create a project" do
      expect {
        post :create, :project => FactoryGirl.attributes_for(:project)
      }.to change(Project, :count).by(0)
    end
  end

end


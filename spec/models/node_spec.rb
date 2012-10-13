require 'spec_helper'

describe Node do

  def build(&block)
    node = FactoryGirl.create(:node)
    block.call(node) if block_given?
    node
  end

  it "has no children by default" do
    node = FactoryGirl.create(:node)
    node.children.size.should eq(0)
  end

  it "can have many children, many levels deep" do
    node = build do |parent|
      parent.children << build
      parent.children << build do |parent|
        3.times {parent.children << build}
      end
    end
    node.children.size.should eq(2)
    node.children[0].children.size.should eq(0)
    node.children[1].children.size.should eq(3)
  end

  describe "when signed in" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "creates a document (and a version) when uploading" do
      pending "we should do this via a controller spec, rather"
      node = FactoryGirl.create(:node)
      params = FactoryGirl.attributes_for(:uploadable_document_version)
      document = node.upload_document_by_user(@user, node, params)
      document.name.should eq(params[:content]["original_filename"])
      document.version.should eq(1)
      document.children.size.should eq(1)
    end

    it "does not set a version for the document itself" do
      pending "uploading probably won't work in model spec, rather use controller spec"
      node = FactoryGirl.create(:node)
      document = node.upload_document_by_user(@user, node, FactoryGirl.attributes_for(:uploadable_document_version))
      document[:version].should eq(nil)
    end

    describe "when uploading a document on an existing document" do
      before(:each) do
        if false # TODO: Disabled
          node = FactoryGirl.create(:node)
          # two files to upload
          @uploadables = (1..2).reduce([]) { |a,i|
            a << FactoryGirl.attributes_for(:uploadable_document_version)
            class << a[-1]
              def name
                self[:content]["original_filename"]
              end
            end
            a
          }
          # first upload creates the document
          @document = node.upload_document_by_user(@user, node, @uploadables[0])
          # second upload creates a second version
          @second_version = @document.upload_document_by_user(@user, @document, @uploadables[1])
          # the first version is supposed to be the last child
          @first_version = @document.children_ordered.last
        end
      end

      it "creates a new document version with the uploaded name,
      and the old version keeps the old name" do
        pending "probably cannot spec upload in model spec?"
        @first_version.version.should eq(1)
        @second_version.version.should eq(2)
        @document.version.should eq(2)
        @second_version.name.should eq(@uploadables[1].name)
        @first_version.name.should eq(@uploadables[0].name)
        @document.name.should eq(@uploadables[1].name)
      end
    end

    it "avoids document name clashes" do
      node = build do |parent|
        parent.children << FactoryGirl.create(:document, :name => 'My Doc', :owner => @user)
      end
      node.children.count.should eq(1)
      node.valid_document_name('My Doc').should eq('My Doc (1)')
    end

  end

  describe "collapsing and expanding" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "remembers that it's collapsed or expanded" do
      node = FactoryGirl.create(:node)
      node.collapse_by_user(@user, false)
      node.collapsed_in_view?(@user).should eq(false)
      node.collapse_by_user(@user, true)
      node.collapsed_in_view?(@user).should eq(true)
    end

    it "is independent per user" do
      node = FactoryGirl.create(:node)
      other_user = FactoryGirl.create(:user)
      node.collapse_by_user(@user, true)
      node.collapse_by_user(other_user, false)
      node.collapsed_in_view?(@user).should eq(true)
      node.collapsed_in_view?(other_user).should eq(false)
    end

  end

  describe "tagging" do
    before(:each) do
      @node = Node.new
    end

    it "has no tags initially" do
      @node.tag_list.should eq([])
    end

    it "can have many tags" do
      @node.tag_list = "tag1, tag2"
      @node.tag_list.should eq(["tag1", "tag2"])
    end

    it "can list its tags in csv format" do
      @node.tag_list = "tag1, tag2"
      @node.tag_list.join(",").should eq("tag1,tag2")
    end
  end

  describe 'ownership' do
    before(:each) do
      @owner = FactoryGirl.create(:user)
      @other_user = FactoryGirl.create(:user)
      @node = FactoryGirl.create(:node, :owner => @owner)
    end
    it "recognizes the owner" do
      @node.owned_by?(@owner).should eq(true)
      @node.owned_by?(@other_user).should eq(false)
    end
    it "recognizes the owner as an (effective) collaborator" do
      # disadvantage: if @owner is null (which it often is, as we'll use <code>current_owner</code>),
      # this will fail
      @node.collaborator?(@owner).should eq(true)
      @node.collaborator?(@other_user).should eq(false)
    end
  end

  describe "is open sourced or closed source" do

    before(:each) do
      @node = build do |root| # tree with 3 levels
        3.times do
          root.children << build do |l1_parent|
            2.times do
              l1_parent.children << build
            end
          end
        end
      end
      @node.visit do |n|
        n.explicitly_open_sourced = false
      end
    end

    describe "when root created open source" do

      before(:each) do
        @node.explicitly_open_sourced = true
      end

      it "is open source, for both root and children" do
        @node.visit do |n|
          n.is_open_source.should be(true)
        end
      end

    end

    describe "when root created closed source" do
      before(:each) do
        @node.explicitly_open_sourced = false
      end

      it "is closed source, for root and children" do
        @node.visit do |n|
          n.is_open_source.should be(false)
        end
      end

      describe "and when a child node is explicitly open sourced" do
        before(:each) do
          @open_node = @node.children[1]
          @open_node.explicitly_open_sourced = true
          @open_nodes = []
          @open_node.visit do |n|
            @open_nodes << n
          end
        end

        it "is open from that node downwards, the rest is closed" do
          @node.visit do |n|
            if @open_nodes.include? n
              n.is_open_source.should be(true)
            else
              n.is_open_source.should be(false)
            end
          end
        end

      end
    end
  end
end

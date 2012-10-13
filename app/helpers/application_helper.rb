module ApplicationHelper

  def operator?
    !current_user.nil? && current_user.operator?
  end

  def moving_node?
    !moving_node.blank?
  end

  def move_target?(node, user)
    node.writable_by?(user) && !node.is_self_or_child_of?(moving_node)
  end

  def moving_node
    Node.find(session[:moving_node]) if session[:moving_node]
  end

  def sanctioned_tags
    SanctionedTag.all().map{|t| t.name }
  end

  def inline_editable(entity, attr_name, options = {})
    if entity.writable_by?(current_user)
      content_tag :span, :class => 'inline_editable' do
        best_in_place(entity, attr_name, options)
      end
    else
      if block_given?
        yield
      else
        entity.send(attr_name)
      end
    end
  end

  def link_to_with_icon(*args, &block)
    if block_given?
      options = args.first || {}
      html_options = args.second
      icon = html_options[:icon]
      link_to options, html_options do
        concat "<i class=\"icon-#{icon}\"></i> ".html_safe
        yield
      end
    else
      name = args[0]
      options = args[1] || {}
      html_options = args[2]
      icon = html_options[:icon]
      link_to options, html_options do
        c = "<i class=\"icon-#{icon}\"></i> ".html_safe
        c += name
        c
      end
    end
  end
  def link_to_user(user, options = {:pic => true, :name => true})
    if options[:pic]
      c = content_tag :div, :class => 'shadowy_IMG' do
        link_to(user_url(user, :only_path => false)) do
          image_tag(user.profile_pic_url, :class => '', :title => user.display_name,
                    :alt => "Profile picture of #{user.display_name}")
        end
      end
      concat c
      concat " "
    end
    if options[:name]
      link_to(user_url(user)) do
        concat user.display_name
      end
    end
  end

  def node_icon(node, user)
    icon = 'minus'
    if node.children.empty?
      icon = 'empty'
    elsif node.collapsed_in_view?(user)
      icon = 'plus'
    end
    icon
  end

  # TODO: this can be removed!
  # enables accordion / tree style views, uses css classes for styling and
  # state (expanded/collapsed), needs jquery with an event handler on
  # css-class '.occordion.title' (see application.js.coffee)
  class Accordion < BlockHelpers::Base

    def initialize(opts = {})
    end

    def node
      @node_id = next_node_id()
      content_tag :div, :class => "occordion item#{@node_id}" do
        yield if block_given?
      end
    end

    def header(title, options = {})
      outer_tag = options[:is_leaf] ? :span : :a
      css_class = options[:css_class]
      content_tag outer_tag,
                  :href => "#",
                  :class => "occordion title #{css_class} item#{@node_id} #{options[:is_leaf] ? 'leaf' : '' } #{options[:initially_hidden] ? 'occordion_hidden' : ''}" do
        s = content_tag(:span, :class => "occordion plusminus #{options[:is_leaf] ? '' : 'minus'} item#{@node_id}") do
          "&nbsp;".html_safe
        end.html_safe
        s << title
      end
    end

    def content(text = nil)
      content_tag :div, :class => "occordion content item#{@node_id}" do
        concat text if text
        yield if block_given?
      end
    end

    def display(body)
      content_tag :span do
        concat body
      end
    end

    private

    def next_node_id
      id = request.instance_variable_get(:@accordion_next_node_id)
      id = (id || 0) + 1
      request.instance_variable_set(:@accordion_next_node_id, id)
    end

  end

  class ButtonMenu < BlockHelpers::Base
    attr_reader :num_items

    def initialize(opts = {})
      @button_icon = opts[:button_icon] || 'chevron-down'
      @css_class = opts[:class] || ''
      @num_items = 0
    end

    # Adds a menu item to tbe button menu.
    #
    # ==== Signatures by Example
    #
    #   m.item('Open', project_path(@project), :icon => 'eye-open')
    #   m.item('Edit', edit_project_path(@project), :icon => 'edit', :remote => true)
    #   <%= m.item edit_project_path(project), :icon => 'edit' do %>
    #     Edit (block)
    #   <% end %>
    #
    def item(*args)
      @num_items += 1
      if block_given?
        text = nil
        options = args.first || {}
        html_options = args.second
      else
        text = args[0]
        options = args[1] || {}
        html_options = args[2]
      end
      icon = html_options.delete(:icon) if html_options
      content_tag :li do
        link_to(options, html_options) do
          c2 = "<i class=\"#{icon ? 'icon-'+icon : ''}\"></i> ".html_safe # odd: we need a space after '</i>' for proper spacing
          c2 += text if text
          concat c2
          yield if block_given?
        end
      end
    end

    def item_to_function(text, function, options = { :icon => 'cog' })
      icon = "icon-#{options.delete(:icon) || 'cog'}"
      content_tag :li do
        link_to_function("<i class=\"#{icon}\"></i> #{text}".html_safe, function, options)
      end
    end

    def separator()
      content_tag :li, :class => "divider" do
        " "
      end
    end

    def display(body)
      content_tag :div, :class => @css_class, :style => "display: inline-block; font-size: 13px;" do
        content_tag :div, :class => "btn-toolbar" do
          content_tag :div, :class => "btn-group" do
            c = content_tag :div, :class => "btn dropdown-toggle", :'data-toggle' => "dropdown" do
              content_tag :span, :class => "icon-#{@button_icon}" do
                ""
              end
            end
            c += content_tag :ul, :class => "dropdown-menu" do
              body
            end
            c
          end
        end
      end
    end

  end

  def display_updated_at(entity)
    content_tag :span, :class => "updated_at", :title => "Last updated #{l entity.updated_at, :format => :short}" do
      "#{time_ago_in_words entity.updated_at} ago"
    end
  end

  def subject_of_activity(activity)
    return render activity.subject if activity.subject
    return activity.options['display_name'] if activity.options['display_name']
    "??"
  end

end

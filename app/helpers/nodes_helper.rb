module NodesHelper

  def collaborators_menu_item(menu, node)
    if current_user && current_user.connected_to?(node)
      menu.item('Unsubscribe', node_unsubscribe_path(node), :method => :post, :icon => 'bullhorn')
    else
      menu.item('Subscribe', node_subscribe_path(node), :method => :post, :icon => 'bullhorn')
    end
  end
end

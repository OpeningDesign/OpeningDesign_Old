class AddSketchspaceCookieToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sketchspace_cookie, :string
    add_index :users, :sketchspace_cookie
    add_index :nodes, :pad_id
  end
end

class CreateLetMeKnowRecipients < ActiveRecord::Migration
  def change
    create_table :let_me_know_recipients do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end

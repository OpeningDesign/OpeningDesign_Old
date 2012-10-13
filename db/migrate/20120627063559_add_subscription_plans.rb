class AddSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.string :title
      t.integer :max_number_closed_source_nodes
      t.string :max_document_space
      t.integer :max_number_collaborators
      t.string :monthly_cost
      t.timestamps
    end
    change_table :users do |t|
      t.references :associated_subscription_plan
    end
  end
end

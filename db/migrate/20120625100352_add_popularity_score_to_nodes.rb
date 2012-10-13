class AddPopularityScoreToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :popularity_score, :float
  end
end

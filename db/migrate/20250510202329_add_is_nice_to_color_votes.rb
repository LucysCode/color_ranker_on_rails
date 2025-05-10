class AddIsNiceToColorVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :color_votes, :is_nice, :boolean
  end
end

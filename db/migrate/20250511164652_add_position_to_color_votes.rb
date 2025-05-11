class AddPositionToColorVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :color_votes, :position, :integer
  end
end

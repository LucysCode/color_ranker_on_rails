class AddColorPairToColorVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :color_votes, :left_color, :string
    add_column :color_votes, :right_color, :string
  end
end

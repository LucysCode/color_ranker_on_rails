class AddColorPairToColorPairVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :color_pair_votes, :color_pair, :string
  end
end

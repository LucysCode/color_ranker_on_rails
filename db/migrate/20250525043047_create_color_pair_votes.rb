class CreateColorPairVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :color_pair_votes do |t|
      t.string :left_color
      t.string :right_color
      t.boolean :is_ugly
      t.boolean :is_nice
      t.string :session_id
      t.integer :position

      t.timestamps
    end
  end
end

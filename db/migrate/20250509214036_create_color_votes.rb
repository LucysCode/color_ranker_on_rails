class CreateColorVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :color_votes do |t|
      t.string :hex_color
      t.boolean :is_ugly

      t.timestamps
    end
  end
end

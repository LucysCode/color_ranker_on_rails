class AddSessionIdToColorVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :color_votes, :session_id, :string
  end
end

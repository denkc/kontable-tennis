class CreatePlayersTags < ActiveRecord::Migration
  def change
    create_table :player_tags do |t|
      t.references :player, :null => false
      t.references :tag, :null => false
    end
    add_index :player_tags, [:tag_id, :player_id], :unique => true
  end
end

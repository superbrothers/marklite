class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :hash_id, :null => false
      t.text :content, :null => false

      t.timestamps
    end
    add_index :posts, :hash_id, :unique => true
  end
end

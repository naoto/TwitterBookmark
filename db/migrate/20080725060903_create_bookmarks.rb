class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.integer :id
      t.string :title
      t.string :uri
      t.string :originaluri
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
end

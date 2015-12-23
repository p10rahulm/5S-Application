class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :title, index:true
      t.text :content
      t.references :user, index:true, foreign_key:true

      t.timestamps null: false
    end
    add_foreign_key :articles, :user_id
    add_index :articles, [:title, :user_id]
  end
end

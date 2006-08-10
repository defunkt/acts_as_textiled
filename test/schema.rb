ActiveRecord::Schema.define(:version => 0) do
  create_table :stories, :force => true do |t|
    t.column :title, :string
    t.column :description, :string    
    t.column :body, :text
    t.column :author_id, :integer
  end

  create_table :authors, :force => true do |t|
    t.column :name, :string
    t.column :blog, :string
  end
end

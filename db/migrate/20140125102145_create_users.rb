class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.column :name, :string, :null => false
      t.column :created_at, :datetime, :null => false
    end
  end

  def down
    drop_table :users
  end
end

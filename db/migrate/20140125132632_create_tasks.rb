class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
      t.column :name, :string, :null => false
      t.column :user_id, :integer, :null => false
      t.column :completed_at, :datetime
      t.timestamps
    end
  end

  def down
    drop_table :tasks
  end
end

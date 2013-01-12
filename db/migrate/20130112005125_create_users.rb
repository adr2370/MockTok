class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :singly_id

      t.timestamps
    end
  end
end

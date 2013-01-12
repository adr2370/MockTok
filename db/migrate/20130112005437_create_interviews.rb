class CreateInterviews < ActiveRecord::Migration
  def change
    create_table :interviews do |t|
      t.integer :expected_time
      t.boolean :waiting
      t.timestamp :finished_at

      t.timestamps
    end
  end
end

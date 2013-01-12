class AddSessionIdToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :session_id, :string
  end
end

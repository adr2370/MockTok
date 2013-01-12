class AddInterviewerIdAndIntervieweeIdToInterviews < ActiveRecord::Migration
  def change
  	add_column :interviews, :identer, :integer
	add_column :interviews, :identee, :integer
  end
end

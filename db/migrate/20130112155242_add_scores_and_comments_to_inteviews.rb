class AddScoresAndCommentsToInteviews < ActiveRecord::Migration
  def change
	add_column :interviews, :identer_score, :integer
	add_column :interviews, :identee_score, :integer
	add_column :interviews, :identer_comments, :string
	add_column :interviews, :identee_comments, :string
  end
end

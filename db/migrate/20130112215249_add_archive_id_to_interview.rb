class AddArchiveIdToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :archive_id, :string
  end
end

class Interview < ActiveRecord::Base
  attr_accessible :expected_time, :finished_at, :waiting, :identee, :identer

  validates :expected_time, :presence => true
end

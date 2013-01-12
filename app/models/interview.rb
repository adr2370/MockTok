class Interview < ActiveRecord::Base
  attr_accessible :expected_time, :finished_at, :waiting

  has_one :interviewer
  has_one :interviewee

  validates :interviewer, :presence => true
  validates :expected_time, :presence => true
  validates :waiting, :presence => true
end

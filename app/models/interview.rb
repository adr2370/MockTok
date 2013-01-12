class Interview < ActiveRecord::Base
  attr_accessible :expected_time, :finished_at, :waiting

  belongs_to :interviewer, :class_name => "User"
  belongs_to :interviewee, :class_name => "User"

  validates :expected_time, :presence => true
  validates :waiting, :presence => true
end

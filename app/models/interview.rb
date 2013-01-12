class Interview < ActiveRecord::Base
  attr_accessible :expected_time,
  				  :finished_at,
  				  :waiting, 
  				  :identee, 
  				  :identer, 
  				  :session_id, 
  				  :identee_score, 
  				  :identer_score,
  				  :identee_comments,
  				  :identer_comments

  validates :expected_time, :presence => true
  validates_inclusion_of :identee_score, :in => 1..10
  validates_inclusion_of :identer_score, :in => 1..10
end

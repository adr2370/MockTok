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
  validates :identee_score, :allow_nil => true, :inclusion => { :in => 0..10 }
  validates :identer_score, :allow_nil => true, :inclusion => { :in => 0..10 }

end

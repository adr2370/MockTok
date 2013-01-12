class User < ActiveRecord::Base
  attr_accessible :singly_id

  has_many :interviews

  validates :singly_id, :presence => true


  def self.findOpenInterview( timespan )
  	@interviews = Interview.find( :all, :waiting => true, :order => "created_at desc" ).first
  	if @interviews == []
  		nil
  	end
  	@interview = @interviews.first
  	@interview.interviewee = self
  	@interview.waiting = false
  	@interview
  end

end

class User < ActiveRecord::Base
  attr_accessible :singly_id

  has_many :interviews

  validates :singly_id, :presence => true


  def findOpenInterview( interviewer, timespan )
    @interviews = Interview.where( "waiting=? AND expected_time=?", true, timespan )
    if @interviews == [] or @interviews.nil?
      nil
    else
      @interview = @interviews.first
      if interviewer
        @interview.identer = self.id
      else
        @interview.identee = self.id
      end
      @interview.waiting = false
      @interview.save!
      @interview
    end
  end
end

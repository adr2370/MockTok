module InterviewsHelper
	def interview_interviewer_review_path
		url_for :controller => :interviews, :action => :interviewer_review
	end

	def interview_interviewee_review_path
		url_for :controller => :interviews, :action => :interviewee_review
	end
end

class InterviewsController < ApplicationController

  # GET /interviews
  # GET /interviews.json
  def index
    @interviews = Interview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interviews }
    end
  end

  # GET /interviews/1
  # GET /interviews/1.json
  def show
    @interview = Interview.find(params[:id])
    p @interview.identer.to_s == session[:user_id].to_s or @interview.identee.to_s == session[:user_id].to_s
    p @interview
    p session[:user_id]
    p "========="
    p "========="
    p "========="
    p "========="
    p "========="
    # if @interview.identer.to_s == session[:user_id].to_s or @interview.identee.to_s == session[:user_id].to_s
      @openTokToken = OTSDK.generateToken :session_id => @interview.session_id, :role => OpenTok::RoleConstants::MODERATOR
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @interview }
       end
    # else
    #   render 'application/forbidden', :status => :unauthorized
    # end
  end

  # GET /interviews/new
  # GET /interviews/new.json
  def new
    @interview = Interview.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  # GET /interviews/1/edit
  def edit
    @interview = Interview.find(params[:id])
  end

  # POST /interviews
  # POST /interviews.json
  def create
    @interviewer = params[:role] == "Interviewer"
    @interview = User.find( session[:user_id] ).findOpenInterview( @interviewer, params[:interview][:expected_time] )
    if @interview
      Pusher['private-interview' + @interview.id.to_s].trigger("message", {
        :user_id => session[:user_id],
        :text => "Match Found!"
      })
      respond_to do |format|
        format.html { redirect_to :action => :show, :id => @interview.id, notice: 'Interview was successfully found.' }
        format.json { render json: @interview, status: :created, location: @interview }
      end
    else
      @interview = Interview.new(params[:interview], :identer => nil, :identee => nil )
      if @interviewer
        @interview.identer = session[:user_id]
      else
        @interview.identee = session[:user_id]
      end
      @interview.session_id = OTSDK.createSession( request.ip ).to_s
      @interview.identee_score = 1
      @interview.identer_score = 1
      respond_to do |format|
        if @interview.save
          format.html { redirect_to :action => :show, :id => @interview.id, notice: 'Interview was successfully created.' }
          format.json { render json: @interview, status: :created, location: @interview }
        else
          format.html { render action: "new" }
          format.json { render json: @interview.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  
  def auth
    channelName = params[:channel_name][17..-1]
    @channel = Pusher[params[:channel_name]]
    @interview = Interview.find(channelName)
    if @interview.identer == session[:user_id] or @interview.identee == session[:user_id]
      response = @channel.authenticate(params[:socket_id], {
        :user_id => session[:user_id],
        :user_info => {}
      })
      render :json => response
    else
      render :text => "Not authorized", :status => '403'
    end
  end
  
  def webhook
    webhook = Pusher::WebHook.new(request)
    p "webhook received!~"
    if webhook.valid?
      webhook.events.each do |event|
        if event["name"] == 'channel_vacated'
          @channel = event["channel"][17..-1]
          @interview = Interview.find(@channel)
          @interview.waiting = false
          @interview.save!
          p "channel vacated!"
        end
      end
      render :text => "Thanks!"
    else
      status 401
    end
  end
  
  # PUT /interviews/1
  # PUT /interviews/1.json
  def update
    @interview = Interview.find(params[:id])

    respond_to do |format|
      if @interview.update_attributes(params[:interview])
        format.html { redirect_to @interview, notice: 'Interview was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interviews/1
  # DELETE /interviews/1.json
  def destroy
    @interview = Interview.find(params[:id])
    @interview.destroy

    respond_to do |format|
      format.html { redirect_to interviews_url }
      format.json { head :no_content }
    end
  end

  def waiting
    if params[:timespan]
      @interview_timespan = params[:timespan]
    elsif params[:interview_id]
      @interview_id = params[:interview_id]
    else
      puts "THIS SHOULD NEVER HAPPEN FUUUUUUUUCK"
      redirect_to :action => :new
    end
  end

  def interview_done
    # TODO save video, text
    @interview = Interview.find(params[:id])
    @interview.finished_at = Time.now
    @interview.save
    render "review"
  end

  def interviewer_review
    @interview = Interview.find(params[:id])
    @interview.identer_score = params[:identer_score]
    @interview.identer_comments = params[:identer_comments]
    @interview.save
    redirect_to :action => :signup, :controller => :pages
  end

  def interviewee_review
    @interview = Interview.find(params[:id])
    @interview.identee_score = params[:identee_score]
    @interview.identee_comments = params[:identee_comments]
    @interview.save
    redirect_to :action => :signup, :controller => :pages
  end

  
  def findOpenInterview
    
    @interview = User.find( session[:user_id] ).findOpenInterview( params[:timespan] )
    if @interview
      render json: { :id => @interview.id }
    else
      render json: { status: "no data", id: 0}
    end
  end

  def goToInterviewIfReady
    @interview = Interview.find(params[:interview_id])
    unless ( @interview.identee.nil? ) 
      render json: { :id => @interview.id }
    else
        render json: { status: "no data", id: 0}
    end
  end

end

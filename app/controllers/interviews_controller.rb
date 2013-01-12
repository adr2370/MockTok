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
    @openTokToken = OTSDK.generateToken :session_id => @interview.session_id, :role => OpenTok::RoleConstants::MODERATOR
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview }
    end
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
      Pusher['private-interview' + @interview.id].trigger("message", {
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
      respond_to do |format|
        if @interview.save
          format.html { redirect_to :action => :waiting, :interview_id => @interview.id, notice: 'Interview was successfully created.' }
          format.json { render json: @interview, status: :created, location: @interview }
        else
          format.html { render action: "new" }
          format.json { render json: @interview.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  
  def auth
    @channel = params[:channel_name][17..]
    @interview = Interview.find(@channel)
    if @interview.identer == session[:user_id] or @interview.identee == session[:user_id]
      response = channel.authenticate(params[:socket_id], {
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
    if webhook.valid?
      webhook.events.each do |event|
        if event["name"] == 'channel_vacated'
          @channel = event["channel"][17..]
          @interview = Interview.find(@channel)
          @interview.waiting = false
          @interview.save!
        end
      end
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

  # TODO
  def findOpenInterview
    
    @interview = User.find( session[:user_id] ).findOpenInterview( params[:timespan] )
    if @interview
      render json: { :id => @interview.id }
    else
      render json: { status: "no data", id: 0}
    end
  end

  # TODO
  def goToInterviewIfReady
    @interview = Interview.find(params[:interview_id])
    unless ( @interview.identee.nil? ) 
      render json: { :id => @interview.id }
    else
        render json: { status: "no data", id: 0}
    end
  end

end

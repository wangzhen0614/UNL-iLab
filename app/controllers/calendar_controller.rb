class CalendarController < ApplicationController
  
  def index
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)
    if current_user.student
      if current_user.student.team_id
        @event_strips = Event.event_strips_for_month(@shown_month, :conditions => "user_id = #{current_user.id} OR team_id = #{current_user.student.team_id}")
      else
        @event_strips = Event.event_strips_for_month(@shown_month, :conditions => "user_id = #{current_user.id}")
      end
    else
      @event_strips = Event.event_strips_for_month(@shown_month, :conditions => "user_id = #{current_user.id} AND team_id is null")
    end
  end

  def team_calendar
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)
    @event_strips = Event.event_strips_for_month(@shown_month, :conditions => "team_id = #{params[:id]}")
    @team = Team.find(params[:id])
    @team_id = params[:id]
    @from = @team_id
  end

  def new
    @event = Event.new
    @url = "create"
  end

  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if current_user.utype == "student"
      if event_params[:team_id]
        @event.team_id = current_user.student.team_id
      end
    end

    if @event.save
      flash[:success] = "Your event was successfully created."
      if @event.team_id
        redirect_to calendar_team_path(@event.team_id)
      else
        redirect_to calendar_path
      end
    else
      flash[:error] = @event.errors.full_messages.join(", ").html_safe
      redirect_to :back
    end
  end

  def show
    @event = Event.find(params[:id])
    @editable = false
    case current_user.utype
      when "instructor"
        @editable = true
      when "sponsor"
        @project_id = Team.find(@event.team_id).project_id
        @sponsor_id = Project.find(@project_id).sponsor_id
        if @sponsor_id == current_user.sponsor.id
          @editable = true
        end
      when "student"
        if current_user.student.team_id == @event.team_id
          @editable = true
        end
    end
  end

  def edit
    set_event
    @url = "update"
  end

  def update
    set_event
    @url = "update"
    if @event.update_attributes(event_params)
      flash[:success] = "Event has successfully updated!"
      redirect_to event_path(@event.id)
    else
      flash[:error] = @event.errors.full_messages
      redirect_to :back
    end
  end

  def new_team_task
    @team_id = params[:id]
    @event = Event.new
    @url = "create"
    if @team_id
      @from = @team_id
    end
  end

  def destroy
    @event = Event.find(params[:id])

    Event.destroy(params[:id])

    if @event.team_id
      redirect_to calendar_team_path(@event.team_id)
    else
      redirect_to calendar_path
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :url, :priority, :team_id, :completed, :start_at, :end_at)
  end

  def set_event
    @event = Event.find_by_id(params[:id])
  end
end

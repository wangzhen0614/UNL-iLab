class SponsorPreferencesController < ApplicationController
  def index
  end

  def new
  end

  def show
  end

  def application
    @projects = Project.where(:sponsor_id => params[:id])
    @url = "preference"
  end

  def preference
    @student_preferences = StudentPreference.where(:project_id => params[:id])
    render partial: "preference", locals: { student_preferences: @student_preferences }
  end

  def update
    params[:rating].each do |key, value|
      @student_preference = StudentPreference.find(key.to_i)
      student_id = @student_preference.student_id
      project_id = @student_preference.project_id
      rating = value.first.to_i
      @sponsor_preference = SponsorPreference.where(:project_id => project_id, :student_id => student_id)
      if(@sponsor_preference.nil?)
        @sponsor_preference = SponsorPreference.new
        @sponsor_preference.student_id = student_id
        @sponsor_preference.project_id = project_id
        @sponsor_preference.rating = rating
        @sponsor_preference.save
      else
        @sponsor_preference.first.rating = rating
        @sponsor_preference.first.save
      end

    end
    #render text: params[:rating].to_s
    flash[:success] = "Your rating was successfully saved!"
    redirect_to :back

  end

  private

  def sponsor_preference_params
    params.require(:sponsor_preference).permit(:student_id, :project_id, :rating)
  end

  def sponsor_student_preference
    @sponsor_preference = SponsorPreference.find_by_id(params[:id])
  end

end
class PreferencesController < ApplicationController
  before_action :signed_in_user

  def student_preferences
    @student_preferences = StudentPreference.all
  end

  def sponsor_preferences
    @sponsor_preferences = SponsorPreference.all
  end

  def update_sponsor_preference

  end
end

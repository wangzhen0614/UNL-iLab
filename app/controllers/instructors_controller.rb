class InstructorsController < ApplicationController
	before_action :signed_in_user
	before_action :signed_in_instructor
	before_action :correct_instructor, only: [:edit, :update]

	def new
		@instructor = Instructor.new
    if current_user.utype != "admin"
      @instructor.email = current_user.email
    end
	end

	def index
		@instructors = Instructor.all
	end

	def create
		@instructor = Instructor.new(instructor_params)
    if current_user.instructor?
      @instructor.user_id = current_user.id
    end
		if @instructor.save
      @instructor_term = InstructorTerm.new(:instructor => @instructor, :semester => @instructor.semester)
      @instructor_term.save
      flash[:success] = "New Instructor was successfully created."
      if current_user.utype == "admin"
			  redirect_to instructors_path
      else
        redirect_to user_path(current_user)
      end
    else
      flash[:error] = @instructor.errors.full_messages.join(", ").html_safe
			render 'new'
		end
	end

	def edit
		set_instructor
		@url = "update"
	end

	def show
		set_instructor
	end

	def update
		set_instructor
		@url = "update"
		if (current_user.utype == "admin" && @instructor.update_attributes(instructor_params)) ||
        (current_user.utype == "instructor" && @instructor.update_attributes(instructor_profile_params))
      flash[:success] = "Profile was successfully saved."
			redirect_to instructor_path(@instructor.id)
    else
      flash[:error] = @instructor.errors.full_messages.join(", ").html_safe
			render 'edit'
		end
	end

	private

			def instructor_params
				params.require(:instructor).permit(:email, :classname, :semester,
					:first_name, :last_name)
      end

      def instructor_profile_params
        params.require(:instructor).permit(:email, :classname,
                                           :first_name, :last_name)
      end

      def set_instructor
				@instructor = Instructor.find_by_id(params[:id])
			end
end

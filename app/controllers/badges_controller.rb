class BadgesController < ApplicationController

  before_filter :ensure_staff?, :only=>[:new,:edit,:create,:update,:destroy]

  def index
    @title = "View All #{term_for :badges}"
    @badges = current_course.badges
  end

  def show
    @badge = current_course.badges.find(params[:id])
    @title = @badge.name
    @earned_badges = @badge.earned_badges
    @tasks = @badge.tasks
  end

  def new
    @title = "Create a New #{term_for :badge}"
    @badge = current_course.badges.new
    @badge_sets = current_course.badge_sets
  end

  def edit
    @badge = current_course.badges.find(params[:id])
    @title = "Edit #{@badge.name}"
    @badge_sets = current_course.badge_sets
  end

  def create
    @badge = current_course.badges.create(params[:badge])

    respond_to do |format|
      if @badge.save
        format.html { redirect_to @badge, notice: 'Badge was successfully created.' }
        format.json { render json: @badge, status: :created, location: @badge }
      else
        format.html { render action: "new" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @badge = current_course.badges.find(params[:id])

    respond_to do |format|
      if @badge.update_attributes(params[:badge])
        format.html { redirect_to @badge, notice: 'Badge was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @badge = current_course.badges.find(params[:id])
    @badge.destroy

    respond_to do |format|
      format.html { redirect_to badges_path, notice: "#{ @badge.name} successfully deleted."  }
      format.json { head :ok }
    end
  end

  def toggle_shared
    @badge = current_course.badges.find(params[:id])
    @badge.shared = !@badge.shared
    @badge.save
    render :json => {
      :shared => @badge.shared
    }
  end
end

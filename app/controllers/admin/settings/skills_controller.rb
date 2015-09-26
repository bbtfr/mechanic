class Admin::Settings::SkillsController < Admin::ApplicationController
  before_filter :find_skill, only: [ :edit, :update, :destroy ]

  def index
    @skills = Skill.all
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)
    if @skill.save
      redirect_to admin_settings_skills_path
    else
      render :new
    end
  end

  def update
    if @skill.update_attributes(skill_params)
      redirect_to admin_settings_skills_path
    else
      render :edit
    end
  end

  def destroy
    @skill.destroy
    redirect_to admin_settings_skills_path
  end

  private

    def skill_params
      params.require(:skill).permit(:name)
    end

    def find_skill
      @skill = Skill.find(params[:id])
    end

end

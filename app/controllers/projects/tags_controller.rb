class Projects::TagsController < Projects::ApplicationController
  include SortingHelper

  # Authorize
  before_action :require_non_empty_project
  before_action :authorize_download_code!
  before_action :authorize_push_code!, only: [:new, :create]
  before_action :authorize_admin_project!, only: [:destroy]

  def index
    params[:sort] = params[:sort].presence || sort_value_recently_updated

    @sort = params[:sort]
    @tags = TagsFinder.new(@repository, params).execute
    @tags = Kaminari.paginate_array(@tags).page(params[:page])

    @releases = project.releases.where(tag: @tags.map(&:name))
  end

  def show
    @tag = @repository.find_tag(params[:id])

    return render_404 unless @tag

    @release = @project.releases.find_or_initialize_by(tag: @tag.name)
    @commit = @repository.commit(@tag.dereferenced_target)
  end

  def create
    result = Tags::CreateService.new(@project, current_user).
      execute(params[:tag_name], params[:ref], params[:message], params[:release_description])

    if result[:status] == :success
      @tag = result[:tag]

      redirect_to namespace_project_tag_path(@project.namespace, @project, @tag.name)
    else
      @error = result[:message]
      render action: 'new'
    end
  end

  def destroy
    result = Tags::DestroyService.new(project, current_user).execute(params[:id])

    respond_to do |format|
      if result[:status] == :success
        format.html do
          redirect_to namespace_project_tags_path(@project.namespace, @project)
        end

        format.js
      else
        @error = result[:message]

        format.html do
          redirect_to namespace_project_tags_path(@project.namespace, @project),
            alert: @error
        end

        format.js do
          render status: :unprocessable_entity
        end
      end
    end
  end
end

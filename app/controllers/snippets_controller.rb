class SnippetsController < ApplicationController
  include Swagger::SnippetApiSchema

  before_action :set_snippet, only: [:show, :update, :destroy]
  before_action :authenticate_user, only: [:create, :update, :destroy]

  INDEX_MAX_SNIPPETS = 3000

  def index
    relation = Snippet.includes(:author)
    if params[:user_id].present?
      author = User.find(params[:user_id])
      relation = relation.where(author_id: author)
    end
    @snippets = relation.limit(INDEX_MAX_SNIPPETS).page(params[:page])
  end

  def show
  end

  def create
    @author = User.find(params[:user_id])
    head :unauthorized and return unless current_user == @author

    @snippet = Snippet.new(snippet_params.merge(author: @author))
    if @snippet.save
      render status: :created
    else
      render json: validation_errors(@snippet), status: :bad_request
    end
  end

  def update
    head :unauthorized and return unless current_user == @snippet.author

    if @snippet.update_attributes(snippet_params)
      render status: :ok
    else
      render json: validation_errors(@snippet), status: :bad_request
    end
  end

  def destroy
    head :unauthorized and return unless current_user == @snippet.author

    @snippet.destroy!
    head :no_content
  end

  private

  def set_snippet
    @snippet = Snippet.find(params[:id])
  end

  def snippet_params
    params.require(:snippet).permit(:title, :content)
  end
end

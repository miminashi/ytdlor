class ArchivesController < ApplicationController
  before_action :set_archive, only: %i[ show edit update destroy ]

  # GET /archives or /archives.json
  def index
    @archives = Archive.ordered
  end

  # GET /archives/1 or /archives/1.json
  def show
  end

  # GET /archives/new
  def new
    @archive = Archive.new
  end

  ## GET /archives/1/edit
  #def edit
  #end

  # POST /archives or /archives.json
  def create
    @archive = Archive.new(archive_params)

    respond_to do |format|
      if @archive.save
        format.html { redirect_to archive_url(@archive), notice: "動画が追加されました" }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  ## PATCH/PUT /archives/1 or /archives/1.json
  #def update
  #  respond_to do |format|
  #    if @archive.update(archive_params)
  #      format.html { redirect_to archive_url(@archive), notice: "Archive was successfully updated." }
  #      format.json { render :show, status: :ok, location: @archive }
  #    else
  #      format.html { render :edit, status: :unprocessable_entity }
  #      format.json { render json: @archive.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  ## DELETE /archives/1 or /archives/1.json
  #def destroy
  #  @archive.destroy

  #  respond_to do |format|
  #    format.html { redirect_to archives_url, notice: "Archive was successfully destroyed." }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def archive_params
      params.require(:archive).permit(:title, :original_url, :status)
    end
end

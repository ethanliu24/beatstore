module Admin
  class TracksController < ApplicationController
    before_action :set_track, except: [ :new, :create ]
    before_action :check_admin

    def new
      @track = Track.new
    end

    def edit
    end

    def create
      @track = Track.new(sanitize_track_params)

      respond_to do |format|
        if @track.save
          format.html { redirect_to @track, notice: "Track was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @track.update(sanitize_track_params)
          format.html { redirect_to @track, notice: "Track was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      # TODO redirect to admin page when its up
      @track.destroy!

      respond_to do |format|
        format.html { redirect_to tracks_path, status: :see_other, notice: "Track was successfully destroyed." }
      end
    end

    private

    def set_track
      @track = Track.find(params[:id])
    end

    def sanitize_track_params
      params.require(:track).permit(
        :title,
        :key,
        :bpm,
        :is_public,
        :tagged_mp3,
        :untagged_mp3,
        :untagged_wav,
        :track_stems,
        :project,
        :cover_photo
      )
    end

    def check_admin
      redirect_to root_path, status: :forbidden, alert: "You are not authorized to access this page." unless current_user&.admin?
    end
  end
end

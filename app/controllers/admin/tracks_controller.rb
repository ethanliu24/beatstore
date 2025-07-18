module Admin
  class TracksController < Admin::BaseController
    before_action :set_track, except: [ :index, :new, :create ]

    def index
      base_scope = Track.order(created_at: :desc)
      @q = base_scope.ransack(params[:q], auth_object: current_user)
      queried_tracks = @q.result(distinct: true).includes(:tags)
      @pagy, @tracks = pagy(queried_tracks, limit: 10)

      if turbo_or_xhr_request?
        render partial: "admin/tracks/track_list", locals: { tracks: @tracks }
      end
    end

    def new
      @track = Track.new
    end

    def edit
    end

    def create
      @track = Track.new(sanitize_track_params)

      respond_to do |format|
        if @track.save
          format.html { redirect_to admin_tracks_path, notice: "Track was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @track.update(sanitize_track_params)
          format.html { redirect_to admin_tracks_path, notice: "Track was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      # TODO redirect to admin page when its up
      @track.destroy!

      respond_to do |format|
        format.html { redirect_to admin_tracks_path, status: :see_other, notice: "Track was successfully destroyed." }
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
        :description,
        :bpm,
        :is_public,
        :genre,
        :tagged_mp3,
        :untagged_mp3,
        :untagged_wav,
        :track_stems,
        :project,
        :cover_photo,
        tags_attributes: [ :id, :name, :_destroy ]
      )
    end
  end
end

module Admin
  class TracksController < Admin::BaseController
    before_action :set_track, except: [ :index, :new, :create ]

    def index
      base_scope = Track.order(created_at: :desc)
      @q = base_scope.ransack(params[:q], auth_object: current_user)
      queried_tracks = @q.result(distinct: true).includes(:tags)
      @pagy, @tracks = pagy(queried_tracks, limit: 8)

      if turbo_or_xhr_request?
        render partial: "admin/tracks/list", locals: { tracks: @tracks }
      end
    end

    def new
      @track = Track.new
      @licenses = License.order(Arel.sql("default_for_new DESC, created_at DESC"))
    end

    def edit
      # Fine for now as there won't be a lot of licenses, if want to be optimize use raw sql
      @licenses = (@track.licenses + License.all).uniq
    end

    def create
      @track = Track.new(sanitize_track_params)

      begin
        if @track.save
          redirect_to admin_tracks_path, notice: t("admin.track.create.success")
        else
          render :new, status: :unprocessable_content
        end
      rescue ArgumentError => _e
        @track.errors.add(:role, "is invalid")
        render :new, status: :unprocessable_content
      end
    end

    def update
      begin
        if @track.update(sanitize_track_params)
          redirect_to admin_tracks_path, notice: t("admin.track.update.success")
        else
          render :new, status: :unprocessable_content
        end
      rescue ArgumentError => _e
        @track.errors.add(:role, "is invalid")
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      @track.destroy!

      redirect_to admin_tracks_path, status: :see_other, notice: t("admin.track.destroy.success")
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
        tags_attributes: [ :id, :name, :_destroy ],
        collaborators_attributes: [ :id, :name, :role, :profit_share, :publishing_share, :notes, :_destroy ],
        samples_attributes: [ :id, :name, :artist, :link, :_destroy ],
        license_ids: []
      )
    end
  end
end

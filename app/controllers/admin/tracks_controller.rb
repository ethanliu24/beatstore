module Admin
  class TracksController < Admin::BaseController
    before_action :set_track, except: [ :index, :new, :create ]
    before_action :load_licenses, only: [ :new, :edit, :create, :update ]

    def index
      base_scope = Track.kept.order(created_at: :desc)
      @q = base_scope.ransack(params[:q], auth_object: current_user)
      queried_tracks = @q.result(distinct: true).includes(:tags)
      @pagy, @tracks = pagy(queried_tracks, limit: 8)

      if turbo_or_xhr_request?
        render partial: "admin/tracks/list", locals: { tracks: @tracks }
      end
    end

    def new
      @track = Track.new
    end

    def edit; end

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
          purge_files(purge_params)
          redirect_to admin_tracks_path, notice: t("admin.track.update.success")
        else
          render :new, status: :unprocessable_content
        end
      rescue ArgumentError => _e
        @track.errors.add(:role, "is invalid")
        render :new, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid
        @track.errors.add(:base, "is invalid")
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      @track.discard!

      redirect_to admin_tracks_path, status: :see_other, notice: t("admin.track.destroy.success")
    end

    private

    def set_track
      @track = Track.kept.find(params[:id])
    end

    def load_licenses
      @licenses =
        if @track&.persisted?
          # Fine for now as there won't be a lot of licenses, if want to be optimize use raw sql
          (@track.undiscarded_licenses + License.kept).uniq
        else
          License.kept.order(Arel.sql("default_for_new DESC, created_at DESC"))
        end
    end

    def purge_files(purge_options)
      @track.tagged_mp3.purge if purge_options[:remove_tagged_mp3] == "1"
      @track.untagged_mp3.purge if purge_options[:remove_untagged_mp3] == "1"
      @track.untagged_wav.purge if purge_options[:remove_untagged_wav] == "1"
      @track.track_stems.purge if purge_options[:remove_track_stems] == "1"
      @track.project.purge if purge_options[:remove_project] == "1"
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

    def purge_params
      params.require(:track).permit(
        :remove_tagged_mp3,
        :remove_untagged_mp3,
        :remove_untagged_wav,
        :remove_track_stems,
        :remove_project,
      )
    end
  end
end

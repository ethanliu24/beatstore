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
      rescue ArgumentError => e
        @track.errors.add(:base, "Update Failed: #{e}")
        render :new, status: :unprocessable_content
      end
    end

    def update
      begin
        if track_valid_after_file_change?
          if @track.update(sanitize_track_params)
            purge_files(@track, purge_params)
            redirect_to admin_tracks_path, notice: t("admin.track.update.success")
            return
          end
        end

        # dedup any errors after sandbox
        base_errors = @track.errors[:base].uniq
        @track.errors.delete(:base)
        base_errors.each { |msg| @track.errors.add(:base, msg) }
        render :edit, status: :unprocessable_content
      rescue ArgumentError => e
        @track.errors.add(:base, "Update Failed: #{e}")
        render :edit, status: :unprocessable_content
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

    def track_valid_after_file_change?
      # 4 steps to duplicate track file state
      # 1) Attach the newly uploaded file if there is one
      # 2) Attach the original file otherwise
      # 3) Apply purges
      # 4) Apply updated licenses

      sandbox = @track.dup
      attachment_keys = [ :tagged_mp3, :untagged_mp3, :untagged_wav, :track_stems, :project ]

      attachment_keys.each do |key|
        # Step 1)
        if sanitize_track_params[key].present?
          sandbox.send(key).attach(sanitize_track_params[key])
          next
        end

        # Step 2)
        attachment = @track.send(key)
        if attachment.attached? && attachment.blob.persisted?
          sandbox.send(key).attach(attachment.blob)
          next
        end
      end

      # Step 3)
      purge_files(sandbox, purge_params)

      # Step 4)
      if sanitize_track_params[:license_ids].present?
        updated_license_ids = sanitize_track_params[:license_ids].reject(&:blank?)
        sandbox.licenses = License.where(id: updated_license_ids)
      else
        sandbox.licenses = @track.licenses.to_a
      end

      if sandbox.valid?
        true
      else
        sandbox.errors[:base].each do |message|
          @track.errors.add(:base, message)
        end

        false
      end
    end

    def purge_files(track, purge_options)
      track.tagged_mp3.purge if purge_options[:remove_tagged_mp3] == "1"
      track.untagged_mp3.purge if purge_options[:remove_untagged_mp3] == "1"
      track.untagged_wav.purge if purge_options[:remove_untagged_wav] == "1"
      track.track_stems.purge if purge_options[:remove_track_stems] == "1"
      track.project.purge if purge_options[:remove_project] == "1"
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

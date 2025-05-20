module Admin
  class TracksController < ApplicationController
    before_action :set_track, except: [ :new ]
    before_action :check_admin

    # GET /tracks/new
    def new
      @track = Track.new
    end

    # GET /tracks/1/edit
    def edit
    end

    # POST /tracks or /tracks.json
    def create
      @track = Track.new(track_params)

      respond_to do |format|
        if @track.save
          format.html { redirect_to @track, notice: "Track was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /tracks/1 or /tracks/1.json
    def update
      respond_to do |format|
        if @track.update(track_params)
          format.html { redirect_to @track, notice: "Track was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /tracks/1 or /tracks/1.json
    def destroy
      @track.destroy!

      respond_to do |format|
        format.html { redirect_to tracks_path, status: :see_other, notice: "Track was successfully destroyed." }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_track
      @track = Track.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def track_params
      params.fetch(:track, {})
    end

    def check_admin
      redirect_to root_path, alert: "You are not authorized to access this page." unless current_user&.admin?
    end
  end
end

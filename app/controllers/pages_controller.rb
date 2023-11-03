class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def news_view
    if params[:keyword].present?
      @data = ApiService.fetch_articles_with_keyword(params[:keyword])
    end
  end

  def nookal_view
    if params[:client_id].present?
      if params[:option] == 'notes'
        @client_name = NookalService.fetch_clients.find { |client| client["clientID"].to_s == params[:client_id] }["fullName"]
        @notes = NookalService.fetch_treatment_notes(clientIDs: [params[:client_id].to_i])
      elsif params[:option] == 'details'
        # Fetch client details here
        @client = NookalService.fetch_clients(clientIDs: [params[:client_id].to_i]).first
      end
    end
  end

  def fetch_cases
    client_id = params[:client_id]

    if client_id.present?
      @cases = NookalService.fetch_cases(clientIDs: [client_id.to_i])
      render json: @cases
    else
      render json: { error: "Client ID not provided." }, status: :bad_request
    end
  end

  def create_note
    result = NookalService.add_treatment_note(
      clientID: params[:clientID],
      caseID: params[:caseID],
      apptID: params[:apptID],
      practitionerID: params[:practitionerID],
      date: params[:date],
      answers: params[:answers],
      status: params[:status],
      templateID: params[:templateID]
    )
    
    if result
      # Handle the successful creation of the note
      redirect_to nookal_view_path, notice: 'Treatment note added successfully!'
    else
      # Handle the failure of note creation
      redirect_to nookal_view_path, alert: 'Failed to add treatment note.'
    end
  end

end

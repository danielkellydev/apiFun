class NookalService
    include HTTParty
  
    AUTH_URL = Rails.application.credentials.nookal[:base_url]
    API_KEY = Rails.application.credentials.nookal[:api_key]
    BASE_URL = "https://au-apiv3.nookal.com/graphql"
  
  
    # Method to get the auth token from the Nookal API
    def self.get_auth_token
        Rails.cache.fetch("nookal_auth_token", expires_in: 1.hour) do
          response = HTTParty.post(AUTH_URL, 
            headers: { "Authorization" => API_KEY, "Content-Type" => "application/x-www-form-urlencoded" },
            body: {
              grant_type: "client_credentials"
            }.to_json
          )
        
          if response.success?
            response["accessToken"]
          else
            Rails.logger.error("NookalService Error: #{response.code} - #{response.body}")
            nil
          end
        end
    end
  
      # Method to fetch treatment notes from the Nookal API
      def self.fetch_treatment_notes(page: nil, pageLength: nil, clientIDs: [], caseIDs: [], noteID: nil, buildNotes: false)
        query = <<-GQL
          query treatmentNotes($page: Int, $pageLength: Int, $clientIDs: [Int], $caseIDs: [Int], $noteID: Int, $buildNotes: Boolean) {
            treatmentNotes(page: $page, pageLength: $pageLength, clientIDs: $clientIDs, caseIDs: $caseIDs, noteID: $noteID, buildNotes: $buildNotes) {
              noteID
              clientID
              caseID
              apptID
              practitionerID
              date
              answers
              status
              templateID
            }
          }
        GQL
    
        # Only add variables if they are not default values
        variables = {}
        variables[:page] = page unless page.nil?
        variables[:pageLength] = pageLength unless pageLength.nil?
        variables[:clientIDs] = clientIDs unless clientIDs.empty?
        variables[:caseIDs] = caseIDs unless caseIDs.empty?
        variables[:noteID] = noteID unless noteID.nil?
        variables[:buildNotes] = buildNotes unless buildNotes == false
    
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{get_auth_token}" # assuming get_auth_token retrieves the token string
        }
    
        body = {
          query: query,
          variables: variables.empty? ? nil : variables
        }.to_json
    
        response = HTTParty.post(BASE_URL, headers: headers, body: body)
    
        # Handle the response, log errors, return the data etc.
        if response.success?
          response.parsed_response.dig("data", "treatmentNotes")
        else
          Rails.logger.error("NookalService Error: #{response.body}")
          nil
        end
      end

      # Method to fetch clients from the Nookal API
      def self.fetch_clients(
        page: nil,
        pageLength: nil,
        locationIDs: [],
        clientIDs: [],
        onlineQuickCode: nil,
        deceased: nil,
        firstName: nil,
        lastName: nil,
        dob: nil,
        fuzzy: nil,
        fileType: nil
      )
        query = <<-GQL
          query clients(
            $page: Int, $pageLength: Int, $locationIDs: [Int], $clientIDs: [Int],
            $onlineQuickCode: String, $deceased: Int, $firstName: String, 
            $lastName: String, $DOB: String, $fuzzy: Int, $fileType: Int
          ) {
            clients(
              page: $page, pageLength: $pageLength, locationIDs: $locationIDs,
              clientIDs: $clientIDs, onlineQuickCode: $onlineQuickCode, deceased: $deceased,
              firstName: $firstName, lastName: $lastName, DOB: $DOB, fuzzy: $fuzzy, fileType: $fileType
            ){
              clientID
              alerts
              DOB
              dateCreated
              dateModified
              employer
              title
              firstName
              middleName
              lastName
              fullName
              locationID
              notes
              occupation
              pensionNo
              privateHealthNo
              privateHealthType
              registrationDate
              active
              allergies
              allowOnlineBookings
              category
              consent
              deceased
              onlineQuickCode
            }
          }
        GQL
    
        variables = {
          page: page,
          pageLength: pageLength,
          locationIDs: locationIDs,
          clientIDs: clientIDs,
          onlineQuickCode: onlineQuickCode, # adjusted this to be just a String
          deceased: deceased,
          firstName: firstName,
          lastName: lastName,
          DOB: dob,
          fuzzy: fuzzy,
          fileType: fileType
        }
    
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{get_auth_token}" # assuming get_auth_token retrieves the token string
        }
    
        body = {
          query: query,
          variables: variables
        }.to_json
    
        response = post(BASE_URL, headers: headers, body: body)
    
        # Handle the response, log errors, return the data etc.
        if response.success?
            clients = response.parsed_response.dig("data", "clients")
            clients.map { |client| OpenStruct.new(client) } if clients
        else
          Rails.logger.error("NookalService Error: #{response.body}")
          nil
        end
      end

      # Method to add treatment notes to the Nookal API
      def self.add_treatment_note(clientID:, caseID:, apptID:, practitionerID:, date:, answers:, status:, templateID:)
        query = <<-GQL
          mutation addTreatmentNote(
            $clientID: Int, $caseID: Int, $apptID: Int, $practitionerID: Int, 
            $date: String, $answers: String, $status: String, $templateID: Int
          ){
            addTreatmentNote(
              clientID: $clientID, caseID: $caseID, apptID: $apptID, practitionerID: $practitionerID, 
              date: $date, answers: $answers, status: $status, templateID: $templateID
            ){
              noteID
              clientID
              caseID
              apptID
              practitionerID
              date
              answers
              status
              templateID
            }
          }
        GQL
      
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{get_auth_token}"
        }
      
        body = {
          query: query,
          variables: {
            clientID: clientID,
            caseID: caseID,
            apptID: apptID,
            practitionerID: practitionerID,
            date: date,
            answers: answers,
            status: status,
            templateID: templateID
          }
        }.to_json
      
        response = HTTParty.post(BASE_URL, headers: headers, body: body)
      
        if response.success?
          response.parsed_response.dig("data", "addTreatmentNote")
        else
          Rails.logger.error("NookalService Error: #{response.body}")
          nil
        end
      end

      # Method to fetch cases from the Nookal API
      def self.fetch_cases(clientIDs: [])
        Rails.logger.info("NookalService: Fetching cases")
        Rails.logger.info("Client IDs: #{clientIDs}")
        query = <<-GQL
          query cases($page: Int, $pageLength: Int, $caseIDs: [Int], $primaryProviderIDs: [Int], $clientIDs: [Int]){
            cases(page: $page, pageLength: $pageLength, caseIDs: $caseIDs, primaryProviderIDs: $primaryProviderIDs, clientIDs: $clientIDs){
              caseID
              clientID
              title
              startDate
              referralDate
              referrerID
              dateAdded
              notes
              primaryProviderID
            }
          }
        GQL
        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{get_auth_token}"
        }
      
        body = {
          query: query,
          variables: {
            clientIDs: clientIDs
          }
        }.to_json
        response = HTTParty.post(BASE_URL, headers: headers, body: body)
        if response.success?
          response.parsed_response.dig("data", "cases")
        else
          nil
        end
      end



      
    private
    # Method to store the token in the cache
    def self.store_token(token)
      Rails.cache.write("nookal_auth_token", token, expires_in: 1.hour) 
    end
  end
module DFESignIn
  class ExternalServerError < StandardError; end
  class ForbiddenRequestError < StandardError; end
  class UnknownResponseError < StandardError; end

  class API
    USERS_PAGE_SIZE = 275
    APPROVERS_PAGE_SIZE = 275

    def users(page: 1)
      perform_request('/users', page, USERS_PAGE_SIZE)
    end

    def approvers(page: 1)
      perform_request('/users/approvers', page, APPROVERS_PAGE_SIZE)
    end

    def invite_someone_to_service
      token = generate_jwt_token
      auth_string = "Bearer #{token}"
      request_params = {
        sourceId: rand(1000),
        given_name: "David",
        family_name: "Mears",
        email: "example@hotmail.co.uk",
        userRedirect: "https://teaching-vacancies.service.gov.uk/",
        organisation: "21E117E7-DF74-4B96-92F3-D883C399E959" # the id of the organisation in DfE Sign In. I derived this from the auth_hash json. This is Weydon
      }

      response = HTTP.auth(auth_string).post("#{DFE_SIGN_IN_URL}/services/#{DFE_SIGN_IN_SERVICE_ID}/invitations",
                                             json: request_params)
    end

  private

    def perform_request(endpoint, page, page_size)
      token = generate_jwt_token
      response = HTTParty.get(
        "#{DFE_SIGN_IN_URL}#{endpoint}?page=#{page}&pageSize=#{page_size}",
        headers: { 'Authorization' => "Bearer #{token}" },
      )

      raise ExternalServerError if response.code.eql?(500)
      raise ForbiddenRequestError if response.code.eql?(403)
      raise UnknownResponseError unless response.code.eql?(200)

      JSON.parse(response.body)
    end

    def generate_jwt_token
      payload = {
        iss: 'schooljobs',
        exp: (Time.now.getlocal + 60).to_i,
        aud: 'signin.education.gov.uk'
      }

      JWT.encode(payload, DFE_SIGN_IN_PASSWORD, 'HS256')
    end
  end

private

  def error_message_for(response)
    response['message'] || 'failed request'
  end

  def number_of_pages
    response = api_response
    raise(response['message'] || 'failed request') if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  def users_nil_or_empty?(response)
    response['users'].blank? || response['users'].first.blank?
  end

  def get_response_pages
    response_pages = []
    (1..number_of_pages).each do |page|
      response = api_response(page: page)
      if users_nil_or_empty?(response)
        Rollbar.log(:error,
                    'DfE Sign In API responded with nil users')
        raise error_message_for(response)
      end
      response_pages.push(response['users'])
    end
    response_pages
  end
end

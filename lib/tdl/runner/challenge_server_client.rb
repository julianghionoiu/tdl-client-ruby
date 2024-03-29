class ChallengeServerClient

    def initialize(hostname, port, journey_id, use_colours)
      @base_url = "http://#{hostname}:#{port}"
      @journey_id = journey_id
      use_colours ? @accept_header = 'text/coloured' : @accept_header = 'text/not-coloured'
    end
  
    def get_journey_progress
      get('journeyProgress')
    end
  
    def get_available_actions
      get('availableActions')
    end
  
    def get_round_description
      get('roundDescription')
    end
  
    def send_action(action)
      encoded_path = @journey_id.encode('utf-8')
      url = URI("#{@base_url}/action/#{action}/#{encoded_path}")
      response = Net::HTTP.post(url, "", {'Accept'=> @accept_header, 'Accept-Charset'=> 'UTF-8'})
      ensure_status_ok(response)
      response.body
    end
  
    private
  
    def get(name)
      journey_id_utf8 = @journey_id.encode('utf-8')
      url = URI("#{@base_url}/#{name}/#{journey_id_utf8}")
      response = Net::HTTP.get_response(url, {'Accept'=> @accept_header, 'Accept-Charset'=> 'UTF-8'})
      ensure_status_ok(response)
      response.body
    end
  
    def ensure_status_ok(response)
      if client_error?(response.code.to_i)
        raise ClientErrorException, response.body
      elsif server_error?(response.code.to_i)
        raise ServerErrorException, response.body
      elsif other_error_response?(response.code.to_i)
        raise OtherCommunicationException, response.body
      end
    end
  
    def client_error?(response_status)
      response_status >= 400 && response_status < 500
    end
  
    def server_error?(response_status)
      response_status >= 500 && response_status < 600
    end
  
    def other_error_response?(response_status)
      response_status < 200 || response_status > 300
    end
  
    class ClientErrorException < RuntimeError
      # def initialise(message)
      #   @response_message = message
      # end
      #
      # def get_response_message
      #   @response_message
      # end
    end
  
    class ServerErrorException < RuntimeError
      # def initialise(message)
      #   @response_message = message
      # end
      #
      # def get_response_message
      #   @response_message
      # end
    end
  
    class OtherCommunicationException < RuntimeError
      # def initialise(message)
      #   @response_message = message
      # end
      #
      # def get_response_message
      #   @response_message
      # end
    end
  end
  
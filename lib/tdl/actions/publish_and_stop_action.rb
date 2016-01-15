module TDL
  class PublishAndStopAction

    def audit_text
      ''
    end

    def after_response(remote_broker, request, response)
      remote_broker.respond_to(request, response)
    end

    def prepare_for_next_request(remote_broker)
      remote_broker.close
    end
  end
end

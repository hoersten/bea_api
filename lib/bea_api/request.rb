module BeaApi
  # => BeaApi::Request
  class Request
    require 'restclient'
    require 'json'

    attr_accessor :response, :error_code, :error_msg
    InvalidKey = 3 # APIErrorCode 3: The BEA API UserID provided in the request does not exist.

    BEA_URL = 'http://www.bea.gov/api/data'

    def self.find(options = {})
      uri = "#{BEA_URL}?#{self.to_params(options)}"
      response = Request.new(uri)
    end

    def initialize(uri)
      @response = RestClient.get(uri.to_s)
      _parse_response
    end

    protected

    def _parse_response
      case @response.code
      when 200
        _response_success(@response)
      else
        _response_error(@response)
      end
    end

    def self.to_params(options)
      options.map { |k,v| "#{k}=#{v}" }.join("&")
    end

    def _response_success(response)
      r = JSON.parse(response)
      h = []
      if (r.length > 0)
        h = r["BEAAPI"]["Results"].first.last
      end
      h
    end

    def _response_error(response)
      r = JSON.parse(response.body)
      puts r["BEAAPI"]["Results"]
      {
        code: response.code,
        location: response.headers[:location],
        error_code: r["BEAAPI"]["Results"].first,
        error_msg: r["BEAAPI"]["Results"].last
      }
    end

  end
end

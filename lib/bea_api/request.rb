module BeaApi
  # => BeaApi::Request
  class Request
    require 'restclient'
    require 'json'

    attr_accessor :response, :notes
    InvalidKey       = 3   # APIErrorCode 3: The BEA API UserID provided in the request does not exist.

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
        _response_html_success(@response)
      else
        _response_html_error(@response)
      end
    end

    def self.to_params(options)
      options.map { |k,v| "#{k}=#{v}" }.join("&")
    end

    def _response_html_success(response)
      r = JSON.parse(response)
      if (!r["BEAAPI"]["Error"].nil? || r["BEAAPI"]["Results"].first.first.to_s.downcase == 'error')
        @response = _response_error(r)
      else
        @response = _response_success(r)
      end
    end

    def _response_success(response)
      h = []
      if (response.length > 0)
        h = _parse_data(response)
        h = [h] unless (h.kind_of?(Array))
        @notes = _parse_notes(response)
      end
      h
    end

    def _parse_data(response)
      if (!response["BEAAPI"]["Results"]["Data"].nil?)
        h = response["BEAAPI"]["Results"]["Data"]
      elsif (!response["BEAAPI"]["Data"].nil?)
        h = response["BEAAPI"]["Data"]
      else
        h = response["BEAAPI"]["Results"].first[1]
      end
      h
    end

    def _parse_notes(response)
      if (!response["BEAAPI"]["Results"]["Notes"].nil?)
        notes = response["BEAAPI"]["Results"]["Notes"]
      elsif (!response["BEAAPI"]["Notes"].nil?)
        notes = response["BEAAPI"]["Notes"]
      end
      notes
    end

    def _response_error(r)
      if (!r["BEAAPI"]["Error"].nil?)
        err = r["BEAAPI"]["Error"]
      else
        err = r["BEAAPI"]["Results"].first.last
      end
      if (err["APIErrorCode"].to_i == InvalidKey)
        fail InvalidKeyError, "'#{api_key}' is not a valid API key. Check your key for errors, or request a new one at http://www.bea.gov/api/" 
      end
      fail ParameterError, err["APIErrorDescription"]
    end

    def _response_html_error(response)
      fail StandardError, response.code + "\n" + response.body
    end

  end
end

module BeaApi
  # => BeaApi::Request
  class Request
    require 'restclient'
    require 'json'

    attr_accessor :response, :error_code, :error_msg, :notes
    Success          = 0   # Sucess, no errors
    InvalidKey       = 3   # APIErrorCode 3: The BEA API UserID provided in the request does not exist.
    MissingParams    = 40  # APIErrorCode 40: The dataset requested requires parameters that were missing from the request
    RetrivalError    = 201 # APIErrorCode 201: Error retrieving NIPA/Fixed Assets data
    GDPRetrivalError = 204 # APIErrorCode 204: Error retrieving GDP by Industry data

    BEA_URL = 'http://www.bea.gov/api/data'

    def self.find(options = {})
      uri = "#{BEA_URL}?#{self.to_params(options)}"
      response = Request.new(uri)
    end

    def initialize(uri)
      @error_code = Request::Success
      @error_msg  = ""
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
        @response = _response_error(response, r)
      else
        @response = _response_success(r)
      end
    end

    def _response_success(response)
      h = []
      if (response.length > 0)
        if (!response["BEAAPI"]["Results"]["Data"].nil?)
          h = response["BEAAPI"]["Results"]["Data"]
        elsif (!response["BEAAPI"]["Data"].nil?)
          h = response["BEAAPI"]["Data"]
        else
          h = response["BEAAPI"]["Results"].first[1]
        end
        if (!h.kind_of?(Array))
          h = [h]
        end
        if (!response["BEAAPI"]["Results"]["Notes"].nil?)
          @notes = response["BEAAPI"]["Results"]["Notes"]
        elsif (!response["BEAAPI"]["Notes"].nil?)
          @notes = response["BEAAPI"]["Notes"]
        end
      end
      h
    end

    def _response_error(response, r)
      if (!r["BEAAPI"]["Error"].nil?)
        @error_code = r["BEAAPI"]["Error"]["APIErrorCode"].to_i
        @error_msg  = r["BEAAPI"]["Error"]["APIErrorDescription"]
      else
        @error_code = r["BEAAPI"]["Results"].first.last["APIErrorCode"].to_i
        @error_msg  = r["BEAAPI"]["Results"].first.last["APIErrorDescription"]
      end
      {
        code: response.code,
        location: response.headers[:location],
        error_code: @error_code,
        error_msg:  @error_msg
      }
    end

    def _response_html_error(response)
      {
        code: response.code,
        location: response.headers[:location],
        body: response.body
      }
    end

  end
end

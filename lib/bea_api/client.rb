module BeaApi
  # => BeaApi::Client
  # client#initialize method takes an api_key
  class Client
    attr_reader :api_key
    attr_reader :datasets 

    def datasets
      [ :RegionalData, :NIPA, :NIUnderlyingDetail, :MNE, :FixedAssets, :ITA, :IIP, :GDPbyIndustry ]
    end

    def initialize(api_key)
      fail ArgumentError, 'You must set an api_key.' unless api_key
      _validate_api_key(api_key)
    end

    def get_datasets()
      _method(nil, 'GetDataSetList', {})
    end

    def get_parameters(dataset)
      fail ArgumentError, 'Invalid dataset.' unless datasets.include?(dataset)
      _method(dataset, 'GetParameterList', {})
    end

    def get_parameter_values(dataset, parameter)
      fail ArgumentError, 'Invalid dataset.' unless datasets.include?(dataset)
      fail ArgumentError, 'Invalid parameter name.' unless parameter
      _method(dataset, 'GetParameterValues', {parametername: parameter})
    end

    def get_data(dataset, fields)
      fail ArgumentError, 'Invalid dataset.' unless datasets.include?(dataset)
      fail ArgumentError, 'Invalid fields.' unless fields.class == Hash && !fields.empty?
      _method(dataset, 'GetData', fields)
    end

    protected
    def _validate_api_key(api_key)
      @api_key = api_key
      response = get_datasets()
      if response.error_code == Request::InvalidKey
        @api_key = nil
        fail "'#{api_key}' is not a valid API key. Check your key for errors,
        or request a new one at http://www.bea.gov/api/"
      end
    end

    def _method(dataset, method, options)
      fail ArgumentError, 'You must include a dataset.' unless dataset || method.downcase == 'getdatasetlist'
      options.merge!(userid: @api_key, datasetname: dataset, method: method.downcase)
      Request.find(options)
    end

  end
end

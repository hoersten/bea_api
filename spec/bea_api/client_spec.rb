require 'spec_helper'

describe BeaApi::Client do

  describe 'client initialization' do

    it 'should not initialize without an api_key' do
      expect { BeaApi::Client.new(nil) }.to raise_error(ArgumentError)
    end

    it 'should not initialize with an invalid api_key' do
      VCR.use_cassette('initialize_client_failure') do
        expect { BeaApi::Client.new('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX') }.to raise_error(BeaApi::InvalidKeyError, /is not a valid API key/)
      end
    end

    it 'should initialize with an api_key' do
      VCR.use_cassette('initialize_client') do
        expect { @client = BeaApi::Client.new(api_key) }.not_to raise_error
        expect(@client.api_key).to eq(api_key)
      end
    end

    it 'should throw an HTTP error' do
      VCR.use_cassette('initialize_http_error') do
        url = BeaApi::Request::BEA_URL
        begin
          expect { BeaApi::Request::BEA_URL = 'http://example.com/404' }.to output(/already initialized constant/).to_stderr
          expect { @client = BeaApi::Client.new(api_key) }.to raise_error
        ensure
          expect { BeaApi::Request::BEA_URL = url }.to output(/already initialized constant/).to_stderr
        end
      end
    end
  end

  describe 'get datasets' do

      it 'should get all the datasets' do
        VCR.use_cassette('get_datasets') do
          @client = BeaApi::Client.new(api_key)
          @datasets = @client.get_datasets()
          expect(@datasets.response.count).to eq(@client.datasets.count)
          @datasets.response.each do |r|
            expect(@client.datasets).to include(r["DatasetName"].to_sym)
          end
        end
      end
  end

  describe 'get parameters' do

      it 'should not get parameters for an invalid dataset' do
        VCR.use_cassette('get invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect {@client.get_parameters("InvalidDataset") }.to raise_error(ArgumentError)
        end
      end

      it 'should get parameters for each dataset' do
        VCR.use_cassette('get_parmeters') do
          @client = BeaApi::Client.new(api_key)
          @client.datasets.each do |d|
            p = @client.get_parameters(d)
            expect(p.response.count).not_to eq(0)
          end
        end
      end
  end

  describe 'get parameter values' do

      it 'should not get parameter values for an invalid dataset' do
        VCR.use_cassette('get invalid parameter values') do
          @client = BeaApi::Client.new(api_key)
          expect {@client.get_parameter_values("InvalidDataset", '') }.to raise_error(ArgumentError)
        end
      end

      it 'should not get parameters values for an invalid parameter' do
        VCR.use_cassette('get invalid parameter values') do
          @client = BeaApi::Client.new(api_key)
          expect {@client.get_parameters(@client.datasets.first, '') }.to raise_error(ArgumentError)
        end
      end

      it 'should get parameters values for each dataset' do
        VCR.use_cassette('get_parmeter_values') do
          @client = BeaApi::Client.new(api_key)
          @client.datasets.each do |d|
            p = @client.get_parameters(d)
            expect(p.response.count).not_to eq(0)
            r = p.response.first
            n = @client.get_parameter_values(d, r['ParameterName'])
            expect(n.response.count).not_to eq(0)
          end
        end
      end
  end

  describe 'get data' do
    it 'should not get data for an invalid dataset' do
      VCR.use_cassette('get invalid data dataset') do
        @client = BeaApi::Client.new(api_key)
        expect {@client.get_data("InvalidDataset", '') }.to raise_error(ArgumentError)
      end
    end
    it 'should not get data values for an invalid parameter' do
      VCR.use_cassette('get invalid data options') do
        @client = BeaApi::Client.new(api_key)
        dataset = @client.datasets.first
        expect {@client.get_data(dataset, {}) }.to raise_error(ArgumentError)
        expect {@client.get_data(dataset, nil) }.to raise_error(ArgumentError)
        expect {@client.get_data(dataset, "") }.to raise_error(ArgumentError)
      end
    end

    describe 'RegionalData' do
      dataset = :RegionalData
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for RegionalData with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "KeyCode" => "PCPI_CI", "GeoFIPS" => "STATE:00000,01000,02000,04000", "Year" => 3009 } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for RegionalData with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "KeyCode" => "PCPI_CI", "GeoFIPS" => "STATE:00000,01000,02000,04000", "Year" => 2009 } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'NIPA' do
      dataset = :NIPA
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for NIPA with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "TableID" => 0, "Frequency" => "A", "Year" => 2009 } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for NIPA with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "TableID" => 1, "Frequency" => "A", "Year" => 2009 } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'NI Underlying Detail' do
      dataset = :NIUnderlyingDetail
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for NI Underlying Detail with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "TableID" => 1, "Frequency" => "A", "Year" => 2009 } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for NI Underlying Detail with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "TableID" => 79, "Frequency" => "A", "Year" => 2004 } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'MNE' do
      dataset = :MNE
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for MNE with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "DirectionOfInvestment" => 'inval', "Classification" => "", "Year" => 2009, "State" => "01" } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for MNE with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "DirectionOfInvestment" => 'inward', "Classification" => "Country", "Year" => 2009, "State" => "01" } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'Fixed Assets' do
      dataset = :FixedAssets
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for FixedAssets with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "TableID" => 0, "Year" => 2009 } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for FixedAssets with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "TableID" => 1, "Year" => 2009 } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'ITA' do
      dataset = :ITA
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for ITA with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "Frequency" => "A", "Year" => 2009 } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for ITA with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "Indicator" => "CurrAndDepLiabsFoa", "Frequency" => "A", "Year" => 2009 } )
          expect(r.response.count).to eq(1)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for ITA with 2 valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "Indicator" => "CurrAndDepLiabsFoa", "Frequency" => "A", "Year" => "2009,2010" } )
          expect(r.response.count).to eq(2)
        end
      end
    end
 
    describe 'IIP' do
      dataset = :IIP
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for IIP with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "Frequency" => "A" } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for IIP with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "Frequency" => "A", "Year" => 2009 } )
          expect(r.response.count).to be > 0
        end
      end
    end

    describe 'GDPbyIndustry' do
      dataset = :GDPbyIndustry
      it 'should not get data values for invalid parameters' do
        VCR.use_cassette('get data for GDP by Industy with invalid parameters') do
          @client = BeaApi::Client.new(api_key)
          expect { @client.get_data(dataset, { "Industry" => "12" } ) }.to raise_error(BeaApi::ParameterError)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for GDP by Frequency with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "Industry" => "GDP", "TableID" => 1, "Frequency" => "A", "Year" => 2009 } )
          expect(r.response.count).to eq(1)
        end
      end
      it 'should get data values for valid parameters' do
        VCR.use_cassette('get data for GDP by Frequency with valid parameters') do
          @client = BeaApi::Client.new(api_key)
          r = @client.get_data(dataset, { "Industry" => "GDP", "TableID" => 1, "Frequency" => "A", "Year" => "2009,2010" } )
          expect(r.response.count).to eq(2)
        end
      end
    end
 
  end
end

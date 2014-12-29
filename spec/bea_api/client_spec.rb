require 'spec_helper'

describe BeaApi::Client do

  describe 'client initialization' do

      VCR.use_cassette('initialize_client_failure') do
        it 'should not initialize without an api_key' do
          expect(lambda { BeaApi::Client.new }).to raise_error
        end
      end

      it 'should initialize with an api_key' do
        VCR.use_cassette('initialize_client') do
          @client = BeaApi::Client.new(api_key)
          expect(@client.api_key).to eq(api_key)
        end
      end
  end
=begin
  describe 'client and dataset initialization' do

    use_vcr_cassette 'initialize_client_and_dataset'

    it 'should initialize with an api_key and dataset' do
      dataset = 'SF1'
      @client = BeaApi::Client.new(api_key, dataset: dataset)
      @client.api_key.should == api_key
      @client.dataset.should == dataset.downcase
    end
  end

  describe 'datasets' do

    use_vcr_cassette 'find_method'
    describe 'sf1' do
      let(:source) { 'sf1' }
      let(:options) do
        { key: api_key,
          vintage: 2010,
          fields: 'P0010001',
          level: 'STATE:06',
          within: [] }
      end

      it 'should request sf1' do
        @client = BeaApi::Client.new(api_key, dataset: source)
        BeaApi::Request.should_receive(:find).with(@client.dataset, options)
        @client.where(options)
      end
    end

    describe 'acs5' do
      let(:source) { 'acs5' }
      let(:options) do
        { key: api_key,
          vintage: 2010,
          fields: 'B00001_001E',
          level: 'STATE:06',
          within: [] }
      end

      it 'should request acs5' do
        @client = BeaApi::Client.new(api_key, dataset: source)
        BeaApi::Request.should_receive(:find).with(@client.dataset, options)
        @client.where(options)
      end
    end
  end

  describe '#find' do

    use_vcr_cassette 'find_method'

    let(:source) { 'sf1' }
    let(:options) do
      { key: api_key,
        vintage: 2010,
        fields: 'P0010001',
        level: 'STATE:06',
        within: [] }
    end

    it 'should be deprecated' do
      @client = BeaApi::Client.new(api_key, dataset: source)
      @client.should_receive(:warn)
      .with('[DEPRECATION] `find` is deprecated. Please use `where` instead.')
      @client.find(options[:fields], options[:level])
    end
  end

  describe '#where' do
    use_vcr_cassette 'where_method'

    let(:source) { 'sf1' }

    let(:options) do
      {
        key: api_key,
        vintage: 2010,
        fields: 'P0010001',
        level: 'STATE:06',
        within: []
      }
    end

    let(:full_params) do
      options.merge!(level: 'COUNTY:001', within: 'STATE:06')
    end

    it 'should raise if missing fields params' do
      @client = BeaApi::Client.new(api_key, dataset: source)
      expect { @client.where(fields: options[:fields]) }
      .to raise_error(ArgumentError)
    end

    it 'should raise if missing level params' do
      @client = BeaApi::Client.new(api_key, dataset: source)
      expect { @client.where(level: options[:level]) }
      .to raise_error(ArgumentError)
    end

    it 'should request sf1 with valid fields and level params' do
      @client = BeaApi::Client.new(api_key, dataset: source)
      BeaApi::Request.should_receive(:find)
      .with(@client.dataset, options)
      expect { @client.where(options) }.not_to raise_error
    end

    it 'should request sf1 with valid fields, level and within params' do
      @client = BeaApi::Client.new(api_key, dataset: source)
      BeaApi::Request.should_receive(:find)
      .with(@client.dataset, full_params)
      expect { @client.where(full_params) }.not_to raise_error
    end
  end
=end
end

#BEA API
[![Circle CI](https://circleci.com/gh/hoersten/bea_api/tree/master.svg?style=svg)](https://circleci.com/gh/hoersten/bea_api/tree/master) [![Code Climate](https://codeclimate.com/github/hoersten/bea_api/badges/gpa.svg)](https://codeclimate.com/github/hoersten/bea_api)

Ruby wrapper for the US Bureau of Economic Analysis (BEA) API.  BEA is an agency of the United States Department of Commerce that produces economic accounts statistics.  The API provides access to regional, national, industrial and international economic statistics.  http://www.bea.gov/about/mission.htm

##Obtaining an API key
To be able to use this gem, you'll need a US Bureau of Economic Analysis API key. To request an API key, visit http://www.bea.gov/api/ and follow the instructions.

##Installing the gem
To use this gem, install it with ```gem install bea_api```  
Or add it to your Gemfile: ```gem 'bea_api'``` and install it with ```bundle install```

##Usage / Retrieving BEA Data

###(Recommended) Set the API key as an environment variable
Once you have the API key, you may want to store it as an environment variable.

```sh
$ export $BEA_API_KEY='your-api-key'
```
###Register a New Client
```ruby
@client = BeaApi::Client.new(ENV['BEA_API_KEY']) # from the environment variable
@client = BeaApi::Client.new(API_KEY) 
```
###Query a Dataset

####Parameters
Each of the datasets have different required fields and optional parameters.  See http://www.bea.gov/API/docs/ for the full list of available parameters.

####Example
To get the 2013 GDP data for Alabama, Illinois and California:
```ruby
@client = BeaApi::Client.new(ENV['BEA_API_KEY']) # Create the client
results = @client.get_data(:RegionalData, { "Year" => 2013, "KeyCode" => "GDP_SP", "GEOFIPS" => "STATE:01000,17000,060000" } ) # Use the RegionalData dataset and use the parameters based upon their requirements
results.response  # An array of hashes of the results from the call
```
```ruby
results.response
=> [
{"GeoFips"=>"01000", "GeoName"=>"Alabama", "Code"=>"GDP_SP", "TimePeriod"=>"2013", "CL_UNIT"=>"USD", "UNIT_MULT"=>"6", "DataValue"=>"193566"}, 
{"GeoFips"=>"06000", "GeoName"=>"California", "Code"=>"GDP_SP", "TimePeriod"=>"2013", "CL_UNIT"=>"USD", "UNIT_MULT"=>"6", "DataValue"=>"2202678"}, 
{"GeoFips"=>"17000", "GeoName"=>"Illinois", "Code"=>"GDP_SP", "TimePeriod"=>"2013", "CL_UNIT"=>"USD", "UNIT_MULT"=>"6", "DataValue"=>"720692"}
] 
```

###Retrieving Metadata
The BEA API provides three methods for pulling metadata information.  
1) **BeaApi::Client::get_datasets()** - pulls all the datasets available from the BEA  
**Example**
```ruby
  results = @client.get_datasets()
```
```ruby
results.response
=> [
{"DatasetName"=>"RegionalData", "DatasetDescription"=>"Retrieves various Regional datasets"}, 
{"DatasetName"=>"NIPA", "DatasetDescription"=>"Standard NIPA tables"}, 
{"DatasetName"=>"NIUnderlyingDetail", "DatasetDescription"=>"Standard NI underlying detail tables"}, 
{"DatasetName"=>"MNE", "DatasetDescription"=>"Multinational Enterprises"}, 
{"DatasetName"=>"FixedAssets", "DatasetDescription"=>"Standard Fixed Assets tables"}, 
{"DatasetName"=>"ITA", "DatasetDescription"=>"International Transactions Accounts"}, 
{"DatasetName"=>"IIP", "DatasetDescription"=>"International Investment Position"}, 
{"DatasetName"=>"GDPbyIndustry", "DatasetDescription"=>"GDP by Industry"}
]
```
2) **BeaApi::Client::get_parameters(dataset)** - pulls the parameters available for get_data for the given dataset  
```ruby
results = @client.get_parameters(:RegionalData)
```
```ruby
results.response
=> [
{"ParameterName"=>"KeyCode", "ParameterDataType"=>"string", "ParameterDescription"=>"The code of the key statistic requested", "ParameterIsRequiredFlag"=>"1", "MultipleAcceptedFlag"=>"0"}, 
{"ParameterName"=>"GeoFips", "ParameterDataType"=>"string", "ParameterDescription"=>"GeoFips Code", "ParameterIsRequiredFlag"=>"0", "MultipleAcceptedFlag"=>"1"}, 
{"ParameterName"=>"Year", "ParameterDataType"=>"integer", "ParameterDescription"=>"Year", "ParameterIsRequiredFlag"=>"0", "ParameterDefaultValue"=>"ALL", "MultipleAcceptedFlag"=>"1", "AllValue"=>"ALL"}
] 
```
3) **BeaApi::Client::get_parameter_values(dataset, parameter)** - pulls the possible values for a specific parameter for the given dataset's get_data  
```ruby
results = @client.get_parameter_values(:RegionalData, "KeyCode")
```
```ruby
results.response
=> [
{"KeyCode"=>"GDP_SP", "Description"=>"GDP in current dollars (state annual product)"}, 
{"KeyCode"=>"RGDP_SP", "Description"=>"Real GDP in chained dollars (state annual product)"}, 
{"KeyCode"=>"PCRGDP_SP", "Description"=>"Per capita real GDP (state annual product)"}, 
{"KeyCode"=>"COMP_SP", "Description"=>"Compensation of employees (state annual product)"}, 
{"KeyCode"=>"TOPILS_SP", "Description"=>"Taxes on production and imports less subsidies (state annual product)"}, 
{"KeyCode"=>"GOS_SP", "Description"=>"Gross operating surplus (state annual product)"}, 
{"KeyCode"=>"SUBS_SP", "Description"=>"Subsidies (state annual product)"}, 
{"KeyCode"=>"TOPI_SP", "Description"=>"Taxes on production and imports (state annual product)"}, 
{"KeyCode"=>"GDP_MP", "Description"=>"GDP in current dollars (MSA annual product)"}, 
{"KeyCode"=>"RGDP_MP", "Description"=>"Real GDP in chained dollars (MSA annual product)"}, 
{"KeyCode"=>"PCRGDP_MP", "Description"=>"Per capita real GDP (MSA annual product)"}, 
{"KeyCode"=>"TPI_SI", "Description"=>"Total personal income (state annual income)"}, 
{"KeyCode"=>"POP_SI", "Description"=>"Population (state annual income)"}, 
{"KeyCode"=>"PCPI_SI", "Description"=>"Per capita personal income (state annual income)"}, 
{"KeyCode"=>"NFPI_SI", "Description"=>"Nonfarm personal income (state annual income)"}, 
{"KeyCode"=>"FPI_SI", "Description"=>"Farm income (state annual income)"}, 
{"KeyCode"=>"EARN_SI", "Description"=>"Earnings by place of work (state annual income)"}, 
{"KeyCode"=>"CGSI_SI", "Description"=>"Contributions for government social insurance (state annual income)"}, 
{"KeyCode"=>"AR_SI", "Description"=>"Adjustment for residence (state annual income)"}, 
{"KeyCode"=>"NE_SI", "Description"=>"Net earnings by place of residence (state annual income)"}, 
{"KeyCode"=>"DIR_SI", "Description"=>"Dividends, interest, and rent (state annual income)"}, 
{"KeyCode"=>"PCTR_SI", "Description"=>"Personal current transfer receipts (state annual income)"}, 
...
]
```

require "bloom_api/version"
require "uri/http"

# A module which contains all code necessary for
# looking up health care providers via the Bloom API.
#
# For more details visit http://www.bloomapi.com/
#
# @author Dan Carpenter
module BloomApi

  require "bloom_api/provider"
  require "bloom_api/address"
  require "bloom_api/identifier"
  require "bloom_api/individual"
  require "bloom_api/organization"
  require "bloom_api/organization_official"
  require "bloom_api/specialty"
  require "bloom_api/medicare_specialty"

  # A custom exception for when no provider is found when performing a lookup.
  class ProviderNotFound < Exception; end

  # The base url for the bloom api.
  BASE_URL = "www.bloomapi.com"

  # API Key for the bloom api.
  @@api_key = nil

  def self.api_key
    @@api_key
  end

  def api_key
    @@api_key
  end

  def self.api_key=(api_key)
    @@api_key = api_key
  end

  # Look up a health care provider or organization by the provided criteria
  #
  # @params options [Hash] criteria to filter results by
  # @params limit [Integer] optional, sets the maximum number of records to return. Default is 20 and maximum is 100
  # @params offset [Integer] optional, sets a number of records to skip before returning. Default is 0
  # @return results [Array] Array of providers and/or organizations that match the criteria
  def self.find_by(options, limit=20, offset=0)
    criteria = options.each_with_index.map {|x,i| "key#{i+1}=#{URI::escape(x[0].to_s)}&op#{i+1}=eq&value#{i+1}=#{URI::escape(x[1])}"} || []
    criteria << "limit=#{limit}&offset=#{offset}"
    criteria << "secret=#{api_key}" if api_key
		uri = URI::HTTP.build(host: BASE_URL, path: '/api/search/npi', query: criteria.join('&'))
		response = Net::HTTP.get_response(uri)

    build_provider(JSON.parse(response.body)['result']) if response && response.code == "200"
  end

  # Look up a health care provider by their national provider identifier
  #
  # @params npi [String] The national provider identifier to be used for lookup
  # @return [BloomApi::Individual] if the npi references an individual provider
  # @return [BloomApi::Organization] if the npi references an organization
  #
  # @raise [ProviderNotFound] if the provided npi does not reference a provider
  def self.find_by_npi(npi)
    path = "/api/npis/#{npi}"
    path += "?secret=#{api_key}" if api_key
    response = Net::HTTP.get_response(BASE_URL, path)

    build_provider(JSON.parse(response.body)['result']) if response && response.code == "200"
  end

  # Look up Medicare Provider/Supplier Type to Healthcare Provider Taxonomy
  #
  # @params code [String] Provider taxonomy code (e.g. 2086S0122X)
  # @return [BloomApi::MedicareSpecialty] if the code matches one or more record
  def self.find_by_specialty_code(code)
    criteria = ["key1=nucc_taxonomy_codes.code&op1=eq&value1=#{URI::escape(code)}"]
    criteria << "secret=#{api_key}" if api_key

    path = '/api/search/usgov.hhs.medicare_specialty_codes'

    uri = URI::HTTP.build(host: BASE_URL, path: path, query: criteria.join('&'))
    response = Net::HTTP.get_response(uri)

    build_medicare_specialty(JSON.parse(response.body)['result']) if response && response.code == "200"
  end

  private

  def self.build_provider(response)
    if response.is_a?(Array)
			response.map { |r| build_provider(r) }
    else
	    return Individual.new(response) if response['type'] == 'individual'
	    return Organization.new(response) if response['type'] == 'organization'
	    Provider.new(response)
    end
  end

  def self.build_medicare_specialty(response)
    if response.is_a?(Array)
      response.map { |r| build_medicare_specialty(r) }
    else
      return MedicareSpecialty.new(response)
    end
  end

end

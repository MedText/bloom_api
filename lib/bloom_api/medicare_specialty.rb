module BloomApi

  # A class representing a medicare specialty
  #
  class MedicareSpecialty

    # Creates a new specialty
    # @param raw_detail [Hash]
    #   A hash representation of a json specialty object
    #   from the Bloom Api
    def initialize raw_detail
      @raw_detail = raw_detail
    end

    # @return [String]
    #   Medicare specialty code
    def code
      @raw_detail['code']
    end

    # @return [String]
    #   Medicare provider/supplier type description
    def description
      @raw_detail['description']
    end
  end

end

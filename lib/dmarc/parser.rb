module DMARC
  #
  # DMARC parser.
  #
  # @see https://tools.ietf.org/html/rfc7489#section-6.4
  #
  class Parser
    def self.parse(record)
      parsed_record = record.split(';').map do |tag|
        tags = tag.split('=')
        tags.each(&:strip!)
        tags.length < 2 ? tags << nil : tags
      end

      parsed_record = parsed_record.to_h.transform_keys(&:to_sym)
      
      transform(parsed_record)
    end

    def self.transform(record)
      record[:rua] = record[:rua].split(',') if record[:rua]
      record[:ruf] = record[:ruf].split(',') if record[:ruf]
      record[:fo] = record[:fo]&.split(':')
      record
    end
  end
end

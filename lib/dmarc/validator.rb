require 'uri'

module DMARC
  class Validator
    REQUIRED_VALIDATIONS = {
      p: %w[none quarantine reject],
      sp: %w[none quarantine reject],
      v: 'DMARC1'
    }.freeze
    OPTIONAL_VALIDATIONS = {
      fo: %w[0 1 d s],
      rf: %w[afrf iodef],
      aspf: %w[r s],
      adkim: %w[r s],
    }.freeze
    URI_FORMAT = 'mailto:username@somehost.com'.freeze

    def self.validate(record)
      sane_validation(record, REQUIRED_VALIDATIONS)
      sane_validation(record, OPTIONAL_VALIDATIONS, optional: true)
      validate_uris(record)
      validate_ranges(record)
      record
    end

    private

      def self.sane_validation(record, validation, optional: false)
        validation.each do |tag, expcted_value|
          tag_value = record.send(tag)
          next if optional && tag_value.nil?

          success = if [Range, Array].include?(expcted_value.class)
            # Handle case for :fo tag.
            if tag_value.is_a?(Array)
              (tag_value && expcted_value) == expcted_value
            else
              expcted_value.include? tag_value
            end
          else
            tag_value == expcted_value
          end

          next if success

          record.errors << Error.new(tag, tag_value, expcted_value)
        end
      end

      def self.validate_uris(record)
        %i[rua ruf].each do |tag|
          tag_value = record.send(tag)

          tag_value.each do |uri|
            URI.parse uri
          rescue
            record.errors << Error.new(tag, uri, URI_FORMAT)
          end
        end
      end

      def self.validate_ranges(record)
        # pct: 0..100,
        # ri: 0..86400
      end
  end
end

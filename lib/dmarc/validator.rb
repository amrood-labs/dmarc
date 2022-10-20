module DMARC
  class Validator
    REQUIRED_VALIDATIONS = {
      p: %w[none quarantine reject],
      sp: %w[none quarantine reject],
      v: 'DMARC1'
    }

    OPTIONAL_VALIDATIONS = {
      fo: %w[0 1 2 3],
      rf: %w[afrf iodef],
      aspf: %w[r s],
      adkim: %w[r s],
      pct: 0..100,
      ri: 0..86400
    }

    def self.validate(record)
      sane_validation(record, REQUIRED_VALIDATIONS)
      sane_validation(record, OPTIONAL_VALIDATIONS, optional: true)
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
  end
end

module DMARC
  class Error
    attr_accessor :tag, :current_value, :expected_value

    def initialize(tag, current_value, expected_value)
      @tag = tag
      @current_value = current_value
      @expected_value = expected_value
    end

    def to_s
      msg = "Invalid #{tag} tag. Current value is "
      msg <<  if current_value.is_a?(Array)
                current_value.join(':')
              elsif current_value.blank?
                'blank'
              else
                current_value.to_s
              end
      msg << ". Value should be "
      msg << if [Range, Array].include?(expected_value.class)
        if current_value.is_a?(Array)
          # Handle case for :fo tag.
          "one or more colon-separated list of characters from #{expected_value.join(', ')}"
        else
          "one of these: #{expected_value.join(', ')}"
        end
      else
        expected_value
      end
    end
  end
end

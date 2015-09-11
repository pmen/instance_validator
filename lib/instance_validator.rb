module InstanceValidator

  class << self

    # Allows us to use easily use default validators in instance methods with the same syntax &
    # behavior as class-level validations
    #
    # Based on ActiveModel::Validations::ClassMethods#validates
    def validates(record, *attributes)
      initial_error_count = record.errors.count
      validations = attributes.extract_options!

      raise ArgumentError, 'You need to supply at least one attribute' if attributes.empty?
      raise ArgumentError, 'You need to supply at least one validation' if validations.empty?

      validations.each do |key, options|
        next unless options
        key = "#{key.to_s.camelize}Validator"

        begin
          validator = ActiveModel::Validations.const_get(key)
        rescue NameError
          raise ArgumentError, "Unknown validator: '#{key}'"
        end

        options = {} if options.is_a? TrueClass
        validator.new(options.merge(attributes: attributes)).validate(record)
      end

      record.errors.count == initial_error_count
    end

  end
end

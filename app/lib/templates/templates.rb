# frozen_string_literal: true

module Templates
  class Templates
    class << self
      private

      def read_template(file_name)
        File.read(file_name)
      end
    end
  end
end

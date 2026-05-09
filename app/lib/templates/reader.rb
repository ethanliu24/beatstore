# frozen_string_literal: true

module Templates
  module Reader
    module_function
    def read_template(file_name)
      File.read(file_name)
    end
  end
end

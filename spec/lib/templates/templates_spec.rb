# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::Templates do
  describe ".read_template (via send)" do
    subject(:call) { described_class.send(:read_template, file_path) }

    let(:file_path) { Rails.root.join("tmp/test_template.md").to_s }

    before do
      File.write(file_path, "hello template")
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    it "reads the file content" do
      expect(call).to eq("hello template")
    end
  end

  describe ".read_template when file is missing" do
    subject(:call) { described_class.send(:read_template, "missing_file.md") }

    it "raises an error from File.read" do
      expect { call }.to raise_error(Errno::ENOENT)
    end
  end
end

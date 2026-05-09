# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::Reader do
  describe ".read_template (via send)" do
    let(:file_path) { Rails.root.join("tmp/test_template.md").to_s }

    before do
      File.write(file_path, "hello template")
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    it "reads the file content" do
      expect(described_class.read_template(file_path)).to eq("hello template")
    end
  end

  describe ".read_template when file is missing" do
    subject(:file_path) { "missing" }

    it "raises an error from File.read" do
      expect { described_class.read_template(file_path) }.to raise_error(Errno::ENOENT)
    end
  end
end

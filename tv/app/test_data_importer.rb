# frozen_string_literal: true

# Import test data into TestData
class TestDataImporter
  def initialize(file_system)
    @file_system = file_system
  end

  def import(rspec_json, metadata)
    test_run = RunData.new
    test_run.create_run_directory
    save_rspec_output(test_run.local_test_run_id, rspec_json)
    save_metadata(test_run.local_test_run_id, JSON.generate(metadata))
    test_run.local_test_run_id
  end

  def save_rspec_output(local_test_run_id, rspec_json)
    @file_system.with_rspec_file(local_test_run_id, 'w') do |json_file|
      json_file.write(rspec_json)
    end
  end

  def save_metadata(local_test_run_id, metadata)
    @file_system.with_metadata_file(local_test_run_id, 'w') do |json_file|
      json_file.write(metadata)
    end
  end
end

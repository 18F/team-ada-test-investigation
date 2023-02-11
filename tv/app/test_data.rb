# frozen_string_literal: true

require 'json'

require_relative 'run_data'
require_relative 'test_data_file_system_interface'

# Top-level class for accessing the test data
class TestData
  def initialize(file_system = TestDataFileSystemInterface.new('test-data'))
    @file_system = file_system
  end

  def local_run_ids
    @file_system.local_run_ids
  end

  def test_ids
    local_run_ids.inject([]) do |return_value, run_id|
      return_value + run_data(run_id).test_ids
    end.uniq
  end

  def import(rspec_json, metadata)
    TestDataImporter.new(@file_system).import(rspec_json, metadata)
  end

  def run_data(local_run_id)
    @file_system.with_rspec_file(local_run_id) do |json_file|
      RunData.from_json(local_run_id, json_file.read)
    end
  end

  def test_runs_by_id(test_id)
    local_run_ids.inject([]) do |return_value, run_id|
      return_value + run_data(run_id).test_runs_for_id(test_id)
    end
  end
end

# frozen_string_literal: true

# File system interface layer for TestData
class TestDataFileSystemInterface
  def initialize(test_data_directory)
    @test_data_directory = test_data_directory
  end

  def local_run_ids
    Dir.glob("#{@test_data_directory}/*").map do |test_dir|
      test_dir.split('/')[-1]
    end
  end

  def with_rspec_file(local_test_run_id, mode = 'r', &block)
    File.open(rspec_filename(local_test_run_id), mode, &block)
  end

  def with_metadata_file(local_test_run_id, mode = 'r', &block)
    File.open(metadata_filename(local_test_run_id), mode, &block)
  end

  private

  def test_run_directory(local_test_run_id)
    "#{@test_data_directory}/#{local_test_run_id}"
  end

  def rspec_filename(local_test_run_id)
    "#{test_run_directory(local_test_run_id)}/rspec.out.json"
  end

  def metadata_filename(local_test_run_id)
    "#{test_run_directory(local_test_run_id)}/metadata.json"
  end
end

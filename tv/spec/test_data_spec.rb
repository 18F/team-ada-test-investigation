# frozen_string_literal: true

require 'fakefs/spec_helpers'

require './app/test_data'

# rubocop:disable Metrics/BlockLength
RSpec.describe TestData do
  describe '#test_runs_by_id' do
    include FakeFS::SpecHelpers

    let(:fake_git_hash) { 'fake-git-hash' }
    let(:test_id) { './spec/some_spec.rb[1:1:1:1]' }

    let(:test_json) do
      JSON.generate({ examples: [{ id: test_id }] })
    end

    let(:local_run_id) do
      TestData.new.import(test_json, { git_hash: fake_git_hash })
    end

    it 'returns [] for a bogus test id' do
      expect(TestData.new.test_runs_by_id('bogus_test_id')).to eq([])
    end

    it 'retrieves the test run data' do
      expected_run_data = Example.new(
        local_run_id: local_run_id,
        id: test_id
      )

      expect(TestData.new.test_runs_by_id(test_id)).to eq(
        [expected_run_data]
      )
    end
  end

  describe '#import' do
    include FakeFS::SpecHelpers

    let(:test_json) do
      JSON.generate(
        {
          version: '3.12.0',
          examples: [
            {
              id: './spec/some_spec.rb[1:1:1:1]',
              description: 'is tested',
              full_description: 'SomeClass#method is tested',
              status: 'passed',
              file_path: './spec/some_spec.rb',
              line_number: 13,
              run_time: 0.011690498,
              pending_message: nil
            }
          ],
          summary: {
            duration: 0.020395725,
            example_count: 1,
            failure_count: 0,
            pending_count: 0,
            errors_outside_of_examples_count: 0
          },
          summary_line: '3 examples, 0 failures'
        }
      )
    end

    let(:git_hash) { '678891c3c2f38304efd1ff47deb0d1ba9f4aac88' }

    let(:test_id) do
      TestData.new.import(test_json, { git_hash: git_hash })
    end

    let(:rspec_data_filename) { "test-data/#{test_id}/rspec.out.json" }

    it 'saves the test data' do
      expect(File.read(rspec_data_filename)).to eq(test_json)
    end
  end

  describe '#test_ids' do
    include FakeFS::SpecHelpers

    let(:fake_git_hash) { 'fake-git-hash' }
    let(:test_json) do
      JSON.generate(
        {
          examples: [
            { id: './spec/some_spec.rb[1:1:1:1]' },
            { id: './spec/some_spec.rb[1:1:1:2]' }
          ]
        }
      )
    end
    let(:different_fake_git_hash) { 'different-fake-git-hash' }
    let(:different_test_json) do
      JSON.generate(
        {
          examples: [
            { id: './spec/some_spec.rb[1:1:1:1]' }
          ]
        }
      )
    end

    before do
      TestData.new.import(test_json,           { git_hash: fake_git_hash })
      TestData.new.import(different_test_json, { git_hash: different_fake_git_hash })
    end

    it 'returns the test ids without duplicates' do
      expect(TestData.new.test_ids).to match_array(%w[./spec/some_spec.rb[1:1:1:1]
                                                      ./spec/some_spec.rb[1:1:1:2]])
    end
  end

  describe '#run_data' do
    include FakeFS::SpecHelpers

    let(:test_json) do
      JSON.generate(
        {
          version: '3.12.0',
          examples: [
            {
              id: './spec/some_spec.rb[1:1:1:1]',
              description: 'is tested',
              full_description: 'SomeClass#method is tested',
              status: 'passed',
              file_path: './spec/some_spec.rb',
              line_number: 13,
              run_time: 0.011690498,
              pending_message: nil
            }
          ],
          summary: {
            duration: 0.020395725,
            example_count: 1,
            failure_count: 0,
            pending_count: 0,
            errors_outside_of_examples_count: 0
          },
          summary_line: '3 examples, 0 failures'
        }
      )
    end

    let(:git_hash) { '678891c3c2f38304efd1ff47deb0d1ba9f4aac88' }

    let(:test_id) do
      TestData.new.import(test_json, { git_hash: git_hash })
    end

    it 'retrieves the test run data' do
      expect(TestData.new.run_data(test_id).version).to eq('3.12.0')
    end
  end

  describe '#local_run_ids' do
    include FakeFS::SpecHelpers

    context 'with a non-existent data directory' do
      it 'shows no data' do
        expect(TestData.new.local_run_ids).to eq([])
      end
    end

    context 'with an empty data directory' do
      before { Dir.mkdir 'test-data' }

      it 'shows no data' do
        expect(TestData.new.local_run_ids).to eq([])
      end
    end

    context 'with a couple of test runs' do
      let(:test_ids) do
        %w[
          0eb55661-0355-48db-97ac-f3aefc4ec22b
          0247035a-ff95-4986-be04-ce0fe775adad
        ]
      end

      before do
        Dir.mkdir 'test-data'
        test_ids.each { |id| Dir.mkdir("test-data/#{id}") }
      end

      it 'shows the test runs' do
        expect(TestData.new.local_run_ids).to match_array(test_ids)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

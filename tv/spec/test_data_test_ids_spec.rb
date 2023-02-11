# frozen_string_literal: true

require 'fakefs/spec_helpers'

require './app/test_data'

# rubocop:disable Metrics/BlockLength
RSpec.describe TestData do
  include FakeFS::SpecHelpers

  describe '#test_ids' do
    let(:fake_git_hash) { 'fake-git-hash' }
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
            },
            {
              id: './spec/some_spec.rb[1:1:1:2]',
              description: 'is also tested',
              full_description: 'SomeClass#method is tested differently',
              status: 'passed',
              file_path: './spec/some_spec.rb',
              line_number: 26,
              run_time: 0.0314,
              pending_message: nil
            },
            {
              id: './spec/some_spec.rb[1:1:1:2]',
              description: 'is also tested',
              full_description: 'SomeClass#method is tested differently',
              status: 'passed',
              file_path: './spec/some_spec.rb',
              line_number: 26,
              run_time: 0.021,
              pending_message: nil
            }
          ],
          summary: {
            duration: 0.020395725,
            example_count: 2,
            failure_count: 0,
            pending_count: 0,
            errors_outside_of_examples_count: 0
          },
          summary_line: '2 examples, 0 failures'
        }
      )
    end

    before do
      @local_run_id = TestData.new.import(test_json, { git_hash: fake_git_hash })
    end

    it 'returns the test ids without duplicates' do
      expect(TestData.new.test_ids).to match_array(%w[./spec/some_spec.rb[1:1:1:1]
                                                      ./spec/some_spec.rb[1:1:1:2]])
    end
  end
end
# rubocop:enable Metrics/BlockLength

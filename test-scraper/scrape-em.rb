# frozen_string_literal: true

require 'watir'

GITLAB_URL = File.read 'config/gitlab-url'

browser = Watir::Browser.new

browser.goto GITLAB_URL

gets

browser.close

require_relative 'config'
require_relative 'page/login'
require_relative 'page/apps'
require_relative 'page/errors'

module Errwipe
  class Wiper
    DELETE_SLEEP_PERIOD = 0.5 # Seconds

    attr_reader :config

    def initialize
      @agent = Mechanize.new
      @config = Config.new
      yield @config if block_given?
    end

    def perform!
      return unless login

      matching_apps.each do |url|
        delete_errors_on_all_pages(url)
      end
    end

    private

    attr_reader :agent

    def login
      puts "Logging in at #{config.errbit_url}..."
      page = Page::Login.new(agent, config.errbit_url)
      success = page.login!(config.username, config.password)
      puts page.flash_message unless success
      success
    end

    def matching_apps
      page = Page::Apps.new(agent)
      page.select_app_links do |label|
        Array(config.apps).any? { |a| label =~ a }
      end
    end

    def delete_errors_on_all_pages(url)
      page = Page::Errors.new(agent, url)
      return if page.empty?

      print "Checking #{page.app_label} (page #{page.page_number})... "
      delete_errors(page)
      delete_errors_on_next_page(page) if page.next_url
    end

    def delete_errors(page)
      page.delete_errors! do |message|
        Array(config.errors).any? { |e| message =~ e }
      end

      puts page.flash_message
    end

    def delete_errors_on_next_page(page)
      if page.errors_deleted?
        # Errbit hates us if we delete too fast
        sleep DELETE_SLEEP_PERIOD
        # Maybe matching errors from the next page moved here
        delete_with_retry(page.url)
      else
        delete_with_retry(page.next_url)
      end
    end

    def delete_with_retry(url, try = 1)
      delete_errors_on_all_pages(url)
    rescue Mechanize::ResponseCodeError => e
      retry_delete_on_known_error(url, e, try)
    rescue SystemExit
      exit 1
    rescue StandardError => e
      puts "Unknown error #{e.class.name} #{e.message}\n#{e.backtrace.join("\n")}"
    end

    def retry_delete_on_known_error(url, error, try)
      puts "got #{error.class.name}, trying again... "
      sleep 2

      if try < 3
        delete_with_retry(url, try + 1)
      else
        puts "Still getting #{error.class.name} #{error.message} " \
             " after retrying #{try} times, I am going to stop."
      end
    end
  end
end

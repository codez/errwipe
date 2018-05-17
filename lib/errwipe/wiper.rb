# encoding: utf-8

require_relative 'config'
require_relative 'page/login'
require_relative 'page/apps'
require_relative 'page/errors'


module Errwipe
  class Wiper

    DELETE_SLEEP_PERIOD=0.5 # Seconds

    attr_reader :config

    def initialize
      @agent = Mechanize.new
      @config = Config.new
      yield @config if block_given?
    end

    def perform!
      return unless login

      matching_apps.each do |url|
        delete_errors(url)
      end
    end

    private

    attr_reader :agent

    def login
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

    def delete_errors(url, page_index=0)
      page = Page::Errors.new(agent, url)
      return if page.empty?

      print "Checking #{page.app_label} (page #{page_index})... "

      perform_delete(page)

      if page.errors_deleted?
        # Errbit hates us if we delete too fast
        sleep DELETE_SLEEP_PERIOD

        # Maybe matching errors from the next page moved here
        retry_on_known_errors { delete_errors(url, page_index) }
      else
        next_url = page.next_url
        return if next_url.nil? # End of paging

        retry_on_known_errors { delete_errors(next_url, page_index + 1) }
      end
    end

    def retry_on_known_errors(try=1, &block)
      begin
        block.call
      rescue Mechanize::ResponseCodeError => e
        puts "got #{e.class.name}, trying again... "
          sleep 2

        if try < 3
          retry_on_known_errors(try + 1, &block)
        else
          puts "Still getting #{e.class.name} #{e.message} after retrying, I am going to stop."
        end
      rescue SystemExit
        exit 1
      rescue Exception => e
        puts "Unknown error #{e.class.name} #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end

    def perform_delete(page)
      page.delete_errors! do |message|
        Array(config.errors).any? { |e| message =~ e }
      end

      puts page.flash_message
    end

  end
end

# encoding: utf-8

require 'rubygems'
require 'mechanize'

require_relative 'config'
require_relative 'page/login'
require_relative 'page/apps'
require_relative 'page/errors'


module Errwipe
  class Wiper

    attr_reader :config

    def initialize
      @config = Config.new
      @agent = Mechanize.new
      yield @config
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

    def delete_errors(app_url)
      page = Page::Errors.new(agent, app_url)

      print "Checking #{page.app_label}... "
      page.delete_errors! do |message|
        Array(config.errors).any? { |e| message =~ e }
      end
      
      puts page.flash_message
    end

  end
end

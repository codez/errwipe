# encoding: utf-8

module Errwipe
  module Page
    class Base

      FLASH_SELECTOR = '#flash-messages'

      attr_reader :url

      def initialize(agent, url = nil)
        @agent = agent
        @url = url
        load
      end

      def flash_message
        find(FLASH_SELECTOR).text.strip
      end

      private

      attr_reader :agent

      def load
        agent.get(url) if url
      end

      def find(selector)
        page.search(selector)
      end

      def page
        agent.page
      end

      def form
        page.forms.last
      end

    end
  end
end

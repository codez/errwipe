# encoding: utf-8

module Errwipe
  module Page
    class Base

      def initialize(agent, url = nil)
        @agent = agent
        @url = url
        load
      end

      def flash_message
        page.search('#flash-messages').text.strip
      end

      private

      attr_reader :agent, :url

      def load
        agent.get(url) if url
      end

      def page
        agent.page
      end

      def form
        page.form
      end

    end
  end
end

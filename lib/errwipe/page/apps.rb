# encoding: utf-8

require_relative 'base'

module Errwipe
  module Page
    class Apps < Base

      LINKS_SELECTOR = '.apps .name a'

      def select_app_links
        app_links.select { |l| yield l.text }.
                  collect { |l| l[:href] }
      end

      private

      def app_links
        find(LINKS_SELECTOR)
      end

    end
  end
end

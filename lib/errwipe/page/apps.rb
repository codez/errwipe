# encoding: utf-8

require_relative 'base'

module Errwipe
  module Page
    class Apps < Base

      def select_app_links
        page.search('.apps .name a').
             select { |l| yield l.text }.
             collect { |l| l[:href] }
      end

      private

      def url
        '/apps'
      end

    end
  end
end

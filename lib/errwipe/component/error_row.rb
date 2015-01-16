# encoding: utf-8

module Errwipe
  module Component
    class ErrorRow
      attr_reader :form, :node

      def initialize(form, node)
        @form = form
        @node = node
      end

      def message
        message = node.search('.message a').text
        message.gsub("\xE2\x80\x8B", '') # errbit hack for wrapping strings
      end

      def check!
        checkbox.check
      end

      private

      def checkbox
        form.checkbox_with(value: error_id)
      end

      def error_id
        node.search('.select input').first['value']
      end
    end
  end
end

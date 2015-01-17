# encoding: utf-8

module Errwipe
  module Component
    class ErrorRow
      
      MESSAGE_SELECTOR = '.message a'
      INPUT_SELECTOR   = '.select input'

      # errbit hack for wrapping strings
      MAGIC_WRAPPING_CHAR = "\xE2\x80\x8B"

      attr_reader :form, :node

      def initialize(form, node)
        @form = form
        @node = node
      end

      def message
        message = node.search(MESSAGE_SELECTOR).text
        message.gsub(MAGIC_WRAPPING_CHAR, '')
      end

      def check!
        checkbox.check
      end

      private

      def checkbox
        form.checkbox_with(value: error_id)
      end

      def error_id
        node.search(INPUT_SELECTOR).first['value']
      end
    end
  end
end

# encoding: utf-8

require_relative 'base'
require_relative '../component/error_row'

module Errwipe
  module Page
    class Errors < Base

      ERROR_ROWS_SELECTOR = 'form .errs .unresolved'
      HEADING_SELECTOR = 'h1'
      DELETE_BUTTON_LABEL = 'Delete'

      def app_label
        find(HEADING_SELECTOR).first.text
      end

      def delete_errors!
        return unless form
        
        error_rows.each do |row|
          row.check! if yield row.message
        end
        submit_delete!
      end

      private

      def error_rows
        find(ERROR_ROWS_SELECTOR).collect do |node|
          Errwipe::Component::ErrorRow.new(form, node)
        end
      end

      def submit_delete!
        button = delete_button
        form.action = button.node['data-action']
        agent.submit(form, button)
      end

      def delete_button
        form.buttons.find { |b| b.value == DELETE_BUTTON_LABEL }
      end

    end
  end
end

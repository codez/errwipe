# encoding: utf-8

require_relative 'base'
require_relative '../component/error_row'

module Errwipe
  module Page
    class Errors < Base

      ERROR_ROWS_SELECTOR = 'form .errs .unresolved'
      NEXT_LINK_SELECTOR = 'form > nav > span.next > a'
      HEADING_SELECTOR = 'h1'
      DELETE_BUTTON_LABEL = 'Delete'

      def app_label
        find(HEADING_SELECTOR).first.text
      end

      def empty?
        error_rows.empty?
      end

      def delete_errors!
        return unless form

        error_rows.each do |row|
          if yield row.message
            @errors_deleted = true
            row.check!
          end
        end
        submit_delete! if @errors_deleted
      end

      def next_url
        link = find(NEXT_LINK_SELECTOR).first
        return nil if link.nil?

        link.attr('href')
      end

      def errors_deleted?
        @errors_deleted
      end

      def page_number
        (url[/page=(\d+)/, 1] || 1).to_i
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

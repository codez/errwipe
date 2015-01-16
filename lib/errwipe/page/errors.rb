# encoding: utf-8

require_relative 'base'
require_relative '../component/error_row'

module Errwipe
  module Page
    class Errors < Base

      def app_label
        page.search('h1').first.text
      end

      def delete_errors!
        error_rows.each do |row|
          row.check! if yield row.message
        end
        submit_delete!
      end

      private

      def error_rows
        page.search('form .errs .unresolved').collect do |node|
          Errwipe::Component::ErrorRow.new(form, node)
        end
      end

      def submit_delete!
        button = delete_button
        form.action = button.node['data-action']
        agent.submit(form, button)
      end

      def delete_button
        form.buttons.find { |b| b.value == 'Delete' }
      end

    end
  end
end

# encoding: utf-8

require_relative 'base'

module Errwipe
  module Page
    class Login < Base

      def login!(username, password)
        username_field.value = username
        password_field.value = password
        submit!
        successfull?
      end

      private

      def username_field
        form.field_with(name: 'user[username]')
      end

      def password_field
        form.field_with(name: 'user[password]')
      end

      def submit!
        agent.submit(form)
      end

      def successfull?
        page.uri.to_s !~ /users\/sign_in/
      end

    end
  end
end

# encoding: utf-8

require_relative 'base'

module Errwipe
  module Page
    class Login < Base

      URL = '/users/sign_in'
      USERNAME_FIELD_NAME = 'user[username]'
      EMAIL_FIELD_NAME    = 'user[email]'
      PASSWORD_FIELD_NAME = 'user[password]'

      def login!(username, password)
        username_field.value = username
        password_field.value = password
        submit!
        successfull?
      end

      private

      def username_field
        form.field_with(name: USERNAME_FIELD_NAME) ||
        form.field_with(name: EMAIL_FIELD_NAME)
      end

      def password_field
        form.field_with(name: PASSWORD_FIELD_NAME)
      end

      def submit!
        agent.submit(form)
      end

      def successfull?
        !page.uri.to_s.include?(URL)
      end

    end
  end
end

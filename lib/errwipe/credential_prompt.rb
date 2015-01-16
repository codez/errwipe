# encoding: utf-8

require 'io/console'

module Errwipe
  class CredentialPrompt

    def username
      print 'Username: '
      gets.strip
    end

    def password
      print 'Password: '
      STDIN.noecho(&:gets).strip
    end

  end
end

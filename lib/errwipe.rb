# encoding: utf-8

require 'rubygems'
require 'mechanize'

class Errwipe < Mechanize

  class Config
    attr_accessor :errbit_url, :username, :password, :apps, :errors
  end

  attr_reader :config

  def configure
    @config ||= Config.new
    yield @config
  end

  def perform!
    if login
      process_apps
    end
  end

  def login
    get(config.errbit_url)
    form = page.form
    form.field_with(name: 'user[username]').value = config.username
    form.field_with(name: 'user[password]').value = config.password
    submit(form)
    login_successfull?
  end

  def login_successfull?
    if page.uri.to_s =~ /users\/sign_in/
      print_flash_message
      false
    else
      true
    end
  end

  def process_apps
    app_links.each do |link|
      print "Checking #{link.text}... "
      delete_matching_errors(link['href'])
    end
  end

  def app_links
    get('/apps')
    page.search('.apps .name a').select { |l| app_link?(l) }
  end

  def app_link?(link)
    link['href'] =~ /^\/apps\// &&
    config.apps.any? { |a| link.text =~ a }
  end

  def delete_matching_errors(app_path)
    get(app_path)
    select_matching_errors
    submit_delete_request
    print_flash_message
  end

  def print_flash_message
    puts page.search('#flash-messages').first.text.strip
  end

  def select_matching_errors
    error_rows.each do |err_row|
      if matching_error?(err_row)
        check_error(err_row)
      end
    end
  end

  def error_rows
    page.search('form .errs .unresolved')
  end

  def matching_error?(err_row)
    message = err_row.search('.message a').text
    message.gsub!("\xE2\x80\x8B", '') # errbit hack for wrapping strings
    config.errors.any? { |e| message =~ e }
  end

  def check_error(err_row)
    id = err_row.search('.select input').first['value']
    page.form.checkbox_with(value: id).check
  end

  def submit_delete_request
    form = page.form
    delete_button = form.buttons.find { |b| b.value == 'Delete' }
    form.action = delete_button.node['data-action']
    submit(form, delete_button)
  end

end

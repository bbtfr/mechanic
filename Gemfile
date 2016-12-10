# source 'https://rubygems.org'
source 'https://gems.ruby-china.org'

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# gem 'rails-i18n'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', github: 'turbolinks/turbolinks-classic'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Simple, efficient background processing for Ruby
gem 'sidekiq'
gem 'sinatra', '>= 2.0.0.beta2', require: false

# Cron jobs in Ruby
gem 'whenever'

# View Helpers
gem 'simple_form'
gem 'index_for', github: 'bbtfr/index_for'
gem 'kaminari'
gem 'kaminari-bootstrap'

# Database
# Use authlogic for authentication
gem 'authlogic', github: 'binarylogic/authlogic'
gem 'paperclip'
gem 'rails-settings-cached'
gem 'activerecord-redundancy', github: 'bbtfr/activerecord-redundancy'
# Simple enum-like field support for ActiveModel (including validations and i18n)
gem 'simple_enum'
gem 'simple_enum-multiple'
gem 'simple_enum-persistence'

# Weixin & Alipay
gem 'weixin_authorize'
gem 'weixin_rails_middleware'
gem 'wx_pay', github: 'bbtfr/wx_pay'
gem 'alipay'

gem 'colorize'
gem 'rest-client'
gem 'rqrcode'
gem 'roo'

gem 'jquery-datatables-rails'
gem 'chart-js-rails', '0.0.9'
gem 'dropzonejs-rails'
gem 'select2-rails'
gem 'tinymce-rails'
gem 'ratchet-sass'
gem 'bootstrap-sass'

# Supporting gem for Rails Panel (Google Chrome extension for Rails development).
gem 'meta_request'
# gem 'tailog', github: 'bbtfr/tailog'

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.5.0'
  gem 'capistrano-rails'
  gem 'capistrano3-puma'
  gem 'capistrano-sidekiq'
end

group :production do
  gem 'pg'
end

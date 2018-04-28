source 'https://rubygems.org'
ruby "2.4.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.0'

gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma'
gem 'dalli'
gem 'minitest', '~> 5.10', '!= 5.10.2' # TODO delete after https://github.com/rails/rails/issues/29031 resolved

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'

  # listens to file modifications
  gem 'listen'
end

group :production do
	gem 'rails_12factor'
end

group :test do
  gem 'rails-controller-testing'
end


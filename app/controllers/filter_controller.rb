class FilterController < ApplicationController
  protect_from_forgery with: :exception

  def filter
    puts params ## TODO DELME
  end
end

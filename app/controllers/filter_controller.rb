class FilterController < ApplicationController
  protect_from_forgery with: :exception

  def show
    puts params ## TODO DELME
  end
end

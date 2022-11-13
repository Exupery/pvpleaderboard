class ResourcesController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  def show
    expires_in 1.day, public: true
    fresh_when(last_modified: last_players_update) if Rails.env.production?

    @title = "Resources"
    @description = "Links to other World of Warcraft PvP resources"
  end
end
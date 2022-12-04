Rails.application.routes.draw do
  root "application#index"

  get "statistics" => "statistics#show"
  get "statistics/:bracket" => "statistics#show"
  get "statistics/:bracket/:region" => "statistics#show"
  get "statistics/:bracket/:region/:rating" => "statistics#show"

  get "pvp" => "classes#select_class"
  get "pvp/filter" => "filter#filter"
  get "pvp/filter/results" => "filter#results"
  get "pvp/:class" => "classes#select_class"
  get "pvp/:class/:spec" => "classes#results_by_class"

  get "leaderboards" => "leaderboards#show"
  get "leaderboards/filter" => "leaderboard_filter#filter"
  get "leaderboards/filter/results" => "leaderboard_filter#results"

  get "leaderboards/solo/:region" => "solo#show"
  get "leaderboards/solo/:region/:class" => "solo#show"
  get "leaderboards/solo/:region/:class/:spec" => "solo#show"
  get "leaderboards/solo/:region/:class/:spec/more" => "solo#more"

  get "leaderboards/:bracket/:region" => "leaderboards#show"
  get "leaderboards/:bracket/:region/more" => "leaderboards#more"

  get "realms" => "realms#show"
  get "realms/:bracket" => "realms#show"
  get "realms/:bracket/:region" => "realms#show"
  get "realms/:bracket/:region/:realm_slug" => "realms#details"

  # Go to realms page if no player provided
  get "players" => "player#search"
  get "players/:region" => "player#search"
  get "players/:region/:realm_slug" => "player#search"
  get "players/:region/:realm_slug/:player" => "player#show"

  get "resources" => "resources#show"

  ## OLD ROUTES BEGIN
  get "filter", to: redirect("/pvp/filter")
  get "filter/results", to: redirect { |path_params, req| "/pvp/filter/results?#{req.query_string}" }

  get "talents", to: redirect("/pvp")
  get "talents/:class", to: redirect { |path_params, req| "/pvp/#{path_params[:class]}" }
  get "talents/:class/:spec", to: redirect { |path_params, req|
    "/pvp/#{path_params[:class]}/#{path_params[:spec]}" }

  get "overview", to: redirect("/statistics")
  get "overview/:bracket", to: redirect { |path_params, req| "/statistics/#{path_params[:bracket]}" }

  get "leaderboards/:bracket", to: redirect { |path_params, req| "/leaderboards/#{path_params[:bracket]}/us" }
  ## OLD ROUTES END
end

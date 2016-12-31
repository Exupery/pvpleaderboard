Rails.application.routes.draw do
  root "application#index"

  get "overview" => "overview#overview"
  get "overview/:bracket" => "overview#overview"
  get "overview/:bracket/:region" => "overview#overview"

  get "pvp" => "classes#select_class"
  get "pvp/filter" => "filter#filter"
  get "pvp/filter/results" => "filter#results"
  get "pvp/:class" => "classes#select_class"
  get "pvp/:class/:spec" => "classes#results_by_class"

  get "leaderboards" => "leaderboards#show"
  get "leaderboards/filter" => "leaderboard_filter#filter"
  get "leaderboards/filter/results" => "leaderboard_filter#results"
  get "leaderboards/:bracket" => "leaderboards#show"
  get "leaderboards/:bracket/more" => "leaderboards#more"

  get "realms" => "realms#show"
  get "realms/:bracket" => "realms#show"
  get "realms/:bracket/:region" => "realms#show"
  get "realms/:bracket/:region/:realm_slug" => "realms#details"

  ## OLD ROUTES BEGIN
  get "filter", to: redirect("/pvp/filter")
  get "filter/results", to: redirect { |path_params, req| "/pvp/filter/results?#{req.query_string}" }

  get "talents", to: redirect("/pvp")
  get "talents/:class", to: redirect { |path_params, req| "/pvp/#{path_params[:class]}" }
  get "talents/:class/:spec", to: redirect { |path_params, req|
    "/pvp/#{path_params[:class]}/#{path_params[:spec]}" }

  get "realms/:realm_slug/2v2", to: redirect { |path_params, req| "/realms/2v2/us/#{path_params[:realm_slug]}" }
  get "realms/:realm_slug/3v3", to: redirect { |path_params, req| "/realms/3v3/us/#{path_params[:realm_slug]}" }
  get "realms/:realm_slug/rbg", to: redirect { |path_params, req| "/realms/rbg/us/#{path_params[:realm_slug]}" }
  ## OLD ROUTES END
end

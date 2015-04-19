Rails.application.routes.draw do
  root "application#index"

  get "overview" => "overview#overview"
  get "overview/:bracket" => "overview#overview"

  get "pvp" => "classes#select_class"
  get "pvp/:class" => "classes#select_class"
  get "pvp/:class/:spec" => "classes#results_by_class"

  get "filter" => "filter#filter"
  get "filter/results" => "filter#results"

  ## Keep the initial talent/glyph/stat routes for now
  ## OLD ROUTES BEGIN
  get "talents", to: redirect("/pvp")
  get "talents/:class", to: redirect { |path_params, req| "/pvp/#{path_params[:class]}" }
  get "talents/:class/:spec", to: redirect { |path_params, req|
    "/pvp/#{path_params[:class]}/#{path_params[:spec]}" }

  get "glyphs", to: redirect("/pvp")
  get "glyphs/:class", to: redirect { |path_params, req| "/pvp/#{path_params[:class]}" }
  get "glyphs/:class/:spec", to: redirect { |path_params, req|
    "/pvp/#{path_params[:class]}/#{path_params[:spec]}" }

  get "stats", to: redirect("/pvp")
  get "stats/:class", to: redirect { |path_params, req| "/pvp/#{path_params[:class]}" }
  get "stats/:class/:spec", to: redirect { |path_params, req|
    "/pvp/#{path_params[:class]}/#{path_params[:spec]}" }
  ## OLD ROUTES END
end

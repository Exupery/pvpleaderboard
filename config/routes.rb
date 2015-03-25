Rails.application.routes.draw do
  root 'application#index'

  get 'overview' => 'overview#stats'
  get 'overview/:bracket' => 'overview#stats'

  get 'talents' => 'talents#talents_by_class'
  get 'talents/:class' => 'talents#talents_by_class'
  get 'talents/:class/:spec' => 'talents#talents_by_class'

  get 'glyphs' => 'glyphs#glyphs_by_class'
  get 'glyphs/:class' => 'glyphs#glyphs_by_class'
  get 'glyphs/:class/:spec' => 'glyphs#glyphs_by_class'

  get 'stats' => 'stats#stats_by_class'
  get 'stats/:class' => 'stats#stats_by_class'
  get 'stats/:class/:spec' => 'stats#stats_by_class'

  get 'filter' => 'filter#show'
end

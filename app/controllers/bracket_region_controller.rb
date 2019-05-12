class BracketRegionController < ApplicationController
  before_action :assign_fields

  def assign_fields
    @bracket = get_bracket
    @title_bracket = get_title_bracket @bracket
    @region = get_region
    @title_region = get_title_region @region

    @bracket_fullname = get_bracket_fullname(@bracket, @region)
    @region_clause = @region.nil? ? nil : "AND leaderboards.region='#{@region}'"

    if !@region.nil? && !params[:realm_slug].nil?
      @realm_slug = params[:realm_slug].downcase.delete("'").gsub(/\s/, "-")
      @realm = Realms.list[@realm_slug + @region.upcase]
    end
  end
end
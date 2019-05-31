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
      # Blizzard's realm slugs use `-` for a space (e.g. emerald-dream for Emerald Dream)
      # but there are some realms with a dash in the name (e.g. Azjol-Nerub) where they
      # remove the dash for the slug so if we didn't find the realm with a dash try
      # again after removing it (this should be an uncommon case as there are over a
      # hundred realms with a space but only a handful with a dash in the actual name)
      @realm = Realms.list[@realm_slug.delete!("-") + @region.upcase] if @realm.nil? && @realm_slug.include?("-")
    end
  end
end
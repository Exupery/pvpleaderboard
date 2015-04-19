[![Build Status](https://travis-ci.org/Exupery/pvpleaderboard.svg)](https://travis-ci.org/Exupery/pvpleaderboard)
# PvPLeaderboard

[PvPLeaderboard](https://www.pvpleaderboard.com/) shows the talent, glyph, and stat choices made by the best [World of Warcraft](http://us.battle.net/wow/en/) PvP players as well as a breakdown of the PvP leaderboards by class, spec, race, and faction.

Use: `bundle exec puma -C config/puma.rb`

Environment variables:
* `RACK_ENV` (required)
* `PVP_DB_HOST` (required)
* `PVP_DB_NAME` (required)
* `PVP_DB_USER` (required)
* `PVP_DB_PASSWORD` (required)
* `WEB_CONCURRENCY` (optional)
* `MAX_THREADS` (optional)


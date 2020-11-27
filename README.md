# PvPLeaderboard

[PvPLeaderboard](https://www.pvpleaderboard.com/) shows the talent choices made by the best [World of Warcraft](https://worldofwarcraft.com/) PvP players as well as a breakdown of the PvP leaderboards by class, spec, race, and faction.

Use: `bundle exec puma -C config/puma.rb`

Environment variables:
* `RACK_ENV` (required)
* `HEROKU_POSTGRESQL_PUCE_URL` (required)
* `WEB_CONCURRENCY` (optional)
* `MAX_THREADS` (optional)


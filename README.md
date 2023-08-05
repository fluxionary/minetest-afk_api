# afk_api

an API for registering events which trigger when a player goes AFK or comes back from AFK.

## API

```lua
afk_api.register_on_afk({
    min_afk_time = nil,  -- if specified, # of seconds after which player will be considered AFK. defaults to the
                         -- default_afk_time setting.
    period = nil,  -- if provided, the callback will be called every `period` seconds. otherwise, it will just be called
                   -- once when a player is deemed to have gone AFK.
    func = function(player, afk_time)
    end,
})
```

```lua
afk_api.register_on_back({
    min_afk_time = nil,  -- if specified, # of seconds after which player will be considered AFK. defaults to the
                         -- default_afk_time setting.
    func = function(player, afk_time)
    end,
})
```

* `afk_api.back(player)`

  indicate that a player is no-longer AFK. use this if you know of player activity mechanisms outside the minetest API.

* `afk_api.get_afk_time(player_or_name[, now])`

  get the amount of time (in seconds w/ us precision) that a player has been AFK. if `now` is specified, it must be
  a value like `minetest.get_us_time() / 1e6` and *NOT* the output of e.g. `os.time()`. if `now` is not specified,
  the current time will be used. if the first argument is not a valid player or the player is not connected, this
  will return `nil`.

* `afk_api.is_afk(player_or_name[, min_afk_time][, now])`

  check whether a player is AFK. returns `true` if they are, `false` if they are not, or `nil` if the argument is
  not a valid connected player. if `min_afk_time` is not specified or `nil`, the default_afk_time setting will be
  used. `now` is the same as in `afk_api.get_afk_time()`

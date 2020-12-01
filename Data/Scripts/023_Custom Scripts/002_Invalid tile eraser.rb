alias __errorTiles__pbDebugMenuCommands pbDebugMenuCommands

def pbDebugMenuCommands(showall = true)
  commands = __errorTiles__pbDebugMenuCommands(showall)
  commands.add("othermenu","invalidtiles",_INTL("Fix Invalid Tiles"),
    _INTL("Scans all maps and erases non-existent tiles."))
  return commands
end

alias __errorTiles__pbDebugMenuActions pbDebugMenuActions

def pbDebugMenuActions(cmd = "", sprites = nil, viewport = nil)
  if cmd == "invalidtiles"
    pbDebugFixInvalidTiles
    return false
  end
  return __errorTiles__pbDebugMenuActions(cmd, sprites, viewport)
end

def pbDebugFixInvalidTiles
  num_errors = 0
  num_error_maps = 0
  @tilesets = pbLoadRxData("Data/Tilesets")
  mapData = MapData.new
  t = Time.now.to_i
  Graphics.update
  for id in mapData.mapinfos.keys.sort
    if Time.now.to_i - t >= 5
      Graphics.update
      t = Time.now.to_i
    end
    changed = false
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    Win32API.SetWindowText(_INTL("Processing map {1} ({2})", id, mapData.mapinfos[id].name))
    passages = mapData.getTilesetPassages(map, id)
    # Check all tiles in map for non-existent tiles
    for x in 0...map.data.xsize
      for y in 0...map.data.ysize
        for i in 0...map.data.zsize
          tile_id = map.data[x, y, i]
          next if pbCheckTileValidity(tile_id, map, @tilesets, passages)
          map.data[x, y, i] = 0
          changed = true
          num_errors += 1
        end
      end
    end
    # Check all events in map for page graphics using a non-existent tile
    for key in map.events.keys
      event = map.events[key]
      for page in event.pages
        next if page.graphic.tile_id <= 0
        next if pbCheckTileValidity(page.graphic.tile_id, map, @tilesets, passages)
        page.graphic.tile_id = 0
        changed = true
        num_errors += 1
      end
    end
    next if !changed
    # Map was changed; save it
    num_error_maps += 1
    mapData.saveMap(id)
  end
  if num_error_maps == 0
    pbMessage(_INTL("No invalid tiles were found."))
  else
    pbMessage(_INTL("{1} error(s) were found across {2} map(s) and fixed.", num_errors, num_error_maps))
    pbMessage(_INTL("Close RPG Maker XP to ensure the changes are applied properly."))
  end
end

def pbCheckTileValidity(tile_id, map, tilesets, passages)
  return false if !tile_id
  if tile_id > 0 && tile_id < 384
    # Check for defined autotile
    autotile_id = tile_id / 48 - 1
    autotile_name = tilesets[map.tileset_id].autotile_names[autotile_id]
    return true if autotile_name && autotile_name != ""
  else
    # Check for tileset data
    return true if passages[tile_id]
  end
  return false
end
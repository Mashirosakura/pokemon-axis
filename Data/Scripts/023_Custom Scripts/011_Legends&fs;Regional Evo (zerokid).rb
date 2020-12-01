ALOLAMAPS=[212,213,214]

def isOnAlolaMap?
  return ALOLAMAPS.include?($game_map.map_id)
end

def isOnGalarMap?
  return false # todo
end

def isUltraBeast?(species)
  if isConst?(species,PBSpecies,:NIHILEGO) ||
     isConst?(species,PBSpecies,:BUZZWOLE) ||
     isConst?(species,PBSpecies,:PHEROMOSA) ||
     isConst?(species,PBSpecies,:XURKITREE) ||
     isConst?(species,PBSpecies,:CELESTEELA) ||
     isConst?(species,PBSpecies,:KARTANA) ||
     isConst?(species,PBSpecies,:GUZZLORD) ||
     isConst?(species,PBSpecies,:POIPOLE) ||
     isConst?(species,PBSpecies,:NAGANADEL) ||
     isConst?(species,PBSpecies,:STAKATAKA) ||
     isConst?(species,PBSpecies,:BLACEPHALON)
    return true
  end
  return false
end

def isLegendaryMythicalOrUltra?(species)
  if isUltraBeast?(species) ||
     isConst?(species,PBSpecies,:ZAPDOS) ||
     isConst?(species,PBSpecies,:ARTICUNO) ||
     isConst?(species,PBSpecies,:MOLTRES) ||
     isConst?(species,PBSpecies,:MEWTWO) ||
     isConst?(species,PBSpecies,:MEW) ||
     isConst?(species,PBSpecies,:RAIKOU) ||
     isConst?(species,PBSpecies,:ENTEI) ||
     isConst?(species,PBSpecies,:SUICUNE) ||
     isConst?(species,PBSpecies,:LUGIA) ||
     isConst?(species,PBSpecies,:HOOH) ||
     isConst?(species,PBSpecies,:CELEBI) ||
     isConst?(species,PBSpecies,:REGIROCK) ||
     isConst?(species,PBSpecies,:REGICE) ||
     isConst?(species,PBSpecies,:REGISTEEL) ||
     isConst?(species,PBSpecies,:LATIAS) ||
     isConst?(species,PBSpecies,:LATIOS) ||
     isConst?(species,PBSpecies,:KYOGRE) ||
     isConst?(species,PBSpecies,:GROUDON) ||
     isConst?(species,PBSpecies,:RAYQUAZA) ||
     isConst?(species,PBSpecies,:JIRACHI) ||
     isConst?(species,PBSpecies,:DEOXYS) ||
     isConst?(species,PBSpecies,:UXIE) ||
     isConst?(species,PBSpecies,:MESPRIT) ||
     isConst?(species,PBSpecies,:AZELF) ||
     isConst?(species,PBSpecies,:DIALGA) ||
     isConst?(species,PBSpecies,:PALKIA) ||
     isConst?(species,PBSpecies,:HEATRAN) ||
     isConst?(species,PBSpecies,:REGIGIGAS) ||
     isConst?(species,PBSpecies,:GIRATINA) ||
     isConst?(species,PBSpecies,:CRESSELIA) ||
     isConst?(species,PBSpecies,:PHIONE) ||
     isConst?(species,PBSpecies,:MANAPHY) ||
     isConst?(species,PBSpecies,:DARKRAI) ||
     isConst?(species,PBSpecies,:SHAYMIN) ||
     isConst?(species,PBSpecies,:ARCEUS) ||
     isConst?(species,PBSpecies,:VICTINI) ||
     isConst?(species,PBSpecies,:COBALION) ||
     isConst?(species,PBSpecies,:TERRAKION) ||
     isConst?(species,PBSpecies,:VIRIZION) ||
     isConst?(species,PBSpecies,:TORNADUS) ||
     isConst?(species,PBSpecies,:THUNDURUS) ||
     isConst?(species,PBSpecies,:RESHIRAM) ||
     isConst?(species,PBSpecies,:ZEKROM) ||
     isConst?(species,PBSpecies,:LANDORUS) ||
     isConst?(species,PBSpecies,:KYUREM) ||
     isConst?(species,PBSpecies,:KELDEO) ||
     isConst?(species,PBSpecies,:MELOETTA) ||
     isConst?(species,PBSpecies,:GENESECT) ||
     isConst?(species,PBSpecies,:XERNEAS) ||
     isConst?(species,PBSpecies,:YVELTAL) ||
     isConst?(species,PBSpecies,:ZYGARDE) ||
     isConst?(species,PBSpecies,:DIANCIE) ||
     isConst?(species,PBSpecies,:HOOPA) ||
     isConst?(species,PBSpecies,:VOLCANION) ||
     isConst?(species,PBSpecies,:TYPENULL) ||
     isConst?(species,PBSpecies,:SILVALLY) ||
     isConst?(species,PBSpecies,:TAPUKOKO) ||
     isConst?(species,PBSpecies,:TAPULELE) ||
     isConst?(species,PBSpecies,:TAPUBULU) ||
     isConst?(species,PBSpecies,:TAPUFINI) ||
     isConst?(species,PBSpecies,:COSMOG) ||
     isConst?(species,PBSpecies,:COSMOEM) ||
     isConst?(species,PBSpecies,:SOLGALEO) ||
     isConst?(species,PBSpecies,:LUNALA) ||
     isConst?(species,PBSpecies,:NECROZMA) ||
     isConst?(species,PBSpecies,:MAGEARNA) ||
     isConst?(species,PBSpecies,:MARSHADOW) ||
     isConst?(species,PBSpecies,:ZERAORA) ||
     isConst?(species,PBSpecies,:MELTAN) ||
     isConst?(species,PBSpecies,:MELMETAL)
    return true
  end
  return false
end
#===============================================================================
# * Ambient Pokémon Cries - by Vendily
#===============================================================================
# This script plays random cries of pokémon that can be encountered on the map
#  for ambiance. It does not activate for maps that don't have pokemon,
#  and optionally only when a switch is active.
# To ensure you get no errors, this script must be under PField_Field. It can
#  be anywhere but it must be under that section. (It's because it uses the
#  Events Module, which is defined in PField_Field)
#===============================================================================
# * The time between cries in seconds (arbitrarily default 60)
# * The variance in time for cries in seconds (arbitrarily default +/-rand(5))
# * The Global Switch that is checked to see if ambiance should be used, set
#      to -1 to always play ambiance if possible
# * The volume to play the cry at (default 65)
# * If the game should play roamer cries, which are the only cries that play
#    should one be found on the current map (default true)
#===============================================================================
TIME_BETWEEN_CRIES  = 2002000
RANDOM_TIME_FACTOR  = 5
AMBIANCE_SWITCH     = -1
CRY_VOLUME          = 60
CRY_ROAMERS         = true
 
class PokemonEncounters
  def pbAllValidEncounterTypes(mapID)
    data=load_data("Data/encounters.dat")
    if data.is_a?(Hash) && data[mapID]
      enctypes=data[mapID][1]
    else
      return nil
    end
    ret=[]
    enctypes.each_index{|enc|
      ret.push(enc) if enctypes[enc]
    }
    return ret
  end
end
 
class PokemonTemp
  attr_accessor :lastCryTime
end
 
def pbPlayAmbiance
  if AMBIANCE_SWITCH<0 || $game_switches[AMBIANCE_SWITCH]
    roam=[]
    if CRY_ROAMERS
      for i in 0...RoamingSpecies.length
        poke=RoamingSpecies[i]
        species=getID(PBSpecies,poke[0])
        next if !species || species<=0
        if $game_switches[poke[2]] && $PokemonGlobal.roamPokemon[i]!=true
          currentArea=$PokemonGlobal.roamPosition[i]
          if !currentArea
            $PokemonGlobal.roamPosition[i]=keys[rand(keys.length)]
            currentArea=$PokemonGlobal.roamPosition[i]
          end
          roamermeta=pbGetMetadata(currentArea,MetadataMapPosition)
          possiblemaps=[]
          mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
          for j in 1...mapinfos.length
            jmeta=pbGetMetadata(j,MetadataMapPosition)
            if mapinfos[j] && mapinfos[j].name==$game_map.name &&
              roamermeta && jmeta && roamermeta[0]==jmeta[0]
              possiblemaps.push(j)   # Any map with same name as roamer's current map
            end
          end
          if possiblemaps.include?(currentArea) && pbRoamingMethodAllowed(poke[3])
            # Change encounter to species and level, with BGM on end
            roam.push(species)
          end
        end
      end
    end
    if roam.length>0
      pbPlayCry(roam[rand(roam.length)],CRY_VOLUME)
    else
      enctypes=$PokemonEncounters.pbAllValidEncounterTypes($game_map.map_id) rescue []
      if enctypes && enctypes.length>0
        invalenc=true
        while invalenc
          enc=enctypes[rand(enctypes.length)]
          if (enc==EncounterTypes::LandNight && !PBDayNight.isNight?) ||
             (enc==EncounterTypes::LandDay && !PBDayNight.isDay?) ||
             (enc==EncounterTypes::LandMorning && !PBDayNight.isMorning?)
          else
            invalenc=false 
          end
        end
        crypoke=$PokemonEncounters.pbEncounteredPokemon(enc)[0] rescue nil
      end
      if crypoke
        pbPlayCry(crypoke,CRY_VOLUME)
      end
    end
  end
end
 
Events.onMapUpdate+=proc {|sender,e|   # Ambiance check
  last=$PokemonTemp.lastCryTime
  now=pbGetTimeNow
  if !last || (now-last>(TIME_BETWEEN_CRIES+((rand(2)==0 ? -1 : 1)*rand(RANDOM_TIME_FACTOR))))
    pbPlayAmbiance
    $PokemonTemp.lastCryTime=now
  end
}
#===============================================================================
# Poke Summon by Zerokid
#===============================================================================

#===============================================================================
# Cut
#===============================================================================
module Zerokid
  def self.canUseMoveCut?
    if $DEBUG || $game_switches[60]
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || (facingEvent.name!="Tree" && facingEvent.name!="CutDoor")
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
    end
    return true
  end
  
  def self.useMoveCut
    pokemon=PokeBattle_Pokemon.new(:SCYTHER,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Cut"))
    end
    facingEvent=$game_player.pbFacingEvent
    if facingEvent
      if facingEvent.name=="CutDoor"
        pbSEPlay("frlg_brailledoor")
        pbMapInterpreter.pbSetSelfSwitch(facingEvent.id,"A",true)
      else
        pbSEPlay("frlg_cut")
        facingEvent.erase
        $PokemonMap.addErasedEvent(facingEvent.id)
      end
    end
    return true
  end
end

def Kernel.pbCut
  if $DEBUG || $game_switches[60]
    Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
    if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
      Zerokid.useMoveCut
      pbSEPlay("frlg_cut")
      return true
    end
  else
    Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
  end
  return false
end

#===============================================================================
# Fly
#===============================================================================
module Zerokid
  def self.canUseMoveFly?
    if $game_switches[169] && $game_map.map_id==19 # Can't fly in Friend Safari
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    if $game_player.pbHasDependentEvents?
      Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
      return false
    end
    if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
  
  def self.useMoveFly
    scene = PokemonRegionMap_Scene.new(-1,false)
    screen = PokemonRegionMapScreen.new(scene)
    ret = screen.pbStartFlyScreen
    if ret
      $PokemonTemp.flydata=ret
    else
      return false
    end
    pokemon=PokeBattle_Pokemon.new(:PIDGEOT,1,$Trainer)
    pokemon.makeNotShiny
    if !$PokemonTemp.flydata
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Fly"))
    end
    pbFadeOutIn(99999){
      $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
      $game_temp.player_new_x         = $PokemonTemp.flydata[1]
      $game_temp.player_new_y         = $PokemonTemp.flydata[2]
      $game_temp.player_new_direction = 2
      Kernel.pbCancelVehicles
      $PokemonTemp.flydata = nil
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
   }
   pbEraseEscapePoint
   return true
  end
end

#===============================================================================
# Surf
#===============================================================================
module Zerokid
  def self.canUseMoveSurf?(showmsg=false)
    if $PokemonGlobal.surfing
      Kernel.pbMessage(_INTL("You're already surfing.")) if showmsg
      return false
    end
    if $game_player.pbHasDependentEvents?
      Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
      return false
    end
    if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
      Kernel.pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
      return false
    end
    if !PBTerrain.isSurfable?(Kernel.pbFacingTerrainTag) ||
      !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
      Kernel.pbMessage(_INTL("No surfing here!")) if showmsg
      return false
    end
    return true
  end
  
  def self.useMoveSurf
    $game_temp.in_menu = false
    Kernel.pbCancelVehicles
    pokemon=PokeBattle_Pokemon.new(:LAPRAS,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Surf"))
    end
    surfbgm = pbGetMetadata(0,MetadataSurfBGM)
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing
    return true
  end
end

def Kernel.pbSurf
  return false if !$DEBUG && !$game_switches[153]
  return false if $game_player.pbHasDependentEvents?
  move = getID(PBMoves,:SURF)
  movefinder = Kernel.pbCheckMove(move)
  if Kernel.pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    Zerokid.useMoveSurf
    return true
  end
  return false
end

#===============================================================================
# Strength
#===============================================================================
module Zerokid
  def self.canUseMoveStrength?(showmsg=false)
   if $PokemonMap.strengthUsed
     Kernel.pbMessage(_INTL("Strength is already being used.")) if showmsg
     return false
   end
   return true
  end
  
  def self.useMoveStrength
    pokemon=PokeBattle_Pokemon.new(:MACHAMP,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!\1",pokemon.name,PBMoves.getName(move)))
    end
    Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
    $PokemonMap.strengthUsed = true
    return true
  end
end

def Kernel.pbStrength
  return false if !$DEBUG 
  if $PokemonMap.strengthUsed
    Kernel.pbMessage(_INTL("Strength made it possible to move boulders around."))
    return false
  end
  move = getID(PBMoves,:STRENGTH)
  if !$DEBUG && !$game_switches[154]
    Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
    return false
  end
  Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside.\1"))
  if Kernel.pbConfirmMessage(_INTL("Would you like to use Strength?"))
    pokemon=PokeBattle_Pokemon.new(:MACHAMP,1,$Trainer)
    pokemon.makeNotShiny
    pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!","Machamp",PBMoves.getName(move)))
    Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!","Machamp"))
    $PokemonMap.strengthUsed = true
    return true
  end
  return false
end

#===============================================================================
# Flash
#===============================================================================
module Zerokid
  def self.canUseMoveFlash?
    if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
    end
    if $PokemonGlobal.flashUsed
      Kernel.pbMessage(_INTL("This is in use already."))
      return false
    end
    return true
  end
  
  def self.useMoveFlash
    pokemon=PokeBattle_Pokemon.new(:RAICHU,1,$Trainer)
    pokemon.makeNotShiny
    darkness=$PokemonTemp.darknessSprite
    return false if !darkness || darkness.disposed?
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Flash"))
    end
    $PokemonGlobal.flashUsed=true
    while darkness.radius<176
      Graphics.update
      Input.update
      pbUpdateSceneMap
      darkness.radius+=4
    end
    return true
  end
end

#===============================================================================
# Rock Smash
#===============================================================================
module Zerokid
  def self.canUseMoveRockSmash?
    if $DEBUG || $game_switches[156]
      facingEvent=$game_player.pbFacingEvent
      if !facingEvent || facingEvent.name!="Rock"
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
    end
    return true
  end
  
  def self.useMoveRockSmash
    pokemon=PokeBattle_Pokemon.new(:DUGTRIO,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Rock Smash"))
    end
    facingEvent=$game_player.pbFacingEvent
    if facingEvent
      pbSmashEvent(facingEvent)
      pbRockSmashRandomEncounter
    end
    return true
  end
end

def Kernel.pbRockSmash
  if $DEBUG || $game_switches[156]
    if Kernel.pbConfirmMessage(_INTL("This rock appears to be breakable. Would you like to use Rock Smash?"))
      Zerokid.useMoveRockSmash
      return true
    end
  else
    Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
  end
  return false
end

#===============================================================================
# Waterfall
#===============================================================================
module Zerokid
  def self.canUseMoveWaterfall?
    if $DEBUG || $game_switches[157]
      if Kernel.pbFacingTerrainTag!=PBTerrain::Waterfall &&
         Kernel.pbFacingTerrainTag!=PBTerrain::WaterfallCrest
        Kernel.pbMessage(_INTL("Can't use that here."))
        return false
      end
      return true
    end
    return false
  end

  def self.useMoveWaterfall
    pokemon=PokeBattle_Pokemon.new(:SEAKING,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Waterfall"))
    end
    Kernel.pbAscendWaterfall if Kernel.pbFacingTerrainTag==PBTerrain::Waterfall
    Kernel.pbDescendWaterfall if Kernel.pbFacingTerrainTag==PBTerrain::WaterfallCrest
    return true
  end
end

def Kernel.pbWaterfall
  if !$DEBUG && !$game_switches[157]
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if Kernel.pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    pokemon=PokeBattle_Pokemon.new(:SEAKING,1,$Trainer)
    pokemon.makeNotShiny
    if !pbHiddenMoveAnimation(pokemon)
      Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,"Waterfall"))
    end
    pbAscendWaterfall if Kernel.pbFacingTerrainTag==PBTerrain::Waterfall
    pbDescendWaterfall if Kernel.pbFacingTerrainTag==PBTerrain::WaterfallCrest
    return true
  end
  return false
end

#===============================================================================
# Poke Summon
#===============================================================================
ItemHandlers::UseFromBag.add(:POKESUMMON,proc{|item|
  next 2 # exit to field before using
})

ItemHandlers::UseInField.add(:POKESUMMON,proc{|item|
  options=[
    [0, _INTL("Scyther (Cut)")],
    [1, _INTL("Pidgeot (Fly)")],
    [2, _INTL("Lapras (Surf)")],
    [3, _INTL("Machamp (Strength)")],
    [4, _INTL("Raichu (Flash)")],
    [5, _INTL("Dugtrio (Rock Smash)")],
    [6, _INTL("Seaking (Waterfall)")]
  ]
  availableoptions=[]
  choices=[]
  if $game_switches[60]
    availableoptions.push(options[0][0])
    choices.push(options[0][1])
  end
  if $game_switches[152]
    availableoptions.push(options[1][0])
    choices.push(options[1][1])
  end
  if $game_switches[153]
    availableoptions.push(options[2][0])
    choices.push(options[2][1])
  end
  if $game_switches[154]
    availableoptions.push(options[3][0])
    choices.push(options[3][1])
  end
  if $game_switches[155]
    availableoptions.push(options[4][0])
    choices.push(options[4][1])
  end
  if $game_switches[156]
    availableoptions.push(options[5][0])
    choices.push(options[5][1])
  end
  if $game_switches[157]
    availableoptions.push(options[6][0])
    choices.push(options[6][1])
  end
  command=Kernel.pbMessage("Summon which Pokémon?",choices,-1)
  return if command==-1 # cancelled
  case availableoptions[command]
  when 0
    if Zerokid.canUseMoveCut?
      Zerokid.useMoveCut
      facingEvent=$game_player.pbFacingEvent
      if facingEvent
        if facingEvent.name=="CutDoor"
          pbSEPlay("frlg_brailledoor")
          pbMapInterpreter.pbSetSelfSwitch(facingEvent.id,"A",true)
        else
          pbSEPlay("frlg_cut")
          facingEvent.erase
          $PokemonMap.addErasedEvent(facingEvent.id)
        end
      end
    end
  when 1
    if Zerokid.canUseMoveFly?
      Zerokid.useMoveFly
    end
  when 2
    if Zerokid.canUseMoveSurf?
      Zerokid.useMoveSurf
    end
  when 3
    if Zerokid.canUseMoveStrength?
      Zerokid.useMoveStrength
    end
  when 4
    if Zerokid.canUseMoveFlash?
      Zerokid.useMoveFlash
    end
  when 5
    if Zerokid.canUseMoveRockSmash?
      Zerokid.useMoveRockSmash
      facingEvent=$game_player.pbFacingEvent
      if facingEvent
        pbSmashEvent(facingEvent)
        pbRockSmashRandomEncounter
      end
    end
  when 6
    if Zerokid.canUseMoveWaterfall?
      Zerokid.useMoveWaterfall
    end
  end
})
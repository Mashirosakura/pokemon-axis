#--------------------------------------------------------------------------------
#Allows for the storing and switching of mons
#--------------------------------------------------------------------------------
module PokeBattle_BattleCommon
  def pbStorePokemon(pokemon)
   if $Trainer.partyplus
    if !(pokemon.isShadow? rescue false)
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
        species=PBSpecies.getName(pokemon.species)
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),pokemon)
        pokemon.name=nickname if nickname!=""
      end
    end
    if $Trainer.party.length<8
      $Trainer.party[$Trainer.party.length]=pokemon
      return -1
    else
      monsent=false
      while !monsent
        if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
          iMon = -2
          eggcount = 0
          for i in $Trainer.party
            next if i.isEgg?
            eggcount += 1
          end
          pbFadeOutIn(99999){
            sscene  = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
            sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
            loop do
              iMon=sscreen.pbChoosePokemon
               if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
                Kernel.pbMessage("That's your last Pokémon!")              
              else
                sscreen.pbEndScene
                break
              end
            end
          }
          if !(iMon < 0)
            iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
            if iBox >= 0
              monsent=true
              player.party[iMon].heal
              Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
              $Trainer.party[iMon] = nil
              $Trainer.party.compact!
              $Trainer.party[$Trainer.party.length]=pokemon
              return -1
            else
              Kernel.pbMessage("No space left in the PC.")
              return false
            end
          end      
        else
          monsent=true
          pokemon.heal
          oldcurbox=$PokemonStorage.currentBox
          storedbox=$PokemonStorage.pbStoreCaught(pokemon)
          if storedbox<0
            pbDisplayPaused(_INTL("Can't catch any more..."))
            return oldcurbox
          else
            return storedbox
          end
        end
      end      
    end
  end
 else
    if !(pokemon.isShadow? rescue false)
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
        species=PBSpecies.getName(pokemon.species)
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),pokemon)
        pokemon.name=nickname if nickname!=""
      end
    end
    if $Trainer.party.length<6
      $Trainer.party[$Trainer.party.length]=pokemon
      return -1
    else
      monsent=false
      while !monsent
        if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
          iMon = -2
          eggcount = 0
          for i in $Trainer.party
            next if i.isEgg?
            eggcount += 1
          end
          pbFadeOutIn(99999){
            sscene  = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
            sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
            loop do
              iMon=sscreen.pbChoosePokemon
               if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
                Kernel.pbMessage("That's your last Pokémon!")              
              else
                sscreen.pbEndScene
                break
              end
            end
          }
          if !(iMon < 0)
            iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
            if iBox >= 0
              monsent=true
              player.party[iMon].heal
              Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
              $Trainer.party[iMon] = nil
              $Trainer.party.compact!
              $Trainer.party[$Trainer.party.length]=pokemon
              return -1
            else
              Kernel.pbMessage("No space left in the PC.")
              return false
            end
          end      
        else
          monsent=true
          pokemon.heal
          oldcurbox=$PokemonStorage.currentBox
          storedbox=$PokemonStorage.pbStoreCaught(pokemon)
          if storedbox<0
            pbDisplayPaused(_INTL("Can't catch any more..."))
            return oldcurbox
          else
            return storedbox
          end
        end
      end      
    end
  end
end  
 
def pbStorePokemon(pokemon)
 if $Trainer.partyplus
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<8
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
        iMon = -2
        eggcount = 0
        for i in $Trainer.party
          next if i.isEgg?
          eggcount += 1
        end
        pbFadeOutIn(99999){
          sscene  = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=sscreen.pbChoosePokemon
            if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!")              
            else
              sscreen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)    
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            $Trainer.party[iMon].heal
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC.")
            return false
          end
        end      
      else
        monsent=true
        oldcurbox=$PokemonStorage.currentBox
        storedbox=$PokemonStorage.pbStoreCaught(pokemon)
        curboxname=$PokemonStorage[oldcurbox].name
        boxname=$PokemonStorage[storedbox].name
        creator=nil
        creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
        if storedbox!=oldcurbox
          if creator
            Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
          else
            Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
          end
          Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
        else
          if creator
            Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
          else
            Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
          end
          Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
        end
      end    
    end
  end
 else
  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
        iMon = -2
        eggcount = 0
        for i in $Trainer.party
          next if i.isEgg?
          eggcount += 1
        end
        pbFadeOutIn(99999){
          sscene  = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=sscreen.pbChoosePokemon
            if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!")              
            else
              sscreen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)    
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            $Trainer.party[iMon].heal
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC.")
            return false
          end
        end      
      else
        monsent=true
        oldcurbox=$PokemonStorage.currentBox
        storedbox=$PokemonStorage.pbStoreCaught(pokemon)
        curboxname=$PokemonStorage[oldcurbox].name
        boxname=$PokemonStorage[storedbox].name
        creator=nil
        creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
        if storedbox!=oldcurbox
          if creator
            Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
          else
            Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
          end
          Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
        else
          if creator
            Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
          else
            Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
          end
          Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
        end
      end    
    end
  end
end
 
def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
if $Trainer.partyplus
  return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name
    pokemon.trainerID = $Trainer.id
  end  
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<8
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
        iMon = -2
        eggcount = 0
        for i in $Trainer.party
          next if i.isEgg?
          eggcount += 1
        end
        pbFadeOutIn(99999){
          sscene  = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=sscreen.pbChoosePokemon
            if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!")              
            else
              sscreen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC.")
            return false
          end
        end      
      else
        monsent=true
        storedbox = $PokemonStorage.pbStoreCaught(pokemon)
        if pokemon.isEgg?
         oldcurbox=$PokemonStorage.currentBox
         #storedbox=$PokemonStorage.pbStoreCaught(pokemon)
         curboxname=$PokemonStorage[oldcurbox].name
         boxname=$PokemonStorage[storedbox].name
         creator=nil
         creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
          if storedbox!=oldcurbox
            if creator
              Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
            else
              Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
            end
            Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
          else
            if creator
              Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
            else
              Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
            end
            Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
          end
        end
      end
    end    
  end
  return true
  else
    return false if !pokemon || pbBoxesFull? || !$Trainer
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon=getID(PBSpecies,pokemon)
  end
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon=PokeBattle_Pokemon.new(pokemon,level,$Trainer)
  end
  if pokemon.ot == ""
    pokemon.ot = $Trainer.name
    pokemon.trainerID = $Trainer.id
  end  
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length]=pokemon
  else
    monsent=false
    while !monsent
      if Kernel.pbConfirmMessageSerious(_INTL("Your party is full, would you like to send someone to the PC?"))
        iMon = -2
        eggcount = 0
        for i in $Trainer.party
          next if i.isEgg?
          eggcount += 1
        end
        pbFadeOutIn(99999){
          sscene  = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          sscreen.pbStartScene(_INTL("Choose a Pokémon."),false)
          loop do
            iMon=sscreen.pbChoosePokemon
            if eggcount<=1 && !($Trainer.party[iMon].isEgg?) && pokemon.isEgg?
              Kernel.pbMessage("That's your last Pokémon!")              
            else
              sscreen.pbEndScene
              break
            end
          end
        }
        if !(iMon < 0)
          iBox = $PokemonStorage.pbStoreCaught($Trainer.party[iMon])
          if iBox >= 0
            monsent=true
            Kernel.pbMessage(_INTL("{1} was sent to {2}.", $Trainer.party[iMon].name, $PokemonStorage[iBox].name))
            $Trainer.party[iMon] = nil
            $Trainer.party.compact!
            $Trainer.party[$Trainer.party.length]=pokemon
          else
            Kernel.pbMessage("No space left in the PC.")
            return false
          end
        end      
      else
        monsent=true
        storedbox = $PokemonStorage.pbStoreCaught(pokemon)
        if pokemon.isEgg?
         oldcurbox=$PokemonStorage.currentBox
         #storedbox=$PokemonStorage.pbStoreCaught(pokemon)
         curboxname=$PokemonStorage[oldcurbox].name
         boxname=$PokemonStorage[storedbox].name
         creator=nil
         creator=Kernel.pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
          if storedbox!=oldcurbox
            if creator
              Kernel.pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
            else
              Kernel.pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
            end
            Kernel.pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
          else
            if creator
              Kernel.pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
            else
              Kernel.pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
            end
            Kernel.pbMessage(_INTL("It was stored in box \"{1}\".",boxname))
          end
        end
      end
    end    
  end
  return true
  end
 end
end

#--------------------------------------------------------------------------------
#Provides Evolution Check on Party Switcher
#--------------------------------------------------------------------------------
class PokemonTemp
  attr_accessor :encounterType
  attr_accessor :evolutionLevels
  attr_accessor :party # changed added
end
 
Events.onStartBattle+=proc {|sender,e| # Changed added $PokemonTemp.party to fix party swap evo bug
  $PokemonTemp.party = []
  $PokemonTemp.evolutionLevels = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.party[i] = $Trainer.party[i]
    $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
  end
}
 
def pbEvolutionCheck(currentlevels)
  for i in 0...currentlevels.length
    pokemon = $Trainer.party[i]
    next if $PokemonTemp.party[i] != $Trainer.party[i] # changed added to fix party swap evo bug
    next if pokemon.hp==0 && !NEWEST_BATTLE_MECHANICS
    if pokemon && (!currentlevels[i] || pokemon.level!=currentlevels[i])
      newspecies = Kernel.pbCheckEvolution(pokemon)
      if newspecies>0
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pokemon,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
      end
    end
  end
end
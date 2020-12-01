def pbChoosePokemonPositionFromPC(variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  pos=-1
  pbFadeOutIn(99999){
    scene=PokemonStorageScene.new
    screen=PokemonStorageScreen.new(scene,$PokemonStorage)
    pos=screen.pbChoosePokemonForTrade(ableProc)
  }
  pbSet(variableNumber,pos)
  if pos!=-1
    pbSet(nameVarNumber,$PokemonStorage[pos[0],pos[1]].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbTradeFromPC(pcPosition,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon=$PokemonStorage[pcPosition[0]][pcPosition[1]]
  opponent=PokeBattle_Trainer.new(trainerName,trainerGender)
  yourPokemon=nil; resetmoves=true
  if newpoke.is_a?(PokeBattle_Pokemon)
    newpoke.ot=opponent.name
    newpoke.otgender=opponent.gender
    newpoke.language=opponent.language
    yourPokemon=newpoke
    resetmoves=false
  else
    if newpoke.is_a?(String) || newpoke.is_a?(Symbol)
      raise _INTL("Species does not exist ({1}).",newpoke) if !hasConst?(PBSpecies,newpoke)
      newpoke=getID(PBSpecies,newpoke)
    end
    yourPokemon=PokeBattle_Pokemon.new(newpoke,myPokemon.level,opponent)
  end
  yourPokemon.name=nickname
  yourPokemon.obtainMode=2 # traded
  yourPokemon.resetMoves if resetmoves
  yourPokemon.pbRecordFirstMoves
  $Trainer.seen[yourPokemon.species]=true
  $Trainer.owned[yourPokemon.species]=true
  pbSeenForm(yourPokemon)
  pbFadeOutInWithMusic(99999){
    evo=PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $PokemonStorage[pcPosition[0]][pcPosition[1]]=yourPokemon
end

class PokemonStorageScreen
  def pbChoosePokemonForTrade(ableProc)
    @heldpkmn=nil
    @scene.pbStartBox(self,0)
    retval=-1
    loop do
      selected=@scene.pbSelectBox(@storage.party)
      if selected && selected[0]==-3 # Close box
        break if pbConfirm(_INTL("Exit from the Box?"))
        next
      end
      if selected==nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0]==-4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0]][selected[1]]
        next if !pokemon
        commands = []
        cmdTrade    = -1
        cmdSummary  = -1
        cmdDebug    = -1
        cmdCancel   = -1
        commands[cmdTrade=commands.length]   = _INTL("Trade it")
        commands[cmdSummary=commands.length] = _INTL("Check summary")
        commands[cmdDebug=commands.length]   = _INTL("Debug") if $DEBUG
        commands[cmdCancel=commands.length]  = _INTL("Cancel")
        helptext = _INTL("What do you want to do with {1}?",PBSpecies.getName(pokemon.species))
        command = pbShowCommands(helptext,commands)
        if cmdTrade>=0 && command==cmdTrade
          if pokemon
            if ableProc==nil || ableProc.call(pokemon)
              retval=selected
              break
            else
              pbDisplay(_INTL("This Pokémon can't be chosen."))
            end
          end
        elsif cmdSummary>=0 && command==cmdSummary
          pbSummary(selected,nil)
        elsif cmdDebug>=0 && command==cmdDebug
          pbPokemonDebug(pokemon,selected)
        elsif cmdCancel>=0 && command==cmdCancel
          retval=-1
          next
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end
end
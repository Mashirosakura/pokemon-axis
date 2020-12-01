#===============================================================================
#
#  Pokémon Birthsigns - By Lucidious89
#  For -Pokémon Essentials v17-
#
#===============================================================================
# This script is what actually implements the effects of all 36 birthsigns set
# up in the core script.
#===============================================================================
# SCRIPT EDITS
#===============================================================================
# This section handles re-writes to several areas of base Essentials to apply
# birthsign mechanics. These will likely re-write your own custom changes if 
# you've made changes to those areas of the script. Below is a list of the main
# areas that have been edited, and what they generally do:
#
# PScreen_Party       - Allows Birthsign commands to display & function
# PScreen_Summary     - Allows Birthsign graphics/info to display in the summary
# PField_Field        - Applies Birthsign effects on wild Pokemon
# PokeBattle_Battle   - Applies Birthsign effects that change battle conditions
# PField_DayCare      - Allows Birthsign mechanics to apply for breeding
# PScreen_EggHatching - Allows eggs to hatch with a birthsign
# PTrainer_NPCTrainers- Allows for NPC's Pokemon to have signs (Zodiac Powers)
# PScreen_PokemonStorage - Allows Birthsign tokens to display in the PC
#
# Other miscellaneous areas also recieve slight modifications.
#===============================================================================

############[BIRTHSIGN EFFECTS - COMMAND SKILLS]################################
#===============================================================================
# Birthsign Commands
#===============================================================================
# This section overwrites the section in PScreen_Party that creates command
# menu options.
#===============================================================================
class PokemonPartyScreen
  def pbPokemonScreen
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false,-1,1)
      break if (pkmnid.is_a?(Numeric) && pkmnid<0) || (pkmnid.is_a?(Array) && pkmnid[1]<0)
      if pkmnid.is_a?(Array) && pkmnid[0]==1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true,-1,2)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands       = []
      cmdSummary     = -1
      cmdDebug       = -1
      cmdMoves       = [-1,-1,-1,-1]
      cmdSwitch      = -1
      cmdMail        = -1
      cmdItem        = -1
      #=========================================================================
      # Celestial Commands
      #=========================================================================
      cmdBlessing    = -1
      cmdLifeGiver   = -1
      #=========================================================================
      # Birthsigns Commands
      #=========================================================================
      cmdStarlight   = -1
      cmdAbilitySwap = -1
      cmdCharity     = -1
      cmdNavigate    = -1
      cmdRebirth     = -1
      cmdEscape      = -1
      cmdCure        = -1
      cmdTrance      = -1
      cmdEndow       = -1
      cmdIncubate    = -1
      cmdReroll      = -1
      cmdReincarnate = -1
      cmdHarmonize   = -1
      cmdBond        = -1
      cmdGambit      = -1
      cmdLunacy      = -1
      cmdTransmute   = -1
      cmdSummon      = -1
      cmdSniffOut    = -1
      cmdTimeskip    = -1
      #=========================================================================
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      for i in 0...pkmn.moves.length
        move = pkmn.moves[i]
        # Check for hidden moves and add any that were found
        if !pkmn.egg? &&
          #=====================================================================
          # HM's - Creates commands for HM moves in the party menu.
          #=====================================================================
          (isConst?(move.id,PBMoves,:CUT) ||
          isConst?(move.id,PBMoves,:FLY) ||
          isConst?(move.id,PBMoves,:SURF) ||
          isConst?(move.id,PBMoves,:STRENGTH) ||
          isConst?(move.id,PBMoves,:ROCKSMASH) ||
          isConst?(move.id,PBMoves,:WATERFALL) ||
          isConst?(move.id,PBMoves,:DIVE) ||
          #=====================================================================
          # Other field commands - Creates commands for other field moves.
          #=====================================================================
          isConst?(move.id,PBMoves,:MILKDRINK) ||
          isConst?(move.id,PBMoves,:HEADBUTT) ||
          isConst?(move.id,PBMoves,:CHATTER) ||
          #=====================================================================
          # Unsupported commands as of Essentials v17.
          # Remove comment tag from field moves you've added yourself.
          # Any custom field moves must be added to this list.
          #=====================================================================
          #isConst?(move.id,PBMoves,:WHIRLPOOL) ||
          #isConst?(move.id,PBMoves,:ROCKCLIMB) ||
          #isConst?(move.id,PBMoves,:SECRETPOWER) ||
          #isConst?(move.id,PBMoves,:DEFOG) ||
          #=====================================================================
          # Birthsign commands - Hides redundant birthsign commands.
          # Adds field commands otherwise.
          #=====================================================================
          # The Beacon
          (isConst?(move.id,PBMoves,:FLASH) && !pkmn.hasStarlightCmd?) ||
          # The Martyr
          (isConst?(move.id,PBMoves,:SOFTBOILED) && !pkmn.hasCharityCmd?) ||
          # The Voyager
          (isConst?(move.id,PBMoves,:TELEPORT) && !pkmn.hasNavigateCmd?) ||
          # The Fugitive
          (isConst?(move.id,PBMoves,:DIG) && !pkmn.hasEscapeCmd?) ||
          # The Bard
          (isConst?(move.id,PBMoves,:SWEETSCENT) && !pkmn.hasHarmonizeCmd?))
          #=====================================================================
          commands[cmdMoves[i] = commands.length] = [PBMoves.getName(move.id),1]
        end
      end
      # Pokemon Following compatibility
      if defined? pbToggleFollowingPokemon
        follower=($game_player.pbHasDependentEvents? && !$game_switches[Following_Activated_Switch])
      else
        follower=$game_player.pbHasDependentEvents?
      end
      reagent=$PokemonBag.pbHasItem?(:STARDUST)
      reagent2=$PokemonBag.pbHasItem?(:STARPIECE)
      stardust=PBItems.getName(PBItems::STARDUST)
      starpiece=PBItems.getName(PBItems::STARPIECE)
      #=========================================================================
      # Omega - Life Giver Command
      #=========================================================================
      if pkmn.isCelestial? && isConst?(pkmn.species,PBSpecies,:ARCEUS)
        usableitem = (isConst?(pkmn.item,PBItems,:ADAMANTORB) ||
                      isConst?(pkmn.item,PBItems,:LUSTROUSORB) ||
                      isConst?(pkmn.item,PBItems,:GRISEOUSORB) || 
                      isConst?(pkmn.item,PBItems,:DIVINEPLATE) ||
                      isConst?(pkmn.item,PBItems,:FALSEPLATE))
        if $Trainer.party.length>=6 || !usableitem || !reagent
          commands[cmdLifeGiver = commands.length] = [_INTL("Life Giver"),3]
        else
          commands[cmdLifeGiver = commands.length] = [_INTL("Life Giver"),2]
        end
      end
      #=========================================================================
      # Celestial Pokemon - Blessing Command
      #=========================================================================
      if pkmn.hasBirthsign? && !pkmn.egg?
        if pkmn.isCelestial?
          if $Trainer.party.length<=1 || !pbCanUseCelestialSkill? || !reagent
            commands[cmdBlessing = commands.length] = [_INTL("Blessing"),3]
          else
            commands[cmdBlessing = commands.length] = [_INTL("Blessing"),2]
          end
        end
      #=========================================================================
      # Birthsign Commands
      #=========================================================================
        # The Beacon
        if pkmn.birthsign==3
          if !pbGetMetadata($game_map.map_id,MetadataDarkMap) || $PokemonGlobal.flashUsed
            commands[cmdStarlight = commands.length] = [_INTL("Starlight"),3]
          else
            commands[cmdStarlight = commands.length] = [_INTL("Starlight"),2]
          end
        end
        # The Prodigy
        if pkmn.birthsign==5
          abils=pkmn.getAbilityList
          if abils.length>1
            if !reagent
              commands[cmdAbilitySwap = commands.length] = [_INTL("Ability Swap"),3]
            else
              commands[cmdAbilitySwap = commands.length] = [_INTL("Ability Swap"),2]
            end
          else
            if pbCanUseBirthsignAbilLure? && !pbAbilLureEffectActive?
              commands[cmdAbilitySwap = commands.length] = [_INTL("Ability Lure"),2]
            else
              commands[cmdAbilitySwap = commands.length] = [_INTL("Ability Lure"),3]
            end
          end
        end
        # The Martyr
        if pkmn.birthsign==6
          k=0
          for i in pkmn.moves
            if i.pp<=(i.totalpp/5).floor || i.pp==1; k+=1; end
          end
          shedinja=isConst?(pkmn.species,PBSpecies,:SHEDINJA)
          if $Trainer.party.length<=1 || (shedinja && k>pkmn.numMoves) ||
             (!shedinja && pkmn.hp<=(pkmn.totalhp/5).floor)
            commands[cmdCharity = commands.length] = [_INTL("Charity"),3]
          else
            commands[cmdCharity = commands.length] = [_INTL("Charity"),2]
          end
        end
        # The Voyager
        if pkmn.birthsign==9
          if !pbGetMetadata($game_map.map_id,MetadataOutdoor) || follower
            commands[cmdNavigate = commands.length] = [_INTL("Navigate"),3]
          else
            commands[cmdNavigate = commands.length] = [_INTL("Navigate"),2]
          end
        end
        # The Phoenix
        if pkmn.birthsign==13
          if !pkmn.fainted?
            commands[cmdRebirth = commands.length] = [_INTL("Rebirth"),3]
          else
            commands[cmdRebirth = commands.length] = [_INTL("Rebirth"),2]
          end
        end
        # The Fugitive
        if pkmn.birthsign==15
          escape=($PokemonGlobal.escapePoint rescue nil)
          outdoors=pbGetMetadata($game_map.map_id,MetadataOutdoor)
          if !escape || escape==[] || outdoors || follower
            commands[cmdEscape = commands.length] = [_INTL("Escape"),3]
          else
            commands[cmdEscape = commands.length] = [_INTL("Escape"),2]
          end
        end
        # The Cleric
        if pkmn.birthsign==17 
          k=0
          for i in pkmn.moves
            if i.pp<=(i.totalpp/4).floor || i.pp==1; k+=1; end
          end
          shedinja=isConst?(pkmn.species,PBSpecies,:SHEDINJA)
          if $Trainer.party.length<=1 || (shedinja && k>pkmn.numMoves) ||
             (!shedinja && pkmn.hp<=(pkmn.totalhp/4).floor)
            commands[cmdCure = commands.length] = [_INTL("Cure"),3]
          else
            commands[cmdCure = commands.length] = [_INTL("Cure"),2]
          end
        end
        # The Monk
        if pkmn.birthsign==18
          if !pbCanUseBirthsignTrance?
            commands[cmdTrance = commands.length] = [_INTL("Trance"),3]
          else
            commands[cmdTrance = commands.length] = [_INTL("Trance"),2]
          end
        end
        # The Ancestor
        if pkmn.birthsign==19
          totalev=0
          for k in 0...6
            totalev+=pkmn.ev[k]
          end
          if totalev==0 || pkmn.fainted? || !reagent
            commands[cmdEndow = commands.length] = [_INTL("Endow"),3]
          else
            commands[cmdEndow = commands.length] = [_INTL("Endow"),2]
          end
        end
        # The Specialist
        if pkmn.birthsign==20
          if pkmn.fainted? || !reagent
            commands[cmdReroll = commands.length] = [_INTL("Re-roll"),3]
          else
            commands[cmdReroll = commands.length] = [_INTL("Re-roll"),2]
          end
        end
        # The Parent
        if pkmn.birthsign==22
          if $Trainer.party.length<=1 || !pbCanUseBirthsignIncubate?
            commands[cmdIncubate = commands.length] = [_INTL("Incubate"),3]
          else
            commands[cmdIncubate = commands.length] = [_INTL("Incubate"),2]
          end
        end
        # The Eternal
        if pkmn.birthsign==24
          if (pkmn.hasCurrentsign? && !pkmn.isCelestial) || !reagent
            commands[cmdReincarnate = commands.length] = [_INTL("Reincarnate"),3]
          else
            commands[cmdReincarnate = commands.length] = [_INTL("Reincarnate"),2]
          end
        end
        # The Bard
        if pkmn.birthsign==25
          if !pbCanUseBirthsignHarmonize? || $game_screen.weather_type!=PBFieldWeather::None ||
             !$PokemonEncounters.isEncounterPossibleHere?
            commands[cmdHarmonize = commands.length] = [_INTL("Harmonize"),3]
          else
            commands[cmdHarmonize = commands.length] = [_INTL("Harmonize"),2]
          end
        end
        # The Empath
        if pkmn.birthsign==26
          if $Trainer.party.length<=1 || !reagent
            commands[cmdBond = commands.length] = [_INTL("Bond"),3]
          else
            commands[cmdBond = commands.length] = [_INTL("Bond"),2]
          end
        end
        # The Tactician
        if pkmn.birthsign==28
          totalev=0
          for k in 0...6
            totalev+=pkmn.ev[k]
          end
          if totalev!=PokeBattle_Pokemon::EVLIMIT || pkmn.fainted? || !reagent
            commands[cmdGambit = commands.length] = [_INTL("Gambit"),3]
          else
            commands[cmdGambit = commands.length] = [_INTL("Gambit"),2]
          end
        end
        # The Fool
        if pkmn.birthsign==29
          minlevel=$Trainer.numbadges*7
          minlevel=10 if $Trainer.numbadges<=1
          minlevel=55 if $Trainer.numbadges>=8
          if pkmn.level<minlevel || pkmn.fainted? || $Trainer.party.length<=1
            commands[cmdLunacy = commands.length] = [_INTL("Lunacy"),3]
          else
            commands[cmdLunacy = commands.length] = [_INTL("Lunacy"),2]
          end
        end
        # The Alchemist
        if pkmn.birthsign==30
          if !pkmn.hasItem? || !reagent
            commands[cmdTransmute = commands.length] = [_INTL("Transmute"),3]
          else
            commands[cmdTransmute = commands.length] = [_INTL("Transmute"),2]
          end
        end
        # The Cultist
        totalIVs=(pkmn.iv[0]+pkmn.iv[1]+pkmn.iv[2]+pkmn.iv[3]+pkmn.iv[4]+pkmn.iv[5])
        outdoorNight=(pbGetMetadata($game_map.map_id,MetadataOutdoor) && PBDayNight.isNight?)
        if pkmn.birthsign==33
          if pkmn.fainted? || totalIVs==0 || follower || !pbCanUseBirthsignSummon? ||
             (!outdoorNight && !$DEBUG) || !reagent
            commands[cmdSummon = commands.length] = [_INTL("Summon"),3]
          else
            commands[cmdSummon = commands.length] = [_INTL("Summon"),2]
          end
        end
        # The Scavenger
        if pkmn.birthsign==35
          if pbDetectItemCount<=0
            commands[cmdSniffOut = commands.length] = [_INTL("Sniff Out"),3]
          else
            commands[cmdSniffOut = commands.length] = [_INTL("Sniff Out"),2]
          end
        end
        # The Timelord
        if pkmn.birthsign==36
          if pkmn.canEvolve?
            if pkmn.fainted? || !reagent || !pbCanUseBirthsignTimeskip?
              commands[cmdTimeskip = commands.length] = [_INTL("Timeskip"),3]
            else
              commands[cmdTimeskip = commands.length] = [_INTL("Timeskip"),2]
            end
          elsif pkmn.canDevolve?
            if pkmn.fainted? || !reagent || !pbCanUseBirthsignTimeskip?
              commands[cmdTimeskip = commands.length] = [_INTL("Rewind"),3]
            else
              commands[cmdTimeskip = commands.length] = [_INTL("Rewind"),2]
            end
          end
        end
      end
      #=========================================================================
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
        end
      end
      commands[commands.length]                   = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      for i in 0...4
        if cmdMoves[i]>=0 && command==cmdMoves[i]
          havecommand = true
          if isConst?(pkmn.moves[i].id,PBMoves,:SOFTBOILED) ||
             isConst?(pkmn.moves[i].id,PBMoves,:MILKDRINK)
            amt = [(pkmn.totalhp/5).floor,1].max
            if pkmn.hp<=amt
              pbDisplay(_INTL("Not enough HP..."))
              break
            end
            @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            oldpkmnid = pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid = @scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn = @party[pkmnid]
              movename = PBMoves.getName(pkmn.moves[i].id)
              if pkmnid==oldpkmnid
                pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,movename))
              elsif newpkmn.egg?
                pbDisplay(_INTL("{1} can't be used on an Egg!",movename))
              elsif newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp
                pbDisplay(_INTL("{1} can't be used on that Pokémon.",movename))
              else
                pkmn.hp -= amt
                hpgain = pbItemRestoreHP(newpkmn,amt)
                @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
                pbRefresh
              end
              break if pkmn.hp<=amt
            end
            @scene.pbSelect(oldpkmnid)
            pbRefresh
            break
          elsif Kernel.pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
            if Kernel.pbConfirmUseHiddenMove(pkmn,pkmn.moves[i].id)
              @scene.pbEndScene
              if isConst?(pkmn.moves[i].id,PBMoves,:FLY)
                scene = PokemonRegionMap_Scene.new(-1,false)
                screen = PokemonRegionMapScreen.new(scene)
                ret = screen.pbStartFlyScreen
                if ret
                  $PokemonTemp.flydata=ret
                  return [pkmn,pkmn.moves[i].id]
                end
                @scene.pbStartScene(@party,
                   (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
                break
              end
              return [pkmn,pkmn.moves[i].id]
            end
          else
            break
          end
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
#===============================================================================
# Omega
# Life Giver effect: Spawns special legendary eggs based on held item.
#===============================================================================
      elsif cmdLifeGiver>=0 && command==cmdLifeGiver
        usableitem = (isConst?(pkmn.item,PBItems,:ADAMANTORB) ||
                      isConst?(pkmn.item,PBItems,:LUSTROUSORB) ||
                      isConst?(pkmn.item,PBItems,:GRISEOUSORB) || 
                      isConst?(pkmn.item,PBItems,:DIVINEPLATE) ||
                      isConst?(pkmn.item,PBItems,:FALSEPLATE))
        if $Trainer.party.length>=6
          Kernel.pbMessage(_INTL("There isn't enough space to carry an egg!"))
        elsif !usableitem
          Kernel.pbMessage(_INTL("{1} isn't holding the right item for this skill.",pkmn.name))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s power?",pkmn.name)
            Kernel.pbMessage(_INTL("Activating this power will consume <c2=65467b14>{1}</c2>, and form an egg based on {2}'s held item.",stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            dialga   = false
            palkia   = false
            giratina = false
            arceus   = false
            typenull = false
            if isConst?(pkmn.item,PBItems,:ADAMANTORB); dialga=true; end
            if isConst?(pkmn.item,PBItems,:LUSTROUSORB); palkia=true; end
            if isConst?(pkmn.item,PBItems,:GRISEOUSORB); giratina=true; end
            if isConst?(pkmn.item,PBItems,:DIVINEPLATE); arceus=true; end
            if isConst?(pkmn.item,PBItems,:FALSEPLATE); typenull=true; end
            pbRitualAnimation(pkmn)
            $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
            $PokemonBag.pbDeleteItem(:STARDUST) if reagent
            pbGenerateEgg(:DIALGA,_I("A Divine Force.")) if dialga
            pbGenerateEgg(:PALKIA,_I("A Divine Force.")) if palkia
            pbGenerateEgg(:GIRATINA,_I("A Divine Force.")) if giratina
            pbGenerateEgg(:ARCEUS,_I("A Divine Force.")) if arceus
            pbGenerateEgg(:TYPENULL,_I("A Corrupted Force.")) if typenull
            newpkmn=$Trainer.lastParty
            if pkmn.ballused!=4 && pkmn.ballused!=15
              newpkmn.ballused=pkmn.ballused
            end
            for i in 0...6
              newpkmn.iv[i]=pkmn.iv[i]
            end
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",pkmn.name))
            if arceus || typenull
              Kernel.pbMessage(_INTL("{1}'s {2} shattered!",pkmn.name,PBItems.getName(pkmn.item)))
            else  
              Kernel.pbMessage(_INTL("{1}'s {2} fused with the egg!",pkmn.name,PBItems.getName(pkmn.item)))
              newpkmn.setItem(pkmn.item)
            end
            pkmn.item=0
            pbHardRefresh
          end
        end
#===============================================================================
# Celestial Pokemon
# Blessing Skill effect: Bestows the user's birthsign onto other party members.
#===============================================================================
      elsif cmdBlessing>=0 && command==cmdBlessing
        if !pkmn.hasBirthsign?
          Kernel.pbMessage(_INTL("Doesn't have a birthsign to bestow!"))
        elsif $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        elsif !pbCanUseCelestialSkill? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          isUsable=(pbCanUseCelestialSkill? && reagent)
          if isUsable
            usetext=_INTL("Activate {1}'s power?\n<c2=65467b14>Blessing: {2}</c2>",pkmn.name,pkmn.pbGetBirthsignName)
            Kernel.pbMessage(_INTL("Activating this celestial power will consume <c2=65467b14>{1}</c2>.",stardust)) 
          else
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again.")) if reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece) if reagent
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust)) if !reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece) if !reagent
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Choose a Pokémon for {1} to bless.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Bless with which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                Kernel.pbMessage(_INTL("{1} can't bless itself!",pkmn.name))
              elsif newpkmn.egg?
                Kernel.pbMessage(_INTL("This power cannot be used on eggs!"))
              elsif (newpkmn.isShadow? rescue false)
                Kernel.pbMessage(_INTL("Shadow Pokémon cannot be blessed."))
              elsif newpkmn.isCelestial?
                Kernel.pbMessage(_INTL("Celestial Pokémon cannot be blessed."))
              elsif pbShareBirthsign?(pkmn,newpkmn)
                Kernel.pbMessage(_INTL("{1} already has that birthsign!",newpkmn.name))
              elsif newpkmn.isBlessed?
                Kernel.pbMessage(_INTL("{1} has already been blessed!",newpkmn.name))
              else
                if newpkmn.hasBirthsign?
                  Kernel.pbMessage(_INTL("Using this power on {1} will replace its current birthsign, and prevent it from receiving another blessing.",newpkmn.name))
                  pbWait(10)
                  if Kernel.pbConfirmMessage(_INTL("Are you sure you want to bless {1}?",newpkmn.name))
                    $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                    $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                    pbUseCelestialSkill
                    pbRitualAnimation(pkmn)
                    pbWait(1)
                    Kernel.pbMessage(_INTL("{1} lost the power of <c2=65467b14>{2}</c2>...",newpkmn.name,newpkmn.pbGetBirthsignName))
                    Kernel.pbMessage(_INTL("And..."))
                    newpkmn.setBirthsign(pkmn.birthsign)
                    newpkmn.makeBlessed
                    pbRefresh
                    pbMEPlay("Evolution success")
                    Kernel.pbMessage(_INTL("\\se[]{1} was blessed with the power of <c2=65467b14>{2}</c2>!\\wt[80]",
                     newpkmn.name,newpkmn.pbGetBirthsignName))
                    pbWait(2)
                    break
                  end
                else
                  Kernel.pbMessage(_INTL("Once blessed, {1} won't be able to receive another blessing.",newpkmn.name))
                  if Kernel.pbConfirmMessage(_INTL("Are you sure you want to bless {1}?",newpkmn.name))
                    $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                    $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                    pbUseCelestialSkill
                    pbRitualAnimation(pkmn)
                    newpkmn.setBirthsign(pkmn.birthsign)
                    newpkmn.makeBlessed
                    pbRefresh
                    pbWait(1)
                    pbMEPlay("Pkmn get")
                    Kernel.pbMessage(_INTL("{1} was blessed with the power of <c2=65467b14>{2}</c2>!",
                     newpkmn.name,newpkmn.pbGetBirthsignName))
                    pbWait(2)
                    break
                  end
                end
              end
              pbRefresh
              break
            end
          end
        end
#===============================================================================
# Birthsigns - The Beacon
# Starlight Skill effect: Mimics the effect of 'Flash'.
#===============================================================================
      elsif cmdStarlight>=0 && command==cmdStarlight
        if !pbGetMetadata($game_map.map_id,MetadataDarkMap) || $PokemonGlobal.flashUsed
          Kernel.pbMessage(_INTL("It's already well-lit here!"))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            @scene.pbEndScene
            darkness=$PokemonTemp.darknessSprite
            pbRitualAnimation(pkmn)
            $PokemonGlobal.flashUsed=true
            pbWait(1)
            pbSEPlay("Vs flash")
            Kernel.pbMessage(_INTL("{1} brightened the area by using the power of <c2=65467b14>{2}</c2>!",
            pkmn.name,pkmn.pbGetBirthsignName))
            pbWait(2)
            while darkness.radius<176
              Graphics.update
              Input.update
              pbUpdateSceneMap
              darkness.radius+=4
            end
            pbRefresh
            return nil
          end
        end
#===============================================================================
# Birthsigns - The Prodigy
# Ability Lure Skill effect: Wild Pokemon spawn with Hidden Abilities.
# Ability Swap Skill effect: Swaps to another of the users's Abilities.
#===============================================================================
      elsif cmdAbilitySwap>=0 && command==cmdAbilitySwap
        abils=pkmn.getAbilityList
        oldabil=PBAbilities.getName(pkmn.ability)
        if abils.length<=1
          # Ability Lure
          if pbAbilLureEffectActive?
            Kernel.pbMessage(_INTL("The effects of this sign's power still lingers."))
          elsif !pbCanUseBirthsignAbilLure? && !reagent2
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
          else
            if !pbCanUseBirthsignAbilLure? && reagent2
              Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
              usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece)
            else
              usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
            end
            if Kernel.pbConfirmMessage(usetext)
              pbRitualAnimation(pkmn)
              pbWait(1)
              $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignAbilLure?
              pbActivateAbilLureEffect
              pbUseBirthsignEffectAbilLure
              Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> may lure Pokémon with hidden abilities!",
              pkmn.pbGetBirthsignName))
            end
          end
        else
          # Ability Swap
          if !reagent && !reagent2
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
          else 
            if reagent
              usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
              Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and change {2}'s ability.",stardust,pkmn.name))
            else
              Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
              usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
            end
            if Kernel.pbConfirmMessage(usetext)
              Kernel.pbMessage(_INTL("Choose an ability for {1} to swap to.",pkmn.name))
              cmd=0
              loop do
                commands=[]
                for i in abils
                  commands.push((i[1]<2 ? "" : "(H) ")+PBAbilities.getName(i[0]))
                end
                commands.push(_INTL("Cancel"))
                msg=[_INTL("Active ability: \n{1}",oldabil),
                     _INTL("Active ability: \n{1}",oldabil)][pkmn.abilityflag!=nil ? 1 : 0]
                cmd=@scene.pbShowCommands(msg,commands,cmd)
                break if cmd==-1
                if cmd>=0 && cmd<abils.length
                  pkmn.setAbility(abils[cmd][1])
                  pbRitualAnimation(pkmn)
                  $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                  $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  Kernel.pbMessage(_INTL("{1} swapped abilities with the power of <c2=65467b14>{2}</c2>!",
                  pkmn.name,pkmn.pbGetBirthsignName))
                  break
                end
              end
            end
          end
          pbRefreshSingle(pkmnid)
        end
#===============================================================================
# Birthsigns - The Martyr
# Charity Skill effect: Mimics the effect of 'Soft-Boiled'.
#===============================================================================
      elsif cmdCharity>=0 && command==cmdCharity
        r=0
        for i in pkmn.moves
          if i.pp<i.totalpp/5.floor || i.pp==1; r+=1; end
        end
        if $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        elsif isConst?(pkmn.species,PBSpecies,:SHEDINJA) && r>pkmn.numMoves
          Kernel.pbMessage(_INTL("{1}'s power is too depleted to heal its allies!",pkmn.name))
        elsif pkmn.hp<=(pkmn.totalhp/5).floor 
          Kernel.pbMessage(_INTL("{1} is too weak to heal its allies!",pkmn.name))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            pbRitualAnimation(pkmn)
            Kernel.pbMessage(_INTL("Choose a Pokémon for {1} to heal.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Heal which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                Kernel.pbMessage(_INTL("{1} can't heal itself!",pkmn.name))
              elsif newpkmn.egg?
                Kernel.pbMessage(_INTL("This power can't be used on eggs!"))
              elsif newpkmn.hp==newpkmn.totalhp
                Kernel.pbMessage(_INTL("That Pokémon doesn't need healing!"))
              else
                targethp=newpkmn.hp
                healtext="revive and heal" if targethp==0
                healtext="heal" if targethp!=0
                if isConst?(pkmn.species,PBSpecies,:SHEDINJA)
                  r=0
                  for i in pkmn.moves
                    i.pp-=i.totalpp/5.floor
                    i.pp=1 if i.pp<1
                     if i.pp<i.totalpp/5.floor || i.pp==1; r+=1; end
                  end
                  hpgain=pbItemRestoreHP(newpkmn,(pkmn.level/2).floor)
                  pbRefresh
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  @scene.pbDisplay(_INTL("The power of <c2=65467b14>{1}</c2> cut {2}'s PP to {3} {4}!",
                  pkmn.pbGetBirthsignName,pkmn.name,healtext,newpkmn.name))
                  pbRefresh
                  if r>=pkmn.numMoves
                    @scene.pbDisplay(_INTL("{1} became too depleted to keep healing...",pkmn.name))
                    break
                  end
                  pbWait(20)
                else
                  pkmn.hp-=(pkmn.totalhp/5).floor
                  hpgain=pbItemRestoreHP(newpkmn,(pkmn.totalhp/5).floor)
                  pbRefresh
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  @scene.pbDisplay(_INTL("The power of <c2=65467b14>{1}</c2> cut {2}'s HP to {3} {4}!",
                  pkmn.pbGetBirthsignName,pkmn.name,healtext,newpkmn.name))
                  pbRefresh
                  if pkmn.hp<=(pkmn.totalhp/5).floor
                    @scene.pbDisplay(_INTL("{1} became too weak to keep healing...",pkmn.name))
                    break
                  end
                  pbWait(20)
                end
              end
            end
          end
        end
#===============================================================================
# Birthsigns - The Voyager
# Navigate Skill effect: Mimics the effect of 'Teleport'.
#===============================================================================
      elsif cmdNavigate>=0 && command==cmdNavigate
        healing = $PokemonGlobal.healingSpot
        healing = pbGetMetadata(0,MetadataHome) if !healing   # Home
        mapname = pbGetMapNameFromId(healing[0])
        if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
          Kernel.pbMessage(_INTL("{1} can't find any stars to navigate with in here!",pkmn.name))
        elsif follower
          Kernel.pbMessage(_INTL("This power can't be used when you have someone with you."))
        elsif !healing
          Kernel.pbMessage(_INTL("{1} has nowhere to navigate to.",pkmn.name))
        else
          Kernel.pbMessage(_INTL("Activating this birthsign will return you to <c2=65467b14>{1}</c2>.",mapname))
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            @scene.pbEndScene
            if !pbRitualAnimation(pkmn)
              pbWait(1)
              Kernel.pbMessage(_INTL("{1} led you to safety!",pkmn.name))
            end
            pbFadeOutIn(99999){
            pbSEPlay("Battle flee")
            $game_temp.player_new_map_id=healing[0]
            $game_temp.player_new_x=healing[1]
            $game_temp.player_new_y=healing[2]
            $game_temp.player_new_direction=2
            Kernel.pbCancelVehicles
            $scene.transfer_player
            $game_map.autoplay
            $game_map.refresh
            }
            pbEraseEscapePoint
            pbWait(2)
            Kernel.pbMessage(_INTL("You returned to <c2=65467b14>{1}</c2> using the power of <c2=65467b14>{2}</c2>!",
            mapname,pkmn.pbGetBirthsignName))
            pbRefresh
            return nil
          end
        end
#===============================================================================
# Birthsigns - The Phoenix
# Rebirth Skill effect: Revives the user with roughly 1/8th its max hp.
#===============================================================================
      elsif cmdRebirth>=0 && command==cmdRebirth
        if !pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} has no need for this power right now.",pkmn.name))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            pbRitualAnimation(pkmn)
            pbWait(1)
            hpgain=pbItemRestoreHP(pkmn,pkmn.totalhp.floor) if rand(5)<1
            hpgain=pbItemRestoreHP(pkmn,pkmn.totalhp/8.floor+1)
            pbMEPlay("Pkmn get")
            pbRefresh
            Kernel.pbMessage(_INTL("{1} was revived by the power of <c2=65467b14>{2}</c2>!",
                             pkmn.name,pkmn.pbGetBirthsignName))
            pbWait(2)
          end
          if rand(100)<1
            item=getID(PBItems,:SACREDASH)
            Kernel.pbMessage(_INTL("Huh?"))
            Kernel.pbMessage(_INTL("<c2=65467b14>{1}</c2> was found on {2} after reviving.",PBItems.getName(item),pkmn.name))
            $PokemonBag.pbStoreItem(item)
          end
          pbRefreshSingle(pkmnid)
        end
#===============================================================================
# Birthsigns - The Fugitive
# Escape Skill effect: Mimics the effects of 'Dig' or 'Escape Rope'.
#===============================================================================
      elsif cmdEscape>=0 && command==cmdEscape
        escape=($PokemonGlobal.escapePoint rescue nil)
        mapname=pbGetMapNameFromId(escape[0])
        outdoors=pbGetMetadata($game_map.map_id,MetadataOutdoor)
        if !escape || escape==[] || outdoors
          Kernel.pbMessage(_INTL("But there's no where to escape to!"))
        elsif follower
          Kernel.pbMessage(_INTL("This power can't be used when you have someone with you."))
        else
          Kernel.pbMessage(_INTL("Activating this birthsign will return you to <c2=65467b14>{1}</c2>.",mapname))
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            if escape
              @scene.pbEndScene
              if !pbRitualAnimation(pkmn)
                pbWait(1)
                Kernel.pbMessage(_INTL("{1} led you to safety!",pkmn.name))
              end
              pbFadeOutIn(99999){
              pbSEPlay("Door exit")
              $game_temp.player_new_map_id=escape[0]
              $game_temp.player_new_x=escape[1]
              $game_temp.player_new_y=escape[2]
              $game_temp.player_new_direction=escape[3]
              Kernel.pbCancelVehicles
              $scene.transfer_player
              $game_map.autoplay
              $game_map.refresh
              }
              pbEraseEscapePoint
              pbWait(2)
              Kernel.pbMessage(_INTL("You escaped to <c2=65467b14>{1}</c2> by using the power of <c2=65467b14>{2}</c2>!",
              mapname,pkmn.pbGetBirthsignName))
              pbRefresh
              return nil
            end
          end
        end
#===============================================================================
# Birthsigns - The Cleric
# Cure Skill effect: Heals the party's status conditions at the cost of HP.
#===============================================================================
      elsif cmdCure>=0 && command==cmdCure
        r=0
        for i in pkmn.moves
          if i.pp<i.totalpp/4.floor || i.pp==1; r+=1; end
        end
        if $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        elsif isConst?(pkmn.species,PBSpecies,:SHEDINJA) && r>=pkmn.numMoves
          Kernel.pbMessage(_INTL("{1}'s power is too depleted to cure its allies!",pkmn.name))
        elsif pkmn.hp<=(pkmn.totalhp/4).floor 
          Kernel.pbMessage(_INTL("{1} is too weak to cure its allies!",pkmn.name))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            pbRitualAnimation(pkmn)
            Kernel.pbMessage(_INTL("Choose a Pokémon for {1} to cure.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Cure which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                Kernel.pbMessage(_INTL("{1} can't cure itself!",pkmn.name))
              elsif newpkmn.egg?
                Kernel.pbMessage(_INTL("This power can't be used on eggs!"))
              elsif newpkmn.hp==0
                Kernel.pbMessage(_INTL("It's too late to cure that Pokémon..."))
              elsif newpkmn.status>0
                if isConst?(pkmn.species,PBSpecies,:SHEDINJA)
                  r=0
                  for i in pkmn.moves
                    i.pp-=i.totalpp/4.floor
                    i.pp=1 if i.pp<1
                     if i.pp<i.totalpp/4.floor || i.pp==1; r+=1; end
                  end
                  newpkmn.status=0
                  newpkmn.statusCount=0
                  pbRefresh
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  @scene.pbDisplay(_INTL("The power of <c2=65467b14>{1}</c2> cut {2}'s PP to cure {3}'s status!",
                  pkmn.pbGetBirthsignName,pkmn.name,newpkmn.name))
                  pbRefresh
                  if r>=pkmn.numMoves
                    Kernel.pbMessage(_INTL("{1} became too depleted to keep curing...",pkmn.name))
                    break
                  end
                  pbWait(20)
                else
                  pkmn.hp-=(pkmn.totalhp/4).floor
                  newpkmn.status=0
                  newpkmn.statusCount=0
                  pbRefresh
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  @scene.pbDisplay(_INTL("The power of <c2=65467b14>{1}</c2> cut {2}'s HP to cure {3}'s status!",
                  pkmn.pbGetBirthsignName,pkmn.name,newpkmn.name))
                  pbRefresh
                  if pkmn.hp<=(pkmn.totalhp/4).floor
                    Kernel.pbMessage(_INTL("{1} became too weak to keep curing...",pkmn.name))
                    break
                  end
                  pbWait(20)
                end
              else
                Kernel.pbMessage(_INTL("That Pokémon doesn't need to be cured!"))
              end
            end
          end
        end
#===============================================================================
# Birthsigns - The Monk
# Trance Skill effect: Selects one of three mantras to change moves or heal PP.
#===============================================================================
      elsif cmdTrance>=0 && command==cmdTrance
        if !pbCanUseBirthsignTrance? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        else
          if !pbCanUseBirthsignTrance? && reagent2
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece)
          else
            usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Which sort of mantra should {1} focus on?",pkmn.name))
            command=0
            loop do
              command=@scene.pbShowCommands(_INTL("Select a mantra."),[
              _INTL("Strong Will"),
              _INTL("Reflection"),
              _INTL("Clear Mind"),
              _INTL("Cancel")
              ],command)
              case command
              when -1, 3
                break
              when 0 # Mantra of Strong Will
                Kernel.pbMessage(_INTL("A <c2=65467b14>Mantra of Strong Will</c2> will replenish {1}'s PP.",pkmn.name))
                if Kernel.pbConfirmMessage(_INTL("Use this mantra?"))
                  ret=0
                  hasfullpp=false
                  for i in pkmn.moves
                    if i.pp==i.totalpp; ret+=1; end
                    hasfullpp=true if ret==pkmn.numMoves
                  end
                  if hasfullpp
                    Kernel.pbMessage(_INTL("But the PP of all of {1}'s moves are already full!",pkmn.name))
                  else
                    Kernel.pbMessage(_INTL("{1} entered a deep trance...",pkmn.name))
                    pbWait(2)
                    Kernel.pbMessage(_INTL("And..."))
                    pbWait(2)
                    pkmn.healPP
                    pbMEPlay("Pkmn get")
                    Kernel.pbMessage(_INTL("{1} replenished its PP with the power of <c2=65467b14>{2}</c2>!",
                    pkmn.name,pkmn.pbGetBirthsignName))
                    $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignTrance?
                    pbUseBirthsignEffectTrance
                    break
                  end
                end
              when 1 # Mantra of Reflection
                Kernel.pbMessage(_INTL("A <c2=65467b14>Mantra of Reflection</c2> will allow {1} to recall a past move.",pkmn.name))
                if Kernel.pbConfirmMessage(_INTL("Use this mantra?"))
                  if pbGetRelearnableMoves(pkmn).length<=0
                    Kernel.pbMessage(_INTL("But {1} has no moves to recall!",pkmn.name))
                  else
                    i=pkmn.moves
                    oldmoveset=[i[0],i[1],i[2],i[3]]
                    pbRitualAnimation(pkmn)
                    Kernel.pbMessage(_INTL("{1} recalled its past moves with the power of <c2=65467b14>{2}</c2>!",
                    pkmn.name,pkmn.pbGetBirthsignName))
                    pbRelearnMoveScreen(pkmn)
                    newmoveset=[i[0],i[1],i[2],i[3]]
                    if newmoveset!=oldmoveset
                      $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignTrance?
                      pbUseBirthsignEffectTrance
                    end
                    break
                  end
                end
              when 2 # Mantra of Clear Mind
                Kernel.pbMessage(_INTL("A <c2=65467b14>Mantra of Clear Mind</c2> will allow {1} to forget a move.",pkmn.name))
                if Kernel.pbConfirmMessage(_INTL("Use this mantra?"))
                  if pkmn.numMoves==1
                    Kernel.pbMessage(_INTL("But {1} only has one move left!",pkmn.name))
                  else
                    moveindex=pbChooseMove(pkmn,_INTL("Forget a move."))
                    if moveindex>=0
                      movename=PBMoves.getName(pkmn.moves[moveindex].id)
                      pkmn.pbDeleteMoveAtIndex(moveindex)
                      pbRitualAnimation(pkmn)
                      Kernel.pbMessage(_INTL("{1} entered a deep trance...",pkmn.name))
                      pbWait(4)
                      Kernel.pbMessage(_INTL("And..."))
                      pbWait(2)
                      pbMEPlay("Pkmn get")
                      Kernel.pbMessage(_INTL("{1} forgot <c2=65467b14>{2}</c2> with the power of <c2=65467b14>{3}</c2>!",
                      pkmn.name,movename,pkmn.pbGetBirthsignName))
                      $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignTrance?
                      pbUseBirthsignEffectTrance
                      break
                    end
                  end
                end
              end
              pbRefresh
            end
          end
        end
#===============================================================================
# Birthsigns - The Ancestor
# Endow Skill effect: Passes along the user's EV spread.
#===============================================================================
      elsif cmdEndow>=0 && command==cmdEndow
        totalev=0
        for k in 0...6
          totalev+=pkmn.ev[k]
        end
        if pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif totalev<pkmn.level*5
          Kernel.pbMessage(_INTL("{1} needs at least <c2=65467b14>{2} EV's</c2> before it can use this skill.",pkmn.name,pkmn.level*5))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Minimum: {2} EV's</c2>",pkmn.name,pkmn.level*5)
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and transfer all of {2}'s effort points to a party member.",
            stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Choose a Pokémon to endow with {1}'s effort points.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Give to which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                Kernel.pbMessage(_INTL("{1} can't be endowed with its own points!",pkmn.name))
              elsif newpkmn.egg?
                Kernel.pbMessage(_INTL("This power can't be used on eggs!"))
                dexdata=pbLoadSpeciesData
                pbGetSpeciesData(dexdata,pkmn.species,SpeciesCompatibility)
                compat10=dexdata.fgetb
                dexdata.close
                Kernel.pbMessage(_INTL("With this birthsign, eggs created by {1} will inherit its EV's naturally.",pkmn.name)) if compat10!=0
              elsif (newpkmn.isShadow? rescue false)
                Kernel.pbMessage(_INTL("Shadow Pokémon can't inherit anything."))
              else
                $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                pbRitualAnimation(pkmn)
                newpkmn.ev=pkmn.ev
                pbWait(2)
                pbMEPlay("Pkmn get")
                Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> endowed {2} with {3}'s effort points!",
                                 pkmn.pbGetBirthsignName,newpkmn.name,pkmn.name))
                pkmn.ev=[0,0,0,0,0,0]
                newpkmn.calcStats
                pkmn.calcStats
                pbRefresh
                break
              end
              break if totalev==0
            end
            pbRefresh
          end
        end
#===============================================================================
# Birthsigns - The Specialist
# Re-roll Skill effect: IV's are reset to yield a new Hidden Power.
#===============================================================================    
      elsif cmdReroll>=0 && command==cmdReroll
        #=======================================================================
        # IV Settings
        # The IV numbers set to odd and even that determines hidden power.
        #=======================================================================
        if pkmn.level>=100 # Lvl 100 Pokemon have IV's rolled between 30-31
          odd = 31
          evn = 30
        elsif pkmn.level>=50 # Lvl 50+ Pokemon have IV's rolled between 25-26
          odd = 25
          evn = 26
        else # All other Pokemon have IV's totally randomized
          odd = (rand(32)/2.floor*2+1)
          evn = (rand(32)/2.floor*2)
        end
        #=======================================================================
        if pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and change {2}'s IV's.",stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Please select a new Hidden Power type."))
            currentpower=pbHiddenPower(pkmn.iv)
            command=0
            loop do
              command=@scene.pbShowCommands(_INTL("Current Type: {1}",
                      PBTypes.getName(currentpower[0])),[
              _INTL("Grass"),
              _INTL("Fire"),
              _INTL("Water"),
              _INTL("Electric"),
              _INTL("Ice"),
              _INTL("Fighting"),
              _INTL("Flying"),
              _INTL("Poison"),
              _INTL("Ground"),
              _INTL("Rock"),
              _INTL("Bug"),
              _INTL("Ghost"),
              _INTL("Steel"),
              _INTL("Psychic"),
              _INTL("Dragon"),
              _INTL("Dark"),
              _INTL("Fairy"),
              _INTL("*Random*"),
              _INTL("Cancel")
            ],command)
            case command
            when -1, 18
              break
            #Re-rolls the user's IV's for a new Hidden Power.
            when 0 # Grass
              pkmn.iv=[odd,odd,evn,odd,evn,odd]
            when 1 # Fire
              pkmn.iv=[odd,odd,evn,evn,evn,odd]
            when 2 # Water
              pkmn.iv=[odd,odd,odd,evn,evn,odd]
            when 3 # Electric
              pkmn.iv=[odd,odd,odd,odd,evn,odd]
            when 4 # Ice
              pkmn.iv=[odd,odd,odd,evn,odd,odd]
            when 5 # Fighting
              pkmn.iv=[odd,odd,evn,evn,evn,evn]
            when 6 # Flying
              pkmn.iv=[odd,odd,odd,evn,evn,evn]
            when 7 # Poison
              pkmn.iv=[odd,odd,evn,odd,evn,evn]
            when 8 # Ground
              pkmn.iv=[odd,odd,odd,odd,evn,evn]
            when 9 # Rock
              pkmn.iv=[odd,odd,evn,evn,odd,evn]
            when 10# Bug
              pkmn.iv=[odd,odd,odd,evn,odd,evn]
            when 11# Ghost
              pkmn.iv=[odd,odd,evn,odd,odd,evn]
            when 12# Steel
              pkmn.iv=[odd,odd,odd,odd,odd,evn]
            when 13# Psychic
              pkmn.iv=[odd,odd,evn,evn,odd,odd]
            when 14# Dragon
              pkmn.iv=[odd,odd,evn,odd,odd,odd]
          #===================================================================
          # Types PBS file must include Fairy type for the below to work.
          # Otherwise it will just return HP Dragon.
          #===================================================================
            when 15# Dark
              pkmn.iv=[odd,evn,odd,odd,odd,odd]
          #===================================================================
          # Types PBS file must include Fairy type for the below to work.
          # Otherwise it will just return HP Dark.
          #===================================================================
            when 16# Fairy
              pkmn.iv=[odd,odd,odd,odd,odd,odd]
          #===================================================================
          # Randomizes the user's IV's and returns their new values.
          #===================================================================
            when 17# Randomize
              if pkmn.level>49 #Users level 50 and higher have better IV rolls.
                pkmn.iv[0]=25+rand(7)
                pkmn.iv[1]=25+rand(7)
                pkmn.iv[2]=25+rand(7)
                pkmn.iv[3]=25+rand(7)
                pkmn.iv[4]=25+rand(7)
                pkmn.iv[5]=25+rand(7)
              else
                pkmn.iv[0]=rand(32)
                pkmn.iv[1]=rand(32)
                pkmn.iv[2]=rand(32)
                pkmn.iv[3]=rand(32)
                pkmn.iv[4]=rand(32)
                pkmn.iv[5]=rand(32)
              end
            end
          #===================================================================
            Kernel.pbMessage(_INTL("Re-roll:\n{1}/{2}/{3}/{4}/{5}/{6}",
            pkmn.iv[0],pkmn.iv[1],pkmn.iv[2],pkmn.iv[4],pkmn.iv[5],pkmn.iv[3]))
            $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
            $PokemonBag.pbDeleteItem(:STARDUST) if reagent
            pbRitualAnimation(pkmn)
            pkmn.calcStats
            pkmn.hp=1 if pkmn.hp<=0
            pbRefreshSingle(pkmnid)
            pbWait(1)
            pbMEPlay("Pkmn get")
            newpower=pbHiddenPower(pkmn.iv)
            Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> changed {2}'s Hidden Power to <c2=65467b14>{3}</c2>!",
            pkmn.pbGetBirthsignName,pkmn.name,PBTypes.getName(newpower[0])))
            break
          end
        end
      end
#===============================================================================
# Birthsigns - The Parent
# Incubate Skill effect: Reduces an egg's stepcount to 1, instantly hatching it.
#===============================================================================
      elsif cmdIncubate>=0 && command==cmdIncubate
        if $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        elsif !pbCanUseBirthsignIncubate? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        else
          if !pbCanUseBirthsignIncubate? && reagent2
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece)
          else
            usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Choose an egg for {1} to incubate.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Incubate which egg?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if Input.trigger?(Input::B)
                break
              elsif newpkmn.egg?
                pbRitualAnimation(pkmn)
                Kernel.pbMessage(_INTL("{1} incubated the egg with the power of <c2=65467b14>{2}</c2>!",
                  pkmn.name,pkmn.pbGetBirthsignName))
                newpkmn.eggsteps=1
                pbWait(1)
                pbMEPlay("Pkmn get")
                Kernel.pbMessage(_INTL("The egg is now ready to hatch!"))
                pbWait(2)
                $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignIncubate?
                pbUseBirthsignEffectIncubate
                break
              else
                Kernel.pbMessage(_INTL("This power only works on eggs!"))
              end
            end
            pbRefresh
          end
        end
#===============================================================================
# Birthsigns - The Eternal
# Reincarnate Skill effect: Resets the user to birth for a new birthsign.
#===============================================================================
      elsif cmdReincarnate>=0 && command==cmdReincarnate
        if pkmn.hasCurrentsign? && !pkmn.isCelestial?
          Kernel.pbMessage(_INTL("This power won't work unless its a different month!"))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Current Sign: {2}</c2>",pkmn.name,PBZodiacsigns.getName(Time.now.mon))
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and may reset {2}'s zodiac sign, level, and many other attributes.",stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            pbWait(10)
            $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
            $PokemonBag.pbDeleteItem(:STARDUST) if reagent
            pbRitualAnimation(pkmn)
            pkmn.hp=pkmn.totalhp
            pkmn.status=0
            pkmn.statusCount=0
            pkmn.level=EGGINITIALLEVEL
            pkmn.ev=[0,0,0,0,0,0]
            pkmn.happiness=120
            pkmn.pokerus=0
            pkmn.timeEggHatched=pbGetTimeNow
            pkmn.obtainText=_INTL("Reincarnated.")
            pkmn.giveRibbon(:SECONDSTEP)
            # Celestial Pokemon keep their sign and trainer data
            if !pkmn.isCelestial?
              pkmn.trainerID = $Trainer.id
              pkmn.ot = $Trainer.name
              pkmn.otgender = $Trainer.gender
              pkmn.setZodiacsign(Time.now.mon)
              pkmn.makeBlessed
            end
            pkmn.calcStats
            pbRefreshSingle(pkmnid)
            pbMEPlay("Pkmn get") if pkmn.isCelestial?
            Kernel.pbMessage(_INTL("{1} was reincarnated by the power of <c2=65467b14>{2}</c2>!",
            pkmn.name,PBBirthsigns.getName(24)))
            if !pkmn.isCelestial?
              Kernel.pbMessage(_INTL("And..."))
              pbRefresh
              pbMEPlay("Evolution success")
              Kernel.pbMessage(_INTL("\\se[]{1} gained the power of\n<c2=65467b14>{2}</c2>!\\wt[80]",
              pkmn.name,pkmn.pbGetBirthsignName))
              if Kernel.pbConfirmMessage(_INTL("Would you like to rename the reincarnated Pokémon?"))
                species=PBSpecies.getName(pkmn.species)
                nickname=pbEnterPokemonName(_INTL("{1}'s new name?",pkmn.name),0,10,"",pkmn)
                pkmn.name=nickname if nickname!=""
                pbRefreshSingle(pkmnid)
              end
            end
            if pkmn.hasRibbon?(:SECONDSTEP)
              Kernel.pbMessage(_INTL("You put the <c2=65467b14>Second Step Ribbon</c2> on {1} to commemorate new life.",pkmn.name))
            end
            pbRefresh
          end
        end
#===============================================================================
# Birthsigns - The Bard
# Harmonize Skill effect: Choose from a list of songs with varying effects.
#===============================================================================
# Alluring Aria: Mimics the effect of 'White Flute', and lures a wild Pokemon.
# Repellent Rapture: Mimics the effect of 'Black Flute', and repels wild Pokemon.
# Mysterious Melody: Attempts to lure a wild Pokemon exclusive to the PokeRadar.
#===============================================================================
      elsif cmdHarmonize>=0 && command==cmdHarmonize
        if !$PokemonEncounters.isEncounterPossibleHere?
          Kernel.pbMessage(_INTL("But there's nothing nearby to hear {1}'s tune...",pkmn.name))
        elsif $game_screen.weather_type!=PBFieldWeather::None
          Kernel.pbMessage(_INTL("{1}'s tune doesn't seem to travel well right now...",pkmn.name))
        elsif !pbCanUseBirthsignHarmonize? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        else
          if !pbCanUseBirthsignHarmonize? && reagent2
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece)
          else
            usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Which song should {1} sing?",pkmn.name))
            command=0
            loop do
              command=@scene.pbShowCommands(_INTL("Choose a song."),[
              _INTL("Alluring Aria"),
              _INTL("Repellent Rapture"),
              _INTL("Mysterious Melody"),
              _INTL("Cancel")
            ],command)
            case command
            when -1, 3
              break
            when 0 # Alluring Aria
              @scene.pbEndScene
              pbRitualAnimation(pkmn)
              pbWait(1)
              pbSEPlay("Anim/Sing")
              Kernel.pbMessage(_INTL("\\se[]With the power of <c2=65467b14>{1}</c2>, {2} emits an alluring tune...\\wt[80]",
                pkmn.pbGetBirthsignName,pkmn.name))
              $PokemonMap.whiteFluteUsed = true if $PokemonMap
              $PokemonMap.blackFluteUsed = false if $PokemonMap
              encounter = nil
              enctype = $PokemonEncounters.pbEncounterType
              if enctype>0 && $PokemonEncounters.isEncounterPossibleHere?
                Kernel.pbMessage(_INTL("{1}'s tune seems to have attracted something!",pkmn.name))
                $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignHarmonize?
                pbUseBirthsignEffectHarmonize
                pbWait(10)
                pbEncounter(enctype)
              else  
                Kernel.pbMessage(_INTL("{1}'s tune didn't seem to attract anything...",pkmn.name))
              end
            when 1 # Repellent Rapture
              @scene.pbEndScene
              pbUseBirthsignEffectHarmonize
              pbRitualAnimation(pkmn)
              pbWait(1)
              pbSEPlay("Anim/Sing")
              Kernel.pbMessage(_INTL("\\se[]With the power of <c2=65467b14>{1}</c2>, {2} emits a repulsive tune...\\wt[80]",
                pkmn.pbGetBirthsignName,pkmn.name))
              $PokemonMap.whiteFluteUsed = false if $PokemonMap
              $PokemonMap.blackFluteUsed = true if $PokemonMap
              pbWait(10)
              Kernel.pbMessage(_INTL("{1}'s tune seems to have scared away wild Pokémon!",pkmn.name))
              $PokemonGlobal.repel=250 if pkmn.level>50
              $PokemonGlobal.repel=200 if pkmn.level>25
              $PokemonGlobal.repel=100 if pkmn.level<25
              $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignHarmonize?
              pbUseBirthsignEffectHarmonize
            when 2 # Mysterious Melody
              @scene.pbEndScene
              pbUseBirthsignEffectHarmonize
              pbRitualAnimation(pkmn)
              pbWait(1)
              pbSEPlay("Anim/Sing")
              Kernel.pbMessage(_INTL("\\se[]With the power of <c2=65467b14>{1}</c2>, {2} emits an odd tune...\\wt[80]",
                pkmn.pbGetBirthsignName,pkmn.name))
              pbWait(10)
              enctype = $PokemonEncounters.pbEncounterType
              map = $game_map.map_id rescue 0
              array = []
              for enc in POKERADAREXCLUSIVES
                array.push(enc) if enc.length>=4 && enc[0]==map && getID(PBSpecies,enc[2])>0
                species=getID(PBSpecies,enc[2])
              end
              if array.length>0
                for enc in array
                  upper = (enc[4]!=nil) ? enc[4] : enc[3]
                  level = enc[3]+rand(1+upper-enc[3])
                  if enctype<0 || !$PokemonEncounters.isEncounterPossibleHere?
                    Kernel.pbMessage(_INTL("{1}'s tune didn't seem to attract anything...",pkmn.name))
                  else
                    Kernel.pbMessage(_INTL("{1}'s tune seems to have attracted something!",pkmn.name))
                    pbWait(10)
                    $PokemonTemp.forceSingleBattle = true
                    pbWildBattle(species,level)
                    $PokemonBag.pbDeleteItem(:STARPIECE) if !pbCanUseBirthsignHarmonize?
                    pbUseBirthsignEffectHarmonize
                  end
                end
              else
                Kernel.pbMessage(_INTL("{1}'s tune didn't seem to attract anything...",pkmn.name))
              end
            end
            return nil
          end
        end
      end
#===============================================================================
# Birthsigns - The Empath
# Bond Skill effect: Copies the nature of a party member.
#===============================================================================
      elsif cmdBond>=0 && command==cmdBond
        if $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Nature: {2}</c2>",pkmn.name,PBNatures.getName(pkmn.nature))
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and change {2}'s nature.",stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            Kernel.pbMessage(_INTL("Choose a Pokémon for {1} to bond with.",pkmn.name))
            @scene.pbSetHelpText(_INTL("Bond with which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                Kernel.pbMessage(_INTL("{1} can't bond with itself!",pkmn.name))
              elsif newpkmn.egg?
                Kernel.pbMessage(_INTL("This power can't be used on eggs!"))
              elsif (newpkmn.isShadow? rescue false)
                Kernel.pbMessage(_INTL("That Pokémon doesn't seem willing to bond..."))
              elsif pkmn.nature==newpkmn.nature
                Kernel.pbMessage(_INTL("{1} is already feeling <c2=65467b14>{2}</c2>!",pkmn.name,PBNatures.getName(pkmn.nature)))
              else
                pbRitualAnimation(pkmn)
                pkmn.setNature(newpkmn.nature)
                $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                pbRefreshSingle(pkmnid)
                pbMEPlay("Pkmn get")
                Kernel.pbMessage(_INTL("{1} is feeling <c2=65467b14>{2}</c2> by using the power of <c2=65467b14>{3}</c2>!",
                 pkmn.name,PBNatures.getName(pkmn.nature),pkmn.pbGetBirthsignName))
                break
              end
            end
            pbRefresh
          end
        end
#===============================================================================
# Birthsigns - The Tactician
# Gambit Skill effect: Allows the user to reallocate EV's by using Stardust.
#===============================================================================
      elsif cmdGambit>=0 && command==cmdGambit
        totalev=0
        for k in 0...6
          totalev+=pkmn.ev[k]
        end
        if pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif totalev!=PokeBattle_Pokemon::EVLIMIT
          Kernel.pbMessage(_INTL("{1} needs the maximum of <c2=65467b14>{2} EV's</c2> before it can use this skill.",pkmn.name,PokeBattle_Pokemon::EVLIMIT))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Requires Max EV's</c2>",pkmn.name)
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and will reset any accumulated effort points.",stardust))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
            i=pkmn.ev
            oldevs=[i[0],i[1],i[2],i[3],i[4],i[5]]
            pkmn.ev=[0,0,0,0,0,0]
            Kernel.pbMessage(_INTL("Please reallocate {1}'s effort points.",pkmn.name))
            command = 0
            loop do
              totalev=0
              for k in 0...6
                totalev+=pkmn.ev[k]
              end
              evcommands = []
              for i in 0...6
                evcommands.push(PBStats.getName(i)+" (#{pkmn.ev[i]})")
              end
              evcommands.push(_INTL("-Change-"))
              evcommands.push(_INTL("-Cancel-"))
              evtotal=(PokeBattle_Pokemon::EVLIMIT-totalev)
              command=@scene.pbShowCommands(_INTL("{1} total points remaining.",evtotal),evcommands,command)
              if command<0 || command==7
                Kernel.pbMessage(_INTL("{1}'s effort points were unchanged.",pkmn.name))
                pkmn.ev=oldevs
                pkmn.calcStats
                pbRefreshSingle(pkmnid)
                break
              elsif command<6
                remainder=(PokeBattle_Pokemon::EVLIMIT-PokeBattle_Pokemon::EVSTATLIMIT)
                if totalev<=remainder
                  statcap=PokeBattle_Pokemon::EVSTATLIMIT
                elsif totalev>remainder
                  statcap=(PokeBattle_Pokemon::EVLIMIT-totalev)
                end
                params = ChooseNumberParams.new
                params.setRange(0,statcap)
                params.setDefaultValue(pkmn.ev[command])
                params.setCancelValue(pkmn.ev[command])
                f = Kernel.pbMessageChooseNumber(_INTL("Set effort for {1}.\nPoints available: {2}",
                   PBStats.getName(command),statcap),params) { @scene.update }
                if f!=pkmn.ev[command]
                  pkmn.ev[command] = f
                end
              elsif command==6
                if Kernel.pbConfirmMessage(_INTL("Are you sure you want this effort spread?"))
                  $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
                  $PokemonBag.pbDeleteItem(:STARDUST) if reagent
                  pbRitualAnimation(pkmn)
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> reallocated {2}'s effort points!",
                    pkmn.pbGetBirthsignName,pkmn.name))
                  pkmn.calcStats
                  pkmn.hp=1 if pkmn.hp<=0
                  pbRefreshSingle(pkmnid)
                  break
                else
                  pkmn.ev=[0,0,0,0,0,0]
                  Kernel.pbMessage(_INTL("Please reallocate {1}'s effort points.",pkmn.name))
                  command=0
                end
              end
            end
          end
        end
#===============================================================================
# Birthsigns - The Fool
# Lunacy Skill effect: Reduces the user's level to raise a party member's level.
#===============================================================================
      elsif cmdLunacy>=0 && command==cmdLunacy
        minlevel=$Trainer.numbadges*7
        minlevel=10 if $Trainer.numbadges<=1
        minlevel=55 if $Trainer.numbadges>=8
        if pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif pkmn.level<minlevel
          Kernel.pbMessage(_INTL("{1} needs to be at least <c2=65467b14>level {2}</c2> to use this skill.",pkmn.name,minlevel))
        elsif $Trainer.party.length<=1
          Kernel.pbMessage(_INTL("But there aren't any other Pokémon in the party!"))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Minimum Level: {2}</c2>",pkmn.name,minlevel))
            Kernel.pbMessage(_INTL("Using this power will lower {1}'s level by 3...",pkmn.name))
            pbWait(5)
            if Kernel.pbConfirmMessage(_INTL("Are you sure you want to activate this power?"))
              Kernel.pbMessage(_INTL("Choose a Pokémon for {1} to level up.",pkmn.name))
              @scene.pbSetHelpText(_INTL("Level up which Pokémon?"))
              oldpkmnid=pkmnid
              maxlevel=PBExperience::MAXLEVEL
              loop do
                @scene.pbPreSelect(oldpkmnid)
                pkmnid=@scene.pbChoosePokemon(true,pkmnid)
                break if pkmnid<0
                newpkmn=@party[pkmnid]
                if pkmnid==oldpkmnid
                  Kernel.pbMessage(_INTL("{1} can't use this power to level itself!",pkmn.name))
                elsif newpkmn.egg?
                  Kernel.pbMessage(_INTL("This power can't be used on eggs!"))
                elsif (newpkmn.isShadow? rescue false)
                  Kernel.pbMessage(_INTL("This power won't work on that Pokémon."))
                elsif pkmn.level<newpkmn.level || newpkmn.level==maxlevel
                  Kernel.pbMessage(_INTL("{1}'s level is too high for this power!",newpkmn.name))
                else
                  pbRitualAnimation(pkmn)
                  #=============================================================
                  # De-leveling User
                  #=============================================================
                  pkmn.level-=3
                  pkmn.calcStats
                  pkmn.hp=1 if pkmn.hp<=0
                  pbRefreshSingle(pkmnid)
                  Kernel.pbMessage(_INTL("{1} fell to Level {2}...",pkmn.name,pkmn.level))
                  Kernel.pbMessage(_INTL("But..."))
                  #=============================================================
                  # Leveling Ally
                  #=============================================================
                  attackdiff=newpkmn.attack
                  defensediff=newpkmn.defense
                  speeddiff=newpkmn.speed
                  spatkdiff=newpkmn.spatk
                  spdefdiff=newpkmn.spdef
                  totalhpdiff=newpkmn.totalhp
                  newpkmn.level+=(1+rand(5))
                  newpkmn.changeHappiness("levelup")
                  newpkmn.calcStats
                  pbRefresh
                  pbWait(1)
                  pbMEPlay("Pkmn get")
                  Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> elevated {2} to Level {3}!",
                  pkmn.pbGetBirthsignName,newpkmn.name,newpkmn.level))
                  pbWait(2)
                  attackdiff=newpkmn.attack-attackdiff
                  defensediff=newpkmn.defense-defensediff
                  speeddiff=newpkmn.speed-speeddiff
                  spatkdiff=newpkmn.spatk-spatkdiff
                  spdefdiff=newpkmn.spdef-spdefdiff
                  totalhpdiff=newpkmn.totalhp-totalhpdiff
                  pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
                    totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
                  pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
                    newpkmn.totalhp,newpkmn.attack,newpkmn.defense,newpkmn.spatk,newpkmn.spdef,newpkmn.speed))
                  movelist=newpkmn.getMoveList
                  for i in movelist
                    if i[0]==newpkmn.level          # Learned a new move
                      pbLearnMove(newpkmn,i[1],true)
                    end
                  end
                  newspecies=pbCheckEvolution(newpkmn)
                  if newspecies>0
                    pbFadeOutInWithMusic(99999){
                       evo=PokemonEvolutionScene.new
                       evo.pbStartScreen(newpkmn,newspecies)
                       evo.pbEvolution
                       evo.pbEndScreen
                    }
                  end
                  pbRefresh
                  break
                end
              end
            end
          end
        end
#===============================================================================
# Birthsigns - The Alchemist
# Transmute Skill effect: Uses Stardust to morph held items into new ones.
#===============================================================================
      elsif cmdTransmute>=0 && command==cmdTransmute
      # Items that should not be transmutable must be added to this list below
        nontransmutable = (pbIsKeyItem?(pkmn.item) ||           
                           pbIsMachine?(pkmn.item) || 
                           pbIsMegaStone?(pkmn.item) ||
                           (pbIsZCrystal?(pkmn.item) if $game_switches[ZMOVES_SWITCH]) ||
                           (pbIsZCrystal2?(pkmn.item) if $game_switches[ZMOVES_SWITCH]) ||
                           isConst?(pkmn.item,PBItems,:REDORB) || 
                           isConst?(pkmn.item,PBItems,:BLUEORB) ||
                           isConst?(pkmn.item,PBItems,:ADAMANTORB) ||
                           isConst?(pkmn.item,PBItems,:LUSTROUSORB) ||
                           isConst?(pkmn.item,PBItems,:GRISEOUSORB) ||
                           isConst?(pkmn.item,PBItems,:SOULDEW) ||
                           isConst?(pkmn.item,PBItems,:BURNDRIVE) ||
                           isConst?(pkmn.item,PBItems,:CHILLDRIVE) ||
                           isConst?(pkmn.item,PBItems,:SHOCKDRIVE) ||
                           isConst?(pkmn.item,PBItems,:DOUSEDRIVE) ||
                           isConst?(pkmn.item,PBItems,:RUSTEDSHIELD) ||
                           isConst?(pkmn.item,PBItems,:RUSTEDSWORD) ||
                           isConst?(pkmn.item,PBItems,:STARDUST) ||
                           isConst?(pkmn.item,PBItems,:STARPIECE) ||
                           isConst?(pkmn.item,PBItems,:MASTERBALL))
        if !pkmn.hasItem?
          Kernel.pbMessage(_INTL("{1} isn't holding an item to transmute!",pkmn.name))
        elsif nontransmutable
          Kernel.pbMessage(_INTL("{1} isn't a transmutable item!",PBItems.getName(pkmn.item)))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          if reagent
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Holding: {2}</c2>",pkmn.name,PBItems.getName(pkmn.item))
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and permanently change {2}'s <c2=65467b14>{3}</c2>.",
            stardust,pkmn.name,PBItems.getName(pkmn.item)))
          else
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece)
          end
          if Kernel.pbConfirmMessage(usetext)
#===============================================================================
#                              Creation List
#===============================================================================
# Includes most items up to Gen 8; no consequences if all items aren't present.
#===============================================================================
excavation = [:HEATROCK,:ICYROCK,:DAMPROCK,:SMOOTHROCK,:LIGHTCLAY,:EVIOLITE,
              :ODDKEYSTONE,:HARDSTONE,:EVERSTONE,:FLOATSTONE,:OVALSTONE,:REDSHARD,
              :BLUESHARD,:YELLOWSHARD,:GREENSHARD,:COMETSHARD,:SHOALSHELL,:REVIVE,
              :MAXREVIVE,:NUGGET,:BIGNUGGET,:PEARL,:BIGPEARL,:SOFTSAND,:RAREBONE,
              :WISHINGPIECE]
              #26===============================================================
mints      = [:LONELYMINT,:ADAMANTMINT,:NAUGHTYMINT,:BRAVEMINT,:BOLDMINT,:IMPISHMINT,
              :LAXMINT,:RELAXEDMINT,:MODESTMINT,:MILDMINT,:RASHMINT,:QUIETMINT,:CALMMINT,
              :GENTLEMINT,:CAREFULMINT,:SASSYMINT,:TIMIDMINT,:HASTYMINT,:JOLLYMINT,
              :NAIVEMINT,:SERIOUSMINT]
              #21===============================================================
beastparts = [:DEEPSEASCALE,:DRAGONSCALE,:HEARTSCALE,:PRISMSCALE,:DEEPSEATOOTH,
              :DRAGONFANG,:RAZORFANG,:GRIPCLAW,:QUICKCLAW,:RAZORCLAW,:LAGGINGTAIL,
              :SLOWPOKETAIL,:SHARPBEAK,:PRETTYWING,:POISONBARB,:STICKYBARB,
              :SHEDSHELL,:SHOALSHELL,:RAREBONE,:BERSERKGENE]
              #20===============================================================
plates     = [:FLAMEPLATE,:SPLASHPLATE,:ZAPPLATE,:MEADOWPLATE,:ICICLEPLATE,:FISTPLATE,
              :TOXICPLATE,:EARTHPLATE,:SKYPLATE,:MINDPLATE,:INSECTPLATE,:STONEPLATE,
              :SPOOKYPLATE,:DRACOPLATE,:DREADPLATE,:IRONPLATE,:PIXIEPLATE,
              :DIVINEPLATE,:FALSEPLATE]
              #19===============================================================
memories   = [:BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,
              :FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,:GRASSMEMORY,
              :GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,:PSYCHICMEMORY,:ROCKMEMORY,
              :STEELMEMORY,:WATERMEMORY]
              #17===============================================================
evostones  = [:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,
              :DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:REDSHARD,:BLUESHARD,:YELLOWSHARD,
              :GREENSHARD,:EVERSTONE,:EVIOLITE,:ICESTONE,:OVALSTONE]
              #17===============================================================
gadgets    = [:MAGNET,:RINGTARGET,:METRONOME,:EJECTBUTTON,:CELLBATTERY,:MACHOBRACE,
              :SOOTHEBELL,:UPGRADE,:DUBIOUSDISC,:ELECTIRIZER,:MAGMARIZER,:PROTECTOR,
              :EXPSHARE,:TERRAINEXTENDER,:ASSAULTVEST,:PROTECTIVEPADS,:EJECTPACK,
              :HEAVYDUTYBOOTS,:ROOMSERVICE,:UTILITYUMBRELLA]
              #20===============================================================
clothing   = [:CHOICESCARF,:CHOICEBAND,:EXPERTBELT,:MUSCLEBAND,:FOCUSBAND,:FOCUSSASH,
              :BINDINGBAND,:BLACKBELT,:SILKSCARF,:REDSCARF,:BLUESCARF,:PINKSCARF,
              :GREENSCARF,:YELLOWSCARF]
              #14===============================================================
junkitem   = [:SHOALSALT,:BRIGHTPOWDER,:SILVERPOWDER,:QUICKPOWDER,:ENERGYPOWDER,
              :HEALPOWDER,:GROWTHMULCH,:DAMPMULCH,:STABLEMULCH,:GOOEYMULCH,
              :SACREDASH,:CHARCOAL,:BLACKSLUDGE]
              #13===============================================================
fossils    = [:HELIXFOSSIL,:DOMEFOSSIL,:ROOTFOSSIL,:CLAWFOSSIL,:SKULLFOSSIL,
              :ARMORFOSSIL,:COVERFOSSIL,:PLUMEFOSSIL,:OLDAMBER,:SAILFOSSIL,
              :JAWFOSSIL,:FOSSILIZEDBIRD,:FOSSILIZEDDINO,:FOSSILIZEDDRAKE,
              :FOSSILIZEDFISH,:THICKCLUB,:SACREDASH]
              #17===============================================================
zodiacgem  = [:JANZODICA,:FEBZODICA,:MARZODICA,:APRIZODICA,:MAYZODICA,:JUNZODICA,
              :JULZODICA,:AUGZODICA,:SEPZODICA,:OCTZODICA,:NOVIZODICA,:DECIZODICA]
              #12===============================================================
herbs      = [:ENERGYROOT,:REVIVALHERB,:ABSORBBULB,:MENTALHERB,:POWERHERB,:WHITEHERB,
              :TINYMUSHROOM,:BIGMUSHROOM,:BALMMUSHROOM,:BIGROOT,:STICK,:LUMINOUSMOSS,
              :SWEETAPPLE,:TARTAPPLE,:LEFTOVERS]
              #15===============================================================
treasure1  = [:RELICCOPPER,:RELICCOPPER,:RELICSILVER,:BOTTLECAP,:NUGGET,:BIGNUGGET,
              :STARPIECE,:SOFTSAND,:KINGSROCK,:REVIVE,:MAXREVIVE,:CRACKEDPOT]
              #12===============================================================
treasure2  = [:RELICGOLD,:RELICGOLD,:RELICVASE,:RELICBAND,:RELICSTATUE,:KINGSROCK,
              :RELICCROWN,:AMULETCOIN,:BOTTLECAP,:BOTTLECAP,:GOLDBOTTLECAP,:CHIPPEDPOT] 
              #12===============================================================
incenses   = [:LAXINCENSE,:FULLINCENSE,:LUCKINCENSE,:PUREINCENSE,:SEAINCENSE,
              :WAVEINCENSE,:ROSEINCENSE,:ODDINCENSE,:ROCKINCENSE,:SACHET]
              #10================================================================
liquids    = [:MYSTICWATER,:MYSTICWATER,:SODAPOP,:LEMONADE,:MOOMOOMILK,:BERRYJUICE,
              :NEVERMELTICE,:SNOWBALL,:THROATSPRAY]
              #9===============================================================
vitamins   = [:PPUP,:PPMAX,:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS,:ABILITYCAPSULE]
              #9================================================================
apricorn   = [:REDAPRICORN,:YLWAPRICORN,:BLUAPRICORN,:GRNAPRICORN,:PNKAPRICORN,
              :WHTAPRICORN,:BLKAPRICORN]              
              #7================================================================
orbs       = [:LIFEORB,:LIGHTORB,:FLAMEORB,:TOXICORB,:SMOKEBALL,:IRONBALL,
              :PEARLSTRING,:ADRENALINEORB] 
              #8================================================================
glass      = [:CHOICESPECS,:BLACKGLASSES,:WISEGLASSES,:SCOPELENS,:WIDELENS,
              :ZOOMLENS,:SAFETYGOGGLES,:BLACKFLUTE,:BLUEFLUTE,:REDFLUTE,
              :WHITEFLUTE,:YELLOWFLUTE]
              #12================================================================
sweets     = [:STRAWBERRYSWEET,:LOVESWEET,:BERRYSWEET,:CLOVERSWEET,:FLOWERSWEET,
              :STARSWEET,:RIBBONSWEET,:SWEETHEART,:CASTELIACONE,:OLDGATEAU,
              :LAVACOOKIE,:RAGECANDYBAR,:PEWTERCRUNCHIES,:WHIPPEDDREAM,:RARECANDY,
              :DYNAMAXCANDY]
              #16===============================================================
expcandy   = [:EXPCANDYXS,:EXPCANDYXS,:EXPCANDYS,:EXPCANDYS,:EXPCANDYM,:EXPCANDYM,
              :EXPCANDYL,:EXPCANDYXL,:RARECANDY,:DYNAMAXCANDY]
              #10===============================================================
berryscrap = [:BERRYJUICE,:BERRYJUICE,:BLACKSLUDGE,:MIRACLESEED,:MIRACLESEED,:LEFTOVERS]
              #6================================================================
poweritem  = [:POWERWEIGHT,:POWERBRACER,:POWERBELT,:POWERLENS,:POWERBAND,:POWERANKLET] 
              #6================================================================
wings      = [:HEALTHWING,:MUSCLEWING,:RESISTWING,:GENIUSWING,:CLEVERWING,:SWIFTWING]
              #6================================================================
potions    = [:POTION,:SUPERPOTION,:SUPERPOTION,:HYPERPOTION,:MAXPOTION,:FULLRESTORE]
              #6================================================================
statusitem = [:ANTIDOTE,:BURNHEAL,:AWAKENING,:ICEHEAL,:PARALYZEHEAL,:FULLHEAL]
              #6================================================================
paperitem  = [:REDCARD,:CLEANSETAG,:CLEANSETAG,:SPELLTAG,:DISCOUNTCOUPON,
              :WEAKNESSPOLICY,:BLUNDERPOLICY]
              #7================================================================
repels     = [:REPEL,:REPEL,:SUPERREPEL,:SUPERREPEL,:MAXREPEL]
              #5================================================================
              
#===============================================================================
# Creates items
#===============================================================================
            # CREATES ELEMENTAL MATERIALS
            if isConst?(pkmn.item,PBItems,:SACREDASH)
              pkmn.setItem(:MIRACLESEED) if rand(100)>75
              pkmn.setItem(:MYSTICWATER) if rand(100)>50
              pkmn.setItem(:CHARCOAL) if rand(100)>25
              pkmn.setItem(:RAREBONE) if rand(100)<25 
            # CREATES FRESH WATER
            elsif (isConst?(pkmn.item,PBItems,:MYSTICWATER) ||
                  isConst?(pkmn.item,PBItems,:NEVERMELTICE))
              pkmn.setItem(:FRESHWATER)
            # CREATES NEVER-MELT ICE
            elsif (isConst?(pkmn.item,PBItems,:CASTELIACONE) ||
                  isConst?(pkmn.item,PBItems,:SNOWBALL))
              pkmn.setItem(:NEVERMELTICE)
            # CREATES HONEY
            elsif (isConst?(pkmn.item,PBItems,:BERRYJUICE) ||
                  isConst?(pkmn.item,PBItems,:LEMONADE) ||
                  isConst?(pkmn.item,PBItems,:SODAPOP) ||
                  isConst?(pkmn.item,PBItems,:PINKNECTAR) ||
                  isConst?(pkmn.item,PBItems,:PURPLENECTAR) ||
                  isConst?(pkmn.item,PBItems,:REDNECTAR) ||
                  isConst?(pkmn.item,PBItems,:YELLOWNECTAR))
              pkmn.setItem(:HONEY)
            # CREATES SEEDS & JUICE
            elsif isConst?(pkmn.item,PBItems,:RINDOBERRY)
              pkmn.setItem(:GRASSYSEED)
            elsif isConst?(pkmn.item,PBItems,:WACANBERRY)
              pkmn.setItem(:ELECTRICSEED)
            elsif isConst?(pkmn.item,PBItems,:PAYAPABERRY)
              pkmn.setItem(:PSYCHICSEED)
            elsif isConst?(pkmn.item,PBItems,:ROSELIBERRY)
              pkmn.setItem(:MISTYSEED)
            elsif pbIsBerry?(pkmn.item)
              pkmn.setItem(berryscrap[rand(berryscrap.length)])
            # CREATES HERBS & ROOTS
            elsif (isConst?(pkmn.item,PBItems,:MIRACLESEED) ||
                  isConst?(pkmn.item,PBItems,:GRASSYSEED) ||
                  isConst?(pkmn.item,PBItems,:ELECTRICSEED) ||
                  isConst?(pkmn.item,PBItems,:PSYCHICSEED) ||
                  isConst?(pkmn.item,PBItems,:MISTYSEED))
              pkmn.setItem(herbs[rand(herbs.length)])
            # CREATES MINTS
            elsif (isConst?(pkmn.item,PBItems,:REVIVALHERB) ||
                  isConst?(pkmn.item,PBItems,:WHITEHERB) ||
                  isConst?(pkmn.item,PBItems,:POWERHERB) ||
                  isConst?(pkmn.item,PBItems,:MENTALHERB))
              pkmn.setItem(mints[rand(mints.length)])
            # CREATES APRICORN
            elsif (isConst?(pkmn.item,PBItems,:LEVELBALL) ||
                  isConst?(pkmn.item,PBItems,:REPEATBALL))
              pkmn.setItem(:REDAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:MOONBALL) ||
                  isConst?(pkmn.item,PBItems,:QUICKBALL))
              pkmn.setItem(:YLWAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:LUREBALL) ||
                  isConst?(pkmn.item,PBItems,:DIVEBALL) ||
                  isConst?(pkmn.item,PBItems,:NETBALL))
              pkmn.setItem(:BLUAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:FRIENDBALL) ||
                  isConst?(pkmn.item,PBItems,:NESTBALL))
              pkmn.setItem(:GRENAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:LOVEBALL) ||
                  isConst?(pkmn.item,PBItems,:HEALBALL) ||
                  isConst?(pkmn.item,PBItems,:DREAMBALL))
              pkmn.setItem(:PNKAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:FASTBALL) ||
                  isConst?(pkmn.item,PBItems,:PREMIERBALL) ||
                  isConst?(pkmn.item,PBItems,:TIMERBALL))
              pkmn.setItem(:WHTAPRICORN)
            elsif (isConst?(pkmn.item,PBItems,:HEAVYBALL) ||
                  isConst?(pkmn.item,PBItems,:LUXURYBALL) ||
                  isConst?(pkmn.item,PBItems,:DUSKBALL))
              pkmn.setItem(:BLKAPRICORN)
            elsif pbIsPokeBall?(pkmn.item)
              pkmn.setItem(apricorn[rand(apricorn.length)])  
            # CREATES INCENSE
            elsif (isConst?(pkmn.item,PBItems,:SHOALSALT) ||
                  isConst?(pkmn.item,PBItems,:BRIGHTPOWDER) ||
                  isConst?(pkmn.item,PBItems,:QUICKPOWDER) ||
                  isConst?(pkmn.item,PBItems,:SILVERPOWDER))
              pkmn.setItem(incenses[rand(incenses.length)])   
            # CREATES MONSTER PARTS
            elsif isConst?(pkmn.item,PBItems,:LUCKYEGG)
              pkmn.setItem(beastparts[rand(beastparts.length)])
            # CREATES FOSSILS
            elsif isConst?(pkmn.item,PBItems,:RAREBONE)
              pkmn.setItem(fossils[rand(fossils.length)])  
            # CREATES EXCAVATION ITEMS
            elsif isConst?(pkmn.item,PBItems,:FIRESTONE)
              pkmn.setItem(:HEATROCK)
            elsif isConst?(pkmn.item,PBItems,:WATERSTONE)
              pkmn.setItem(:DAMPROCK)
            elsif isConst?(pkmn.item,PBItems,:ICESTONE)
              pkmn.setItem(:ICYROCK)
            elsif pbIsFossil?(pkmn.item) || pbIsEvolutionStone?(pkmn.item)
              pkmn.setItem(excavation[rand(excavation.length)])
            # CREATES PLATES
            elsif (isConst?(pkmn.item,PBItems,:REDSHARD) ||
                  isConst?(pkmn.item,PBItems,:BLUESHARD) ||
                  isConst?(pkmn.item,PBItems,:GREENSHARD) ||
                  isConst?(pkmn.item,PBItems,:YELLOWSHARD))
              pkmn.setItem(plates[rand(plates.length)])
            # CREATES ORBS
            elsif (isConst?(pkmn.item,PBItems,:PEARL) ||
                  isConst?(pkmn.item,PBItems,:BIGPEARL))
              pkmn.setItem(orbs[rand(orbs.length)])
            # CREATES TREASURE 
            elsif (isConst?(pkmn.item,PBItems,:HARDSTONE) ||
                  isConst?(pkmn.item,PBItems,:EVERSTONE) ||
                  isConst?(pkmn.item,PBItems,:FLOATSTONE) ||
                  isConst?(pkmn.item,PBItems,:OVALSTONE) ||
                  isConst?(pkmn.item,PBItems,:CHARCOAL))
              pkmn.setItem(treasure1[treasure1.length])
            elsif (isConst?(pkmn.item,PBItems,:NUGGET) ||
                  isConst?(pkmn.item,PBItems,:BIGNUGGET))
              pkmn.setItem(treasure2[rand(treasure2.length)])
            # CREATES EVOLUTION STONES
            elsif isConst?(pkmn.item,PBItems,:FIREGEM)
              pkmn.setItem(:FIRESTONE)
            elsif isConst?(pkmn.item,PBItems,:WATERGEM)
              pkmn.setItem(:WATERSTONE)
            elsif isConst?(pkmn.item,PBItems,:ELECTRICGEM)
              pkmn.setItem(:THUNDERSTONE)
            elsif isConst?(pkmn.item,PBItems,:GRASSGEM)
              pkmn.setItem(:LEAFSTONE)
            elsif isConst?(pkmn.item,PBItems,:ICEGEM)
              pkmn.setItem(:ICESTONE)
            elsif (isConst?(pkmn.item,PBItems,:DARKGEM) ||
                  isConst?(pkmn.item,PBItems,:GHOSTGEM))
              pkmn.setItem(:DUSKSTONE)
            elsif (isConst?(pkmn.item,PBItems,:FAIRYGEM) ||
                  isConst?(pkmn.item,PBItems,:NORMALGEM))
              pkmn.setItem(:SHINYSTONE)
            elsif (isConst?(pkmn.item,PBItems,:FIGHTINGGEM) ||
                  isConst?(pkmn.item,PBItems,:PSYCHICGEM))
              pkmn.setItem(:DAWNSTONE)
            elsif pbIsGem?(pkmn.item)
              pkmn.setItem(evostones[rand(evostones.length)])  
            # CREATES EVIOLITE
            elsif isConst?(pkmn.item,PBItems,:EVERSTONE)
              pkmn.setItem(:EVIOLITE)  
            # CREATES SOFT SAND
            elsif (isConst?(pkmn.item,PBItems,:ROCKYHELMET) ||
                  isConst?(pkmn.item,PBItems,:RELICSTATUE) ||
                  isConst?(pkmn.item,PBItems,:RELICVASE) ||
                  isConst?(pkmn.item,PBItems,:SMOOTHROCK) ||
                  isConst?(pkmn.item,PBItems,:ODDKEYSTONE) ||
                  isConst?(pkmn.item,PBItems,:LIGHTCLAY) ||
                  isConst?(pkmn.item,PBItems,:STRANGESOUVENIR))
              pkmn.setItem(:SOFTSAND) 
            # CREATES SHELL BELL
            elsif isConst?(pkmn.item,PBItems,:SHOALSHELL)
              pkmn.setItem(:SHELLBELL)
            # CREATES REPELS
            elsif (pbIsMulch?(pkmn.item) || 
                  isConst?(pkmn.item,PBItems,:BLACKSLUDGE))
              pkmn.setItem(repels[rand(repels.length)])
            # CREATES POTIONS
            elsif isConst?(pkmn.item,PBItems,:ENERGYPOWDER)
              pkmn.setItem(potions[rand(potions.length)])
            # CREATES STATUS CURES
            elsif isConst?(pkmn.item,PBItems,:HEALPOWDER)
              pkmn.setItem(statusitem[rand(statusitem.length)])
            # CREATES DRINKS
            elsif isConst?(pkmn.item,PBItems,:FRESHWATER)
              pkmn.setItem(liquids[rand(liquids.length)])
            # CREATES SWEETS
            elsif (isConst?(pkmn.item,PBItems,:HONEY) ||
                  isConst?(pkmn.item,PBItems,:MOOMOOMILK))
              pkmn.setItem(sweets[rand(sweets.length)])
            # CREATES GROWTH CANDY
            elsif (isConst?(pkmn.item,PBItems,:SWEETHEART) ||
                  isConst?(pkmn.item,PBItems,:RAGECANDYBAR) ||
                  isConst?(pkmn.item,PBItems,:OLDGATEAU) ||
                  isConst?(pkmn.item,PBItems,:LAVACOOKIE) ||
                  isConst?(pkmn.item,PBItems,:CASTELIACONE) ||
                  isConst?(pkmn.item,PBItems,:PEWTERCRUNCHIES) ||
                  isConst?(pkmn.item,PBItems,:BIGMALASADA) ||
                  isConst?(pkmn.item,PBItems,:LUMIOSEGALETTE) ||
                  isConst?(pkmn.item,PBItems,:SHALOURSABLE))
              pkmn.setItem(expcandy[rand(expcandy.length)])
            elsif (isConst?(pkmn.item,PBItems,:EXPCANDYXS) ||
                  isConst?(pkmn.item,PBItems,:EXPCANDYS) ||
                  isConst?(pkmn.item,PBItems,:EXPCANDYM) ||
                  isConst?(pkmn.item,PBItems,:EXPCANDYXL) ||
                  isConst?(pkmn.item,PBItems,:EXPCANDYXL) ||
                  isConst?(pkmn.item,PBItems,:DYNAMAXCANDY))
              pkmn.setItem(:RARECANDY)
            # CREATES WING ITEMS
            elsif isConst?(pkmn.item,PBItems,:PRETTYWING)
              pkmn.setItem(wings[rand(wings.length)])
            # CREATES VITAMINS
            elsif (isConst?(pkmn.item,PBItems,:XATTACK) ||
                  isConst?(pkmn.item,PBItems,:XDEFENSE) ||
                  isConst?(pkmn.item,PBItems,:XSPATK) ||
                  isConst?(pkmn.item,PBItems,:XSPDEF) ||
                  isConst?(pkmn.item,PBItems,:XSPEED) ||
                  isConst?(pkmn.item,PBItems,:XACCURACY) ||
                  isConst?(pkmn.item,PBItems,:DIREHIT) ||
                  isConst?(pkmn.item,PBItems,:GUARDSPEC))
              pkmn.setItem(vitamins[rand(vitamins.length)]) 
            # CREATES PP UP
            elsif (isConst?(pkmn.item,PBItems,:ETHER) ||
                  isConst?(pkmn.item,PBItems,:MAXETHER))
              pkmn.setItem(:PPUP)
            # CREATES PP MAX
            elsif (isConst?(pkmn.item,PBItems,:ELIXIR) ||
                  isConst?(pkmn.item,PBItems,:MAXELIXIR) ||
                  isConst?(pkmn.item,PBItems,:RARECANDY) ||
                  isConst?(pkmn.item,PBItems,:DYNAMAXCANDY) ||
                  isConst?(pkmn.item,PBItems,:ABILITYCAPSULE) ||
                  isConst?(pkmn.item,PBItems,:PPUP))
              pkmn.setItem(:PPMAX)
            # CREATES ABILITY CAPSULE
            elsif isConst?(pkmn.item,PBItems,:PPMAX)
              pkmn.setItem(:ABILITYCAPSULE)
            # CREATES PAPER ITEMS
            elsif pbIsMail?(pkmn.item)
              pkmn.setItem(paperitem[rand(paperitem.length)])
            # CREATES GLASS ITEMS
            elsif isConst?(pkmn.item,PBItems,:SOFTSAND)
              pkmn.setItem(lenses[rand(lenses.length)])
            # CREATES GROWTH GEAR
            elsif (isConst?(pkmn.item,PBItems,:MACHOBRACE) ||
                  isConst?(pkmn.item,PBItems,:EXPSHARE))
              pkmn.setItem(poweritem[rand(poweritem.length)])
            # CREATES ASSAULT VEST
            elsif isConst?(pkmn.item,PBItems,:PROTECTOR)
              pkmn.setItem(:ASSAULTVEST)
            # CREATES ROCKY HELMET
            elsif (isConst?(pkmn.item,PBItems,:KINGSROCK) ||
                  isConst?(pkmn.item,PBItems,:RELICCROWN))
              pkmn.setItem(:ROCKYHELMET)
            # CREATES CHIPPED POT
            elsif isConst?(pkmn.item,PBItems,:CRACKEDPOT)
              pkmn.setItem(:CHIPPEDPOT)
            # CREATES FABRIC & CLOTHING
            elsif (isConst?(pkmn.item,PBItems,:DESTINYKNOT) ||
                  isConst?(pkmn.item,PBItems,:REAPERCLOTH))
              pkmn.setItem(clothing[rand(clothing.length)])
            elsif (isConst?(pkmn.item,PBItems,:REDSCARF) ||
                  isConst?(pkmn.item,PBItems,:BLUESCARF) ||
                  isConst?(pkmn.item,PBItems,:PINKSCARF) ||
                  isConst?(pkmn.item,PBItems,:GREENSCARF) ||
                  isConst?(pkmn.item,PBItems,:YELLOWSCARF) ||
                  isConst?(pkmn.item,PBItems,:SILKSCARF) ||
                  isConst?(pkmn.item,PBItems,:FOCUSSASH) ||
                  isConst?(pkmn.item,PBItems,:POKEDOLL))
              pkmn.setItem(:REAPERCLOTH)
            elsif (isConst?(pkmn.item,PBItems,:EXPERTBELT) ||
                  isConst?(pkmn.item,PBItems,:MUSCLEBAND) ||
                  isConst?(pkmn.item,PBItems,:FOCUSBAND) ||
                  isConst?(pkmn.item,PBItems,:BINDINGBAND) ||
                  isConst?(pkmn.item,PBItems,:BLACKBELT) ||
                  isConst?(pkmn.item,PBItems,:ESCAPEROPE) ||
                  isConst?(pkmn.item,PBItems,:FLUFFYTAIL))
              pkmn.setItem(:DESTINYKNOT)
            # CREATES GADGETS & METALS
            elsif (isConst?(pkmn.item,PBItems,:METALCOAT) ||
                  isConst?(pkmn.item,PBItems,:IRONBALL) ||
                  isConst?(pkmn.item,PBItems,:LUCKYPUNCH) ||
                  isConst?(pkmn.item,PBItems,:CELLBATTERY))
              pkmn.setItem(gadgets[rand(gadgets.length)])
            elsif (isConst?(pkmn.item,PBItems,:SOOTHEBELL) ||
                  isConst?(pkmn.item,PBItems,:RELICSILVER) ||
                  isConst?(pkmn.item,PBItems,:RELICCOPPER) ||
                  isConst?(pkmn.item,PBItems,:RELICGOLD) ||
                  isConst?(pkmn.item,PBItems,:RELICBAND) ||
                  isConst?(pkmn.item,PBItems,:TWISTEDSPOON))
              pkmn.setItem(:METALPOWDER)
            elsif isConst?(pkmn.item,PBItems,:METALPOWDER)
              pkmn.setItem(:METALCOAT)
            # CREATES CELL BATTERY
            elsif (isConst?(pkmn.item,PBItems,:EJECTBUTTON) ||
                  isConst?(pkmn.item,PBItems,:ELECTIRIZER) ||
                  isConst?(pkmn.item,PBItems,:EJECTPACK))
              pkmn.setItem(:CELLBATTERY)
            # CREATES MEMORIES
            elsif (isConst?(pkmn.item,PBItems,:UPGRADE) ||
                  isConst?(pkmn.item,PBItems,:DUBIOUSDISC))
              pkmn.setItem(memories[rand(memories.length)])
            # CREATES POKEBALLS
            elsif isConst?(pkmn.item,PBItems,:REDAPRICORN)
              pkmn.setItem(:LEVELBALL)
            elsif isConst?(pkmn.item,PBItems,:YLWAPRICORN)
              pkmn.setItem(:MOONBALL)
            elsif isConst?(pkmn.item,PBItems,:BLUAPRICORN)
              pkmn.setItem(:LUREBALL)
            elsif isConst?(pkmn.item,PBItems,:GRNAPRICORN)
              pkmn.setItem(:FRIENDBALL)
            elsif isConst?(pkmn.item,PBItems,:PNKAPRICORN)
              pkmn.setItem(:LOVEBALL)
            elsif isConst?(pkmn.item,PBItems,:WHTAPRICORN)
              pkmn.setItem(:FASTBALL)
            elsif isConst?(pkmn.item,PBItems,:BLKAPRICORN)
              pkmn.setItem(:HEAVYBALL)
            # CREATES ZODIAC GEMS
            elsif (isConst?(pkmn.item,PBItems,:COMETSHARD) ||
                   isConst?(pkmn.item,PBItems,:WISHINGPIECE))
              pkmn.setItem(zodiacgem[rand(zodiacgem.length)])
            # CREATES STARDUST
            elsif pbIsZodiacGem?(pkmn.item)
              pkmn.setItem(:STARDUST) if rand(10)<5
              pkmn.setItem(:STARPIECE) if rand(10)>=5
            else
            # CREATES POWDER
              pkmn.setItem(junkitem[rand(junkitem.length)])
            end
            #Gives junk item if named item isn't present
            if pkmn.item==nil || pkmn.item==0 
              pkmn.setItem(junkitem[rand(junkitem.length)])
            end
            pbRitualAnimation(pkmn)
            $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
            $PokemonBag.pbDeleteItem(:STARDUST) if reagent
            pbWait(1)
            pbMEPlay("Pkmn get")
            if isConst?(pkmn.item,PBItems,:LEFTOVERS)
              Kernel.pbMessage(_INTL("{1} created some <c2=65467b14>{2}</c2> using the power of <c2=65467b14>{3}</c2>!",
              pkmn.name,PBItems.getName(pkmn.item),pkmn.pbGetBirthsignName))
            elsif ['a','e','i','o','u'].include?(PBItems.getName(pkmn.item)[0,1].downcase)
              Kernel.pbMessage(_INTL("{1} created an <c2=65467b14>{2}</c2> using the power of <c2=65467b14>{3}</c2>!",
              pkmn.name,PBItems.getName(pkmn.item),pkmn.pbGetBirthsignName))
            else
              Kernel.pbMessage(_INTL("{1} created a <c2=65467b14>{2}</c2> using the power of <c2=65467b14>{3}</c2>!",
              pkmn.name,PBItems.getName(pkmn.item),pkmn.pbGetBirthsignName))
            end
            pbRefreshSingle(pkmnid)
          end
        end
#===============================================================================
# Birthsigns - The Cultist
# Summon Skill effect: Spawns a Shadow Pokemon by sacrificing stats & Stardust.
#===============================================================================
      elsif cmdSummon>=0 && command==cmdSummon
        # The species list that may be summoned
        speciesS=[:MEWTWO,:LUGIA,:REGIGIGAS,:GIRATINA,:DARKRAI,:ARCEUS,:DIALGA,
                  :PALKIA,:ZEKROM,:RESHIRAM]
        speciesA=[:GENGAR,:MISMAGIUS,:CHANDELURE,:COFAGRIGUS,:HYDREIGON,:GOLURK,
                  :GOTHITELLE,:GLISCOR,:DUSKNOIR,:SPIRITOMB]
        speciesB=[:WEEZING,:BANNET,:DUSCLOPS,:ABSOL,:SWOOBAT,:LIEPARD,:ZWEILOUS,
                  :ZOROARK,:SABLEYE,:GOTHORITA]  
        speciesC=[:RATICATE,:ARBOK,:HYPNO,:GOLBAT,:MAROWAK,:HAUNTER,:ARIADOS,
                  :GLIGAR,:LAMPENT,:HOUNDOOM]
        speciesD=[:KOFFING,:SHUPPET,:DUSKULL,:YAMASK,:WOOBAT,:PURRLOIN,:DEINO,
                  :ZORUA,:GOLET,:GOTHITA]
        speciesE=[:RATTATA,:EKANS,:DROWZEE,:ZUBAT,:CUBONE,:GASTLY,:SPINARAK,
                  :MISDREAVUS,:LITWICK,:HOUNDOUR]
        # The items that may be randomly held
        itemS=[:OLDAMBER,:COMETSHARD,:RELICSTATUE,:RELICCROWN,:LUCKYEGG,:LIFEORB,
               :ODDKEYSTONE,:REAPERCLOTH,:SACREDASH,:STARDUST]
        itemA=[:DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:SKULLFOSSIL,:DOMEFOSSIL,
               :ODDKEYSTONE,:RELICBAND,:LUCKYEGG,:BIGNUGGET,:STARDUST]
        itemB=[:MOONSTONE,:SUNSTONE,:HELIXFOSSIL,:CLAWFOSSIL,:PLUMEFOSSIL,
               :LUCKYEGG,:RAREBONE,:NUGGET,:STARPIECE,:STARDUST]
        itemC=[:ROOTFOSSIL,:COVERFOSSIL,:ARMORFOSSIL,:SMOKEBALL,:STICKYBARB,
               :SPELLTAG,:STARPIECE,:STARDUST,:STARDUST,:STARDUST]
        itemD=[:REDSHARD,:YELLOWSHARD,:BLUESHARD,:GREENSHARD,:SMOKEBALL,
               :STICKYBARB,:CLEANSETAG,:STARDUST,:STARDUST,:STARDUST]
        itemE=[:ENERGYPOWDER,:HEALPOWDER,:CHARCOAL,:STICKYBARB,:EVERSTONE,
               :STARDUST,:STARDUST,:STARDUST,:STARDUST,:STARDUST]
        # The possible level ranges for each species rank
        levelS=[52,54,56,58,60,62,64,66,68,70]
        levelA=[40,41,42,43,44,45,46,47,48,49]
        levelB=[30,31,32,33,34,35,36,37,38,39]
        levelC=[20,21,22,23,24,25,26,27,28,29]
        levelD=[10,11,12,13,14,15,16,17,18,19]
        levelE=[2,3,4,4,5,5,6,7,8,9]
        totalIVs=(pkmn.iv[0]+pkmn.iv[1]+pkmn.iv[2]+pkmn.iv[3]+pkmn.iv[4]+pkmn.iv[5])
        if !(pbGetMetadata($game_map.map_id,MetadataOutdoor) && PBDayNight.isNight?) && !$DEBUG
          Kernel.pbMessage(_INTL("This power can only be used under a night sky.",pkmn.name))
        elsif pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif follower
          Kernel.pbMessage(_INTL("This power can't be used when you have someone with you."))
        elsif totalIVs==0
          Kernel.pbMessage(_INTL("{1}'s stats are too drained to summon anymore...",pkmn.name))
        elsif !pbCanUseBirthsignSummon? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          rank=["?","E","D","C","B","A","S"]
          if totalIVs>=180 && pkmn.level>=50    # Rank:S
            quality=6                             
          elsif totalIVs>=144 && pkmn.level>=40 # Rank:A
            quality=5
          elsif totalIVs>=108 && pkmn.level>=30 # Rank:B
            quality=4
          elsif totalIVs>=72 && pkmn.level>=20  # Rank:C
            quality=3
          elsif totalIVs>=36 && pkmn.level>=10  # Rank:D
            quality=2
          elsif totalIVs<36 || pkmn.level<10    # Rank:E
            quality=1
          end
          isUsable=(pbCanUseBirthsignSummon? && reagent)
          if isUsable
            usetext=_INTL("Activate {1}'s birthsign?\n<c2=65467b14>Summon Rank: {2}</c2>",pkmn.name,rank[quality])
            Kernel.pbMessage(_INTL("Activating this birthsign will consume <c2=65467b14>{1}</c2>, and drain {2}'s IV's.",stardust,pkmn.name))
          else
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again.")) if reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece) if reagent
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust)) if !reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece) if !reagent
          end
          if Kernel.pbConfirmMessage(usetext)
            $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
            $PokemonBag.pbDeleteItem(:STARDUST) if reagent
            pbUseBirthsignEffectSummon
            Kernel.pbMessage(_INTL("{1}'s IV's were all reduced by {2}!",pkmn.name,quality))
            @scene.pbEndScene
            # Reduces user's IV's with each Summon
            pkmn.iv[0]-=quality
            pkmn.iv[0]=0 if pkmn.iv[0]<=0
            pkmn.iv[1]-=quality
            pkmn.iv[1]=0 if pkmn.iv[1]<=0
            pkmn.iv[2]-=quality
            pkmn.iv[2]=0 if pkmn.iv[2]<=0
            pkmn.iv[3]-=quality
            pkmn.iv[3]=0 if pkmn.iv[3]<=0
            pkmn.iv[4]-=quality
            pkmn.iv[4]=0 if pkmn.iv[4]<=0
            pkmn.iv[5]-=quality
            pkmn.iv[5]=0 if pkmn.iv[5]<=0
            pkmn.calcStats
            pkmn.hp=1 if pkmn.hp<=0
            pbRefreshSingle(pkmnid)
            pbRitualAnimation(pkmn)
            pbWait(10)
            Kernel.pbMessage(_INTL("A wild Pokémon was pulled from the void!"))
            Kernel.pbMessage(_INTL("The wild Pokémon attacked in a rage!"))
            pbWait(10)
            $game_switches[SUMMON_SWITCH]=true
            Events.onWildPokemonCreate+=proc {|sender,e|
            pokemon=e[0]
             if $game_switches[SUMMON_SWITCH]
               pokemon.iv=[31,31,31,31,31,31]
               pokemon.obtainText=_INTL("Summoned from the void.")
               pokemon.setAbility(2)
               pokemon.setBirthsign(0)
               pokemon.makeShadow
               if rand(100)>50
                 pokemon.setItem(itemS[rand(9)]) if quality==6 # Rank:S
                 pokemon.setItem(itemA[rand(9)]) if quality==5 # Rank:A
                 pokemon.setItem(itemB[rand(9)]) if quality==4 # Rank:B
                 pokemon.setItem(itemC[rand(9)]) if quality==3 # Rank:C
                 pokemon.setItem(itemD[rand(9)]) if quality==2 # Rank:D
                 pokemon.setItem(itemE[rand(9)]) if quality==1 # Rank:E
               end
             end
            }
            $PokemonGlobal.nextBattleBGM="Summon Battle"
            if quality==6    # Rank:S
              pbWildBattle(speciesS[rand(9)],levelS[rand(9)])
            elsif quality==5 # Rank:A
              pbWildBattle(speciesA[rand(9)],levelA[rand(9)])
            elsif quality==4 # Rank:B 
              pbWildBattle(speciesB[rand(9)],levelB[rand(9)])
            elsif quality==3 # Rank:C
              pbWildBattle(speciesC[rand(9)],levelC[rand(9)])
            elsif quality==2 # Rank:D
              pbWildBattle(speciesD[rand(9)],levelD[rand(9)])
            elsif quality==1 # Rank:E 
              pbWildBattle(speciesE[rand(9)],levelE[rand(9)])
            end
            $game_switches[SUMMON_SWITCH]=false
            break
          end
          pbRefresh
        end
#===============================================================================
# Birthsigns - The Scavenger
# Detect Item Skill Effect: Returns the number of nearby items to be found.
#===============================================================================
      elsif cmdSniffOut>=0 && command==cmdSniffOut
        if pbDetectItemCount<=0
          Kernel.pbMessage(_INTL("There doesn't seem to be any items nearby."))
        else
          if Kernel.pbConfirmMessage(_INTL("Activate {1}'s birthsign?",pkmn.name))
            pbRitualAnimation(pkmn)
            pbWait(1)
            total=pbDetectItemCount
            text="items"
            text="item" if total==1
            Kernel.pbMessage(_INTL("With the power of <c2=65467b14>{1}</c2>, {2} detects <c2=65467b14>{3} {4}</c2> nearby!",
            pkmn.pbGetBirthsignName,pkmn.name,total,text))
            pbWait(2)
          end
        end
#===============================================================================
# Birthsigns - The Timelord
# Timeskip Skill Effect: Forces immediate evolution, at the cost of Stardust.
# Rewind Skill Effect: Forces immediate de-evolution, at the cost of Stardust.
#===============================================================================
      elsif cmdTimeskip>=0 && command==cmdTimeskip
        fspecies   = pbGetFSpeciesFromForm(pkmn.species,pkmn.form)
        evos       = pbGetEvolvedFormData(fspecies)     # Gets evolutions
        baby       = pbGetBabySpecies(fspecies)         # Gets baby stage
        prevo      = pbGetPreviousForm(fspecies)        # Gets previous stage
        newspecies = prevo                              # Species defaults to prevo
        if pkmn.fainted?
          Kernel.pbMessage(_INTL("{1} can't use this power while fainted!",pkmn.name))
        elsif !pbCanUseBirthsignTimeskip? && !reagent2
          Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again."))
        elsif !reagent && !reagent2
          Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust))
        else
          isUsable=(pbCanUseBirthsignTimeskip? && reagent)
          if isUsable
            usetext=_INTL("Activate {1}'s birthsign?",pkmn.name)
            if pkmn.canEvolve?
              Kernel.pbMessage(_INTL("Using this power will consume <c2=65467b14>{1}</c2> and trigger {2}'s evolution.",stardust,pkmn.name))
            elsif pkmn.canDevolve?
              Kernel.pbMessage(_INTL("Using this power will consume <c2=65467b14>{1}</c2> and revert {2} into its previous evolutionary stage.",stardust,pkmn.name))
            end
          else
            Kernel.pbMessage(_INTL("This power needs time to recharge before it may be used again.")) if reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> to bypass this cooldown?",starpiece) if reagent
            Kernel.pbMessage(_INTL("Missing reagent: <c2=65467b14>{1}</c2>.",stardust)) if !reagent
            usetext=_INTL("Would you like to use a <c2=65467b14>{1}</c2> as a substitute?",starpiece) if !reagent
          end
          if Kernel.pbConfirmMessage(usetext)
            command = 0
            evobranch=(pkmn.canBranchEvolve? && isConst?(pkmn.species,PBSpecies,:BURMY))
            prevobranch=pkmn.canBranchDevolve?
            Kernel.pbMessage(_INTL("Which timeline should {1} skip to?",pkmn.name)) if evobranch
            Kernel.pbMessage(_INTL("Which point in time should {1} revert to?",pkmn.name)) if prevobranch
            loop do
              if evobranch || prevobranch
                choices = []
                #===============================================================
                # Choose Evolved Species
                #===============================================================
                if evobranch
                  for i in evos
                    newspecies=i[2]
                    choices.push(_INTL("{1}",PBSpecies.getName(i[2])))
                  end
                  choices.push(_INTL("Cancel"))
                  command=@scene.pbShowCommands(_INTL("Choose an evolution."),choices,command)
                  break if command<0 || command>=evos.length
                  newspecies=evos[command][2]
                #===============================================================
                # Choose De-Evolved Species
                #===============================================================
                elsif prevobranch
                  choices.push(_INTL("{1}",PBSpecies.getName(baby)))
                  choices.push(_INTL("{1}",PBSpecies.getName(prevo)))
                  choices.push(_INTL("Cancel"))
                  command=@scene.pbShowCommands(_INTL("Choose a previous stage."),choices,command)
                  break if command<0 || command>1
                  newspecies=baby if command==0
                  newspecies=prevo if command==1
                end
              else
                #===============================================================
                # Determines Evolution if only one option pick from
                #===============================================================
                if pkmn.canEvolve?
                  if !pkmn.canBranchEvolve?
                    newspecies=evos[0][2]
                  else
                    newspecies=evos[1][2]
                  end
                end
              end
              pbRitualAnimation(pkmn)
              pbWait(1)
              if evobranch
                Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> skipped {2} to a timeline where it becomes <c2=65467b14>{3}</c2>!",
                pkmn.pbGetBirthsignName,pkmn.name,PBSpecies.getName(newspecies)))
              elsif prevobranch
                Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> reverted {2} to a time where it was <c2=65467b14>{3}</c2>!",
                pkmn.pbGetBirthsignName,pkmn.name,PBSpecies.getName(newspecies)))
              else 
                Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> skipped {2} to the time of its evolution!",
                pkmn.pbGetBirthsignName,pkmn.name)) if newspecies!=prevo
                Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> wound back {2}'s evolutionary history!",
                pkmn.pbGetBirthsignName,pkmn.name)) if newspecies==prevo
              end
              pbWait(2)
              pbFadeOutInWithMusic(99999){
              evo=PokemonEvolutionScene.new
              pkmn.form=pbGetEvoForm(pkmn,newspecies)
              evo.pbStartScreen(pkmn,newspecies)
              noform = [:PICHU,:PIKACHU,:EXEGGCUTE,:CUBONE,:KOFFING, # Lose form when devolved
                        :MIMEJR,:ROCKRUFF,:TOXEL,:KUBFU,
                        :MOTHIM,:PERRSERKER,:SIRFETCHD,:MRRIME,      # Lose form when evolved
                        :CURSOLA,:OBSTAGOON,:RUNERIGUS]
              for i in noform
                pkmn.form=0 if newspecies==getID(PBSpecies,i)
              end
              evo.pbEvolution(false)
              pkmn.resetMoves if newspecies==(prevo) || newspecies==(baby)
              evo.pbEndScreen
              }
              $PokemonBag.pbDeleteItem(:STARPIECE) if !reagent
              $PokemonBag.pbDeleteItem(:STARDUST) if reagent
              pbUseBirthsignEffectTimeskip
              pbHardRefresh
              break
            end
          end
        end
#===============================================================================
      elsif cmdMail>=0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0 # Read
          pbFadeOutIn(99999){ pbDisplayMail(pkmn.mail,pkmn) }
        when 1 # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        end
      elsif cmdItem>=0 && command==cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? && !pbIsMail?(pkmn.item)
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag,pkmn)
          if item>0
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag)
          if item>0
            if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item = pkmn.item
          itemname = PBItems.getName(item)
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            if pkmnid==oldpkmnid
              break
            elsif newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.setItem(item)
              pkmn.setItem(0)
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif pbIsMail?(newpkmn.item)
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = PBItems.getName(newitem)
              if isConst?(newitem,PBItems,:LEFTOVERS)
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif ['a','e','i','o','u'].include?(newitemname[0,1].downcase)
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.setItem(item)
                pkmn.setItem(newitem)
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

############[BIRTHSIGN EFFECTS - WILD ENCOUTNER]################################
#===============================================================================
# Birthsign Bonuses - Encounter Effects
#===============================================================================
# Applies Birthsign effects that alter conditions for wild encounters.
# Overwrites sections in PField_Field.
#===============================================================================
def pbGenerateWildPokemon(species,level,isroamer=false)
  shadowpkmn=false
  genwildpoke = PokeBattle_Pokemon.new(species,level,$Trainer)
  items = genwildpoke.wildHoldItems
  firstpoke = $Trainer.firstPokemon
  chances = [50,5,1]
  chances = [60,20,5] if firstpoke && !firstpoke.egg? && isConst?(firstpoke.ability,PBAbilities,:COMPOUNDEYES)
  itemrnd = rand(100)
  if itemrnd<chances[0] || (items[0]==items[1] && items[1]==items[2])
    genwildpoke.setItem(items[0])
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.setItem(items[1])
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.setItem(items[2])
  end
  #=============================================================================
  # Birthsign - The Prodigy
  #=============================================================================
  # Wild Pokemon may spawn with Hidden Abilities for 200 steps (Ability Lure)
  #=============================================================================
  if pbAbilLureEffectActive?
    genwildpoke.setAbility(2) if rand(100)<25
  end
  #=============================================================================
  # Fortune Teller Event
  #=============================================================================
  # Wild Pokemon spawn with a sign relative to the player's trainer sign.
  #=============================================================================
  if !genwildpoke.isBlessed?
    if pbFortuneEffectActive?
      if $PokemonGlobal.fortuneEqual==true
        genwildpoke.setZodiacsign($Trainer.getCalendarsign)
      elsif $PokemonGlobal.fortuneGood==true
        genwildpoke.setPartnersign($Trainer.getCalendarsign)
        genwildpoke.happiness=genwildpoke.happiness*1.5
        genwildpoke.setItem(getZodiacGem(genwildpoke.monthsign)) if rand(10)<5
      elsif $PokemonGlobal.fortuneBad==true
        genwildpoke.setRivalsign($Trainer.getCalendarsign)
        genwildpoke.happiness=genwildpoke.happiness/2
      end
  #=============================================================================
  # Birthsign - The Soulmate
  #=============================================================================
  # Wild Pokemon spawn with one of the user's Partner signs when leading.
  #=============================================================================
    elsif firstpoke.hasZodiacsign? && firstpoke.birthsign==32 && !firstpoke.fainted?
      genwildpoke.setPartnersign(firstpoke.getCalendarsign)
    else
  #=============================================================================
  # Birthsigns for wild encounters
  #=============================================================================
      # Generates wild Pokemon with the current month's sign
      if $PokemonGlobal.wildsign==1
        genwildpoke.setZodiacsign(Time.now.mon)
      # Generates wild Pokemon with partner/rival signs of the current month
      elsif $PokemonGlobal.wildsign==2
        randsign=rand(10)
        if randsign>5
          genwildpoke.setPartnersign(Time.now.mon)
        else
          genwildpoke.setRivalsign(Time.now.mon)
        end
      # Generates wild Pokemon with random zodiac signs
      elsif $PokemonGlobal.wildsign==3
        genwildpoke.setRandomZodiac
      # Generates wild Pokemon with completely random signs
      elsif $PokemonGlobal.wildsign==4
        genwildpoke.setRandomsign
      else
        genwildpoke.setBirthsign(0)
      end
      # Overrides current wild sign with a specific birthsign
      if $PokemonGlobal.wildsignOverride!=0 && $PokemonGlobal.wildsignOverride!=nil
        $PokemonGlobal.wildsign=0
        genwildpoke.setBirthsign($PokemonGlobal.wildsignOverride)
      end
    end
  end
  #=============================================================================
  # Birthsign - The Wishmaker
  # Increased odds of spawning shiny. Stacks with similar effects.
  #=============================================================================
  if genwildpoke.birthsign==12
    for i in 0...2   # 3 times as likely
      break if genwildpoke.isShiny?
      genwildpoke.personalID = rand(65536)|(rand(65536)<<16)
    end
  end
  #=============================================================================
  if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
    for i in 0...2   # 3 times as likely
      break if genwildpoke.isShiny?
      genwildpoke.personalID = rand(65536)|(rand(65536)<<16)
    end
  end
  if rand(65536)<POKERUS_CHANCE
    genwildpoke.givePokerus
  end
  if firstpoke && !firstpoke.egg?
    activepkmnsign=(firstpoke.hasBirthsign? && !firstpoke.fainted?)
    #===========================================================================
    # Birthsigns - The Companion
    # Wild Pokemon have a higher base happiness when leading.
    #===========================================================================
    if activepkmnsign && firstpoke.birthsign==2
      genwildpoke.happiness=genwildpoke.happiness*2
    end
    #===========================================================================
    # Birthsign - The Maiden/The Gladiator
    # Wild Pokemon are likely to be of the opposite gender of the user leading.
    #===========================================================================
    # If user is female with The Maiden, spawns are likely to be male.
    # If user is male with The Gladiator, spawns are likely to be female.
    #===========================================================================
    if activepkmnsign && !genwildpoke.isSingleGendered?
       if firstpoke.isMale? && firstpoke.birthsign==8
        (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif firstpoke.isFemale? && firstpoke.birthsign==7
        (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    end
    #===========================================================================
    # Birthsigns - The Thief
    # Wild Pokemon have a chance of holding treasure when leading.
    #===========================================================================
    if activepkmnsign && firstpoke.birthsign==10 && genwildpoke.item==0 
      baseloot = [:PEARL,:BIGPEARL,:RELICCOPPER,:NUGGET]
      rareloot = [:RELICSILVER,:PEARLSTRING,:RELICGOLD,:BIGNUGGET,:BOTTLECAP]
      epicloot = [:RELICVASE,:RELICBAND,:RELICSTATUE,:RELICCROWN,:GOLDBOTTLECAP]
      genwildpoke.setItem(baseloot[rand(baseloot.length)]) if rand(100)<5
      genwildpoke.setItem(rareloot[rand(rareloot.length)]) if rand(100)<3
      genwildpoke.setItem(epicloot[rand(epicloot.length)]) if rand(100)<1
      genwildpoke.item=0 if genwildpoke.item==nil
    end
    #===========================================================================
    # Birthsign - The Assassin
    # Wild Pokemon have a chance of being asleep for 1 turn when leading.
    #===========================================================================
    if activepkmnsign && firstpoke.birthsign==21
      if !isConst?(genwildpoke.ability,PBAbilities,:INSOMNIA) &&
         !isConst?(genwildpoke.ability,PBAbilities,:VITALSPIRIT) &&
         genwildpoke.status=0
        # The odds of encountering sleeping Pokemon at night (70%)
        if PBDayNight.isNight?(pbGetTimeNow) && rand(100)<70
          genwildpoke.status=1
          genwildpoke.statusCount=2
        # The odds of encountering sleeping Pokemon in day (30%)
        elsif PBDayNight.isDay?(pbGetTimeNow) && rand(100)<30
          genwildpoke.status=1
          genwildpoke.statusCount=2
        end
      end
    end
    #===========================================================================
    # Birthsign - The Empath
    # Wild Pokemon have 50% change of sharing same Nature as leading Pokemon.
    #===========================================================================
    if activepkmnsign && firstpoke.birthsign==26
      genwildpoke.setNature(firstpoke.nature) if !isroamer && rand(10)<5
    end
    #===========================================================================
    # Birthsign - The Mirror
    # Wild Pokemon have a 50% chance of sharing each IV with the leading Pokemon.
    #===========================================================================
    if activepkmnsign && firstpoke.birthsign==27
      genwildpoke.iv[0]=firstpoke.iv[0] if !isroamer && rand(10)<5
      genwildpoke.iv[1]=firstpoke.iv[1] if !isroamer && rand(10)<5
      genwildpoke.iv[2]=firstpoke.iv[2] if !isroamer && rand(10)<5
      genwildpoke.iv[3]=firstpoke.iv[3] if !isroamer && rand(10)<5
      genwildpoke.iv[4]=firstpoke.iv[4] if !isroamer && rand(10)<5
      genwildpoke.iv[5]=firstpoke.iv[5] if !isroamer && rand(10)<5
    end
    #===========================================================================
    if isConst?(firstpoke.ability,PBAbilities,:CUTECHARM) && !genwildpoke.isSingleGendered?
      if firstpoke.isMale?
        (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
      elsif firstpoke.isFemale?
        (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
      end
    elsif isConst?(firstpoke.ability,PBAbilities,:SYNCHRONIZE)
      genwildpoke.setNature(firstpoke.nature) if !isroamer && rand(10)<5
    end
  end
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  return genwildpoke
end

############[BIRTHSIGN EFFECTS - BATTLE]########################################
#===============================================================================
# Birthsign Bonuses - Battle Effects
#===============================================================================
# Applies Birthsign effects that alter conditions during battle.
# Overwrites sections in PokeBattle_Battle.
#===============================================================================
class PokeBattle_Battle #Mod for The Apprentice/The Scholar/The Timelord
  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growthRate = pkmn.growthrate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=PBExperience.pbGetMaxExperience(growthRate)
      pkmn.calcStats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.baseExp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a/(SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a/(SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.trainerID!=pbPlayer.id ||
                 (pkmn.language!=0 && pkmn.language!=pbPlayer.language))
    if isOutsider
      if pkmn.language!=0 && pkmn.language!=pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # Make sure Exp doesn't exceed the maximum
    expFinal = PBExperience.pbAddExperience(pkmn.exp,exp,growthRate)
    expGained = expFinal-pkmn.exp
    return if expGained<=0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = PBExperience.pbGetLevelFromExperience(expFinal,growthRate)
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = PBExperience.pbGetStartExperience(curLevel,growthRate)
      levelMaxExp = PBExperience.pbGetStartExperience(curLevel+1,growthRate)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calcStats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calcStats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
    end
  end
end

module PokeBattle_BattleCommon
  def pbThrowPokeBall(idxPokemon,ball,rareness=nil,showplayer=false)
    itemname=PBItems.getName(ball)
    battler=nil
    if pbIsOpposing?(idxPokemon)
      battler=self.battlers[idxPokemon]
    else
      battler=self.battlers[idxPokemon].pbOppositeOpposing
    end
    if battler.fainted?
      battler=battler.pbPartner
    end
    pbDisplayBrief(_INTL("{1} threw one {2}!",self.pbPlayer.name,itemname))
    if battler.fainted?
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if @opponent && (!pbIsSnagBall?(ball) || !battler.isShadow?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
    #===========================================================================
    # Poke Ball failure - Added for Max Raids
    #===========================================================================
    elsif defined?(MAXRAID_SWITCH) && $game_switches[MAXRAID_SWITCH] && 
          battler.effects[PBEffects::MaxRaidBoss] && battler.hp>1
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The ball was repelled by a burst of Dynamax energy!"))
    #===========================================================================
    else
      pokemon=battler.pokemon
      species=pokemon.species
      if $DEBUG && Input.press?(Input::CTRL)
        shakes=4
      else
        if !rareness
          dexdata=pbLoadSpeciesData
          pbGetSpeciesData(dexdata,pokemon.fSpecies,16)
          rareness=dexdata.fgetb # Get rareness from dexdata file
          dexdata.close
        end
        a=battler.totalhp
        b=battler.hp
        rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler)
        x=(((a*3-b*2)*rareness)/(a*3)).floor
        if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN
          x=(x*2.5).floor
        elsif battler.status!=0
          x=(x*1.5).floor
        end
        c=0
        if $Trainer
          if $Trainer.pokedexOwned>600
            c=(x*2.5/6).floor
          elsif $Trainer.pokedexOwned>450
            c=(x*2/6).floor
          elsif $Trainer.pokedexOwned>300
            c=(x*1.5/6).floor
          elsif $Trainer.pokedexOwned>150
            c=(x*1/6).floor
          elsif $Trainer.pokedexOwned>30
            c=(x*0.5/6).floor
          end
        end
        #=======================================================================
        # Birthsign - The Hunter
        # Increases the capture rate by 20% when leading.
        #=======================================================================
        firstpoke=$Trainer.party[0]
        if firstpoke.hasBirthsign? && firstpoke.birthsign==23 && !firstpoke.fainted?
          x=(x*3/2.5).floor
          #x=(x*255).floor #Makes catch rate 100%. Used for testing.
        end
        #=======================================================================
        shakes=0; critical=false
        if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
          shakes=4
        else
          x=1 if x<1
          y = ( 65536 / ((255.0/x)**0.1875) ).floor
          if USECRITICALCAPTURE && pbRandom(256)<c
            critical=true
            shakes=4 if pbRandom(65536)<y
          else
            shakes+=1 if pbRandom(65536)<y
            shakes+=1 if pbRandom(65536)<y && shakes==1
            shakes+=1 if pbRandom(65536)<y && shakes==2
            shakes+=1 if pbRandom(65536)<y && shakes==3
          end
        end
      end
      PBDebug.log("[Threw Poké Ball] #{itemname}, #{shakes} shakes (4=capture)")
      @scene.pbThrow(ball,shakes,critical,battler.index,showplayer)
      case shakes
      when 0
        pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
        BallHandlers.onFailCatch(ball,self,battler)
      when 1
        pbDisplay(_INTL("Aww... It appeared to be caught!"))
        BallHandlers.onFailCatch(ball,self,battler)
      when 2
        pbDisplay(_INTL("Aargh! Almost had it!"))
        BallHandlers.onFailCatch(ball,self,battler)
      when 3
        pbDisplay(_INTL("Gah! It was so close, too!"))
        BallHandlers.onFailCatch(ball,self,battler)
      when 4
        pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pokemon.name))
        @scene.pbThrowSuccess
        if pbIsSnagBall?(ball) && @opponent
          pbRemoveFromParty(battler.index,battler.pokemonIndex)
          battler.pbReset
          battler.participants=[]
        else
          @decision=4
        end
        if pbIsSnagBall?(ball)
          pokemon.ot=self.pbPlayer.name
          pokemon.trainerID=self.pbPlayer.id
        end
        BallHandlers.onCatch(ball,self,pokemon)
        pokemon.ballused=pbGetBallType(ball)
        ((pokemon.makeUnmega if pokemon.isMega?) rescue nil)
        pokemon.makeUnprimal rescue nil
        #=======================================================================
        if defined?(pokemon.isDynamax?) # Added for Dynamax
          ((pokemon.makeUnmax if pokemon.isDynamax?) rescue nil) 
        end
        #=======================================================================
        pokemon.pbRecordFirstMoves
        if GAINEXPFORCAPTURE
          battler.captured=true
          pbGainEXP
          battler.captured=false
        end
        if !self.pbPlayer.hasOwned?(species)
          self.pbPlayer.setOwned(species)
          if $Trainer.pokedex
            pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
            @scene.pbShowPokedex(species)
          end
        end
        pokemon.forcedForm = nil if MultipleForms.hasFunction?(pokemon.species,"getForm")
        @scene.pbHideCaptureBall
        if pbIsSnagBall?(ball) && @opponent
          pokemon.pbUpdateShadowMoves rescue nil
          @snaggedpokemon.push(pokemon)
        else
          pbStorePokemon(pokemon)
        end
      end
    end
  end
end


############[BIRTHSIGN EFFECTS - MISCELLANEOUS]#################################
#===============================================================================
# Birthsign Bonuses - Passive Effects
# Applies the effects of birthsigns that somehow alter a Pokemon's attributes.
#===============================================================================
def applyBirthsignBonuses
  if hasBirthsign?
    # The Void
    if birthsign==0
      @shinyflag=nil
      @abilityflag=nil
      @genderflag=nil
      @zodiacflag=0
    end
    # The Companion
    if birthsign==2
      @happiness=@happiness*2
    end
    # The Savage
    if birthsign==4
      @iv[0]=0
      @iv[1]=31
      @iv[3]=31
      @iv[4]=31
    end
    # The Maiden
    if birthsign==7
      @ev=[0,0,0,0,150,0]
      if isSingleGendered?
        genderflag = nil
      elsif rand(100)<75 || $DEBUG
        makeFemale
      end
    end
    # The Gladiator
    if birthsign==8
      @ev=[0,150,0,0,0,0]
      if isSingleGendered?
        genderflag = nil
      elsif rand(100)<75 || $DEBUG
        makeMale
      end
    end
    # The Glutton
    if birthsign==11
      @iv[0]=31
      @iv[2]=31
      @iv[3]=0
      @iv[5]=31
    end
    # The Wishmaker
    if birthsign==12
      makeShiny if $DEBUG
    end
  end
end

#===============================================================================
# Birthsigns - The Parent
# Halves the steps needed to hatch an egg while in the party.
#===============================================================================
Events.onStepTaken+=proc {|sender,e|
  next if !$Trainer
  for egg in $Trainer.party
    if egg.eggsteps>0
      egg.eggsteps-=1
      for i in $Trainer.pokemonParty
        if isConst?(i.ability,PBAbilities,:FLAMEBODY) ||
           isConst?(i.ability,PBAbilities,:MAGMAARMOR) ||
           (i.hasBirthsign? && i.birthsign==22)
          egg.eggsteps-=1
          break
        end
      end
      if egg.eggsteps<=0
        egg.eggsteps=0
        pbHatch(egg)
      end
    end
  end
}

#===============================================================================
# Birthsign - The Vampire
#===============================================================================
# Heals user while walking at night. Harms/Burns user while walking in daylight.
#===============================================================================
Events.onStepTakenTransferPossible+=proc {|sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount%4==0
    flashed = false
    firstpoke=$Trainer.party[0]
    if $Trainer.party.length>0
      # Heals HP, PP, and status for all users while walking outdoors at night.
      if (PBDayNight.isNight? && pbGetMetadata($game_map.map_id,MetadataOutdoor)) ||
         ($DEBUG && Input.press?(Input::CTRL))
        for i in $Trainer.ablePokemonParty
          if i.birthsign==31
            i.hp += 1 if i.hp<i.totalhp
            i.healStatus
            if $PokemonGlobal.stepcount%50==0
              for j in i.moves
                j.pp +=1 if j.pp<j.totalpp
              end
            end
          end
        end
      # Harms/Burns the user while walking outside during the day when leading.
      elsif (PBDayNight.isDay? && pbGetMetadata($game_map.map_id,MetadataOutdoor) &&
         firstpoke.birthsign==31 && !firstpoke.fainted?)
        if !flashed
          $game_screen.start_flash(Color.new(255,0,0,128), 4)
          flashed = true
        end
        firstpoke.hp -= 1 if firstpoke.hp>0
        # Immune to Burn effect if the user has the following Abilities/Type
        if !firstpoke.hasType?(:FIRE) &&
           !firstpoke.isConst?(firstpoke.ability,PBAbilities,:WATERVEIL) &&
           !firstpoke.isConst?(firstpoke.ability,PBAbilities,:WATERBUBBLE) &&
           !firstpoke.isConst?(firstpoke.ability,PBAbilities,:COMATOSE)
          firstpoke.status = 3
        end
        if firstpoke.hp==0
          firstpoke.changeHappiness("faint")
          firstpoke.status = 0
          Kernel.pbMessage(_INTL("{1} fainted...",firstpoke.name))
          if defined? pbToggleFollowingPokemon
            $PokemonTemp.dependentEvents.refresh_sprite
          end
        end
        if pbAllFainted
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}

#===============================================================================
# Birthsign - The Racketeer
#===============================================================================
# When the user is leading, 25% discount at shops, and 25% markup when selling.
# Only works if the user meets the minimum level requirement.
#===============================================================================
class PokemonMartAdapter
  def getPrice(item,selling=false)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1]>=0
      else
        return $game_temp.mart_prices[item][0] if $game_temp.mart_prices[item][0]>0
      end
    end
    minlevel=$Trainer.numbadges*7
    minlevel=10 if $Trainer.numbadges<=1
    minlevel=55 if $Trainer.numbadges>=8
    if $Trainer.party[0].birthsign==34 && $Trainer.party[0].level>=minlevel
      return ($ItemData[item][ITEMPRICE]*1.25).floor if selling
      return ($ItemData[item][ITEMPRICE]/1.25).floor if !selling
    else
      return $ItemData[item][ITEMPRICE]
    end
  end
end

# Displays a discount/markup window in shops when sign's effect is active.
class PokemonMart_Scene
  alias discount_pbStartBuyOrSellScene pbStartBuyOrSellScene
  def pbStartBuyOrSellScene(buying,stock,adapter)
    discount_pbStartBuyOrSellScene(buying,stock,adapter)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    minlevel=$Trainer.numbadges*7
    minlevel=10 if $Trainer.numbadges<=1
    minlevel=55 if $Trainer.numbadges>=8
    if $Trainer.party[0].birthsign==34 && $Trainer.party[0].level>=minlevel
      @sprites["discount"]=Window_AdvancedTextPokemon.new("25% Discount")
      pbPrepareWindow(@sprites["discount"])
      @sprites["discount"].setSkin("Graphics/Windowskins/choice 3")
      @sprites["discount"].visible=true
      @sprites["discount"].viewport=@viewport
      @sprites["discount"].x=0
      @sprites["discount"].y=96
      @sprites["discount"].width=190
      @sprites["discount"].height=64
      @sprites["discount"].baseColor=Color.new(88,88,80)
      @sprites["discount"].shadowColor=Color.new(168,184,184)
    end
  end
  
  alias discount_pbStartSellScene2 pbStartSellScene2
  def pbStartSellScene2(bag,adapter)
    discount_pbStartSellScene2(bag,adapter)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    minlevel=$Trainer.numbadges*7
    minlevel=10 if $Trainer.numbadges<=1
    minlevel=55 if $Trainer.numbadges>=8
    if $Trainer.party[0].birthsign==34 && $Trainer.party[0].level>=minlevel
      @sprites["markup"]=Window_AdvancedTextPokemon.new("25% Markup")
      pbPrepareWindow(@sprites["markup"])
      @sprites["markup"].setSkin("Graphics/Windowskins/choice 3")
      @sprites["markup"].visible=true
      @sprites["markup"].viewport=@viewport
      @sprites["markup"].x=0
      @sprites["markup"].y=112
      @sprites["markup"].width=186
      @sprites["markup"].height=64
      @sprites["markup"].baseColor=Color.new(88,88,80)
      @sprites["markup"].shadowColor=Color.new(168,184,184)
    end
  end
end

#===============================================================================
# Birthsign - The Scavenger
#===============================================================================
# May pick up items related to the environment while walking.
#===============================================================================
Events.onStepTakenTransferPossible+=proc {|sender,e|
  handled = e[0]
  next if handled[0]
  if $Trainer.party.length>0
    for i in $Trainer.ablePokemonParty
      if i.birthsign==35 && !i.hasItem?
        env=pbGetEnvironment()
        #=Space=================================================================
        if env==PBEnvironment::Space
          find=[:STARDUST,:STARPIECE,:COMETSHARD,:EVIOLITE,:SHINYSTONE]
          rare=[:JANZODICA,:FEBZODICA,:MARZODICA,:APRIZODICA,:MAYZODICA,
                :JUNZODICA,:JULZODICA,:AUGZODICA,:SEPZODICA,:OCTZODICA,
                :NOVIZODICA,:DECIZODICA]
          i.setItem(:STARDUST) if rand(1000)<1
          i.setItem(find[rand(find.length)]) if rand(3500)<1
          i.setItem(rare[rand(rare.length)]) if rand(5000)<1
        #=Sky===================================================================
        elsif env==PBEnvironment::Sky
          find=[:PRETTYWING,:HEALTHWING,:MUSCLEWING,:RESISTWING,:GENIUSWING,
                :CLEVERWING,:SWIFTWING,:SHARPBEAK]
          i.setItem(find[rand(find.length)]) if rand(1000)<1
        #=Underwater============================================================
        elsif env==PBEnvironment::Underwater
          find=[:DEEPSEASCALE,:DEEPSEATOOTH,:HEARTSCALE,:PRISMSCALE,:DRAGONSCALE,
                :PEARL,:BIGPEARL,:DAMPROCK,:WATERSTONE,:MYSTICWATER,:SHELLBELL]
          rare=[:RELICCOPPER,:RELICSILVER,:RELICGOLD,:RELICVASE,:RELICBAND,
                :RELICSTATUE,:RELICCROWN,:BOTTLECAP,:GOLDBOTTLECAP,:PEARLSTRING]
          i.setItem(:HEARTSCALE) if rand(1000)<1      
          i.setItem(find[rand(find.length)]) if rand(3500)<1
          i.setItem(rare[rand(rare.length)]) if rand(5000)<1
        #=Water=================================================================
        elsif env==PBEnvironment::MovingWater || env==PBEnvironment::StillWater
          find=[:MYSTICWATER,:DAMPROCK,:WATERSTONE,:FRESHWATER]
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Snow==================================================================
        elsif env==PBEnvironment::Snow
          find=[:NEVERMELTICE,:ICYROCK,:SNOWBALL,:ICESTONE,:DAWNSTONE]
          i.setItem(:SNOWBALL) if rand(1000)<1
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Sand==================================================================
        elsif env==PBEnvironment::Sand
          find=[:SOFTSAND,:BRIGHTPOWDER,:SMOOTHROCK,:LIGHTCLAY]
          i.setItem(:SOFTSAND) if rand(1000)<1
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Volcano===============================================================
        elsif env==PBEnvironment::Volcano
          find=[:CHARCOAL,:HEATROCK,:FLAMEORB,:FIRESTONE,:SUNSTONE,:DRAGONFANG]
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Graveyard=============================================================
        elsif env==PBEnvironment::Graveyard
          find=[:SPELLTAG,:LIFEORB,:RAREBONE,:REAPERCLOTH,:ODDKEYSTONE,:THICKCLUB,
                :CLEANSETAG,:DUSKSTONE,:DESTINYKNOT,:SMOKEBALL,:BLACKSLUDGE,
                :FOCUSSASH,:FOCUSBAND,:TOXICORB]
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Rock/Cave=============================================================
        elsif env==PBEnvironment::Rock || env==PBEnvironment::Cave
          find=[:HARDSTONE,:EVERSTONE,:LAGGINGTAIL,:MOONSTONE,:NUGGET,:BIGNUGGET,
                :FLOATSTONE,:KINGSROCK,:ROCKYHELMET,:REVIVE,:MAXREVIVE]
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Grass=================================================================
        elsif env==PBEnvironment::Grass || env==PBEnvironment::TallGrass || env==PBEnvironment::Forest
          find=[:MIRACLESEED,:ABSORBBULB,:LEAFSTONE,:HONEY,:TINYMUSHROOM,
                :BIGMUSHROOM,:BALMMUSHROOM,:SHEDSHELL,:BIGROOT,:LEFTOVERS,
                :MENTALHERB,:WHITEHERB,:POWERHERB,:STICKYBARB,:POISONBARB,
                :SILVERPOWDER,:STICK,:ENERGYROOT,:ENERGYPOWDER,:HEALPOWDER,
                :REVIVALHERB,:LUMINOUSMOSS,:ELECTRICSEED,:GRASSYSEED,:MISTYSEED,
                :PSYCHICSEED,:SWEETAPPLE,:TARTAPPLE]
          i.setItem(find[rand(find.length)]) if rand(2500)<1
        #=Building==============================================================
        elsif !pbGetMetadata($game_map.map_id,MetadataOutdoor)
          find=[:MAGNET,:CELLBATTERY,:THUNDERSTONE,:TWISTEDSPOON,:EJECTBUTTON,
                :WISEGLASSES,:MUSCLEBAND,:AMULETCOIN,:SOOTHEBELL,:BLACKGLASSES,
                :SILKSCARF,:POKEDOLL,:POKEBALL,:GREATBALL,:ULTRABALL]
          rare=[:RARECANDY,:PPUP,:PPMAX,:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,
                :CARBOS,:BOTTLECAP,:GOLDBOTTLECAP]
          i.setItem(:POKEBALL) if rand(2500)<1
          i.setItem(find[rand(find.length)]) if rand(3500)<1
          i.setItem(rare[rand(rare.length)]) if rand(5000)<1
        end
        i.item=0 if i.item==nil
        if i.item>0
          Kernel.pbMessage(_INTL("Huh?\1\n{1} seems to have scavenged something!",i.name))
        end
      end
    end
  end
}

############[BREEDING MECHANIC EDITS]###########################################
#===============================================================================
# Birthsign Bonuses - Hatch effects
#===============================================================================
# Applies Birthsign effects to eggs.
# Overwrites sections in PField_DayCare & PScreen_EggHatching
#===============================================================================

#===============================================================================
# Legendary Breeding - Mew
#===============================================================================
# Defines Mew as a parent so that it may be used similarly to Ditto.
#===============================================================================
def pbIsMew?(pokemon)
  dexdata=pbLoadSpeciesData
  pbGetSpeciesData(dexdata,pokemon.species,SpeciesCompatibility)
  compat10=dexdata.fgetb
  compat11=dexdata.fgetb
  dexdata.close
  return isConst?(compat10,PBEggGroups,:Ancestor) ||
         isConst?(compat11,PBEggGroups,:Ancestor)
end
#===============================================================================

def pbDayCareGetCompat
  if pbDayCareDeposited==2
    pokemon1=$PokemonGlobal.daycare[0][0]
    pokemon2=$PokemonGlobal.daycare[1][0]
    return 0 if (pokemon1.isShadow? rescue false)
    return 0 if (pokemon2.isShadow? rescue false)
    #===========================================================================
    # Makes celestial species unbreedable
    #===========================================================================
    return 0 if pokemon1.isCelestial?
    return 0 if pokemon2.isCelestial?
    # Insert code here if certain forms of certain species cannot breed
    #===========================================================================
    # Legendary Breeding - Exceptions
    #===========================================================================
    # Prevents certain forms of legendaries from breeding.
    #===========================================================================
    return 0 if (isConst?(pokemon1.species,PBSpecies,:TORNADUS) && pokemon1.form!=1)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:TORNADUS) && pokemon2.form!=1)
    return 0 if (isConst?(pokemon1.species,PBSpecies,:THUNDURUS) && pokemon1.form!=1)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:THUNDURUS) && pokemon2.form!=1)
    return 0 if (isConst?(pokemon1.species,PBSpecies,:LANDORUS) && pokemon1.form!=1)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:LANDORUS) && pokemon2.form!=1)
    return 0 if (isConst?(pokemon1.species,PBSpecies,:KYUREM) && pokemon1.form!=0)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:KYUREM) && pokemon2.form!=0)
    return 0 if (isConst?(pokemon1.species,PBSpecies,:ZYGARDE) && pokemon1.form!=0)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:ZYGARDE) && pokemon2.form!=0)
    return 0 if (isConst?(pokemon1.species,PBSpecies,:NECROZMA) && pokemon1.form!=0)
    return 0 if (isConst?(pokemon2.species,PBSpecies,:NECROZMA) && pokemon2.form!=0)
    #===========================================================================
    dexdata=pbLoadSpeciesData
    pbGetSpeciesData(dexdata,pokemon1.species,SpeciesCompatibility)
    compat10=dexdata.fgetb
    compat11=dexdata.fgetb
    pbGetSpeciesData(dexdata,pokemon2.species,SpeciesCompatibility)
    compat20=dexdata.fgetb
    compat21=dexdata.fgetb
    dexdata.close
    if !isConst?(compat10,PBEggGroups,:Undiscovered) &&
       !isConst?(compat11,PBEggGroups,:Undiscovered) &&
       !isConst?(compat20,PBEggGroups,:Undiscovered) &&
       !isConst?(compat21,PBEggGroups,:Undiscovered)
      if compat10==compat20 || compat11==compat20 ||
         compat10==compat21 || compat11==compat21 ||
         #======================================================================
         # Legendary Breeding - Compatibility
         #======================================================================
         # Determines compatibility between Ditto/Mew and Legendaries/UB's.
         #======================================================================
         # Ditto can breed with any regular species.
         ((isConst?(compat10,PBEggGroups,:Ditto) ||
         isConst?(compat11,PBEggGroups,:Ditto) ||
         isConst?(compat20,PBEggGroups,:Ditto) ||
         isConst?(compat21,PBEggGroups,:Ditto)) &&
         # Ditto can't breed with legendary species or Ultra Beasts.
         !(isConst?(compat10,PBEggGroups,:Skycrest) ||
         isConst?(compat11,PBEggGroups,:Skycrest) ||
         isConst?(compat20,PBEggGroups,:Skycrest) ||
         isConst?(compat21,PBEggGroups,:Skycrest) ||
         isConst?(compat10,PBEggGroups,:Bestial) ||
         isConst?(compat11,PBEggGroups,:Bestial) ||
         isConst?(compat20,PBEggGroups,:Bestial) ||
         isConst?(compat21,PBEggGroups,:Bestial) ||
         isConst?(compat10,PBEggGroups,:Titan) ||
         isConst?(compat11,PBEggGroups,:Titan) ||
         isConst?(compat20,PBEggGroups,:Titan) ||
         isConst?(compat21,PBEggGroups,:Titan) ||
         isConst?(compat10,PBEggGroups,:Overlord) ||
         isConst?(compat11,PBEggGroups,:Overlord) ||
         isConst?(compat20,PBEggGroups,:Overlord) ||
         isConst?(compat21,PBEggGroups,:Overlord) ||
         isConst?(compat10,PBEggGroups,:Nebulous) ||
         isConst?(compat11,PBEggGroups,:Nebulous) ||
         isConst?(compat20,PBEggGroups,:Nebulous) ||
         isConst?(compat21,PBEggGroups,:Nebulous) ||
         isConst?(compat10,PBEggGroups,:Enchanted) ||
         isConst?(compat11,PBEggGroups,:Enchanted) ||
         isConst?(compat20,PBEggGroups,:Enchanted) ||
         isConst?(compat21,PBEggGroups,:Enchanted) ||
         isConst?(compat10,PBEggGroups,:Ancestor) ||
         isConst?(compat11,PBEggGroups,:Ancestor) ||
         isConst?(compat20,PBEggGroups,:Ancestor) ||
         isConst?(compat21,PBEggGroups,:Ancestor) ||
         isConst?(compat10,PBEggGroups,:Ultra) ||
         isConst?(compat11,PBEggGroups,:Ultra) ||
         isConst?(compat20,PBEggGroups,:Ultra) ||
         isConst?(compat21,PBEggGroups,:Ultra)
         )) ||
         # Mew can breed with any regular or legendary species.
         ((isConst?(compat10,PBEggGroups,:Ancestor) ||
         isConst?(compat11,PBEggGroups,:Ancestor) ||
         isConst?(compat20,PBEggGroups,:Ancestor) ||
         isConst?(compat21,PBEggGroups,:Ancestor)) &&
         # Mew cannot breed with Ditto or Ultra Beasts.
         !(isConst?(compat10,PBEggGroups,:Ditto) ||
         isConst?(compat11,PBEggGroups,:Ditto) ||
         isConst?(compat20,PBEggGroups,:Ditto) ||
         isConst?(compat21,PBEggGroups,:Ditto) ||
         isConst?(compat10,PBEggGroups,:Ultra) ||
         isConst?(compat11,PBEggGroups,:Ultra) ||
         isConst?(compat20,PBEggGroups,:Ultra) ||
         isConst?(compat21,PBEggGroups,:Ultra)
         ))
         #======================================================================
        if pbDayCareCompatibleGender(pokemon1,pokemon2)
          ret=1
          ret+=1 if pokemon1.species==pokemon2.species
          ret+=1 if pokemon1.trainerID!=pokemon2.trainerID
          return ret
        end
      end
    end
  end
  return 0
end

def pbDayCareGenerateEgg
  return if pbDayCareDeposited!=2
  if $Trainer.party.length>=6
    raise _INTL("Can't store the egg")
  end
  pokemon0=$PokemonGlobal.daycare[0][0]
  pokemon1=$PokemonGlobal.daycare[1][0]
  mother=nil
  father=nil
  babyspecies=0
  ditto0=pbIsDitto?(pokemon0)
  ditto1=pbIsDitto?(pokemon1)
  #=============================================================================
  # Legendary Breeding - Egg Species
  #=============================================================================
  # Egg is always partner's species when breeding with Ditto or Mew.
  #=============================================================================
  mew0=pbIsMew?(pokemon0)
  mew1=pbIsMew?(pokemon1)
  if pokemon0.isFemale? || ditto0 || mew0
    babyspecies=(ditto0 || mew0) ? pokemon1.species : pokemon0.species
    mother=pokemon0
    father=pokemon1
  else
    babyspecies=(ditto1 || mew1) ? pokemon0.species : pokemon1.species
    mother=pokemon1
    father=pokemon0
  end
  #=============================================================================
  babyspecies=pbGetBabySpecies(babyspecies,mother.item,father.item)
  if (isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)) ||
        (isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE))
    babyspecies=[getConst(PBSpecies,:NIDORANmA),
                 getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)) ||
        (isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT))
    babyspecies=[getConst(PBSpecies,:VOLBEAT),
                 getConst(PBSpecies,:ILLUMISE)][rand(2)]
  #=============================================================================
  # Legendary Breeding - Baby Species
  #=============================================================================
  # Gets different species for legendary offsping under certain conditions.
  #=============================================================================
  # Latias can produce Latias or Latios eggs.
  elsif (isConst?(babyspecies,PBSpecies,:LATIAS) && hasConst?(PBSpecies,:LATIOS)) ||
        (isConst?(babyspecies,PBSpecies,:LATIOS) && hasConst?(PBSpecies,:LATIAS))
    babyspecies=[getConst(PBSpecies,:LATIOS),
                 getConst(PBSpecies,:LATIAS)][rand(2)]
  # Manaphy produces Phione eggs unless mother is holding Mystic Water.
  elsif (isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE) &&
        !isConst?(mother.item,PBItems,:MYSTICWATER) && !isConst?(father.item,PBItems,:MYSTICWATER))
    babyspecies=getConst(PBSpecies,:PHIONE)
  # Mew can produce Mewtwo eggs while holding Berserk Gene.
  elsif (isConst?(mother.species,PBSpecies,:MEW) && isConst?(father.species,PBSpecies,:MEW)) &&
        (isConst?(mother.item,PBItems,:BERSERKGENE) || isConst?(father.item,PBItems,:BERSERKGENE))
    babyspecies=getConst(PBSpecies,:MEWTWO)
  # Regigigas can produce other Regi's eggs depending on held item.
  elsif (isConst?(mother.species,PBSpecies,:REGIGIGAS) && isConst?(father.species,PBSpecies,:REGIGIGAS))
    # Regirock
    if (isConst?(mother.item,PBItems,:HARDSTONE) || isConst?(father.item,PBItems,:HARDSTONE))
      babyspecies=getConst(PBSpecies,:REGIROCK)
    # Regice
    elsif (isConst?(mother.item,PBItems,:NEVERMELTICE) || isConst?(father.item,PBItems,:NEVERMELTICE))
      babyspecies=getConst(PBSpecies,:REGICE)
    # Registeel
    elsif (isConst?(mother.item,PBItems,:IRONBALL) || isConst?(father.item,PBItems,:IRONBALL))
      babyspecies=getConst(PBSpecies,:REGISTEEL)
    # Regieleki
    elsif (isConst?(mother.item,PBItems,:LIGHTBALL) || isConst?(father.item,PBItems,:LIGHTBALL))
      babyspecies=getConst(PBSpecies,:REGIELEKI)
    # Regidrago
    elsif (isConst?(mother.item,PBItems,:DRAGONFANG) || isConst?(father.item,PBItems,:DRAGONFANG))
      babyspecies=getConst(PBSpecies,:REGIDRAGO)
    end
  #=============================================================================
  end
  # Generate egg
  egg=PokeBattle_Pokemon.new(babyspecies,EGGINITIALLEVEL,$Trainer)
  # Randomise personal ID
  pid=rand(65536)
  pid|=(rand(65536)<<16)
  egg.personalID=pid
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) ||
     isConst?(babyspecies,PBSpecies,:SHELLOS) ||
     isConst?(babyspecies,PBSpecies,:BASCULIN) ||
     isConst?(babyspecies,PBSpecies,:FLABEBE) ||
     isConst?(babyspecies,PBSpecies,:PUMPKABOO) ||
     isConst?(babyspecies,PBSpecies,:ORICORIO) ||
     isConst?(babyspecies,PBSpecies,:MINIOR) ||
  #=============================================================================
  # Legendary Breeding - Form Inheritence
  #=============================================================================
  # Inherits mother's form, or partner's form if breeding with Ditto/Mew
  #=============================================================================
     isConst?(babyspecies,PBSpecies,:DEOXYS) ||
     isConst?(babyspecies,PBSpecies,:TORNADUS) ||
     isConst?(babyspecies,PBSpecies,:THUNDURUS) ||
     isConst?(babyspecies,PBSpecies,:LANDORUS)
    if pbIsDitto?(mother) || pbIsMew?(mother)
      egg.form=father.form
    else
      egg.form=mother.form
    end
  end  
  # Zygarde always hatches in its 10% form
  if isConst?(babyspecies,PBSpecies,:ZYGARDE)
    egg.form=1 #Assumes form 0 is 50% Forme, and form 1 is 10% Forme.
  end
  #=============================================================================
  # Inheriting Moves
  moves=[]
  othermoves=[] 
  movefather=father; movemother=mother
  if pbIsDitto?(movefather) && !mother.isFemale?
    movefather=mother; movemother=father
  end
  # Initial Moves
  initialmoves=egg.getMoveList
  for k in initialmoves
    if k[0]<=EGGINITIALLEVEL
      moves.push(k[1])
    else
      othermoves.push(k[1]) if mother.hasMove?(k[1]) && father.hasMove?(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  if !USENEWBATTLEMECHANICS
    for i in 0...$ItemData.length
      next if !$ItemData[i]
      atk=$ItemData[i][ITEMMACHINE]
      next if !atk || atk==0
      if egg.isCompatibleWithMove?(atk)
        moves.push(atk) if movefather.hasMove?(atk)
      end
    end
  end
  # Inheriting Egg Moves
  if movefather.isMale?
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
       f.pos=(egg.fSpecies-1)*8
       offset=f.fgetdw
       length=f.fgetdw
       if length>0
         f.pos=offset
         i=0; loop do break unless i<length
           atk=f.fgetw
           moves.push(atk) if movefather.hasMove?(atk)
           i+=1
         end
       end
    }
  end
  if USENEWBATTLEMECHANICS
    pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
       f.pos=(egg.fSpecies-1)*8
       offset=f.fgetdw
       length=f.fgetdw
       if length>0
         f.pos=offset
         i=0; loop do break unless i<length
           atk=f.fgetw
           moves.push(atk) if movemother.hasMove?(atk)
           i+=1
         end
       end
    }
  end
  # Volt Tackle
  lightball=false
  if (isConst?(father.species,PBSpecies,:PIKACHU) || 
      isConst?(father.species,PBSpecies,:RAICHU)) && 
      isConst?(father.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if (isConst?(mother.species,PBSpecies,:PIKACHU) || 
      isConst?(mother.species,PBSpecies,:RAICHU)) && 
      isConst?(mother.item,PBItems,:LIGHTBALL)
    lightball=true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  moves|=[] # remove duplicates
  # Assembling move list
  finalmoves=[]
  listend=moves.length-4
  listend=0 if listend<0
  j=0
  for i in listend..listend+3
    moveid=(i>=moves.length) ? 0 : moves[i]
    finalmoves[j]=PBMove.new(moveid)
    j+=1
  end 
  # Inheriting Individual Values
  ivs=[]
  for i in 0...6
    ivs[i]=rand(32)
  end
  ivinherit=[]
  for i in 0...2
    parent=[mother,father][i]
    ivinherit[i]=PBStats::HP if isConst?(parent.item,PBItems,:POWERWEIGHT)
    ivinherit[i]=PBStats::ATTACK if isConst?(parent.item,PBItems,:POWERBRACER)
    ivinherit[i]=PBStats::DEFENSE if isConst?(parent.item,PBItems,:POWERBELT)
    ivinherit[i]=PBStats::SPEED if isConst?(parent.item,PBItems,:POWERANKLET)
    ivinherit[i]=PBStats::SPATK if isConst?(parent.item,PBItems,:POWERLENS)
    ivinherit[i]=PBStats::SPDEF if isConst?(parent.item,PBItems,:POWERBAND)
  end
  num=0; r=rand(2)
  for i in 0...2
    if ivinherit[r]!=nil
      parent=[mother,father][r]
      ivs[ivinherit[r]]=parent.iv[ivinherit[r]]
      num+=1
      break
    end
    r=(r+1)%2
  end
  stats=[PBStats::HP,PBStats::ATTACK,PBStats::DEFENSE,
         PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
  limit=(USENEWBATTLEMECHANICS && (isConst?(mother.item,PBItems,:DESTINYKNOT) ||
         isConst?(father.item,PBItems,:DESTINYKNOT))) ? 5 : 3
  loop do
    freestats=[]
    for i in stats
      freestats.push(i) if !ivinherit.include?(i)
    end
    break if freestats.length==0
    r=freestats[rand(freestats.length)]
    parent=[mother,father][rand(2)]
    ivs[r]=parent.iv[r]
    ivinherit.push(r)
    num+=1
    break if num>=limit
  end
  # Inheriting nature
  newnatures=[]
  newnatures.push(mother.nature) if isConst?(mother.item,PBItems,:EVERSTONE)
  newnatures.push(father.nature) if isConst?(father.item,PBItems,:EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries=0
  shinyretries+=5 if father.language!=mother.language
  shinyretries+=2 if hasConst?(PBItems,:SHINYCHARM) &&
                     $PokemonBag.pbHasItem?(:SHINYCHARM)
  if shinyretries>0
    for i in 0...shinyretries
      break if egg.isShiny?
      egg.personalID=rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
  if (!ditto0 && !ditto1)
    if mother.hasHiddenAbility?
      egg.setAbility(mother.abilityIndex) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex)
      else
        egg.setAbility((mother.abilityIndex+1)%2)
      end
    end
  elsif ((!ditto0 && ditto1) || (!ditto1 && ditto0)) && USENEWBATTLEMECHANICS
    parent=(!ditto0) ? mother : father
    if parent.hasHiddenAbility?
      egg.setAbility(parent.abilityIndex) if rand(10)<6
    end
  end
  # Inheriting Poké Ball from the mother
  if mother.isFemale? &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:MASTERBALL) &&
     !isConst?(pbBallTypeToBall(mother.ballused),PBItems,:CHERISHBALL)
    egg.ballused=mother.ballused
  end
  egg.iv[0]=ivs[0]
  egg.iv[1]=ivs[1]
  egg.iv[2]=ivs[2]
  egg.iv[3]=ivs[3]
  egg.iv[4]=ivs[4]
  egg.iv[5]=ivs[5]
  egg.moves[0]=finalmoves[0]
  egg.moves[1]=finalmoves[1]
  egg.moves[2]=finalmoves[2]
  egg.moves[3]=finalmoves[3]
  #=============================================================================
  # Birthsigns - The Ancestor
  # Passes down EV spreads of the parent to the offspring.
  #=============================================================================
  egg.ev=mother.ev if (mother.hasBirthsign? && mother.birthsign==19)
  egg.ev=father.ev if (father.hasBirthsign? && father.birthsign==19)
  if (mother.hasBirthsign? && mother.birthsign==19) &&
     (father.hasBirthsign? && father.birthsign==19)
    if rand(100)<50
      egg.ev=mother.ev 
    else
      egg.ev=father.ev
    end
  end
  #=============================================================================
  egg.calcStats
  egg.obtainText=_INTL("Day-Care Couple")
  egg.name=_INTL("Egg")
  dexdata=pbLoadSpeciesData
  pbGetSpeciesData(dexdata,babyspecies,21)
  eggsteps=dexdata.fgetw
  dexdata.close
  egg.eggsteps=eggsteps
  #=============================================================================
  # Birthsigns - Partner Sign breeding bonuses
  #=============================================================================
  # Has a 50% chance of inheriting only the parent's 30/31 IV's.
  # Egg steps required are halved, or even quartered.
  # Eggs sometimes hatch holding random item.
  #=============================================================================
  if pbSharePartnersign?(mother,father)
    allymonth = (mother.hasPartnersign?(Time.now.mon) || father.hasPartnersign?(Time.now.mon))
    mothergem = getZodiacGem(mother.monthsign)
    fathergem = getZodiacGem(father.monthsign)
    baseitem  = [:STARDUST,:STARDUST,:STARDUST,:STARPIECE]
    rareitem  = [:EVIOLITE,:SHEDSHELL,:LEFTOVERS,:LUCKYEGG]
    # Passes down parent's IV's
    if rand(10)<5
      for i in 0...6
        egg.iv[i]=mother.iv[i] if mother.iv[i]>29
        egg.iv[i]=father.iv[i] if father.iv[i]>29 && egg.iv[i]<31
      end
    end
    # Egg hatches with an item
    if rand(10)<5
      egg.setItem(baseitem[rand(baseitem.length)]) if rand(100)<=75
      egg.setItem(rareitem[rand(rareitem.length)]) if rand(100)<=25
      if defined?(INCLUDEZPOWER)
        egg.setItem(mothergem) if rand(100)<=15
        egg.setItem(fathergem) if rand(100)<=5
      end
    end
    # Egg steps are reduced
    if allymonth
      egg.eggsteps=eggsteps/4
    else
      egg.eggsteps=eggsteps/2
    end
    egg.calcStats
  end
  #===========================================================================
  # Birthsigns - Rival Sign breeding penalties
  #===========================================================================
  # Has a 50% chance of inheriting only the parent's 0 IV's.
  # Egg steps needed to hatch are increased.
  # Don't hatch with any bonus items.
  #===========================================================================
  if pbShareRivalsign?(mother,father)
    if rand(10)<5
      for i in 0...6
        egg.iv[i]=mother.iv[i] if mother.iv[i]==0
        egg.iv[i]=father.iv[i] if father.iv[i]==0
      end
      egg.calcStats
    end
    egg.eggsteps+=1500
  end
  #=============================================================================
  if rand(65536)<POKERUS_CHANCE
    egg.givePokerus
  end
  # Family Tree compatibility
  if SHOW_FAMILYTREE
    egg.family = PokemonFamily.new(egg, father, mother)
  end
  $Trainer.party[$Trainer.party.length]=egg
end

alias birthsigns_hatch pbHatch
def pbHatch(pokemon)
  birthsigns_hatch(pokemon)
  #=============================================================================
  # Applies corresponding Birthsign upon hatching
  #=============================================================================
  pokemon.setZodiacsign(Time.now.mon)
  #=============================================================================
end


############[SUMMARY SCREEN EDITS]##############################################
#===============================================================================
# Birthsigns Summary - Page rewrites
#===============================================================================
# Overwrites areas within the PScreen_Summary section.
#===============================================================================
class PokemonSummary_Scene
  #=============================================================================
  # Zodiac Token
  #=============================================================================
  def pbDisplaySummaryToken
    if @pokemon.hasBirthsign?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      tokenpath1="Graphics/Pictures/Birthsigns/token%02d"
      tokenpath2="Graphics/Pictures/Birthsigns/bless_token%02d"
      if @pokemon.isBlessed?
        zodiactoken=sprintf(tokenpath2,PBBirthsigns.signValue(@pokemon.birthsign))
      else
        zodiactoken=sprintf(tokenpath1,PBBirthsigns.signValue(@pokemon.birthsign))
      end
      imagepos.push([zodiactoken,-9,225,0,0,-1,-1])
      pbDrawImagePositions(overlay,imagepos)
    end
  end
  #===========================================================================
  # Birthsign Page Button
  #===========================================================================
  def pbDisplayZodiacButton  
    if @pokemon.hasBirthsign?
      overlay=@sprites["overlay"].bitmap
      button=AnimatedBitmap.new(_INTL("Graphics/Pictures/Birthsigns/Other/battlezodiacEB2"))
      overlay.blt(158,312,button.bitmap,Rect.new(0,0,44,44))
    end
  end
  #=============================================================================
  # Shiny Leaf - Shows Shiny Leaves or Crown
  #=============================================================================
  def pbDisplayShinyLeaf
    if SHOW_SHINY_LEAF
      leaf="Graphics/Pictures/Birthsigns/Other/leaf"
      leafcrown="Graphics/Pictures/Birthsigns/Other/leafcrown"
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      if @pokemon.leafflag!=nil && !@pokemon.egg?
        if @pokemon.shinyleaf==6 || @pokemon.shinyleaf>6
          imagepos.push([leafcrown,164,121,0,0,-1,-1])
        else
          imagepos.push([leaf,142,124,0,0,-1,-1]) if @pokemon.shinyleaf>4
          imagepos.push([leaf,152,124,0,0,-1,-1]) if @pokemon.shinyleaf>3
          imagepos.push([leaf,162,124,0,0,-1,-1]) if @pokemon.shinyleaf>2
          imagepos.push([leaf,172,124,0,0,-1,-1]) if @pokemon.shinyleaf>1
          imagepos.push([leaf,182,124,0,0,-1,-1]) if @pokemon.shinyleaf>0
        end
      end
      pbDrawImagePositions(overlay,imagepos)
    end
  end
  #=============================================================================
  # Egg Groups - Shows Pokemon's Egg Groups on Page 2 (Memo)
  #=============================================================================
  def pbDisplayEggGroups
    if SHOW_EGG_GROUPS
      if !@pokemon.egg?
        dexdata=pbLoadSpeciesData
        pbGetSpeciesData(dexdata,@pokemon.species,SpeciesCompatibility)
        compat10=dexdata.fgetb
        compat11=dexdata.fgetb
        noGender=(@pokemon.isGenderless? && !isConst?(@pokemon.species,PBSpecies,:DITTO))
        eggGroupbitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Birthsigns/Other/typesEgg"))
        eggGroup0rect=Rect.new(0,700,64,28)
        eggGroup1rect=Rect.new(0,compat10*28,64,28)
        eggGroup2rect=Rect.new(0,compat11*28,64,28)
        overlay = @sprites["overlay"].bitmap
        if (noGender && compat10!=0) || @pokemon.isCelestial?
          overlay.blt(364,336,eggGroupbitmap.bitmap,eggGroup0rect)
        elsif compat10==compat11
          overlay.blt(364,336,eggGroupbitmap.bitmap,eggGroup1rect)
        else
          overlay.blt(364,336,eggGroupbitmap.bitmap,eggGroup1rect)
          overlay.blt(432,336,eggGroupbitmap.bitmap,eggGroup2rect)
        end
        dexdata.close
      end
      if compat10>14 || @pokemon.isCelestial?
        textpos=[[_INTL("Egg Groups:"),234,334,0,Color.new(41,86,143),Color.new(150,177,210)]]
      else
        textpos=[[_INTL("Egg Groups:"),234,334,0,Color.new(64,64,64),Color.new(176,176,176)]]
      end
      pbDrawTextPositions(overlay,textpos)
    end
  end
  #=============================================================================
  # IV Stars - Shows IV Star ratings on Page 3 (Stats)
  #=============================================================================
  def pbDisplayIVStars
    if SHOW_IV_STARS
      nostar="Graphics/Pictures/Birthsigns/Other/starempty"
      lowstar="Graphics/Pictures/Birthsigns/Other/starlow"
      highstar="Graphics/Pictures/Birthsigns/Other/starhigh"
      perfectstar="Graphics/Pictures/Birthsigns/Other/starperfect"
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push([nostar,465,82,0,0,-1,-1])
      imagepos.push([nostar,465,126,0,0,-1,-1])
      imagepos.push([nostar,465,158,0,0,-1,-1])
      imagepos.push([nostar,465,190,0,0,-1,-1])
      imagepos.push([nostar,465,222,0,0,-1,-1])
      imagepos.push([nostar,465,254,0,0,-1,-1])
      #HP
      if @pokemon.iv[0]>30
        imagepos.push([perfectstar,465,82,0,0,-1,-1])
      elsif @pokemon.iv[0]>29
        imagepos.push([highstar,465,82,0,0,-1,-1])
      elsif @pokemon.iv[0]>0 && @pokemon.iv[0]<30
        imagepos.push([lowstar,465,82,0,0,-1,-1])
      end
      #Atk
      if @pokemon.iv[1]>30
        imagepos.push([perfectstar,465,126,0,0,-1,-1])
      elsif @pokemon.iv[1]>29
        imagepos.push([highstar,465,126,0,0,-1,-1])
      elsif @pokemon.iv[1]>0 && @pokemon.iv[1]<30
        imagepos.push([lowstar,465,126,0,0,-1,-1])
      end
      #Def
      if @pokemon.iv[2]>30
        imagepos.push([perfectstar,465,158,0,0,-1,-1])
      elsif @pokemon.iv[2]>29
        imagepos.push([highstar,465,158,0,0,-1,-1])
      elsif @pokemon.iv[2]>0 && @pokemon.iv[2]<30
        imagepos.push([lowstar,465,158,0,0,-1,-1])
      end
      #SpAtk
      if @pokemon.iv[4]>30
        imagepos.push([perfectstar,465,190,0,0,-1,-1])
      elsif @pokemon.iv[4]>29
        imagepos.push([highstar,465,190,0,0,-1,-1])
      elsif @pokemon.iv[4]>0 && @pokemon.iv[4]<30
        imagepos.push([lowstar,465,190,0,0,-1,-1])
      end
      #SpDef
      if @pokemon.iv[5]>30
        imagepos.push([perfectstar,465,222,0,0,-1,-1])
      elsif @pokemon.iv[5]>29
        imagepos.push([highstar,465,222,0,0,-1,-1])
      elsif @pokemon.iv[5]>0 && @pokemon.iv[5]<30
        imagepos.push([lowstar,465,222,0,0,-1,-1])
      end
      #Speed
      if @pokemon.iv[3]>30
        imagepos.push([perfectstar,465,254,0,0,-1,-1])
      elsif @pokemon.iv[3]>29
        imagepos.push([highstar,465,254,0,0,-1,-1])
      elsif @pokemon.iv[3]>0 && @pokemon.iv[3]<30
        imagepos.push([lowstar,465,254,0,0,-1,-1])
      end
      pbDrawImagePositions(overlay,imagepos)
    end
  end
  
  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg; return
    end
    @sprites["pokemon"].z = 255
    @sprites["itemicon"].item = @pokemon.item
    @sprites["itemicon"].visible = true
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos=[]
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Show status/fainted/Pokérus infected icon
    status = -1
    status = 6 if @pokemon.pokerusStage==1
    status = @pokemon.status-1 if @pokemon.status>0
    status = 5 if @pokemon.hp==0
    if status>=0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100,0,0,-1,-1])
    end
    # Show shininess star
    if @pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    #===========================================================================
    # Page additions
    #===========================================================================
    pbDisplaySummaryToken
    pbDisplayShinyLeaf
    pbDisplayZodiacButton if @page==2
    pbDisplayEggGroups if @page==2
    pbDisplayIVStars if @page==3
    pbDisplayGMaxFactor if defined?(@pokemon.isDynamax?)
    pbDisplayDynamaxMeter if defined?(@pokemon.isDynamax?)
    #===========================================================================
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    textpos = []
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("MOVES"),
                _INTL("RIBBONS"),
                # Family Tree compatibility
                if SHOW_FAMILYTREE
                  _INTL("FAMILY TREE")
                end][page-1]
    textpos = [
       [pagename,26,16,0,base,shadow],
       [@pokemon.name,46,62,0,base,shadow],
       [@pokemon.level.to_s,46,92,0,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Item"),66,318,0,base,shadow]
    ]
    #===========================================================================
    # Added for Dynamax
    if defined?(@pokemon.isDynamax?)
      nodynamax=false
      for i in DMAX_BANLIST
        if isConst?(@pokemon.species,PBSpecies,i)
          nodynamax=true
        end
      end
      textpos[3][0]="" if @page==3 if !nodynamax
    end
    #===========================================================================
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([PBItems.getName(@pokemon.item),16,352,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,352,0,Color.new(192,200,208),Color.new(208,216,224)])
    end
    # Write the gender symbol
    if @pokemon.isMale?
      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
    elsif @pokemon.isFemale?
      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay,84,292)
    # Draw page-specific information
    case page
    when 1; drawPageOne
    when 2; drawPageTwo
    when 3; drawPageThree
    when 4; drawPageFour
    when 5; drawPageFive
    # Family Tree compatibility
    when 6; drawPageSix if SHOW_FAMILYTREE
    end
  end
  
#===============================================================================
# Page 1: Egg
# Change: Item text is now hidden. Used for Partner Sign breeding effects.
#===============================================================================
  def drawPageOneEgg
    @sprites["itemicon"].visible = false
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    pbSetSystemFont(overlay)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_egg")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    # Write various bits of text
    textpos=[
       [_INTL("TRAINER MEMO"),26,16,0,base,shadow],
       [@pokemon.name,46,62,0,base,shadow]
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    memo = ""
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
    end
    # Write map name egg was received on
    mapname = pbGetMapNameFromId(@pokemon.obtainMap)
    if (@pokemon.obtainText rescue false) && @pokemon.obtainText!=""
      mapname=@pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=_INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg received from <c3=F83820,E09890>{1}<c3=404040,B0B0B0>.\n",mapname)
    else
      memo+=_INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg.\n",mapname)
    end
    memo+="\n" # Empty line
    # Write Egg Watch blurb
    memo += _INTL("<c3=404040,B0B0B0>\"The Egg Watch\"\n")
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.eggsteps<10200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.eggsteps<2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.eggsteps<1275
    memo += sprintf("<c3=404040,B0B0B0>%s\n",eggstate)
    # Draw all text
    drawFormattedTextEx(overlay,232,78,268,memo)
    # Draw the Pokémon's markings
    drawMarkings(overlay,82,292)
  end

#===============================================================================
# Summary - Birthsign Page
#===============================================================================  
# Draws the Birthsign Summary Page, accessible by pressing the confirm
# button on the Memo Page (Page 2).
#===============================================================================    
  def pbDrawBirthsignPage
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    imagepos=[]
    #=========================================================================
    # Images
    #=========================================================================
    bgpath="Graphics/Pictures/Birthsigns/birthsign%02d"
    zodiacimage=sprintf(bgpath,PBBirthsigns.signValue(@pokemon.birthsign))
    imagepos.push([zodiacimage,0,0,0,0,-1,-1])
    if SHOW_FAMILYTREE
      imagepos.push(["Graphics/Pictures/Birthsigns/Other/summaryFamilyTree",0,0,0,0,-1,-1])
    else
      imagepos.push(["Graphics/Pictures/Birthsigns/Other/summaryzboarder",0,0,0,0,-1,-1])
    end
    if @pokemon.isBirthday?
      imagepos.push(["Graphics/Pictures/Birthsigns/Other/bdayicon",190,316,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,imagepos)
    pbDisplaySummaryToken
    #=========================================================================
    # Text
    #=========================================================================
    zodiac=@pokemon.pbGetBirthsignName
    zodiacdesc=@pokemon.pbGetBirthsignDesc
    hatch=pbGetAbbrevMonthName(@pokemon.timeEggHatched.mon)
    if @pokemon.monthsign==nil
      month=pbGetAbbrevMonthName(0)
    else
      month=pbGetAbbrevMonthName(@pokemon.getCalendarsign)
    end
    lastday=@pokemon.pbLastMonthDay
    pokename=@pokemon.name
    # White Text
    base=Color.new(248,248,248)
    shadow=Color.new(104,104,104)
    # Black Text
    base2=Color.new(64,64,64)
    shadow2=Color.new(176,176,176)
    # Birthday Text
    bdaycolor1=Color.new(255,215,0)
    bdaycolor2=Color.new(0,0,125)
    pbSetSystemFont(overlay)
    textpos=[
        [_INTL("BIRTHSIGN"),26,16,0,base,shadow],
        [_INTL("{1}'s Birthsign",pokename),123,60,2,base,shadow],
        [zodiac,121,90,2,base2,shadow2],
        [_INTL("Sign: {1} {2}",month,lastday),4,352,0,base2,shadow2]
    ]
    if @pokemon.obtainMode==1
      if @pokemon.timeEggHatched
        date=@pokemon.timeEggHatched.day
        year=@pokemon.timeEggHatched.year
        if @pokemon.isBirthday?
          textpos.push([_INTL("Happy Birthday!"),22,320,0,bdaycolor1,bdaycolor2])
        else
          textpos.push([_INTL("Birthday: {1} {2}, {3}",hatch,date,year),4,320,0,base,shadow])
        end
      end
    else
      textpos.push([_INTL("Birthday:  Unknown"),4,320,0,base,shadow])
    end
    pbDrawTextPositions(overlay,textpos)
    pbSetSmallFont(overlay)
    drawTextEx(overlay,254,320,258,0,zodiacdesc,base,shadow)
    pbSetSystemFont(overlay)
  end
  
#===============================================================================
# Family Tree compatibility
#===============================================================================  
  def pbGoToPrevious
    newindex = @partyindex
    while newindex>0
      newindex -= 1
      if @party[newindex] && (@page==1 || !@party[newindex].egg? ||
         (SHOW_FAMILYTREE && (@page==6 && SHOWFAMILYEGG)))
        @partyindex = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    while newindex<@party.length-1
      newindex += 1
      if @party[newindex] && (@page==1 || !@party[newindex].egg? ||
         (SHOW_FAMILYTREE && (@page==6 && SHOWFAMILYEGG)))
        @partyindex = newindex
        break
      end
    end
  end
  
#===============================================================================
# Summary Options
# Opens Birthsigns Journal if the user has a zodiac sign.
#===============================================================================
  def pbOptions
    dorefresh = false
    commands   = []
    cmdSignInfo = -1
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdMark     = -1
    if !@pokemon.egg?
      if defined?(BirthsignJournalScene) && @pokemon.hasZodiacsign?
        commands[cmdSignInfo = commands.length] = _INTL("Sign Info")
      end
      commands[cmdGiveItem = commands.length] = _INTL("Give item")
      commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      commands[cmdPokedex = commands.length]  = _INTL("View Pokédex")
    end
    commands[cmdMark = commands.length]     = _INTL("Mark")
    commands[commands.length]               = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdSignInfo>=0 && command==cmdSignInfo
      pbOpenJournalMini(@pokemon.getCalendarsign)
      dorefresh = true
    elsif cmdGiveItem>=0 && command==cmdGiveItem
      item = 0
      pbFadeOutIn(99999){
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        item = screen.pbChooseItemScreen(Proc.new{|item| pbCanHoldItem?(item) })
      }
      if item>0
        dorefresh = pbGiveItemToPokemon(item,@pokemon,self,@partyindex)
      end
    elsif cmdTakeItem>=0 && command==cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon,self)
    elsif cmdPokedex>=0 && command==cmdPokedex
      pbUpdateLastSeenForm(@pokemon)
      pbFadeOutIn(99999){
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      }
      dorefresh = true
    elsif cmdMark>=0 && command==cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end

#===============================================================================  
# Summary - Page access
#===============================================================================  
  def pbScene
    pbPlayCry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      # Family Tree compatibility
      if SHOW_FAMILYTREE
        handleInputsEgg
      end
      if Input.trigger?(Input::A)
        #=======================================================================
        if @page==2 && @pokemon.hasBirthsign?
          pbPlayDecisionSE
          pbDrawBirthsignPage
        else
          pbSEStop; pbPlayCry(@pokemon)
        end
        #=======================================================================
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE 
        if @page==4
          pbMoveSelection
          dorefresh = true
        elsif @page==5
          pbRibbonSelection
          dorefresh = true
        else
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon = @party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["itemicon"].item = @pokemon.item
          pbSEStop; pbPlayCry(@pokemon)
          @ribbonOffset = 0
          # Family Tree compatibility
          if SHOW_FAMILYTREE
            if SHOWFAMILYEGG && @pokemon.isEgg? && @page==6
              dorefresh = false
              drawPageSix
            else
              dorefresh = true
            end
          else
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          @pokemon = @party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["itemicon"].item = @pokemon.item
          pbSEStop; pbPlayCry(@pokemon)
          @ribbonOffset = 0
          # Family Tree compatibility
          if SHOW_FAMILYTREE
            if SHOWFAMILYEGG && @pokemon.isEgg? && @page==6
              dorefresh = false
              drawPageSix
            else
              dorefresh = true
            end
          else
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        # Family Tree compatibility
        if SHOW_FAMILYTREE
          @page = 6 if @page>6
        else
          @page = 5 if @page>5
        end
        if @page!=oldpage # Move to next page
          pbPlayCursorSE
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        # Family Tree compatibility
        if SHOW_FAMILYTREE
          @page = 6 if @page>6
        else
          @page = 5 if @page>5
        end
        if @page!=oldpage # Move to next page
          pbPlayCursorSE
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end


############[STORAGE SCREEN EDITS]##############################################
#===============================================================================
# PC Modifications - Storage Scene
#===============================================================================
# Allows birthsign tokens to be displayed in the PC storage window.
# Overwrites sections in PScreen_Storage.
#===============================================================================
class PokemonStorageScene
  
  def pbUpdateOverlay(selection,party=nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248,248,248)
    buttonshadow = Color.new(80,80,80)
    pbDrawTextPositions(overlay,[
       [_INTL("Party: {1}",(@storage.party.length rescue 0)),270,328,2,buttonbase,buttonshadow,1],
       [_INTL("Exit"),446,328,2,buttonbase,buttonshadow,1],
    ])
    pokemon = nil
    if @screen.pbHeldPokemon
      pokemon = @screen.pbHeldPokemon
    elsif selection>=0
      pokemon = (party) ? party[selection] : @storage[@storage.currentBox,selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    @sprites["pokemon"].z = 0
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    nonbase   = Color.new(208,208,208)
    nonshadow = Color.new(224,224,224)
    pokename = pokemon.name
    textstrings = [
       [pokename,10,8,false,base,shadow]
    ]
    if !pokemon.egg?
      imagepos = []
      if pokemon.isMale?
        textstrings.push([_INTL("♂"),148,8,false,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.isFemale?
        textstrings.push([_INTL("♀"),148,8,false,Color.new(248,56,32),Color.new(224,152,144)])
      end
      imagepos.push(["Graphics/Pictures/Storage/overlay_lv",6,246,0,0,-1,-1])
      textstrings.push([pokemon.level.to_s,28,234,false,base,shadow])
      if pokemon.ability>0
        textstrings.push([PBAbilities.getName(pokemon.ability),86,306,2,base,shadow])
      else
        textstrings.push([_INTL("No ability"),86,306,2,nonbase,nonshadow])
      end
      if pokemon.item>0
        textstrings.push([PBItems.getName(pokemon.item),86,342,2,base,shadow])
      else
        textstrings.push([_INTL("No item"),86,342,2,nonbase,nonshadow])
      end
      if pokemon.isShiny?
        imagepos.push(["Graphics/Pictures/shiny",156,198,0,0,-1,-1])
      end
      #=========================================================================
      # Birthsigns - Token Display
      #=========================================================================
      if pokemon.birthsign>0 && !(pokemon.isShadow? rescue false) && !pokemon.egg?
        imagepos.push(["Graphics/Pictures/Birthsigns/Other/storagesign",142,161,0,0,-1,-1])
        tokenpath1="Graphics/Pictures/Birthsigns/token%02d"
        tokenpath2="Graphics/Pictures/Birthsigns/bless_token%02d"
        if pokemon.isBlessed?
          zodiactoken=sprintf(tokenpath2,PBBirthsigns.signValue(pokemon.birthsign))
        else
          zodiactoken=sprintf(tokenpath1,PBBirthsigns.signValue(pokemon.birthsign))
        end
        imagepos.push([zodiactoken,139,157,0,0,-1,-1])
      end
      #=========================================================================
      # Shiny Leaf
      #=========================================================================
      if SHOW_SHINY_LEAF
        leaf="Graphics/Pictures/Birthsigns/Other/leaf"
        leafcrown="Graphics/Pictures/Birthsigns/Other/leafcrown"
        if pokemon.leafflag!=nil
          if pokemon.shinyleaf==6 || pokemon.shinyleaf>6
            imagepos.push([leafcrown,140,47,0,0,-1,-1])
          else
            imagepos.push([leaf,118,50,0,0,-1,-1]) if pokemon.shinyleaf>4
            imagepos.push([leaf,128,50,0,0,-1,-1]) if pokemon.shinyleaf>3
            imagepos.push([leaf,138,50,0,0,-1,-1]) if pokemon.shinyleaf>2
            imagepos.push([leaf,148,50,0,0,-1,-1]) if pokemon.shinyleaf>1
            imagepos.push([leaf,158,50,0,0,-1,-1]) if pokemon.shinyleaf>0
          end
        end
      end
      #=========================================================================
      # IV Star Gauge
      #=========================================================================
      if SHOW_IV_STARS
        nostar="Graphics/Pictures/Birthsigns/Other/starempty"
        lowstar="Graphics/Pictures/Birthsigns/Other/starlow"
        highstar="Graphics/Pictures/Birthsigns/Other/starhigh"
        perfectstar="Graphics/Pictures/Birthsigns/Other/starperfect"
        #HP
        if pokemon.iv[0]>30
          imagepos.push([perfectstar,8,198,0,0,-1,-1])
        elsif pokemon.iv[0]>29
          imagepos.push([highstar,8,198,0,0,-1,-1])
        elsif pokemon.iv[0]>0 && pokemon.iv[0]<30
          imagepos.push([lowstar,8,198,0,0,-1,-1])
        else
          imagepos.push([nostar,8,198,0,0,-1,-1])
        end
        #Atk
        if pokemon.iv[1]>30
          imagepos.push([perfectstar,24,198,0,0,-1,-1])
        elsif pokemon.iv[1]>29
          imagepos.push([highstar,24,198,0,0,-1,-1])
        elsif pokemon.iv[1]>0 && pokemon.iv[1]<30
          imagepos.push([lowstar,24,198,0,0,-1,-1])
        else
          imagepos.push([nostar,24,198,0,0,-1,-1])
        end
        #Def
        if pokemon.iv[2]>30
          imagepos.push([perfectstar,40,198,0,0,-1,-1])
        elsif pokemon.iv[2]>29
          imagepos.push([highstar,40,198,0,0,-1,-1])
        elsif pokemon.iv[2]>0 && pokemon.iv[2]<30
          imagepos.push([lowstar,40,198,0,0,-1,-1])
        else
          imagepos.push([nostar,40,198,0,0,-1,-1])
        end
        #SpAtk
        if pokemon.iv[4]>30
          imagepos.push([perfectstar,56,198,0,0,-1,-1])
        elsif pokemon.iv[4]>29
          imagepos.push([highstar,56,198,0,0,-1,-1])
        elsif pokemon.iv[4]>0 && pokemon.iv[4]<30
          imagepos.push([lowstar,56,198,0,0,-1,-1])
        else
          imagepos.push([nostar,56,198,0,0,-1,-1])
        end
        #SpDef
        if pokemon.iv[5]>30
          imagepos.push([perfectstar,72,198,0,0,-1,-1])
        elsif pokemon.iv[5]>29
          imagepos.push([highstar,72,198,0,0,-1,-1])
        elsif pokemon.iv[5]>0 && pokemon.iv[5]<30
          imagepos.push([lowstar,72,198,0,0,-1,-1])
        else
          imagepos.push([nostar,72,198,0,0,-1,-1])
        end
        #Speed
        if pokemon.iv[3]>30
          imagepos.push([perfectstar,88,198,0,0,-1,-1])
        elsif pokemon.iv[3]>29
          imagepos.push([highstar,88,198,0,0,-1,-1])
        elsif pokemon.iv[3]>0 && pokemon.iv[3]<30
          imagepos.push([lowstar,88,198,0,0,-1,-1])
        else
          imagepos.push([nostar,88,198,0,0,-1,-1])
        end
      end
      #=========================================================================
      typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      type1rect = Rect.new(0,pokemon.type1*28,64,28)
      type2rect = Rect.new(0,pokemon.type2*28,64,28)
      if pokemon.type1==pokemon.type2
        overlay.blt(52,272,typebitmap.bitmap,type1rect)
      else
        overlay.blt(18,272,typebitmap.bitmap,type1rect)
        overlay.blt(88,272,typebitmap.bitmap,type2rect)
      end
      drawMarkings(overlay,70,240,128,20,pokemon.markings)
      pbDrawImagePositions(overlay,imagepos)
    end
    pbDrawTextPositions(overlay,textstrings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)
  end
end


############[NPC TRAINERS EDITS]################################################
#===============================================================================
# NPC Trainers - Party birthsigns
#===============================================================================
# Allows you to give birthsigns to NPC trainers' Pokemon.
#
# In the Trainer PBS file, you may add birthsigns to a trainer's Pokemon as the
# 17th variable. Enter this sign in this format: "SIGN00" replacing the 00's
# with the number of your desired birthsign (01-33).
#
# If you equip the appropriate Zodiac Gem to one of these Pokemon, they will
# automatically activate its Zodiac Power on turn 1. Must have the Zodiac Power
# add-on script installed for this to occur.
#===============================================================================
TPBIRTHSIGN = 16
TPDYNAMAX   = 17 # Added for Dynamax
TPGMAX      = 18 # Added for Dynamax

module TrainersMetadata
  InfoTypes = {
    "Items"     => [0,           "eEEEEEEE", :PBItems, :PBItems, :PBItems, :PBItems,
                                             :PBItems, :PBItems, :PBItems, :PBItems],
    "Pokemon"   => [TPSPECIES,   "ev", :PBSpecies,nil],   # Species, level
    "Item"      => [TPITEM,      "e", :PBItems],
    "Moves"     => [TPMOVES,     "eEEE", :PBMoves, :PBMoves, :PBMoves, :PBMoves],
    "Ability"   => [TPABILITY,   "u"],
    "Gender"    => [TPGENDER,    "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                        "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
    "Form"      => [TPFORM,      "u"],
    "Shiny"     => [TPSHINY,     "b"],
    "Nature"    => [TPNATURE,    "e", :PBNatures],
    "IV"        => [TPIV,        "uUUUUU"],
    "Happiness" => [TPHAPPINESS, "u"],
    "Name"      => [TPNAME,      "s"],
    "Shadow"    => [TPSHADOW,    "b"],
    "Ball"      => [TPBALL,      "u"],
    "EV"        => [TPEV,        "uUUUUU"],
    "LoseText"  => [TPLOSETEXT,  "s"],
    "BirthSign" => [TPBIRTHSIGN, "u"]
  }
end

def pbLoadTrainer(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    if !hasConst?(PBTrainers,trainerid)
      raise _INTL("Trainer type does not exist ({1}, {2}, ID {3})",trainerid,trainername,partyid)
    end
    trainerid = getID(PBTrainers,trainerid)
  end
  success = false
  items = []
  party = []
  opponent = nil
  trainers = pbLoadTrainersData
  for trainer in trainers
    thistrainerid = trainer[0]
    name          = trainer[1]
    thispartyid   = trainer[4]
    next if thistrainerid!=trainerid || name!=trainername || thispartyid!=partyid
    # Found the trainer we want, load it up
    items = trainer[2].clone
    name = pbGetMessageFromHash(MessageTypes::TrainerNames,name)
    for i in RIVAL_NAMES
      next if !isConst?(trainerid,PBTrainers,i[0]) || !$game_variables[i[1]].is_a?(String)
      name = $game_variables[i[1]]
      break
    end
    loseText = pbGetMessageFromHash(MessageTypes::TrainerLoseText,trainer[5])
    opponent = PokeBattle_Trainer.new(name,thistrainerid)
    opponent.setForeignID($Trainer)
    # Load up each Pokémon in the trainer's party
    for poke in trainer[3]
      species = pbGetSpeciesFromFSpecies(poke[TPSPECIES])[0]
      level = poke[TPLEVEL]
      pokemon = pbNewPkmn(species,level,opponent,false)
      if poke[TPFORM]
        pokemon.forcedForm = poke[TPFORM] if MultipleForms.hasFunction?(pokemon.species,"getForm")
        pokemon.formSimple = poke[TPFORM]
      end
      pokemon.setItem(poke[TPITEM]) if poke[TPITEM]
      if poke[TPMOVES] && poke[TPMOVES].length>0
        for move in poke[TPMOVES]
          pokemon.pbLearnMove(move)
        end
      else
        pokemon.resetMoves
      end
      pokemon.setAbility(poke[TPABILITY] || 0)
      g = (poke[TPGENDER]) ? poke[TPGENDER] : (opponent.female?) ? 1 : 0
      pokemon.setGender(g)
      (poke[TPSHINY]) ? pokemon.makeShiny : pokemon.makeNotShiny
      n = (poke[TPNATURE]) ? poke[TPNATURE] : (pokemon.species+opponent.trainertype)%(PBNatures.maxValue+1)
      pokemon.setNature(n)
      for i in 0...6
        if poke[TPIV] && poke[TPIV].length>0
          pokemon.iv[i] = (i<poke[TPIV].length) ? poke[TPIV][i] : poke[TPIV][0]
        else
          pokemon.iv[i] = [level/2,PokeBattle_Pokemon::IV_STAT_LIMIT].min
        end
        if poke[TPEV] && poke[TPEV].length>0
          pokemon.ev[i] = (i<poke[TPEV].length) ? poke[TPEV][i] : poke[TPEV][0]
        else
          pokemon.ev[i] = [level*3/2,PokeBattle_Pokemon::EV_LIMIT/6].min
        end
      end
      pokemon.happiness = poke[TPHAPPINESS] if poke[TPHAPPINESS]
      pokemon.name = poke[TPNAME] if poke[TPNAME] && poke[TPNAME]!=""
      if poke[TPSHADOW]   # if this is a Shadow Pokémon
        pokemon.makeShadow rescue nil
        pokemon.pbUpdateShadowMoves(true) rescue nil
        pokemon.makeNotShiny
      end
      pokemon.ballused = poke[TPBALL] if poke[TPBALL]
      pokemon.setBirthsign(poke[TPBIRTHSIGN])
      pokemon.calcStats
      party.push(pokemon)
    end
    success = true
    break
  end
  return success ? [opponent,items,party,loseText] : nil
end


############[MISCELLANEOUS EDITS]###############################################
#===============================================================================
# Trainer Card
#===============================================================================
# Display's the trainer's birthsign on their trainer card.
#===============================================================================
class PokemonTrainerCard_Scene
  alias birthsigns_TrainerCard pbDrawTrainerCardFront
  def pbDrawTrainerCardFront
    birthsigns_TrainerCard
    #===========================================================================
    # Birthsign Token graphic
    #===========================================================================
    overlay = @sprites["overlay"].bitmap
    imagePositions = []
    tokenpath1="Graphics/Pictures/Birthsigns/token%02d"
    tokenpath2="Graphics/Pictures/Birthsigns/bless_token%02d"
    if $Trainer.isBlessed?
      zodiactoken=sprintf(tokenpath2,PBBirthsigns.signValue($Trainer.birthsign))
    else
      zodiactoken=sprintf(tokenpath1,PBBirthsigns.signValue($Trainer.birthsign))
    end
    imagePositions.push([zodiactoken,416+RXMOD+20,242,0,0,-1,-1])
    #===========================================================================
    pbDrawImagePositions(overlay,imagePositions)
  end
end

#===============================================================================
# Purify Shadow Pokemon
#===============================================================================
# Applies passive birthsign effects to a purified Shadow Pokemon if it was
# obtained through an egg.
#===============================================================================
alias birthsigns_purify pbPurify
def pbPurify(pokemon,scene)
  birthsigns_purify(pokemon,scene)
  #===========================================================================
  # Unlocks latent Birthsign on Shadow Pokemon
  #===========================================================================
  if pokemon.hasBirthsign?
    pokemon.applyBirthsignBonuses
    scene.pbDisplay(_INTL("{1} unlocked its birthsign!",pokemon.name))
    scene.pbDisplay(_INTL("{1} inherits the power of <c2=65467b14>{2}</c2>!",pokemon.name,pokemon.pbGetBirthsignName))
  end
  #===========================================================================
end

#===============================================================================
# Fling
#===============================================================================
# Allows Zodiac Gems to be used by the move Fling.
#===============================================================================
class PokeBattle_Move_0F7 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if attacker.item==0 ||
                   @battle.pbIsUnlosableItem(attacker,attacker.item) ||
                   pbIsPokeBall?(attacker.item) ||
                   @battle.field.effects[PBEffects::MagicRoom]>0 ||
                   attacker.hasWorkingAbility(:KLUTZ) ||
                   attacker.effects[PBEffects::Embargo]>0
    for i in flingarray.keys
      if flingarray[i]
        for j in flingarray[i]
          return false if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return false if pbIsBerry?(attacker.item) &&
                    !attacker.pbOpposing1.hasWorkingAbility(:UNNERVE) &&
                    !attacker.pbOpposing2.hasWorkingAbility(:UNNERVE)
    return false if pbIsMegaStone?(attacker.item) && !pbIsUnlosableItem(attacker,item)
    return false if pbIsZodiacGem?(attacker.item)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return 10 if pbIsBerry?(attacker.item)
    return 80 if pbIsMegaStone?(attacker.item) || pbIsZodiacGem?(attacker.item)
    for i in flingarray.keys
      if flingarray[i]
        for j in flingarray[i]
          return i if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return 1
  end
end

#===============================================================================
# Window Text
#===============================================================================
# Edits the color of window text to allow sign commands to appear grey/purple.
#===============================================================================
class Window_CommandPokemonColor < Window_CommandPokemon
  def drawItem(index,count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect = drawCursor(index,rect)
    base   = self.baseColor
    shadow = self.shadowColor
    if @colorKey[index] && @colorKey[index]==1
      base   = Color.new(0,80,160)
      shadow = Color.new(128,192,240)
    end
    #===========================================================================
    # Color coats birthsign commands
    #===========================================================================
    # Colors usable commands purple
    if @colorKey[index] && @colorKey[index]==2
      base   = Color.new(149,33,246)
      shadow = Color.new(261,161,326)
    end
    # Colors unusable commands grey
    if @colorKey[index] && @colorKey[index]==3
      base   = Color.new(184,184,184)
      shadow = Color.new(96,96,96)
    end
    #===========================================================================
    pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@commands[index],base,shadow)
  end
end

#===============================================================================
# New Zodiac
#===============================================================================
# Overwrites the default zodiac in PField_Time.
#===============================================================================
def zodiac(month,day)
  time=[
    1,1,1,31, 
    2,1,2,28,  
    3,1,3,31, 
    4,1,4,30,   
    5,1,5,31,   
    6,1,6,30,    
    7,1,7,31,   
    8,1,8,31,   
    9,1,9,30,    
    10,1,10,31, 
    11,1,11,30,
    12,1,12,31
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+2]
  end
  return 0
end

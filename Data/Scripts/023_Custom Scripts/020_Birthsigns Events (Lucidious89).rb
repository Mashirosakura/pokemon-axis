#===============================================================================
#
#  Birthsign Events - By Lucidious89
#  For -Pokémon Essentials v17-
#  Add-On for -Pokémon Birthsigns-
#
#===============================================================================
# This script is meant as an add-on to the Pokémon Birthsigns script.
# This may cause errors if Pokémon Birthsigns is not installed.
#===============================================================================
#  ~Installation~
#===============================================================================
# To install, insert a new section below PokemonBirthsigns (and above Main),
# and paste this script there. This is a plug-n-play addition, and doesn't
# require any other script changes.
#
# To set up a Birthsign Event, all you have to do is put this script in an event:
#   
#   pbBirthsignEvent(eventnum,monthnum)
#
# Set "eventnum" to the number associated with your desired event type.
# When set to 1, it will run the Birthstone event.
# When set to 2, it will run the Birthpath event.
# When set to 3, it will run the Celestial Boss event.
# When set to 4, it will run the Matchmaker event.
# When set to 5, it will run the Fortune Teller event.
# When set to 0, or left blank, it will default to a Birthstone event.
#
# Set "monthnum" to the desired month number (1-12) to select the particular sign
# for this event to check for. For example, setting "month" to 12 for a
# Birthstone event will give a Pokemon December's birthsign.
# Note: If you set "month" to 0, it will return a random month.
#       If left blank, it will return the current month.
#
# Control Self Switch A is automatically turned on once a Birthsign Event
# is completed.
#===============================================================================
# Everything below is written for Pokémon Essentials v.17
#===============================================================================
BIRTHSTONE    = false
BIRTHPATH     = false
CELESTIALBOSS = false
MATCHMAKER    = false
FORTUNETELLER = false

def pbBirthsignEvent(eventnum=nil,monthnum=nil)
  $game_variables[1]=-1
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  BIRTHSTONE==true if eventnum==1
  BIRTHPATH==true if eventnum==2
  CELESTIALBOSS==true if eventnum==3
  MATCHMAKER==true if eventnum==4
  FORTUNETELLER==true if eventnum==5
  TRAINERSIGN==true if eventnum==6
  monthnum=Time.now.mon if monthnum==nil
  monthnum=(1+rand(11)) if monthnum==0
  sign=$PokemonGlobal.zodiacset[monthnum-1]
  sprites={}
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites["ritual"] = IconSprite.new(0,0)
  sprites["token"] = IconSprite.new(207,142)
  sprites["token"].zoom_x=1.5
  sprites["token"].zoom_y=1.5
  case eventnum
  #=============================================================================
  # Birthstone Event (eventnum==1)
  #=============================================================================
  # Blesses a Pokemon with the birthsign associated with the chosen month. 
  #=============================================================================
  when nil,0,1
    sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    sprites["token"].setBitmap(sprintf(tokenpath,sign))
    Kernel.pbMessage(_INTL("The sign of <c2=65467b14>{1}</c2> is etched into the surface...",
    PBZodiacsigns.getName(monthnum)))
    pbWait(10)
    Kernel.pbMessage(_INTL("If a Pokémon communes with this stone, it may be blessed with the sign's power!"))
    if Kernel.pbConfirmMessage(_INTL("Commune with the zodiac stone?"))
      Kernel.pbMessage(_INTL("Choose a Pokémon to receive this blessing."))
      pbWait(5)
      sprites["token"].dispose
      sprites["ritual"].dispose
      pbChoosePokemon(1,3)
      poke=pbGetPokemon(1)
      pokename=$game_variables[3]
      if $game_variables[1]<0
        Kernel.pbMessage(_INTL("...but you decide to leave the zodiac stone alone."))
      elsif (poke.isShadow? rescue false)
        Kernel.pbMessage(_INTL("...but shadow Pokémon can't have zodiac signs!"))
      elsif poke.egg?
        Kernel.pbMessage(_INTL("...but eggs can't have zodiac signs!"))
      elsif poke.isCelestial?
        Kernel.pbMessage(_INTL("...but celestial Pokémon can't change zodiac signs!"))
      elsif poke.isBlessed?
        Kernel.pbMessage(_INTL("...but that Pokémon has already been blessed!"))
      elsif poke.getCalendarsign==monthnum
        Kernel.pbMessage(_INTL("...but that Pokémon already has the depicted zodiac sign!"))
      else
        Kernel.pbMessage(_INTL("Accepting this blessing will replace any current zodiac sign, and prevent {1} from receiving another blessing.",pokename))
        pbWait(10)
        if Kernel.pbConfirmMessage(_INTL("Are you sure you want to bless {1}?",pokename))
          Kernel.pbMessage(_INTL("{1} touched the zodiac stone and entered a trance!",pokename))
          pbRitualAnimation(poke)
          if poke.hasBirthsign?
            Kernel.pbMessage(_INTL("{1} lost the power of <c2=65467b14>{2}</c2>...",pokename,poke.pbGetBirthsignName))
          end
          Kernel.pbMessage(_INTL("And..."))
          pbWait(5)
          $game_screen.start_flash(Color.new(255,255,255,255), 20)
          pbMEPlay("Evolution success")
          Kernel.pbMessage(_INTL("\\se[]{1} was blessed with the power of <c2=65467b14>{2}</c2>!\\wt[80]",poke.name,PBZodiacsigns.getName(monthnum)))
          poke.setZodiacsign(monthnum)
          poke.applyBirthsignBonuses
          if poke.birthsign==7 || poke.birthsign==8
            poke.genderflag=nil
          elsif poke.birthsign==12 && !poke.isShiny?
            poke.makeShiny
          end
          poke.makeBlessed
          poke.calcStats
          pbWait(5)
          pbSetSelfSwitch(thisEvent.id,"A",true)
          if pbSetSelfSwitch(thisEvent.id,"A",true)
            Kernel.pbMessage(_INTL("With the ritual complete, the zodiac stone reverts to its dormant state."))
          end
        else
         Kernel.pbMessage(_INTL("...you decide to leave the zodiac stone alone."))
        end
      end
    else
      Kernel.pbMessage(_INTL("You decide to leave the zodiac stone alone."))  
    end
  #=============================================================================
  # Birthpath Event (eventnum==2)
  #=============================================================================
  # Opens up a path if a Pokemon with the chosen month's birthsign is selected.
  #=============================================================================
  when 2
    sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    sprites["token"].setBitmap(sprintf(tokenpath,sign))
    Kernel.pbMessage(_INTL("The sign of <c2=65467b14>{1}</c2> is etched into the surface...",
    PBZodiacsigns.getName(monthnum)))
    pbWait(10)
    Kernel.pbMessage(_INTL("If a Pokémon has this zodiac sign, it may uncover the secret hidden here!"))
    if Kernel.pbConfirmMessage(_INTL("Reveal the secret behind the ritual wall?"))
      Kernel.pbMessage(_INTL("Choose a Pokémon with the depicted zodiac sign."))
      pbWait(5)
      sprites["token"].dispose
      sprites["ritual"].dispose
      pbChoosePokemon(1,3)
      poke=pbGetPokemon(1)
      pokename=$game_variables[3]
      if $game_variables[1]<0
        Kernel.pbMessage(_INTL("...but you decide to leave the mysterious wall alone."))
        $game_variables[1]=-1
      elsif (poke.isShadow? rescue false)
        Kernel.pbMessage(_INTL("...but shadow Pokémon don't have zodiac signs!"))
        $game_variables[1]=-1
      elsif poke.egg?
        Kernel.pbMessage(_INTL("...but eggs don't have zodiac signs!"))
        $game_variables[1]=-1
      elsif poke.Calendarsign!=monthnum
        Kernel.pbMessage(_INTL("...but that Pokémon doesn't have the right zodiac sign!"))
        $game_variables[1]=-1
      else
        Kernel.pbMessage(_INTL("{1}'s presence causes the wall to react!",pokename))
        pbRitualAnimation(poke)
        Kernel.pbMessage(_INTL("{1} discovered an ancient passage!",pokename))
        pbSEPlay("Entering Door")
        $game_screen.start_flash(Color.new(255,255,255,255), 20)
        pbSetSelfSwitch(thisEvent.id,"A",true)
      end
    else
      Kernel.pbMessage(_INTL("You decide to leave the mysterious wall alone."))
    end
  #=============================================================================
  # Celestial Boss Event (eventnum==3)
  #=============================================================================
  # Initiates a battle with a Celestial Boss relative to the chosen month. 
  #============================================================================= 
  when 3
    sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    sprites["token"].setBitmap(sprintf(tokenpath,sign))
    Kernel.pbMessage(_INTL("The sign of <c2=65467b14>{1}</c2> is etched into the surface...",
    PBZodiacsigns.getName(monthnum)))
    pbWait(10)
    Kernel.pbMessage(_INTL("The markings indicate that this is a shrine to <c2=65467b14>{1}</c2>.",
    pbGetBossName(sign)))
    if PBDayNight.isNight? || $DEBUG
      Kernel.pbMessage(_INTL("If a Pokemon has this zodiac sign, perhaps it may draw out the guardian of this shrine."))
      if Kernel.pbConfirmMessage(_INTL("Should your Pokémon call to this shrine's guardian?"))
        Kernel.pbMessage(_INTL("Choose a Pokémon with the depicted zodiac sign."))
        pbWait(5)
        sprites["token"].dispose
        sprites["ritual"].dispose
        pbChoosePokemon(1,3)
        poke=pbGetPokemon(1)
        pokename=$game_variables[3]
        if $game_variables[1]<0
          Kernel.pbMessage(_INTL("...but you decide to leave the celestial shrine alone."))
          $game_variables[1]=-1
        elsif (poke.isShadow? rescue false)
          Kernel.pbMessage(_INTL("...but shadow Pokémon don't have zodiac signs!"))
          $game_variables[1]=-1
        elsif poke.egg?
          Kernel.pbMessage(_INTL("...but eggs don't have zodiac signs!"))
          $game_variables[1]=-1
        elsif poke.getCalendarsign!=monthnum
          Kernel.pbMessage(_INTL("...but that Pokémon doesn't have the right zodiac sign!"))
          $game_variables[1]=-1
        else
          # Species for each boss
          celestial=[:ARCEUS,:PIKACHU,:LUVDISC,:AMPHAROS,:LUXRAY,:EEVEE,:CHANSEY,
                   :GARDEVOIR,:GALLADE,:BEHEEYEM,:SNEASEL,:MUNCHLAX,:JIRACHI,
                   :HOOH,:SLOWKING,:KLEFKI,:MEOWTH,:AUDINO,:MEDICHAM,:SIGILYPH,
                   :SMEARGLE,:DARKRAI,:KANGASKHAN,:HOUNDOOM,:MEW,:KRICKETUNE,
                   :MESPRIT,:BRONZOR,:BISHARP,:SPINDA,:SHUCKLE,:GLISCOR,311, #Plusle
                   :HYPNO,:HONCHKROW,:SABLEYE,:CELEBI]
          # Boss levels - fluctuates based on player's badge count
          if $Trainer.numbadges>=8
            level=70
          elsif $Trainer.numbadges==7
            level=60
          elsif $Trainer.numbadges==6
            level=55
          elsif $Trainer.numbadges==5
            level=45
          elsif $Trainer.numbadges==4
            level=35 
          elsif $Trainer.numbadges==3
            level=30
          else
            level=25
          end
          pbRitualAnimation(poke)
          pbWait(60)
          Kernel.pbMessage(_INTL("...."))
          pbWait(30)
          cry=pbCryFile(celestial[poke.birthsign])
          pbSEPlay(cry,80,100) if cry
          Kernel.pbMessage(_INTL("\\se[]{1}'s call was answered!\\wt[20]",poke.name))
          pbWait(5)
          $game_switches[BOSS_SWITCH]=true
          pbCelestialBosses
          pbWait(5)
          $PokemonGlobal.nextBattleBGM="Celestial Battle"
          if poke.birthsign==32 
            pbDoubleWildBattle(celestial[poke.birthsign],level,
                               celestial[poke.birthsign]+1,level,1,false,true)
          else
            pbWildBattle(celestial[poke.birthsign],level,1,false,true)
          end
          $game_switches[BOSS_SWITCH]=false
          pbSetSelfSwitch(thisEvent.id,"A",true)
          if pbSetSelfSwitch(thisEvent.id,"A",true)
            if $game_variables[1]==4 || $game_variables[1]==1
              pbRegisterCelestial(monthnum-1,poke.birthsign)
            end
            Kernel.pbMessage(_INTL("After its guardian's appearance, this shrine no longer has any use."))
          end
        end
      else
        Kernel.pbMessage(_INTL("You decide to leave the celestial shrine alone."))
      end
    else
      pbWait(5)
      Kernel.pbMessage(_INTL("...but the shrine appears unresponsive right now."))
    end
  #=============================================================================
  # Matchmaker Event (eventnum==4)
  #=============================================================================
  # Matches up a Pokemon with the chosen month & rewards based on compatibility.
  #=============================================================================
  when 4
    Kernel.pbMessage(_INTL("Hiya!\nThey call me the Pokémon Matchmaker."))
    Kernel.pbMessage(_INTL("People come to me whenever they want to find new playmates for their Pokémon!"))
    Kernel.pbMessage(_INTL("Pairing up Pokémon based on their zodiac sign is a sure-fire way of knowing they'll get along."))
    Kernel.pbMessage(_INTL("That's just science!"))
    Kernel.pbMessage(_INTL("Right now, my buddy is looking for a Pokémon that pairs well with those that have this zodiac sign:"))
    sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    sprites["token"].setBitmap(sprintf(tokenpath,sign))
    pbWait(100)
    sprites["token"].dispose
    sprites["ritual"].dispose
    if Kernel.pbConfirmMessage(_INTL("Would you happen to have a Pokémon that would want to play?"))
      Kernel.pbMessage(_INTL("Excellent! Show me who would get along with my buddy's Pokémon!"))
      pbChoosePokemon(1,3)
      poke=pbGetPokemon(1)
      pokename=$game_variables[3]
      if $game_variables[1]<0
        Kernel.pbMessage(_INTL("Aww, change of heart, huh? No problem, come back some other time!"))
      elsif (poke.isShadow? rescue false)
        Kernel.pbMessage(_INTL("Hmm...no offence, but that Pokémon doesn't look very friendly."))
        Kernel.pbMessage(_INTL("Come back with a Pokémon that would like to play."))
      elsif poke.egg?
        Kernel.pbMessage(_INTL("Whoa there! An egg is way too fragile to be played with!"))
      else
        Kernel.pbMessage(_INTL("Aw yeah! Your {1} looks like it's raring to go!",pokename))
        Kernel.pbMessage(_INTL("Let me introduce it to my buddy's Pokémon!"))
        pbFadeOutIn(99999){pbWait(80)}
        if poke.hasPartnersign?(monthnum)
          Kernel.pbMessage(_INTL("Wow! They got along great! {1} looks overjoyed!",pokename))
          Kernel.pbMessage(_INTL("Another successful matchmaking by yours truly!"))
          pbWait(20)
          Kernel.pbMessage(_INTL("Oh? {1} seems to have come back with something...",pokename))
          getitem = [:LUCKYEGG,:DESTINYKNOT,:POWERWEIGHT,:POWERBRACER,:POWERLENS,
                     :POWERBAND,:POWERANKLET,:MACHOBRACE,:RARECANDY,:HEARTSCALE]
          Kernel.pbReceiveItem(getitem[rand(9)],1)
          poke.changeHappiness("groom")
        elsif poke.getCalendarsign==monthnum
          Kernel.pbMessage(_INTL("It seems like they got along fine, but they got bored of each other pretty fast."))
          Kernel.pbMessage(_INTL("I guess it's not as exciting to meet others who are just like yourself. Variety is the spice of life!"))
          pbWait(20)
          Kernel.pbMessage(_INTL("Oh? {1} seems to have come back with something...",pokename))
          getitem = [:LAXINCENSE,:FULLINCENSE,:LUCKINCENSE,:PUREINCENSE,:SEAINCENSE,
                     :WAVEINCENSE,:ROSEINCENSE,:ROCKINCENSE,:ODDINCENSE]
          Kernel.pbReceiveItem(getitem[rand(8)],1)
          poke.changeHappiness("levelup")
        elsif poke.hasRivalsign?(monthnum)
          Kernel.pbMessage(_INTL("Oh dear. That could have gone better. {1} didn't seem to like its playmate at all...",pokename))
          Kernel.pbMessage(_INTL("Try bringing a Pokémon with a sign that better matches its playmate next time. I've got a reputation to uphold!"))
          pbWait(20)
          Kernel.pbMessage(_INTL("{1} seems to have come back with something...",pokename))
          getitem = [:TOXICORB,:FLAMEORB,:STICKYBARB,:POISONBARB]
          Kernel.pbReceiveItem(getitem[rand(3)],1)
          poke.changeHappiness("revivalherb")
        else
          Kernel.pbMessage(_INTL("{1} didn't really seem to have much in common with its playmate...",pokename))
          Kernel.pbMessage(_INTL("Oh well, can't win 'em all I suppose."))
        end
        pbWait(5)
        pbSetSelfSwitch(thisEvent.id,"A",true)
        if pbSetSelfSwitch(thisEvent.id,"A",true)
          Kernel.pbMessage(_INTL("Come back another time and I'm sure I'll have a new Pokémon lined up looking to play!"))
        end
      end
    else
      Kernel.pbMessage(_INTL("Aww, it's ok. Come back if you want to arrange a Poké-Playdate!"))
    end
  #=============================================================================
  # Fortune Teller Event (eventnum==5)
  #============================================================================= 
  when 5
    Kernel.pbMessage(_INTL("Hello, I'm the Fortune Teller."))
    Kernel.pbMessage(_INTL("I can read the stars and make predictions of your future!"))
    if $Trainer.hasZodiacsign?
      trainermonth=$Trainer.getCalendarsign
      trainersign=$PokemonGlobal.zodiacset[$Trainer.monthsign]
      rival=$Trainer.getRivalsign
      partner1=$Trainer.getPartnersign(1)
      partner2=$Trainer.getPartnersign(2)
      if Kernel.pbConfirmMessage(_INTL("Would you like to hear more?"))
        Kernel.pbMessage(_INTL("Of course!"))
        Kernel.pbMessage(_INTL("Ah! I can sense that you have the sign of <c2=65467b14>{1}</c2>!",PBZodiacsigns.getName(trainermonth)))
        if Kernel.pbConfirmMessage(_INTL("Would you like me to take your reading?"))
          Kernel.pbMessage(_INTL("I knew you'd agree! Now, let me see..."))
          $PokemonGlobal.fortuneEqual=false
          $PokemonGlobal.fortuneGood=false
          $PokemonGlobal.fortuneBad=false
          pbFadeOutIn(99999){
            pbWait(10)
            sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
            tokenpath="Graphics/Pictures/Birthsigns/token%02d"
            sprites["token"].setBitmap(sprintf(tokenpath,trainersign))
          }
          pbWait(10)
          Kernel.pbMessage(_INTL("Hmm..."))
          pbWait(20)
          Kernel.pbMessage(_INTL("Yes! I see it!"))
          Kernel.pbMessage(_INTL("Right now, the sign of <c2=65467b14>{1}</c2> is shining brightest in the stars.",PBZodiacsigns.getName(monthnum)))
          if trainermonth==monthnum
            Kernel.pbMessage(_INTL("This is good news for you!"))
            Kernel.pbMessage(_INTL("I foresee future meetings with Pokémon that are very similar to yourself!"))
            pbActivateFortuneEffect
            $PokemonGlobal.fortuneEqual=true
          elsif $Trainer.hasPartnersign?(monthnum)
            Kernel.pbMessage(_INTL("This is wonderful news for you!"))
            Kernel.pbMessage(_INTL("I foresee future meetings with Pokémon that you'll get along with very well!"))
            pbActivateFortuneEffect
            $PokemonGlobal.fortuneGood=true
          elsif $Trainer.hasRivalsign?(monthnum)
            Kernel.pbMessage(_INTL("This does not bode well for you..."))
            Kernel.pbMessage(_INTL("I foresee future meetings with Pokémon that you'll have trouble getting along with."))
            pbActivateFortuneEffect
            $PokemonGlobal.fortuneBad=true
          else
            Kernel.pbMessage(_INTL("This doesn't seem to influence you one way or the other..."))
          end
          Kernel.pbMessage(_INTL("I think you will find the best friendships with those born in the months of <c2=65467b14>{1}</c2> or <c2=65467b14>{2}</c2>.",
          pbGetMonthName(partner1),pbGetMonthName(partner2)))
          Kernel.pbMessage(_INTL("But be careful! Those born in <c2=65467b14>{1}</c2> will be difficult to get along with.",pbGetMonthName(rival)))
          Kernel.pbMessage(_INTL("This is all that I'm able to see..."))
          pbFadeOutIn(99999){
            pbWait(10)
            sprites["token"].dispose
            sprites["ritual"].dispose
          }
          if defined?(INCLUDEZPOWER)
            Kernel.pbMessage(_INTL("Thanks for listening, I want you to have this."))
            Kernel.pbReceiveItem(getZodiacGem(monthnum-1),1)
          end
          Kernel.pbMessage(_INTL("I hope this information proves useful on your journey."))
          pbWait(5)
          pbSetSelfSwitch(thisEvent.id,"A",true)
          if pbSetSelfSwitch(thisEvent.id,"A",true)
            Kernel.pbMessage(_INTL("Please visit me again for your next reading!"))
          end
        else
          Kernel.pbMessage(_INTL("Do not worry, the stars shall lead your way back to me."))
        end
      else
        Kernel.pbMessage(_INTL("Ehem...yes. I could foresee that you'd say that."))
      end
    else
      Kernel.pbMessage(_INTL("Hmm...nevermind. I don't sense that you're the sort that would get anything from this."))
    end
  #=============================================================================
  end
  sprites["token"].dispose
  sprites["ritual"].dispose
  BIRTHSTONE==false
  BIRTHPATH==false
  CELESTIALBOSS==false
  MATCHMAKER==false
  FORTUNETELLER==false
end

#===============================================================================
# Celestial Bosses - Boss List
#===============================================================================
def pbCelestialBosses
  Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon=e[0]
  if $game_switches[BOSS_SWITCH]
    pokemon.iv=[31,31,31,31,31,31]
    if isConst?(pokemon.species,PBSpecies,:ARCEUS)
      pokemon.setBirthsign(0)
      pokemon.name=pbGetBossName(0)
      pokemon.setNature(:SERIOUS)
      pokemon.ev=[252,126,0,6,126,0]
      pokemon.celestial=true
      pokemon.forcedForm=30
      pokemon.form=30
    elsif isConst?(pokemon.species,PBSpecies,:PIKACHU)
      pokemon.setBirthsign(1)
      pokemon.name=pbGetBossName(1)
      pokemon.setNature(:HASTY)
      pokemon.makeMale
      pokemon.ev=[6,252,0,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:LUVDISC)
      pokemon.setBirthsign(2)
      pokemon.name=pbGetBossName(2)
      pokemon.setNature(:BOLD)
      pokemon.makeFemale
      pokemon.ev=[126,0,252,6,126,0]
    elsif isConst?(pokemon.species,PBSpecies,:AMPHAROS)
      pokemon.setBirthsign(3)
      pokemon.name=pbGetBossName(3)
      pokemon.setNature(:QUIET)
      pokemon.makeFemale
      pokemon.ev=[252,0,6,0,252,0]
    elsif isConst?(pokemon.species,PBSpecies,:LUXRAY)
      pokemon.setBirthsign(4)
      pokemon.name=pbGetBossName(4)
      pokemon.setNature(:NAUGHTY)
      pokemon.makeMale
      pokemon.ev=[0,252,6,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:EEVEE)
      pokemon.setBirthsign(5)
      pokemon.name=pbGetBossName(5)
      pokemon.setNature(:TIMID)
      pokemon.makeMale
      pokemon.ev=[6,0,0,252,252,0]
    elsif isConst?(pokemon.species,PBSpecies,:CHANSEY)
      pokemon.setBirthsign(6)
      pokemon.name=pbGetBossName(6)
      pokemon.setNature(:BOLD)
      pokemon.makeFemale
      pokemon.ev=[126,0,252,6,126,0]
    elsif isConst?(pokemon.species,PBSpecies,:GARDEVOIR)
      pokemon.setBirthsign(7)
      pokemon.name=pbGetBossName(7)
      pokemon.setNature(:MODEST)
      pokemon.makeFemale
      pokemon.ev=[0,0,0,252,252,6]
    elsif isConst?(pokemon.species,PBSpecies,:GALLADE)
      pokemon.setBirthsign(8)
      pokemon.name=pbGetBossName(8)
      pokemon.setNature(:ADAMANT)
      pokemon.makeMale
      pokemon.ev=[0,252,6,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:BEHEEYEM)
      pokemon.setBirthsign(9)
      pokemon.name=pbGetBossName(9)
      pokemon.setNature(:QUIET)
      pokemon.setGender(2)
      pokemon.ev=[252,0,6,0,252,0]
    elsif isConst?(pokemon.species,PBSpecies,:SNEASEL)
      pokemon.setBirthsign(10)
      pokemon.name=pbGetBossName(10)
      pokemon.setNature(:JOLLY)
      pokemon.makeMale
      pokemon.ev=[0,252,6,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:MUNCHLAX)
      pokemon.setBirthsign(11)
      pokemon.name=pbGetBossName(11)
      pokemon.setNature(:RELAXED)
      pokemon.makeMale
      pokemon.ev=[126,252,126,0,0,6]
    elsif isConst?(pokemon.species,PBSpecies,:JIRACHI)
      pokemon.setBirthsign(12)
      pokemon.name=pbGetBossName(12)
      pokemon.setNature(:NAIVE)
      pokemon.makeMale
      pokemon.ev=[0,252,6,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:HOOH)
      pokemon.setBirthsign(13)
      pokemon.name=pbGetBossName(13)
      pokemon.setNature(:BOLD)
      pokemon.makeMale
      pokemon.ev=[252,0,126,6,126,0]
    elsif isConst?(pokemon.species,PBSpecies,:SLOWKING)
      pokemon.setBirthsign(14)
      pokemon.name=pbGetBossName(14)
      pokemon.setNature(:RELAXED)
      pokemon.makeMale
      pokemon.ev=[252,0,126,0,126,6]
    elsif isConst?(pokemon.species,PBSpecies,:KLEFKI)
      pokemon.setBirthsign(15)
      pokemon.name=pbGetBossName(15)
      pokemon.setNature(:HASTY)
      pokemon.makeFemale
      pokemon.ev=[252,0,126,6,0,126]
    elsif isConst?(pokemon.species,PBSpecies,:MEOWTH)
      pokemon.setBirthsign(16)
      pokemon.name=pbGetBossName(16)
      pokemon.setNature(:HASTY)
      pokemon.makeFemale
      pokemon.ev=[0,252,0,252,0,6]
    elsif isConst?(pokemon.species,PBSpecies,:AUDINO)
      pokemon.setBirthsign(17)
      pokemon.name=pbGetBossName(17)
      pokemon.setNature(:BOLD)
      pokemon.makeFemale
      pokemon.ev=[126,0,252,6,126,0]
    elsif isConst?(pokemon.species,PBSpecies,:MEDICHAM)
      pokemon.setBirthsign(18)
      pokemon.name=pbGetBossName(18)
      pokemon.setNature(:TIMID)
      pokemon.makeFemale
      pokemon.ev=[126,0,126,252,0,6]
    elsif isConst?(pokemon.species,PBSpecies,:SIGILYPH)
      pokemon.setBirthsign(19)
      pokemon.name=pbGetBossName(19)
      pokemon.setNature(:CALM)
      pokemon.setGender(2)
      pokemon.ev=[252,0,126,6,0,126]
    elsif isConst?(pokemon.species,PBSpecies,:SMEARGLE)
      pokemon.setBirthsign(20)
      pokemon.name=pbGetBossName(20)
      pokemon.setNature(:HASTY)
      pokemon.makeMale
      pokemon.ev=[126,0,0,252,126,6]
    elsif isConst?(pokemon.species,PBSpecies,:DARKRAI)
      pokemon.setBirthsign(21)
      pokemon.name=pbGetBossName(21)
      pokemon.setNature(:TIMID)
      pokemon.makeMale
      pokemon.ev=[0,0,0,252,252,6]
    elsif isConst?(pokemon.species,PBSpecies,:KANGASKHAN)
      pokemon.setBirthsign(22)
      pokemon.name=pbGetBossName(22)
      pokemon.setNature(:ADAMANT)
      pokemon.makeFemale
      pokemon.ev=[252,252,6,0,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:HOUNDOOM)
      pokemon.setBirthsign(23)
      pokemon.name=pbGetBossName(23)
      pokemon.setNature(:LONELY)
      pokemon.makeMale
      pokemon.ev=[0,252,0,252,6,0]
    elsif isConst?(pokemon.species,PBSpecies,:MEW)
      pokemon.setBirthsign(24)
      pokemon.name=pbGetBossName(24)
      pokemon.setNature(:QUIRKY)
      pokemon.makeMale
      pokemon.ev=[126,126,6,126,126,0]
    elsif isConst?(pokemon.species,PBSpecies,:KRICKETUNE)
      pokemon.setBirthsign(25)
      pokemon.name=pbGetBossName(25)
      pokemon.setNature(:TIMID)
      pokemon.makeMale
      pokemon.ev=[0,0,6,252,252,0]
    elsif isConst?(pokemon.species,PBSpecies,:MESPRIT)
      pokemon.setBirthsign(26)
      pokemon.name=pbGetBossName(26)
      pokemon.setNature(:TIMID)
      pokemon.makeFemale
      pokemon.ev=[126,0,126,6,126,126]
    elsif isConst?(pokemon.species,PBSpecies,:BRONZOR)
      pokemon.setBirthsign(27)
      pokemon.name=pbGetBossName(27)
      pokemon.setNature(:QUIET)
      pokemon.setGender(2)
      pokemon.ev=[252,0,0,0,252,6]
    elsif isConst?(pokemon.species,PBSpecies,:BISHARP)
      pokemon.setBirthsign(28)
      pokemon.name=pbGetBossName(28)
      pokemon.setNature(:ADAMANT)
      pokemon.makeMale
      pokemon.ev=[126,252,6,126,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:SPINDA)
      pokemon.setBirthsign(29)
      pokemon.name=pbGetBossName(29)
      pokemon.setNature(:NAIVE)
      pokemon.makeFemale
      pokemon.ev=[252,126,6,126,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:SHUCKLE)
      pokemon.setBirthsign(30)
      pokemon.name=pbGetBossName(30)
      pokemon.setNature(:RELAXED)
      pokemon.makeMale
      pokemon.ev=[252,0,126,0,6,126]
    elsif isConst?(pokemon.species,PBSpecies,:GLISCOR)
      pokemon.setBirthsign(31)
      pokemon.name=pbGetBossName(31)
      pokemon.setNature(:JOLLY)
      pokemon.makeMale
      pokemon.ev=[126,126,126,126,0,6]
    elsif isConst?(pokemon.species,PBSpecies,:PLUSLE)
      pokemon.setBirthsign(32)
      pokemon.name=pbGetDoubleBoss(0)
      pokemon.setNature(:HASTY)
      pokemon.makeFemale
      pokemon.ev=[126,0,0,252,126,6]
    elsif isConst?(pokemon.species,PBSpecies,:MINUN)
      pokemon.setBirthsign(32)
      pokemon.name=pbGetDoubleBoss(1)
      pokemon.setNature(:NAIVE)
      pokemon.makeMale
      pokemon.ev=[126,126,6,252,0,0]
    elsif isConst?(pokemon.species,PBSpecies,:HYPNO)
      pokemon.setBirthsign(33)
      pokemon.name=pbGetBossName(33) 
      pokemon.setNature(:BOLD)
      pokemon.makeMale
      pokemon.ev=[126,0,126,0,252,6]
    elsif isConst?(pokemon.species,PBSpecies,:HONCHKROW)
      pokemon.setBirthsign(34)
      pokemon.name=pbGetBossName(34)
      pokemon.setNature(:BRAVE)
      pokemon.makeMale
      pokemon.ev=[252,126,126,0,0,6]
    elsif isConst?(pokemon.species,PBSpecies,:SABLEYE)
      pokemon.setBirthsign(35)
      pokemon.name=pbGetBossName(35) 
      pokemon.setNature(:HASTY)
      pokemon.makeFemale
      pokemon.ev=[6,126,0,126,126,126]
    elsif isConst?(pokemon.species,PBSpecies,:CELEBI)
      pokemon.setBirthsign(36)
      pokemon.name=pbGetBossName(36) 
      pokemon.setNature(:MILD)
      pokemon.makeFemale
      pokemon.ev=[6,0,0,252,126,126]
    end
    if isConst?(pokemon.species,PBSpecies,:ARCEUS)
      pokemon.setItem(:DIVINEPLATE)
      pokemon.setItem(:STARPIECE) if pokemon.item==nil
    else
      pokemon.setItem(:STARDUST)
      pokemon.setItem(getZodiacGem(pokemon.monthsign)) if defined?(INCLUDEZPOWER)
    end
    pokemon.obtainText=_INTL("Celestial Shrine.")
    pokemon.ot=pokemon.name
    pokemon.otgender=pokemon.gender
    pokemon.trainerID=$Trainer.getForeignID
    pokemon.makeNotShiny
    pokemon.makeCelestial
    pokemon.resetMoves
    pokemon.calcStats
  end
}
end

# Allows Arceus to spawn with the omega form
MultipleForms.register(:ARCEUS,{
"getForm"=>proc{|pokemon|
    next 30 if pokemon.celestial==true
    next 0
}
})

#===============================================================================
# Celestial Bosses - Skips nicknaming prompt after capture.
#===============================================================================
module PokeBattle_BattleCommon
  def pbStorePokemon(pokemon)
    if !(pokemon.isShadow? rescue false) && !pokemon.isCelestial?
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
        species=PBSpecies.getName(pokemon.species)
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),pokemon)
        pokemon.name=nickname if nickname!=""
      end
    end
    oldcurbox=@peer.pbCurrentBox()
    storedbox=@peer.pbStorePokemon(self.pbPlayer,pokemon)
    creator=@peer.pbGetStorageCreator()
    return if storedbox<0
    curboxname=@peer.pbBoxName(oldcurbox)
    boxname=@peer.pbBoxName(storedbox)
    if storedbox!=oldcurbox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curboxname,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curboxname))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pokemon.name,boxname))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pokemon.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pokemon.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxname))
    end
  end
end

#===============================================================================
# Celestial Bosses - Redundancy to prevent evolution.
#===============================================================================
def pbCheckEvolutionEx(pokemon)
  return -1 if pokemon.species<=0 || pokemon.egg? || pokemon.isCelestial?
  return -1 if isConst?(pokemon.item,PBItems,:EVERSTONE)
  return -1 if isConst?(pokemon.species,PBSpecies,:PICHU) && pokemon.form==1
  ret=-1
  for form in pbGetEvolvedFormData(pbGetFSpeciesFromForm(pokemon.species,pokemon.form))
    ret = yield pokemon,form[0],form[1],form[2]
    break if ret>0
  end
  return ret
end

############[OTHER EVENTS]######################################################
#===============================================================================
# Celestial Bosses - Omega Battle
#===============================================================================
def pbOmegaBoss
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  sprites={}
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  sprites["ritual"] = IconSprite.new(0,0)
  if getBossNum<11
    Kernel.pbMessage(_INTL("This appears to be a celestial shrine, but it's marked with all twelve zodiac signs."))
    Kernel.pbMessage(_INTL("You can make out only a single faded word...<c2=65467b14>{1}</c2>.",pbGetBossName(0)))
  else
    cry=pbCryFile(:ARCEUS)
    Kernel.pbMessage(_INTL("...huh?"))
    pbWait(5)
    $game_screen.start_flash(Color.new(255,255,255,255), 20)
    pbWait(5)
    $game_screen.start_flash(Color.new(255,255,255,255), 40)
    pbWait(5)
    Kernel.pbMessage(_INTL("The celestial shrine appears to be glowing!"))
    pbWait(5)
    $game_screen.start_flash(Color.new(255,255,255,255), 80)
    Kernel.pbMessage(_INTL("All 12 zodiac signs etched into its surface begin to react to you!"))
    pbWait(5)
    $game_screen.start_flash(Color.new(255,255,255,255), 100)
    sprites["ritual"].setBitmap("Graphics/Pictures/Birthsigns/Other/ritualoverlay")
    tokenpath="Graphics/Pictures/Birthsigns/bless_token%02d"
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[0])))
    sprites["jan"] = IconSprite.new(221,-6)
    sprites["jan"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[0]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[1])))
    sprites["feb"] = IconSprite.new(300,19)
    sprites["feb"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[1]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[2])))
    sprites["mar"] = IconSprite.new(361,77)
    sprites["mar"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[2]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[3])))
    sprites["apr"] = IconSprite.new(382,157)
    sprites["apr"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[3]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[4])))
    sprites["may"] = IconSprite.new(361,236)
    sprites["may"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[4]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[5])))
    sprites["jun"] = IconSprite.new(300,295)
    sprites["jun"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[5]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[6])))
    sprites["jul"] = IconSprite.new(221,320)
    sprites["jul"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[6]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[7])))
    sprites["aug"] = IconSprite.new(142,295)
    sprites["aug"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[7]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[8])))
    sprites["sep"] = IconSprite.new(81,236)
    sprites["sep"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[8]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[9])))
    sprites["oct"] = IconSprite.new(60,157)
    sprites["oct"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[9]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[10])))
    sprites["nov"] = IconSprite.new(81,78)
    sprites["nov"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[10]))
    pbWait(5)
    Kernel.pbMessage(_INTL("<ac><c2=65467b14>{1}</c2></ac>",pbGetBossName($PokemonGlobal.zodiacset[11])))
    sprites["dec"] = IconSprite.new(142,19)
    sprites["dec"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[11]))
    pbWait(5)
    Kernel.pbMessage(_INTL("The spirits of all the celestials seem to be calling out to something!"))
    $game_screen.start_flash(Color.new(255,255,255,255), 40)
    sprites["omega"] = IconSprite.new(0,0)
    sprites["omega"].setBitmap("Graphics/Pictures/Birthsigns/Other/omega")
    pbSEPlay(cry,80,100)
    $game_screen.start_flash(Color.new(255,255,255,255), 40)
    pbWait(60)
    Kernel.pbMessage(_INTL("...."))
    pbWait(30)
    pbSEPlay(cry,80,100)
    Kernel.pbMessage(_INTL("\\se[]An immense force approaches you!\\wt[20]"))
    pbWait(5)
    $game_switches[BOSS_SWITCH]=true
    pbCelestialBosses
    $PokemonGlobal.nextBattleBGM="Omega Battle"
    pbWildBattle(:ARCEUS,85,1,false,true)
    $game_switches[BOSS_SWITCH]=false
    pbFadeOutIn(99999) {
    sprites["jan"].dispose
    sprites["feb"].dispose
    sprites["mar"].dispose
    sprites["apr"].dispose
    sprites["may"].dispose
    sprites["jun"].dispose
    sprites["jul"].dispose
    sprites["aug"].dispose
    sprites["sep"].dispose
    sprites["oct"].dispose
    sprites["nov"].dispose
    sprites["dec"].dispose
    sprites["omega"].dispose
    sprites["ritual"].dispose
    }
    pbSetSelfSwitch(thisEvent.id,"A",true)
    if pbSetSelfSwitch(thisEvent.id,"A",true)
      if $game_variables[1]==4 || $game_variables[1]==1
        $PokemonGlobal.omegaboss=true
      end
      Kernel.pbMessage(_INTL("With <c2=65467b14>{1}</c2>'s presence removed, all the energy radiating from this shrine vanished...",pbGetBossName(0)))
    end
  end
end

#===============================================================================
# Legendary Breeding - Forming eggs with Arceus
#===============================================================================
def pbArceusEggSpawn
  if Kernel.pbConfirmMessage(_INTL("Would you like a Pokémon to form an egg?"))
    if $Trainer.party.length>=6
      Kernel.pbMessage(_INTL("There isn't enough space to carry an egg!"))
    else
      Kernel.pbMessage(_INTL("Please select a Pokémon."))
      pbChoosePokemon(1,3)
      poke=pbGetPokemon(1)
      if isConst?(poke.species,PBSpecies,:ARCEUS)
        if poke.egg?
          Kernel.pbMessage(_INTL("That Pokémon must be hatched before it can form an egg."))
        elsif (poke.isShadow? rescue false)
          Kernel.pbMessage(_INTL("{1} must be purified before it can form an egg.",poke.name))
        # Creates a Dialga egg
        elsif isConst?(poke.item,PBItems,:ADAMANTORB)
          Kernel.pbMessage(_INTL("{1} is radiating a mysterious energy...",poke.name))
          if Kernel.pbConfirmMessage(_INTL("Should {1} create an egg?",poke.name))
            pbRitualAnimation(poke)
            pbGenerateEgg(:DIALGA,_I("A Divine Force."))
            pkmn=$Trainer.lastParty
            pkmn.setItem(:ADAMANTORB)
            if poke.ballused!=4 && poke.ballused!=15
              pkmn.ballused=poke.ballused
            end
            pkmn.setNature(poke.nature) if rand(10)<5
            pkmn.iv[0]=poke.iv[0] if rand(10)<8
            pkmn.iv[1]=poke.iv[1] if rand(10)<8
            pkmn.iv[2]=poke.iv[2] if rand(10)<8
            pkmn.iv[3]=poke.iv[3] if rand(10)<8
            pkmn.iv[4]=poke.iv[4] if rand(10)<8
            pkmn.iv[5]=poke.iv[5] if rand(10)<8
            pbWait(1)
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",poke.name))
            pbWait(5)
            Kernel.pbMessage(_INTL("{1}'s {2} fused with the egg!",
            poke.name,PBItems.getName(poke.item)))
            poke.item=0
          else
            Kernel.pbMessage(_INTL("You decided not to form an egg."))
          end
        # Creates a Palkia egg
        elsif isConst?(poke.item,PBItems,:LUSTROUSORB)
          Kernel.pbMessage(_INTL("{1} is radiating a mysterious energy...",poke.name))
          if Kernel.pbConfirmMessage(_INTL("Should {1} create an egg?",poke.name))
            pbRitualAnimation(poke)
            pbGenerateEgg(:PALKIA,_I("A Divine Force."))
            pkmn=$Trainer.lastParty
            pkmn.setItem(:LUSTROUSORB)
            if poke.ballused!=4 && poke.ballused!=15
              pkmn.ballused=poke.ballused
            end
            pkmn.setNature(poke.nature) if rand(10)<5
            pkmn.iv[0]=poke.iv[0] if rand(10)<8
            pkmn.iv[1]=poke.iv[1] if rand(10)<8
            pkmn.iv[2]=poke.iv[2] if rand(10)<8
            pkmn.iv[3]=poke.iv[3] if rand(10)<8
            pkmn.iv[4]=poke.iv[4] if rand(10)<8
            pkmn.iv[5]=poke.iv[5] if rand(10)<8
            pbWait(1)
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",poke.name))
            pbWait(5)
            Kernel.pbMessage(_INTL("{1}'s {2} fused with the egg!",
            poke.name,PBItems.getName(poke.item)))
            poke.item=0
          else
            Kernel.pbMessage(_INTL("You decided not to form an egg."))
          end
        # Creates a Giratina egg
        elsif isConst?(poke.item,PBItems,:GRISEOUSORB)
          Kernel.pbMessage(_INTL("{1} is radiating a mysterious energy...",poke.name))
          if Kernel.pbConfirmMessage(_INTL("Should {1} create an egg?",poke.name))
            pbRitualAnimation(poke)
            pbGenerateEgg(:GIRATINA,_I("A Divine Force."))
            pkmn=$Trainer.lastParty
            pkmn.setItem(:GRISEOUSORB)
            if poke.ballused!=4 && poke.ballused!=15
              pkmn.ballused=poke.ballused
            end
            pkmn.setNature(poke.nature) if rand(10)<5
            pkmn.iv[0]=poke.iv[0] if rand(10)<8
            pkmn.iv[1]=poke.iv[1] if rand(10)<8
            pkmn.iv[2]=poke.iv[2] if rand(10)<8
            pkmn.iv[3]=poke.iv[3] if rand(10)<8
            pkmn.iv[4]=poke.iv[4] if rand(10)<8
            pkmn.iv[5]=poke.iv[5] if rand(10)<8
            pbWait(1)
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",poke.name))
            pbWait(5)
            Kernel.pbMessage(_INTL("{1}'s {2} fused with the egg!",
            poke.name,PBItems.getName(poke.item)))
            poke.item=0
          else
            Kernel.pbMessage(_INTL("You decided not to form an egg."))
          end
        # Creates an Arceus egg
        elsif isConst?(poke.item,PBItems,:DIVINEPLATE)
          Kernel.pbMessage(_INTL("{1} is radiating a mysterious energy...",poke.name))
          if Kernel.pbConfirmMessage(_INTL("Should {1} create an egg?",poke.name))
            pbRitualAnimation(poke)
            pbGenerateEgg(:ARCEUS,_I("A Divine Force."))
            pkmn=$Trainer.lastParty
            if poke.ballused!=4 && poke.ballused!=15
              pkmn.ballused=poke.ballused
            end
            pkmn.setNature(poke.nature)
            pkmn.iv[0]=31
            pkmn.iv[1]=31
            pkmn.iv[2]=31
            pkmn.iv[3]=31
            pkmn.iv[4]=31
            pkmn.iv[5]=31
            pbWait(1)
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",poke.name))
            pbWait(5)
            Kernel.pbMessage(_INTL("{1}'s {2} shattered!",
            poke.name,PBItems.getName(poke.item)))
            poke.item=0
          else
            Kernel.pbMessage(_INTL("You decided not to form an egg."))
          end
        # Creates a Type: Null egg
        elsif isConst?(poke.item,PBItems,:FALSEPLATE)
          Kernel.pbMessage(_INTL("{1} is radiating a mysterious energy...",poke.name))
          if Kernel.pbConfirmMessage(_INTL("Should {1} create an egg?",poke.name))
            pbRitualAnimation(poke)
            pbGenerateEgg(:TYPENULL,_I("A Corrupted Force."))
            pkmn=$Trainer.lastParty
            if poke.ballused!=4 && poke.ballused!=15
              pkmn.ballused=poke.ballused
            end
            pkmn.setNature(poke.nature)
            pkmn.iv[0]=poke.iv[0]
            pkmn.iv[1]=poke.iv[1]
            pkmn.iv[2]=poke.iv[2]
            pkmn.iv[3]=poke.iv[3]
            pkmn.iv[4]=poke.iv[4]
            pkmn.iv[5]=poke.iv[5]
            pbWait(1)
            pbMEPlay("Pkmn get")
            Kernel.pbMessage(_INTL("{1} formed an egg!",poke.name))
            pbWait(5)
            Kernel.pbMessage(_INTL("{1}'s {2} shattered!",
            poke.name,PBItems.getName(poke.item)))
            poke.item=0
          else
            Kernel.pbMessage(_INTL("You decided not to form an egg."))
          end
        else
          Kernel.pbMessage(_INTL("{1} isn't holding the correct item to form an egg.",poke.name))
        end
      elsif $game_variables[1]<0
        Kernel.pbMessage(_INTL("You decided not to form an egg."))
      elsif !isConst?(poke.species,PBSpecies,:ARCEUS)
        Kernel.pbMessage(_INTL("That Pokémon isn't capable of forming an egg."))
      end
    end
    $game_variables[1]=-1
  end
end

#===============================================================================
# Trainer Signs - Sign Selection Event
#===============================================================================
def pbTrainerSignEvent
  Kernel.pbMessage(_INTL("Could you tell me what month were you born in, {1}?",$Trainer.name))
  command=0
  loop do
    command=Kernel.pbShowCommands(nil,[
    _INTL("January"),
    _INTL("February"),
    _INTL("March"),
    _INTL("April"),
    _INTL("May"),
    _INTL("June"),
    _INTL("July"),
    _INTL("August"),
    _INTL("September"),
    _INTL("October"),
    _INTL("November"),
    _INTL("December"),
    _INTL("Who knows?"),
    _INTL("Rather not say")
    ],command)
    case command
    when 0,1,2,3,4,5,6,7,8,9,10,11
      $Trainer.setZodiacsign(command+1)
      Kernel.pbMessage(_INTL("Right! That means you have the sign of <c2=65467b14>{1}</c2>! It suits you!",
        PBBirthsigns.getName($PokemonGlobal.zodiacset[command])))
    when 12# Random
      $Trainer.setRandomZodiac
      Kernel.pbMessage(_INTL("Hmm...well, you look like someone who would have the sign of <c2=65467b14>{1}</c2> to me.",
        PBBirthsigns.getName($Trainer.birthsign)))
    when 13# Default
      Kernel.pbMessage(_INTL("Ah! The mysterious type, eh?"))
    end
    break
  end
end
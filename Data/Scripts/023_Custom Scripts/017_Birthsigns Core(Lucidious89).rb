#===============================================================================
#
#  Pokémon Birthsigns - By Lucidious89
#  For -Pokémon Essentials v17-
#
#===============================================================================
# This project intends to add a new mechanic known as "Birthsigns" to
# Pokémon. Each month of the year corresponds to a different sign,
# and a Pokémon born under these signs will be infused with their bonuses.
#
# This is the core script, and adds 36 unique Birthsigns to choose from that 
# can be grouped into sets of 12 that act as a 12-month zodiac. All the tools
# necessary to make birthsigns work are in this script, and utilized by other
# scripts to implement the effects of all the birthsigns.
#
#===============================================================================
#  ~Installation~
#===============================================================================
# To install, insert this and all susequent Birthsign scripts near the end of
# the Essentials script, above Main. Above Debug_Menu is a good spot. If you're
# using Luka's EBS, make sure his scripts are below the Birthsign scripts.
#===============================================================================


############[CUSTOMIZATION]#####################################################
#===============================================================================
# Toggles compatibility with other scripts
#===============================================================================
SHOW_IV_STARS    = false # Shows stars in summary/storage to indicate IV quality
SHOW_EGG_GROUPS  = false # Shows Egg Groups in the summary (Page 2)
SHOW_SHINY_LEAF  = false # Adds HGSS Shiny Leaf functionality
SHOW_FAMILYTREE  = false  # Compatibility with FL's 'Family Tree' script

#===============================================================================
# Toggles regional evolutions for birthsign effects that cause evolution.
#===============================================================================
ALOLANREGION     = false
GALARIANREGION   = false

#===============================================================================
# The switch numbers used for Summons and Celestial Bosses
#===============================================================================
BOSS_SWITCH      = 109
SUMMON_SWITCH    = 110

#===============================================================================
# WILD BIRTHSIGNS
#===============================================================================
# 0  =  No signs    
# 1  =  Current sign         (Based on your active zodiac)
# 2  =  Random Partner/Rival (Based on the current month/zodiac)
# 3  =  Random zodiac sign   (Based on your active zodiac)
# 4  =  Random birthsign     (Out of all possible signs)
#===============================================================================
# Set WILDBIRTHSINGS to a number above to set the initial signs on wild Pokemon.
#===============================================================================
# Use the script pbSetWildsigns to change wild signs during gameplay.
# Set "sign" to a number found above and leave "override" blank to change signs.
# When "override" is true, "sign" will instead refer to a specific birthsign.
#===============================================================================
WILDBIRTHSIGNS   = 3

def pbSetWildsigns(sign,override=false)
  if override
    $PokemonGlobal.wildsign=0
    $PokemonGlobal.wildsignOverride=sign
  else
    $PokemonGlobal.wildsign=sign
    $PokemonGlobal.wildsignOverride=0
  end
end

#===============================================================================
# ZODIAC SETS
#===============================================================================
# 0  =  Null Set           (No zodiac, but can still give signs through scripts)
# 1  =  Birthsigns Set 1   (Uses signs 1-12 to make a zodiac)
# 2  =  Birthsigns Set 2   (Uses signs 13-24 to make a zodiac)
# 3  =  Birthsigns Set 3   (Uses signs 25-36 to make a zodiac)
# 4  =  Randomized Set     (Compiles a random zodiac out of all signs)
# 5+ =  Custom Sets        (Make your own zodiacs)
#===============================================================================
# Set ZODIACSET to a number above to set the initial zodiac in your game.
#===============================================================================
# Use the script pbSwapZodiac to change zodiac sets during gameply.
# Set "setnum" to a number found above to swap to the signs found in that set.
# Use the script pbSwapSign to change specific zodiac signs during gameplay.
# Set "monthnum" to the month and "signnum" to the desired sign number.
#===============================================================================
ZODIACSET        = 5

def pbSwapZodiac(setnum)
  $PokemonGlobal.setZodiac0 if setnum==0
  $PokemonGlobal.setZodiac1 if setnum==1
  $PokemonGlobal.setZodiac2 if setnum==2
  $PokemonGlobal.setZodiac3 if setnum==3
  $PokemonGlobal.setZodiac4 if setnum==4
  $PokemonGlobal.setZodiac5 if setnum==5
  $PokemonGlobal.setZodiac6 if setnum==6
end

def pbSwapSign(monthnum,signnum)
  $PokemonGlobal.zodiacset[monthnum-1]=signnum
end

#===============================================================================
# CUSTOM ZODIAC SETS
#===============================================================================
# Creating a custom zodiac simply requires you to set each month to a number 
# corresponding to a birthsign. Here's a chart of all the sign numbers:
#===============================================================================
# 0  = Void       1  = Apprentice  2  = Companion  3  = Beacon     4  = Savage  
# 5  = Prodigy    6  = Martyr      7  = Maiden     8  = Gladiator  9  = Voyager
# 10 = Thief      11 = Glutton     12 = Wishmaker  13 = Phoenix    14 = Scholar
# 15 = Fugitive   16 = Aristocrat  17 = Cleric     18 = Monk       19 = Ancestor
# 20 = Specialist 21 = Assassin    22 = Parent     23 = Hunter     24 = Eternal
# 25 = Bard       26 = Empath      27 = Mirror     28 = Tactician  29 = Fool
# 30 = Alchemist  31 = Vampire     32 = Soulmate   33 = Cultist    34 = Racketeer
# 35 = Scavenger  36 = Timelord
#===============================================================================
# Custom zodiac sets (5, 6)
#===============================================================================
def setZodiac5
  # Replace all the 0's below with your desired sign for each month.
  c1  = 16     # January
  c2  = 32     # February
  c3  = 30     # March
  c4  = 6      # April
  c5  = 29     # May
  c6  = 25     # June
  c7  = 5      # July
  c8  = 10     # August
  c9  = 22     # September
  c10 = 31     # October
  c11 = 11     # November
  c12 = 12     # December
  @zodiacset = [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12]
end

def setZodiac6
  # Replace all the 0's below with your desired sign for each month.
  c1  = 1      # January
  c2  = 4      # February
  c3  = 18     # March
  c4  = 14     # April
  c5  = 27     # May
  c6  = 25     # June
  c7  = 28     # July
  c8  = 7      # August
  c9  = 8      # September
  c10 = 19     # October
  c11 = 2      # November
  c12 = 24     # December
  @zodiacset = [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12]
end

#===============================================================================
# Randomized zodiac set (4)
# Compiles a semi-random set of signs out of all available birthsigns.
# You may remove sign numbers from the "signlist" array if you don't want them 
# to appear in the random selection.
#===============================================================================
def setZodiac4
  signlist=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
            20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36]
  totalsigns=signlist.length
  rndm=rand(totalsigns)
  r1=signlist[rndm%totalsigns]
  r2=signlist[2+rndm%totalsigns]
  r3=signlist[4+rndm%totalsigns]
  r4=signlist[6+rndm%totalsigns]
  r5=signlist[8+rndm%totalsigns]
  r6=signlist[10+rndm%totalsigns]
  r7=signlist[11+rndm%totalsigns]
  r8=signlist[9+rndm%totalsigns]
  r9=signlist[7+rndm%totalsigns]
  r10=signlist[5+rndm%totalsigns]
  r11=signlist[3+rndm%totalsigns]
  r12=signlist[1+rndm%totalsigns]
  @zodiacset = [r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12]
end

#===============================================================================
# Base Zodiac sets (0-3)
#===============================================================================
def setZodiac0
  @zodiacset = [0,0,0,0,0,0,0,0,0,0,0,0]
end

def setZodiac1
  @zodiacset = [1,2,3,4,5,6,7,8,9,10,11,12]
end

def setZodiac2
  @zodiacset = [13,14,15,16,17,18,19,20,21,22,23,24]
end

def setZodiac3
  @zodiacset = [25,26,27,28,29,30,31,32,33,34,35,36]
end

##########[BIRTHSIGN TEXT & NAMES]##############################################
#===============================================================================
# Birthsign Names
#===============================================================================
# You may rename signs here. They will be recognized by the rest of the script.
#===============================================================================
BIRTHSIGN_00 = _INTL("'The Void'")
BIRTHSIGN_01 = _INTL("'The Apprentice'")
BIRTHSIGN_02 = _INTL("'The Companion'")
BIRTHSIGN_03 = _INTL("'The Beacon'")
BIRTHSIGN_04 = _INTL("'The Savage'")
BIRTHSIGN_05 = _INTL("'The Prodigy'")
BIRTHSIGN_06 = _INTL("'The Martyr'")
BIRTHSIGN_07 = _INTL("'The Maiden'")
BIRTHSIGN_08 = _INTL("'The Gladiator'")
BIRTHSIGN_09 = _INTL("'The Voyager'")
BIRTHSIGN_10 = _INTL("'The Thief'")
BIRTHSIGN_11 = _INTL("'The Glutton'")
BIRTHSIGN_12 = _INTL("'The Wishmaker'")
BIRTHSIGN_13 = _INTL("'The Phoenix'")
BIRTHSIGN_14 = _INTL("'The Scholar'")
BIRTHSIGN_15 = _INTL("'The Fugitive'")
BIRTHSIGN_16 = _INTL("'The Aristocrat'")
BIRTHSIGN_17 = _INTL("'The Cleric'")
BIRTHSIGN_18 = _INTL("'The Monk'")
BIRTHSIGN_19 = _INTL("'The Ancestor'")
BIRTHSIGN_20 = _INTL("'The Specialist'")
BIRTHSIGN_21 = _INTL("'The Assassin'")
BIRTHSIGN_22 = _INTL("'The Parent'")
BIRTHSIGN_23 = _INTL("'The Hunter'")
BIRTHSIGN_24 = _INTL("'The Eternal'")
BIRTHSIGN_25 = _INTL("'The Bard'")
BIRTHSIGN_26 = _INTL("'The Empath'")
BIRTHSIGN_27 = _INTL("'The Mirror'")
BIRTHSIGN_28 = _INTL("'The Tactician'")
BIRTHSIGN_29 = _INTL("'The Fool'")
BIRTHSIGN_30 = _INTL("'The Alchemist'")
BIRTHSIGN_31 = _INTL("'The Vampire'")
BIRTHSIGN_32 = _INTL("'The Soulmate'")
BIRTHSIGN_33 = _INTL("'The Cultist'")
BIRTHSIGN_34 = _INTL("'The Racketeer'")
BIRTHSIGN_35 = _INTL("'The Scavenger'")
BIRTHSIGN_36 = _INTL("'The Timelord'")

#===============================================================================
# Zodiac Power Names
#===============================================================================
# The names for each Zodiac Power's effects in battle.
#===============================================================================
def pbGetPowerName(sign)
  return [_INTL("Empty Gesture"),    #'The Void'
          _INTL("Understudy"),       #'The Apprentice'
          _INTL("Friend Boost"),     #'The Companion'
          _INTL("Blinding Light"),   #'The Beacon'
          _INTL("Feral Frenzy"),     #'The Savage'
          _INTL("Ability Whiz"),     #'The Prodigy'
          _INTL("Self Sacrifice"),   #'The Martyr'
          _INTL("Beauty Queen"),     #'The Maiden'
          _INTL("Battle Cry"),       #'The Gladiator'
          _INTL("Tour Guide"),       #'The Voyager'
          _INTL("Hit & Run"),        #'The Thief'
          _INTL("Pig Out"),          #'The Glutton'
          _INTL("Lucky Boost"),      #'The Wishmaker'
          _INTL("Last Stand"),       #'The Phoenix'
          _INTL("Quick Study"),      #'The Scholar'
          _INTL("Escape Artist"),    #'The Fugitive'
          _INTL("Market Crash"),     #'The Aristocrat'
          _INTL("Great Purge"),      #'The Cleric'
          _INTL("Mind's Eye"),       #'The Monk'
          _INTL("Spirit Guard"),     #'The Ancestor'
          _INTL("Lock Down"),        #'The Specialist'
          _INTL("Ambush"),           #'The Assassin'
          _INTL("Bodyguard"),        #'The Parent'
          _INTL("Corner Strike"),    #'The Hunter'
          _INTL("Lottery"),          #'The Eternal'
          _INTL("Stifling Song"),    #'The Bard'
          _INTL("Solidarity"),       #'The Empath'
          _INTL("Mirror Image"),     #'The Mirror'
          _INTL("Table Turn"),       #'The Tactician'
          _INTL("Big Gamble"),       #'The Fool'
          _INTL("Transmogrify"),     #'The Alchemist'
          _INTL("Life Drain"),       #'The Vampire'
          _INTL("Star-Crossed"),     #'The Soulmate'
          _INTL("Dark Pact"),        #'The Cultist'
          _INTL("Bribery"),          #'The Racketeer'
          _INTL("Natural Selection"),#'The Scavenger'
          _INTL("Borrowed Time")     #'The Timelord'
          ][sign]  
end

# Used to get specific power names for the different effects of Stifling Song
def pbGetSongName(value)
  return [_INTL("Stifling Song"),         
          _INTL("Brittle Ballad"),         # Lowers Attack
          _INTL("Silent Serenade"),        # Lowers Sp.Atk 
          _INTL("Lagging Lullaby")][value] # Lowers Speed
end

#===============================================================================
# Celestial Boss Names
#===============================================================================
# The names for each sign's Celestial Boss.
#===============================================================================
def pbGetBossName(sign)
  return [_INTL("Omega"),            #'The Void'
          _INTL("Zealos"),           #'The Apprentice'
          _INTL("Deliphis"),         #'The Companion'
          _INTL("Phobos"),           #'The Beacon'
          _INTL("Reivolt"),          #'The Savage'
          _INTL("Klevar"),           #'The Prodigy'
          _INTL("Mediva"),           #'The Martyr'
          _INTL("Damsella"),         #'The Maiden'
          _INTL("Bat'aal"),          #'The Gladiator'
          _INTL("Ragnarova"),        #'The Voyager'
          _INTL("Swyndell"),         #'The Thief'
          _INTL("Gorvus"),           #'The Glutton'
          _INTL("Alistaar"),         #'The Wishmaker'
          _INTL("Ashbeyard"),        #'The Phoenix'
          _INTL("Astuvius"),         #'The Scholar'
          _INTL("Eluzi"),            #'The Fugitive'
          _INTL("Koynn"),            #'The Aristocrat'
          _INTL("Quu'ral"),          #'The Cleric'
          _INTL("Luminatta"),        #'The Monk'
          _INTL("Artu'fak"),         #'The Ancestor'
          _INTL("Dopple"),           #'The Specialist'
          _INTL("Deimos"),           #'The Assassin'
          _INTL("Matria"),           #'The Parent'
          _INTL("Maulgriev"),        #'The Hunter'
          _INTL("Astrol"),           #'The Eternal'
          _INTL("Ballaborg"),        #'The Bard'
          _INTL("Sentimus"),         #'The Empath'
          _INTL("Xerok"),            #'The Mirror'
          _INTL("Griddeous"),        #'The Tactician'
          _INTL("Turvii"),           #'The Fool'
          _INTL("Boddelgeuz"),       #'The Alchemist'
          _INTL("Vladimorg"),        #'The Vampire'
          _INTL("Vymm & Vygor"),     #'The Soulmate'
          _INTL("Lucifus"),          #'The Cultist'
          _INTL("Gangkrupt"),        #'The Racketeer'
          _INTL("Gemineye"),         #'The Scavenger'
          _INTL("Pandorica")         #'The Timelord'
          ][sign]     
end

# Used to get individual boss names for 'The Soulmate' (0 or 1)
def pbGetDoubleBoss(value)
  return [_INTL("Vymm"),_INTL("Vygor")][value]
end

#===============================================================================
#  Birthsign Descriptions
#===============================================================================
# Text for each birthsign's effect in the Summary.
#===============================================================================
def pbGetZodiacDesc(sign)
  return [_INTL("Unknown."),
          _INTL("The Pokémon gains twice as many EV's from battle."), 
          _INTL("Wild Pokémon share the user's increased happiness."),
          _INTL("The Pokémon may brighten up dark areas with Starlight."),
          _INTL("The Pokémon has max IV's in offense & speed, but 0 HP."),
          _INTL("The Pokémon may swap to one of its other Abilities."),
          _INTL("The Pokémon may sacrifice HP to heal a hurt ally."),
          _INTL("The Pokémon has 150 Sp.Atk EV's. High female ratio."),
          _INTL("The Pokémon has 150 Attack EV's. High male ratio."),
          _INTL("The Pokémon may use the stars to Navigate to safety."),
          _INTL("The Pokémon may find loot on wild Pokémon."),
          _INTL("The Pokémon has max IV's in defenses & HP, but 0 speed."),
          _INTL("The Pokémon has higher odds of being shiny."),
          _INTL("The Pokémon may revive itself from the party menu."), 
          _INTL("The Pokémon gains 20% more Exp. points from battles."),
          _INTL("The Pokémon may Escape to safety from dungeons."),
          _INTL("The Pokémon may find extra money while leading."),
          _INTL("The Pokémon may sacrifice HP to Cure an ally's status."),
          _INTL("May enter a Trance to heal PP or change its moves."),
          _INTL("EV's are inherited by eggs, or others who are Endowed."),
          _INTL("The Pokémon may Re-roll for a new Hidden Power."),
          _INTL("The Pokémon may sneak up on sleeping wild Pokémon."),
          _INTL("The Pokémon may Incubate eggs to hatch them earlier."),
          _INTL("The Pokémon raises capture rates by 20% when leading."),
          _INTL("The Pokémon may begin anew and Reincarnate itself."),
          _INTL("The Pokémon may Harmonize to lure/repel wild Pokémon."),
          _INTL("The Pokémon Bonds with allies & copies their nature."),
          _INTL("The Pokémon may find wild Pokémon with similar IV's."),
          _INTL("The Pokémon may use a Gambit to reallocate its EV's."),
          _INTL("The Pokémon may give away its levels with Lunacy."),
          _INTL("The Pokémon may Transmute held items into new ones ."),
          _INTL("Walking at night heals the Pokémon. Daylight burns."),
          _INTL("Wild Pokémon may share compatible partner signs."),
          _INTL("The Pokémon may Summon by sacrificing its stats."),
          _INTL("The Pokémon may net you deals at shops when leading."),
          _INTL("The Pokémon may find items related to its environment."),
          _INTL("The Pokémon may Timeskip to a future evolution.")
          ][sign]
end
  
#===============================================================================
#  Birthsign Values
#===============================================================================
# The name and numbers that represent each birthsign. 
#===============================================================================
module PBBirthsigns
   SIGN00   = 0     #'The Void'
   SIGN01   = 1     #'The Apprentice'
   SIGN02   = 2     #'The Companion'
   SIGN03   = 3     #'The Beacon'
   SIGN04   = 4     #'The Savage'
   SIGN05   = 5     #'The Prodigy'
   SIGN06   = 6     #'The Martyr'
   SIGN07   = 7     #'The Maiden'
   SIGN08   = 8     #'The Gladiator'
   SIGN09   = 9     #'The Voyager'
   SIGN10   = 10    #'The Thief'
   SIGN11   = 11    #'The Glutton'
   SIGN12   = 12    #'The Wishmaker'
   SIGN13   = 13    #'The Phoenix'
   SIGN14   = 14    #'The Scholar'
   SIGN15   = 15    #'The Fugitive'
   SIGN16   = 16    #'The Aristocrat'
   SIGN17   = 17    #'The Cleric'
   SIGN18   = 18    #'The Monk'
   SIGN19   = 19    #'The Ancestor'
   SIGN20   = 20    #'The Specialist'
   SIGN21   = 21    #'The Assassin'
   SIGN22   = 22    #'The Parent'
   SIGN23   = 23    #'The Hunter'
   SIGN24   = 24    #'The Eternal'
   SIGN25   = 25    #'The Bard'
   SIGN26   = 26    #'The Empath'
   SIGN27   = 27    #'The Mirror'
   SIGN28   = 28    #'The Tactician'
   SIGN29   = 29    #'The Fool'
   SIGN30   = 30    #'The Alchemist'
   SIGN31   = 31    #'The Vampire'
   SIGN32   = 32    #'The Soulmate'
   SIGN33   = 33    #'The Cultist'
   SIGN34   = 34    #'The Racketeer'
   SIGN35   = 35    #'The Scavenger'
   SIGN36   = 36    #'The Timelord'
  end

  def PBBirthsigns.maxValue; 36; end
  def PBBirthsigns.getCount; 37; end
    
  def PBBirthsigns.signValue(id)
    return (id)%37
  end
  
  def PBBirthsigns.getName(id)
    names=[
        BIRTHSIGN_00,        #'The Void'
        BIRTHSIGN_01,        #'The Apprentice'
        BIRTHSIGN_02,        #'The Companion'
        BIRTHSIGN_03,        #'The Beacon'
        BIRTHSIGN_04,        #'The Savage'
        BIRTHSIGN_05,        #'The Prodigy'
        BIRTHSIGN_06,        #'The Martyr'
        BIRTHSIGN_07,        #'The Maiden'
        BIRTHSIGN_08,        #'The Gladiator'
        BIRTHSIGN_09,        #'The Voyager'
        BIRTHSIGN_10,        #'The Thief'
        BIRTHSIGN_11,        #'The Glutton'
        BIRTHSIGN_12,        #'The Wishmaker'
        BIRTHSIGN_13,        #'The Phoenix'
        BIRTHSIGN_14,        #'The Scholar'
        BIRTHSIGN_15,        #'The Fugitive'
        BIRTHSIGN_16,        #'The Aristocrat'
        BIRTHSIGN_17,        #'The Cleric'
        BIRTHSIGN_18,        #'The Monk'
        BIRTHSIGN_19,        #'The Ancestor'
        BIRTHSIGN_20,        #'The Specialist'
        BIRTHSIGN_21,        #'The Assassin'
        BIRTHSIGN_22,        #'The Parent'
        BIRTHSIGN_23,        #'The Hunter'
        BIRTHSIGN_24,        #'The Eternal'
        BIRTHSIGN_25,        #'The Bard'
        BIRTHSIGN_26,        #'The Empath'
        BIRTHSIGN_27,        #'The Mirror'
        BIRTHSIGN_28,        #'The Tactician'
        BIRTHSIGN_29,        #'The Fool'
        BIRTHSIGN_30,        #'The Alchemist'
        BIRTHSIGN_31,        #'The Vampire'
        BIRTHSIGN_32,        #'The Soulmate'
        BIRTHSIGN_33,        #'The Cultist'
        BIRTHSIGN_34,        #'The Racketeer'
        BIRTHSIGN_35,        #'The Scavenger'
        BIRTHSIGN_36         #'The Timelord'
    ]
    return names[id]
end

# Used for Debug
def pbChooseBirthsignList(default=0)
  commands = []
  for i in 1..PBBirthsigns.maxValue
    cname = getConstantName(PBBirthsigns,i) rescue nil
    commands.push([i,PBBirthsigns.getName(i)]) if cname
  end
  return pbChooseList(commands,default,-1)
end

#===============================================================================
#  Zodiac Values
#===============================================================================
# The name and numbers that represent each zodiac sign. 
#===============================================================================
module PBZodiacsigns
   JAN   = 1  
   FEB   = 2 
   MAR   = 3   
   APR   = 4
   MAY   = 5   
   JUN   = 6   
   JUL   = 7  
   AUG   = 8   
   SEP   = 9   
   OCT   = 10  
   NOV   = 11  
   DEC   = 12  
  end

  def PBZodiacsigns.maxValue; 12; end
  def PBZodiacsigns.getCount; 13; end
    
  def PBZodiacsigns.signValue(id)
    return (id)%13
  end
  
  def PBZodiacsigns.getName(id)
    names=[
        _INTL("-Clear Sign-"),
        PBBirthsigns.getName($PokemonGlobal.zodiacset[0]),
        PBBirthsigns.getName($PokemonGlobal.zodiacset[1]),
        PBBirthsigns.getName($PokemonGlobal.zodiacset[2]),
        PBBirthsigns.getName($PokemonGlobal.zodiacset[3]),       
        PBBirthsigns.getName($PokemonGlobal.zodiacset[4]),     
        PBBirthsigns.getName($PokemonGlobal.zodiacset[5]),       
        PBBirthsigns.getName($PokemonGlobal.zodiacset[6]),     
        PBBirthsigns.getName($PokemonGlobal.zodiacset[7]),       
        PBBirthsigns.getName($PokemonGlobal.zodiacset[8]),     
        PBBirthsigns.getName($PokemonGlobal.zodiacset[9]),  
        PBBirthsigns.getName($PokemonGlobal.zodiacset[10]),
        PBBirthsigns.getName($PokemonGlobal.zodiacset[11])
    ]
    return names[id]
end

# Used for debug
def pbChooseZodiacList(default=0)
  commands = []
  for i in 1..PBZodiacsigns.maxValue
    cname = getConstantName(PBZodiacsigns,i) rescue nil
    commands.push([i,PBZodiacsigns.getName(i)]) if cname
  end
  return pbChooseList(commands,default,-1)
end

############[BIRTHSIGNS - DATA]#################################################
#===============================================================================
# Birthsigns - Global Metadata
#===============================================================================
# Holds a variety of data, including zodiac sets, wild birthsigns, step resets,
# and celestial bosses battled.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :zodiacset
  attr_accessor :wildsign
  attr_accessor :celestialboss
  attr_accessor :omegaboss
  attr_accessor :wildsignOverride
  attr_accessor :timerAbilLure
  attr_accessor :resetBirthsignAbilLure
  attr_accessor :resetBirthsignTrance
  attr_accessor :resetBirthsignHarmonize
  attr_accessor :resetBirthsignIncubate
  attr_accessor :resetBirthsignSummon
  attr_accessor :resetBirthsignTimeskip
  attr_accessor :resetCelestialSkill
  attr_accessor :resetFortuneTeller
  attr_accessor :fortuneEqual
  attr_accessor :fortuneBad
  attr_accessor :fortuneGood
  alias new_initialize initialize
  def initialize
    new_initialize
    @zodiacset                    = [0,0,0,0,0,0,0,0,0,0,0,0]
    setZodiac0                        if ZODIACSET==0
    setZodiac1                        if ZODIACSET==1
    setZodiac2                        if ZODIACSET==2
    setZodiac3                        if ZODIACSET==3
    setZodiac4                        if ZODIACSET==4
    setZodiac5                        if ZODIACSET==5
    setZodiac6                        if ZODIACSET==6
    @wildsign                     = 0 
    @wildsign                     = 0 if WILDBIRTHSIGNS==0
    @wildsign                     = 1 if WILDBIRTHSIGNS==1
    @wildsign                     = 2 if WILDBIRTHSIGNS==2
    @wildsign                     = 3 if WILDBIRTHSIGNS==3
    @wildsign                     = 4 if WILDBIRTHSIGNS==4
    @wildsign                     = 5 if WILDBIRTHSIGNS==5
    @wildsignOverride             = 0
    @celestialboss                = []
    for i in 0..12               
      @celestialboss[i]=nil
    end
    @timerAbilLure                = 0
    @resetBirthsignAbilLure       = 0
    @resetBirthsignTrance         = 0
    @resetBirthsignHarmonize      = 0
    @resetBirthsignIncubate       = 0
    @resetBirthsignSummon         = 0
    @resetBirthsignTimeskip       = 0
    @resetCelestialSkill          = 0
    @resetFortuneTeller           = 0
    @fortuneEqual                 = false
    @fortuneBad                   = false
    @fortuneGood                  = false
    @omegaboss                    = false
  end
end

#===============================================================================
# Birthsigns - Pokemon Data
#===============================================================================
# Holds the Pokemon data that defines birthsigns, blessings, celestials, etc.
#===============================================================================
class PokeBattle_Pokemon
    attr_accessor(:zodiacflag)
    attr_accessor(:leafflag)
    attr_accessor(:celestial)
    attr_accessor(:blessed)
    
  # Flags a Pokemon as blessed
  def makeBlessed
    if self.hasBirthsign? && !isCelestial?
      self.blessed=true
    end
  end
  
  # Unflags a Pokemon's blessing
  def makeUnblessed
    if !isCelestial?
      self.blessed=false
    end
  end
  
  # Determines if the Pokemon is blessed
  def isBlessed?
    if self.blessed
      return true
    end
  end

  # Makes a Pokemon into a Celestial species
  def makeCelestial
    if hasBirthsign?
      self.celestial=true
      self.blessed=true
      self.form=30
    end
  end
  
  # Removes the Celestial flag from a Pokemon
  def removeCelestial
    self.celestial=false
    self.blessed=false
    self.form=0
  end

  # Determines whether a Pokemon is a Celestial species
  def isCelestial?
    if self.celestial
      return true
    end
  end

  # Defines birthsigns
  def birthsign
    return @zodiacflag if @zodiacflag!=nil
    return @personalID%37
  end
  
  # Sets a specific birthsign on a Pokemon (0-36)
  def setBirthsign(value)
    if !(self.isShadow? rescue false) && !egg? && !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBBirthsigns,value)
      end
      if value!=nil
        @zodiacflag=value
        applyBirthsignBonuses
        self.calcStats
      end
    else
      return false
    end
  end
  
  # Sets a random birthsign on a Pokemon (1-36)
  def setRandomsign
    randsign=(1+rand(PBBirthsigns.maxValue))
    setBirthsign(randsign)
  end
  
  # Sets a specific zodiac sign on a Pokemon (1-12)
  def setZodiacsign(value)
    if !(self.isShadow? rescue false) && !egg? && !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=nil
        value-=1
        @zodiacflag=$PokemonGlobal.zodiacset[value]
        applyBirthsignBonuses
        self.calcStats
      end
    else
      return false
    end
  end
  
  # Sets a random zodiac sign on a Pokemon
  def setRandomZodiac
    randsign=(1+rand(11))
    setZodiacsign(randsign)
  end

  # Sets a rival sign on a Pokemon relative to (value)
  def setRivalsign(value)
    if !(self.isShadow? rescue false) && !egg? && !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=nil
        value-=1
        @zodiacflag=$PokemonGlobal.zodiacset[((value+6)%12)]
        applyBirthsignBonuses
        self.calcStats
      end
    else
      return false
    end
  end
  
  # Sets a particular partner sign (num) on a Pokemon relative to (value)
  def setPartnersign(value,num=nil)
    if !(self.isShadow? rescue false) && !egg? && !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=nil
        value-=1
        randsign=rand(10)
        case num
        when 1
          @zodiacflag=$PokemonGlobal.zodiacset[((value+4)%12)]
        when 2
          @zodiacflag=$PokemonGlobal.zodiacset[((value+8)%12)]
        else
          if randsign>5
            @zodiacflag=$PokemonGlobal.zodiacset[((value+4)%12)]
          else
            @zodiacflag=$PokemonGlobal.zodiacset[((value+8)%12)]
          end
        end
        applyBirthsignBonuses
        self.calcStats
      end
    else
      return false
    end
  end

  # Defines shiny leaf
  def shinyleaf
    return @leafflag if @leafflag!=nil
  end
  
  # Sets a number of shiny leaves on a Pokemon. 6 leaves make a crown.
  def setShinyLeaf(value)
    if !egg?
      @leafflag=value
    end
  end
  
  # Adds 1 shiny leaf to a Pokemon's total, up to 6.
  def addShinyLeaf
    if !egg?
      if @leafflag==nil
        setShinyLeaf(0)
      elsif @leafflag<0
        @leafflag+=-@leafflag
      end
      if @leafflag<6
        @leafflag+=1
      end
    end
  end
  
  # Subtracts 1 shiny leaf from a Pokemon's total, down to 0.
  def removeShinyLeaf
    if @leafflag==nil
      setShinyLeaf(0)
    elsif @leafflag>6
      @leafflag-=self.leafflag
      @leafflag+=6
    end
    if @leafflag>0
      @leafflag-=1
    end
  end
    
  # Checks to see if the Pokemon has a leaf crown.  
  def hasLeafCrown?
    if @leafflag==6 || @leafflag>6
      return true
    end
  end
  
  alias birthsign_initialize initialize  
  def initialize(*args)
    birthsign_initialize(*args)
    #===========================================================================
    # Newly generated Pokemon have all flags set to neutral
    #===========================================================================
    @zodiacflag    = 0
    @leafflag      = 0
    @celestial     = false
    @blessed       = false
    #===========================================================================
  end
end

#===============================================================================
# Birthsigns - Trainer Data
#===============================================================================
# Holds the Trainer data that defines birthsigns for trainers.
#===============================================================================
class PokeBattle_Trainer
    attr_accessor(:zodiacflag)
    attr_accessor(:blessed)
    attr_accessor(:hassign)
    
  def makeBlessed
    if self.birthsign>0
      self.blessed=true
    end
  end
  
  def makeUnblessed
    self.blessed=false
  end
  
  def hasSign?
    if self.zodiacflag!=nil
      return true
    end
  end
      
  def makeSigned
      self.hassign=true
  end
  
  def isBlessed?
    if self.blessed
      return true
    end
  end
  
  def birthsign
    return @zodiacflag if @zodiacflag!=nil
  end
  
  def setBirthsign(value)
    if !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBBirthsigns,value)
      end
      if value!=0 || value!=nil
        @zodiacflag=value
      end
    end
  end

  def setRandomsign
    randsign=(1+rand(PBBirthsigns.maxValue))
    setBirthsign(randsign)
  end
  
  def setZodiacsign(value)
    if !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=0 || value!=nil
        value-=1
        @zodiacflag=$PokemonGlobal.zodiacset[value]
      end
    end
  end
  
  def setRandomZodiac
    randsign=(1+rand(11))
    setZodiacsign(randsign)
  end
  
  def setRivalsign(value)
    if !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=0 || value!=nil
        value-=1
        @zodiacflag=$PokemonGlobal.zodiacset[((value+6)%12)]
      end
    end
  end
  
  def setPartnersign(value,num=nil)
    if !isBlessed?
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBZodiacsigns,value)
      end
      if value!=0 || value!=nil
        value-=1
        randsign=rand(10)
        case num
        when 1
          @zodiacflag=$PokemonGlobal.zodiacset[((value+4)%12)]
        when 2
          @zodiacflag=$PokemonGlobal.zodiacset[((value+8)%12)]
        else
          if randsign>5
            @zodiacflag=$PokemonGlobal.zodiacset[((value+4)%12)]
          else
            @zodiacflag=$PokemonGlobal.zodiacset[((value+8)%12)]
          end
        end
      end
    end
  end
  
  def hasBirthsign?
    if birthsign>0
      return true
    end
  end
  
  def hasZodiacsign?
    if monthsign!=nil
      return true
    end
  end
  
  # Trainer sign is set to adventure start month by default
  alias birthsign_initialize initialize
  def initialize(name,trainertype)
    birthsign_initialize(name,trainertype)
    @zodiacflag=$PokemonGlobal.zodiacset[$PokemonGlobal.startTime.mon-1]
    @blessed=false
  end
end


############[BIRTHSIGN FUNCTIONS]###############################################
#===============================================================================
# Birthsign Checks
#===============================================================================
# Returns true if the Pokemon has any birthsign
def hasBirthsign?
  if !(self.isShadow? rescue false) && !egg?
    if birthsign>0
      return true
    end
  end
end

# Returns true if the Pokemon has a zodiac sign
def hasZodiacsign?
  if !(self.isShadow? rescue false) && !egg?
    if monthsign!=nil
      return true
    end
  end
end

#===============================================================================
# Month Checks
#===============================================================================
# January
def hasJanBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[0]
    return true
  end
end

# February
def hasFebBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[1]
    return true
  end
end

# March
def hasMarBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[2]
    return true
  end
end

# April
def hasAprBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[3]
    return true
  end
end

# May
def hasMayBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[4]
    return true
  end
end

# June
def hasJunBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[5]
    return true
  end
end

# July
def hasJulBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[6]
    return true
  end
end

# August
def hasAugBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[7]
    return true
  end
end

# September
def hasSepBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[8]
    return true
  end
end

# October
def hasOctBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[9]
    return true
  end
end

# November
def hasNovBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[10]
    return true
  end
end

# December
def hasDecBirthsign?
  if birthsign==$PokemonGlobal.zodiacset[11]
    return true
  end
end

#===============================================================================
# Relative Sign Checks
#===============================================================================
# Returns true if the Pokemon has the zodiac sign relative to the current month
def hasCurrentsign?
  return true if getCalendarsign==Time.now.mon
end

# Returns true if a Pokemon has the Rival sign relative to (value)
# Note: Don't set (value) to a Pokemon, use phShareRivalsign? instead
def hasRivalsign?(value)
  return true if monthsign==zodiacOpposite(value-1)
end

# Returns true if a Pokemon has a Partner sign relative to (value)
# Note: Don't set (value) to  a Pokemon, use phSharePartnersign? instead
def hasPartnersign?(value)
  value-=1
  return true if monthsign==(value+4)%12
  return true if monthsign==(value+8)%12
end

#===============================================================================
# Sign Sharing Checks
#===============================================================================
# Returns true if pkmn1 and pkmn2 share a birthsign
def pbShareBirthsign?(pkmn1,pkmn2)
  return false if pkmn1.birthsign==nil
  return false if pkmn2.birthsign==nil
  if pkmn1.birthsign==pkmn2.birthsign
    return true
  end
end

# Returns true if pkmn1 and pkmn2 share a zodiac sign
def pbShareZodiacsign?(pkmn1,pkmn2)
  return false if pkmn1.monthsign==nil
  return false if pkmn2.monthsign==nil
  if pkmn1.monthsign==pkmn2.monthsign
    return true
  end
end

# Returns true if pkmn1 and pkmn2 share a Rival sign
def pbShareRivalsign?(pkmn1,pkmn2)
  return false if pkmn1.monthsign==nil
  return false if pkmn2.monthsign==nil
  if pkmn1.monthsign==zodiacOpposite(pkmn2.monthsign)
    return true
  end
end

# Returns true if pkmn1 and pkmn2 share a Partner sign
def pbSharePartnersign?(pkmn1,pkmn2)
  return false if pkmn1.monthsign==nil
  return false if pkmn2.monthsign==nil
  return true if pkmn1.monthsign==(pkmn2.monthsign+4)%12 
  return true if pkmn1.monthsign==(pkmn2.monthsign+8)%12
end

#===============================================================================
# Checking for a particular sign
#===============================================================================
# Returns the calander month number associated with a Pokemon's zodiac sign
def getCalendarsign
  if monthsign!=nil
    return (1+monthsign)
  end
end

# Returns the calander month number associated with a Pokemon's rival sign
def getRivalsign
  return (1+zodiacOpposite(self.monthsign))
end

# Returns the calander month numbers associated with a Pokemon's partner signs
# Note: Set (num) to 1 or 2 to get the first or second partner, respectively
def getPartnersign(num)
  return (1+((self.monthsign+4)%12)) if num==1
  return (1+((self.monthsign+8)%12)) if num==2
end

#===============================================================================
# Checks for a particular sign number from a list
#===============================================================================
# Returns the internal month number for each zodiac sign
def monthsign
  if hasJanBirthsign?
    return 0
  elsif hasFebBirthsign?
    return 1
  elsif hasMarBirthsign?
    return 2
  elsif hasAprBirthsign?
    return 3
  elsif hasMayBirthsign?
    return 4
  elsif hasJunBirthsign?
    return 5
  elsif hasJulBirthsign?
    return 6
  elsif hasAugBirthsign?
    return 7
  elsif hasSepBirthsign?
    return 8
  elsif hasOctBirthsign?
    return 9
  elsif hasNovBirthsign?
    return 10
  elsif hasDecBirthsign?
    return 11
  else
    return nil
  end
end
        
#===============================================================================
# Miscellaneous
#===============================================================================
# Returns true if the current day is the user's birthday. (Hatched Pokemon) 
def isBirthday?
  # Determines the current date
  year=Time.now.year
  month=Time.now.mon
  day=Time.now.day
  # Determines date of birth
  birthyear=timeEggHatched.year
  birthmonth=timeEggHatched.mon
  birthday=timeEggHatched.day
  # Determines if there is a match
  if obtainMode==1
    if (birthmonth==month) && (birthday==day) && (birthyear<year)
      return true
    end
  end
end

# Returns true if the current day is the anniversary of the Player's start time.
def pbAnniversaryCheck
  # Determines the current date
  year=Time.now.year
  month=Time.now.mon
  day=Time.now.day
  # Determines date of start time
  startyear=$PokemonGlobal.startTime.year
  startmonth=$PokemonGlobal.startTime.mon
  startday=$PokemonGlobal.startTime.day
  # Determines if there is a match
  if (startmonth==month) && (startday==day) && (startyear<year)
    return true
  end
end

# Checks if a Pokemon is capable of evolution.
def canEvolve?
  return false if isCelestial?
  return false if isConst?(self.species,PBSpecies,:PICHU) && form==1
  return false if isConst?(self.species,PBSpecies,:COMBEE) && isMale?
  return false if isConst?(self.species,PBSpecies,:SALANDIT) && isMale?
  if isConst?(self.species,PBSpecies,:KUBFU)
    if defined?(DARKTOWER_MAP) && $game_map && DARKTOWER_MAP.include?($game_map.map_id)
      return true
    elsif defined?(WATERTOWER_MAP) && $game_map && WATERTOWER_MAP.include?($game_map.map_id)
      return true
    else
      return false
    end
  end
  evos=pbGetEvolvedFormData(pbGetFSpeciesFromForm(self.species,self.form))
  return true if (evos && evos.length>0 && evos!=nil && evos!=self.species)
end

# Checks if a Pokemon has branched evolutions. Burmy male not included.
def canBranchEvolve?
  return false if isCelestial?
  return false if isConst?(self.species,PBSpecies,:NINCADA)
  return false if isConst?(self.species,PBSpecies,:SNORUNT) && isMale?
  return false if isConst?(self.species,PBSpecies,:KIRLIA) && isFemale?
  return false if isConst?(self.species,PBSpecies,:BURMY) && isFemale?
  evos=pbGetEvolvedFormData(pbGetFSpeciesFromForm(self.species,self.form))
  if evos.length>1; return false if evos[0][2]==evos[1][2]; end
  return true if evos.length>1
end
                      
# Checks if a Pokemon is capable of de-evolution.
def canDevolve?
  return false if isCelestial?
  return false if isConst?(self.species,PBSpecies,:SHEDINJA)
  prevo=pbGetPreviousForm(self.species)
  return true if (prevo && prevo!=nil && prevo!=self.species)
end

# Checks if a Pokemon has more than one previous evolutionary stage.
def canBranchDevolve?
  return false if isCelestial?
  prevo=pbGetPreviousForm(self.species)
  baby=pbGetBabySpecies(self.species)
  return true if (baby && baby!=nil && baby!=prevo)
end

# Selects the appropriate form upon evolution
def pbGetEvoForm(pokemon,newpoke,battle=false)
  newform=pokemon.form
  #=============================================================================
  # Alolan Evolved Forms
  #=============================================================================
  alolaEvo = [:PIKACHU,:EXEGGCUTE,:CUBONE]
  for i in alolaEvo
    if (defined?(ALOLAN_MAPS) && $game_map && 
       ALOLAN_MAPS.include?($game_map.map_id)) || ALOLANREGION
      newform=1 if isConst?(pokemon.species,PBSpecies,i)
    end
  end
  #=============================================================================
  # Galarian Evolved Forms
  #=============================================================================
  galarEvo = [:KOFFING,:MIMEJR]
  for i in galarEvo
    if (defined?(GALARIAN_MAPS) && $game_map && 
       GALARIAN_MAPS.include?($game_map.map_id)) || GALARIANREGION
      newform=1 if isConst?(pokemon.species,PBSpecies,i)
    end
  end
  #=============================================================================
  # Galarian De-Evolved Forms
  #=============================================================================
  galarPrevo = [:SIRFETCHD,:MRRIME,:CURSOLA,:OBSTAGOON,:RUNERIGUS]
  for i in galarPrevo
    newform=1 if isConst?(pokemon.species,PBSpecies,i)
  end
  newform=2 if isConst?(pokemon.species,PBSpecies,:PERRSERKER)
  #=============================================================================
  # Miscellaneous forms
  #=============================================================================
  # Lycanroc - Decides evolved form based on time/ability
  if isConst?(pokemon.species,PBSpecies,:ROCKRUFF)
    dusk = (pbGetTimeNow.hour>=17 && pbGetTimeNow.hour<18)
    newform=1 if PBDayNight.isNight?
    newform=2 if isConst?(pokemon.ability,PBAbilities,:OWNTEMPO) && dusk
  end
  # Toxtricity - Decides evolved form based on nature
  if isConst?(pokemon.species,PBSpecies,:TOXEL)
    natures=[:LONELY,:BOLD,:RELAXED,:TIMID,:SERIOUS,:MODEST,
             :MILD,:QUIET,:BASHFUL,:CALM,:GENTLE,:CAREFUL]
    for i in natures
      newform=1 if isConst?(pokemon.nature,PBNatures,i)
    end
  end
  # Urshifu - Decides evolved form based on map location
  if isConst?(pokemon.species,PBSpecies,:KUBFU)
    if defined?(DARKTOWER_MAP) && $game_map && DARKTOWER_MAP.include?($game_map.map_id)
      newform=0
    elsif defined?(WATERTOWER_MAP) && $game_map && WATERTOWER_MAP.include?($game_map.map_id)
      newform=1
    end
  end
  #=============================================================================
  # Returns new species + form when battle=true, otherwise returns form number
  #=============================================================================
  if battle==true
    noform = [:PICHU,:PIKACHU,:EXEGGCUTE,:CUBONE,:KOFFING, # Lose form when devolved
              :MIMEJR,:ROCKRUFF,:TOXEL,:KUBFU,
              :MOTHIM,:PERRSERKER,:SIRFETCHD,:MRRIME,      # Lose form when evolved
              :CURSOLA,:OBSTAGOON,:RUNERIGUS]
    for i in noform
      newform=0 if newpoke==getID(PBSpecies,i)
    end
    return newpoke if newform==0
    if newform>0
      formdata = pbLoadFormsData
      if formdata[newpoke] && formdata[newpoke][newform] && formdata[newpoke][newform]>0
        return formdata[newpoke][newform]
      end
    end
    return newpoke
  else
    return newform
  end
end

# Returns the number of items on the current map (includes hidden).
def pbDetectItemCount
  total = 0
  for event in $game_map.events.values
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    if event.name=="Item" || event.name=="HiddenItem"
      total+=1
    end
  end
  return total
end

# Returns the description of a Pokemon's birthsign effect (Summary)
# Certain signs have different effects depending on the user.
def pbGetBirthsignDesc
  dexdata=pbLoadSpeciesData
  pbGetSpeciesData(dexdata,self.species,SpeciesCompatibility)
  compat10=dexdata.fgetb
  compat11=dexdata.fgetb
  dexdata.close
  abils=getAbilityList
  shedinja=isConst?(self.species,PBSpecies,:SHEDINJA)
  if birthsign==5 && abils.length<=1                  # The Prodigy
    return _INTL("Wild Pokémon with hidden abilities may be lured.")
  elsif birthsign==6 && shedinja                      # The Martyr
    return _INTL("The Pokémon may sacrifice PP to heal a hurt ally.")
  elsif birthsign==17 && shedinja                     # The Cleric
    return _INTL("The Pokémon may sacrifice PP to Cure an ally's status.")
  elsif birthsign==19 && compat10==0                  # The Ancestor
    return _INTL("The Pokémon may Endow a party member with its EV's.")
  elsif birthsign==36 && canDevolve? && !canEvolve?   # The Timelord
    return _INTL("The Pokémon may Rewind its evolutionary history.")
  elsif birthsign==36 && !canEvolve? && !canDevolve?  # The Timelord
    return _INTL("Skips ahead in time, learning moves earlier in battle.")
  else
    return pbGetZodiacDesc(self.birthsign)
  end
end

# Returns the name of a Pokemon's birthsign
def pbGetBirthsignName
  PBBirthsigns.getName(self.birthsign) if hasBirthsign?
end  

# Returns the range of the zodiac month
def pbLastMonthDay
  if hasZodiacsign?
    if hasFebBirthsign?
      return _INTL("1st - 28th")
    elsif hasAprBirthsign? ||
          hasJunBirthsign? ||
          hasSepBirthsign? ||
          hasNovBirthsign?
      return _INTL("1st - 30th")
    else
      return _INTL("1st - 31st")
    end
  else
    return _INTL("Unknown")
  end
end

# Returns the total number of defeated Celestial Bosses
def getBossNum
  ret = 0
  for i in 0...12
    ret+=1 if $PokemonGlobal.celestialboss[i]!=nil
  end
  return ret
end

# Resets celestial boss counter
def pbBossCountReset
  for i in 0..12
    $PokemonGlobal.omegaboss=false
    $PokemonGlobal.celestialboss[i]=nil
  end
end

# Registers a particular month's Celestial Boss
def pbRegisterCelestial(monthnum,signnum)
  $PokemonGlobal.celestialboss[monthnum-1]=signnum
end

#===============================================================================
# Birthsign Command Checks
#===============================================================================
# Returns true if the user has a particular command through a birthsign.
# Used to eliminate redundant commands.
#===============================================================================
# The Beacon
def hasStarlightCmd?
  if hasZodiacsign? && birthsign==3
    return true
  end
end

# The Martyr
def hasCharityCmd?
  if hasZodiacsign? && birthsign==6
    return true
  end
end

# The Voyager
def hasNavigateCmd?
  if hasZodiacsign? && birthsign==9
    return true
  end
end

# The Fugitive
def hasEscapeCmd?
  if hasZodiacsign? && birthsign==15
    return true
  end
end

# The Bard
def hasHarmonizeCmd?
  if hasZodiacsign? && birthsign==25
    return true
  end
end

#===============================================================================
# Zodiac Gems
#===============================================================================
# Defines Zodiac Gems as an item type
def pbIsZodiacGem?(item)
  return $ItemData[item] && $ItemData[item][ITEMTYPE]==15
end

# Returns a zodiac gem out of a list, relative to (month) (0-11)
def getZodiacGem(value)
  gem = [:JANZODICA,:FEBZODICA,:MARZODICA,:APRIZODICA,:MAYZODICA,:JUNZODICA,
         :JULZODICA,:AUGZODICA,:SEPZODICA,:OCTZODICA,:NOVIZODICA,:DECIZODICA]
  zodiacgem=getID(PBItems,gem[value])
  return zodiacgem
end


#===============================================================================
# Birthsigns - Command & Event Resets
#===============================================================================
# Counts steps to reset certain birthsign effects.
#===============================================================================
Events.onStepTaken+=proc {|sender,e|
  # The Prodigy
  if $PokemonGlobal.resetBirthsignAbilLure && $PokemonGlobal.resetBirthsignAbilLure>0
    $PokemonGlobal.resetBirthsignAbilLure -= 1
    if $PokemonGlobal.resetBirthsignAbilLure<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(5)))
    end
  end
  
  # Ability Lure duration
  if $PokemonGlobal.timerAbilLure && $PokemonGlobal.timerAbilLure>0
    $PokemonGlobal.timerAbilLure -= 1
    if $PokemonGlobal.timerAbilLure<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> wore off...",
      PBBirthsigns.getName(5)))
    end
  end
  
  # The Monk
  if $PokemonGlobal.resetBirthsignTrance && $PokemonGlobal.resetBirthsignTrance>0
    $PokemonGlobal.resetBirthsignTrance -= 1
    if $PokemonGlobal.resetBirthsignTrance<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(18)))
    end
  end
  
  # The Parent
  if $PokemonGlobal.resetBirthsignIncubate && $PokemonGlobal.resetBirthsignIncubate>0
    $PokemonGlobal.resetBirthsignIncubate -= 1
    if $PokemonGlobal.resetBirthsignIncubate<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(22)))
    end
  end
  
  # The Bard
  if $PokemonGlobal.resetBirthsignHarmonize && $PokemonGlobal.resetBirthsignHarmonize>0
    $PokemonGlobal.resetBirthsignHarmonize -= 1
    if $PokemonGlobal.resetBirthsignHarmonize<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(25)))
    end
  end
  
  # The Cultist
  if $PokemonGlobal.resetBirthsignSummon && $PokemonGlobal.resetBirthsignSummon>0
    $PokemonGlobal.resetBirthsignSummon -= 1
    if $PokemonGlobal.resetBirthsignSummon<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(33)))
    end
  end
  
  # The Timelord
  if $PokemonGlobal.resetBirthsignTimeskip && $PokemonGlobal.resetBirthsignTimeskip>0
    $PokemonGlobal.resetBirthsignTimeskip -= 1
    if $PokemonGlobal.resetBirthsignTimeskip<=0
      Kernel.pbMessage(_INTL("The power of <c2=65467b14>{1}</c2> has recharged!",
      PBBirthsigns.getName(36)))
    end
  end
  
  # Celestial Blessing
  if $PokemonGlobal.resetCelestialSkill && $PokemonGlobal.resetCelestialSkill>0
    $PokemonGlobal.resetCelestialSkill -= 1
    if $PokemonGlobal.resetCelestialSkill<=0
      Kernel.pbMessage(_INTL("The power of the <c2=65467b14>Celestial's Blessing</c2> has recharged!"))
    end
  end
  
  # Fortune Teller
  if $PokemonGlobal.resetFortuneTeller && $PokemonGlobal.resetFortuneTeller>0
    $PokemonGlobal.resetFortuneTeller -= 1
  end
}

#===============================================================================
# Sets the reset step counter for 'The Prodigy' to 1,000 steps on use.
#===============================================================================
def pbCanUseBirthsignAbilLure?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignAbilLure && $PokemonGlobal.resetBirthsignAbilLure>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectAbilLure
  if pbCanUseBirthsignAbilLure?
    $PokemonGlobal.resetBirthsignAbilLure = 1000
    return true
  end
  return false
end

# Ability Lure duration set to 200 steps
def pbAbilLureEffectActive?
  if $PokemonGlobal.timerAbilLure && $PokemonGlobal.timerAbilLure>0
    return true
  else
    return false
  end
end
  
def pbActivateAbilLureEffect
  $PokemonGlobal.timerAbilLure = 200
end

#===============================================================================
# Sets the reset step counter for 'The Monk' to 1,000 steps on use.
#===============================================================================
def pbCanUseBirthsignTrance?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignTrance && $PokemonGlobal.resetBirthsignTrance>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectTrance
  if pbCanUseBirthsignTrance?
    $PokemonGlobal.resetBirthsignTrance = 1000
    return true
  end
  return false
end

#===============================================================================
# Sets the reset step counter for 'The Parent' to 1,000 steps on use.
#===============================================================================
def pbCanUseBirthsignIncubate?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignIncubate && $PokemonGlobal.resetBirthsignIncubate>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectIncubate
  if pbCanUseBirthsignIncubate?
    $PokemonGlobal.resetBirthsignIncubate = 1000
    return true
  end
  return false
end

#===============================================================================
# Sets the reset step counter for 'The Bard' to 400 steps on use.
#===============================================================================
def pbCanUseBirthsignHarmonize?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignHarmonize && $PokemonGlobal.resetBirthsignHarmonize>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectHarmonize
  if pbCanUseBirthsignHarmonize?
    $PokemonGlobal.resetBirthsignHarmonize = 400
    return true
  end
  return false
end

#===============================================================================
# Sets the reset step counter for 'The Cultist' to 3,000 steps on use.
#===============================================================================
def pbCanUseBirthsignSummon?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignSummon && $PokemonGlobal.resetBirthsignSummon>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectSummon
  if pbCanUseBirthsignSummon?
    $PokemonGlobal.resetBirthsignSummon = 3000
    return true
  end
  return false
end

#===============================================================================
# Sets the reset step counter for 'The Timelord' to 10,000 steps on use.
#===============================================================================
def pbCanUseBirthsignTimeskip?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetBirthsignTimeskip && $PokemonGlobal.resetBirthsignTimeskip>0
    return false
  end
  return true
end
  
def pbUseBirthsignEffectTimeskip
  if pbCanUseBirthsignTimeskip?
    $PokemonGlobal.resetBirthsignTimeskip = 10000
    return true
  end
  return false
end

#===============================================================================
# Sets the reset step counter for Celestial Blessings to 5,000 steps on use.
#===============================================================================
def pbCanUseCelestialSkill?
  return true if $DEBUG && Input.press?(Input::CTRL)
  if $PokemonGlobal.resetCelestialSkill && $PokemonGlobal.resetCelestialSkill>0
    return false
  end
  return true
end
  
def pbUseCelestialSkill
  if pbCanUseCelestialSkill?
    $PokemonGlobal.resetCelestialSkill = 5000
    return true
  end
  return false
end

#===============================================================================
# Sets the step duration for the Fortune Teller effect to 2,500 steps on use.
#===============================================================================
def pbFortuneEffectActive?
  if $PokemonGlobal.resetFortuneTeller && $PokemonGlobal.resetFortuneTeller>0
    return true
  else
    return false
  end
end
  
def pbActivateFortuneEffect
  $PokemonGlobal.resetFortuneTeller = 2500
end


############[MISCELLANEOUS]#####################################################
#===============================================================================
# Ritual Animation. Same as the Hidden Moves animation, with new graphics.
#===============================================================================
def pbRitualAnimation(pokemon)
  return false if !pokemon
  viewport=Viewport.new(0,0,0,0)
  viewport.z=99999
  bg=Sprite.new(viewport)
  bg.bitmap=BitmapCache.load_bitmap("Graphics/Pictures/Birthsigns/Other/ritualbg")
  sprite=PokemonSprite.new(viewport)
  sprite.setOffset(PictureOrigin::Center)
  sprite.setPokemonBitmap(pokemon)
  sprite.z=1
  sprite.visible=false
  strobebitmap=AnimatedBitmap.new("Graphics/Pictures/Birthsigns/Other/ritualStrobes")
  strobes=[]
  15.times do |i|
    strobe=BitmapSprite.new(26*2,8*2,viewport)
    strobe.bitmap.blt(0,0,strobebitmap.bitmap,Rect.new(0,(i%2)*8*2,26*2,8*2))
    strobe.z=((i%2)==0 ? 2 : 0)
    strobe.visible=false
    strobes.push(strobe)
  end
  strobebitmap.dispose
  interp=RectInterpolator.new(
    Rect.new(0,Graphics.height/2,Graphics.width,0),
    Rect.new(0,(Graphics.height-bg.bitmap.height)/2,Graphics.width,bg.bitmap.height),
    10)
  ptinterp=nil
  phase=1
  frames=0
  begin
    Graphics.update
    Input.update
    sprite.update
    case phase
    when 1 # Expand viewport height from zero to full
      interp.update
      interp.set(viewport.rect)
      bg.oy=(bg.bitmap.height-viewport.rect.height)/2
      if interp.done?
        phase=2
        ptinterp=PointInterpolator.new(
          Graphics.width+(sprite.bitmap.width/2),bg.bitmap.height/2,
          Graphics.width/2,bg.bitmap.height/2,
          16)
      end
    when 2 # Slide Pokémon sprite in from right to centre
      ptinterp.update
      sprite.x=ptinterp.x
      sprite.y=ptinterp.y
      sprite.visible=true
      if ptinterp.done?
        phase=3
        pbPlayCry(pokemon)
        frames=0
      end
    when 3 # Wait
      frames+=1
      if frames>30
        phase=4
        ptinterp=PointInterpolator.new(
          Graphics.width/2,bg.bitmap.height/2,
          -(sprite.bitmap.width/2),bg.bitmap.height/2,
          16)
        frames=0
      end
    when 4 # Slide Pokémon sprite off from centre to left
      ptinterp.update
      sprite.x=ptinterp.x
      sprite.y=ptinterp.y
      if ptinterp.done?
        phase=5
        sprite.visible=false
        interp=RectInterpolator.new(
          Rect.new(0,(Graphics.height-bg.bitmap.height)/2,Graphics.width,bg.bitmap.height),
          Rect.new(0,Graphics.height/2,Graphics.width,0),
          10)
      end
    when 5 # Shrink viewport height from full to zero
      interp.update
      interp.set(viewport.rect)
      bg.oy=(bg.bitmap.height-viewport.rect.height)/2
      phase=6 if interp.done?    
    end
    for strobe in strobes
      strobe.ox=strobe.viewport.rect.x
      strobe.oy=strobe.viewport.rect.y
      if !strobe.visible
        randomY=16*(1+rand(bg.bitmap.height/16-2))
        strobe.y=randomY+(Graphics.height-bg.bitmap.height)/2
        strobe.x=rand(Graphics.width)
        strobe.visible=true
      elsif strobe.x<Graphics.width
        strobe.x+=32
      else
        randomY=16*(1+rand(bg.bitmap.height/16-2))
        strobe.y=randomY+(Graphics.height-bg.bitmap.height)/2
        strobe.x=-strobe.bitmap.width-rand(Graphics.width/4)
      end
    end
    pbUpdateSceneMap
  end while phase!=6
  sprite.dispose
  for strobe in strobes
    strobe.dispose
  end
  strobes.clear
  bg.dispose
  viewport.dispose
  return true
end
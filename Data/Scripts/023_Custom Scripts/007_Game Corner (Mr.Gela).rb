#===============================================================================
# Game Corner Helper by Kiedisticelixer (Discord: Jteo#5809)
#===============================================================================
# I think I do a good job at explaining stuff for educational purposes, 
# but feel free to reply to the resource's thread for assistance or guidance.
# Things you may learn with this code if you pay attention to it:
# - How do arrays inside arrays work (e.g. 'index' inside 'mode')
# - How to process text and the use of "#{variablename}", \ch and += in strings
#===============================================================================
def gameCornerShop(mode,index,gender=0,level=15)
  
  # Usage: In a Script Call as "gameCornerShop(mode,index,gender,level)"
  # Gender: 0 (default) black text, 1 (M) for blue text, 2 (F) for red text
  # E.g. "gameCornerShop(0,1,2)" to call the TMs list with a red text NPC.
  # When calling the Pokémon shop, you can OPTIONALLY add the level at which 
  # they should be acquired, such as "gameCornerShop(1,0,0,30)", 
  # to get the Abra list, and receive them at level 30 with default text color.

  # Begin Configuration ========================================================
  
  # Prizes configuration:
    # List of items in internal name
    # Price of items
    # List of Pokémon in internal names
    # Price of Pokémon
  # (!)Do NOT remove the last zero and add any other prizes or prices before it.
  list=[ 
  # I'm splitting it into two large arrays ("mode"), to process whether it's an 
  # item or a Pokémon (PBItems or PBSpecies) without more complex code wizardry.
  
  # Mode 0 (Items)
      [
      # Index 0
      [:SMOKEBALL,:MIRACLESEED,:CHARCOAL,:MYSTICWATER,:YELLOWFLUTE,0],
      # Index 1
      [:TM51,TM64,:TM75,:TM87,:TM90,0],
      # Index 2
      [:LEMONADE,:MOOMOOMILK,0],
      [800,1000,1000,1000,1600,0],    # Index 0 Prices
      [5000,3500,4000,4500,5000,0],   # Index 1 Prices
      [50,60,0]                       # Index 2 Prices
      ],
  # Mode 1 (Pokémon)
      [
      # Index 0
      [:CLEFAIRY,:MAGNEMITE,:GLIGAR,:MUNCHLAX,0],
      # Index 1
      [:EKANS,:CUBONE,:WOBBUFFET,0],
      # Index 2
      [:EEVEE,:TOGEPI,0],
      [500,2000,4000,5500,0],         # Index 0 Prices
      [700,800,1500,0],               # Index 1 Prices
      [1000,2000,0]                   # Index 2 Prices
      ]]
  # Speech strings (for ease of typing) in this order:
    # Greeting, Choosing a prize, What the player can select to cancel and exit,
    # Confirming prize (lacks the question mark on purpose), Bag is full, 
  strings=[
    "We exchange your coins for prizes.",
    "Which prize would you like?",
    "No thanks",
    "So, you want the ",
    "Sorry, you'll need more coins than that.",
    "You have no room in your Bag."]
    
  # End Configuration ==========================================================

  
  # Process gender (0 to 2) into '\b' or '\r'
    # (!) Keep in mind text codes need an additional '\' in here. (e.g. "\\b")
  
  gendercode=""
  case gender
  when 0
    # Do nothing
  when 1
    # Write "\b" for blue (male) speech
    gendercode="\\b"
  when 2
    # Write "\r" for red (female) speech
    gendercode="\\r"
  end

  # Pre-process text
  # All the text and options are processed before choosing text so that there
  # is no "lag" between the "greeting" and choosing a prize, for smoothness.
  text="\\CN#{gendercode}#{strings[0]}"
  text_0="\\CN#{gendercode}#{strings[1]}\\ch[1,{listlength},"

  # Add each element in the list, then the "Cancel" message
  #listlength-=-1 # To not count the "Cancel" message (the last 0 in the arrays)
  prizename=""
  for i in 0...list[mode][index].length-1#0..list[mode][index].length
    if mode==0    # Item
      item=list[mode][index][i]
      itemid=getID(PBItems,item)
      prizename=PBItems.getName(itemid)
      price=list[mode][index+3][i]
    elsif mode==1 # Pokémon
      item=list[mode][index][i]
      itemid=getID(PBSpecies,item)
      prizename=PBSpecies.getName(itemid)
      price=list[mode][index+3][i]
    end
     text_0+="#{prizename} - #{price} coins,"
  end
  
  text_0+="#{strings[2]}"
  text_0+="]"
  
  # Actually show the messages and let the player choose and receive a prize
  Kernel.pbMessage(_INTL("{1}",text))
  Kernel.pbMessage(_INTL("{1}",text_0))
  choice=$game_variables[1] # For ease of typing
  if choice!=list[mode][index].length-1 # Unless cancelled
    if mode==0    # Item
      item=list[mode][index][choice]
      itemid=getID(PBItems,item)
      prizename=PBItems.getName(itemid)
      price=list[mode][index+3][i]
    elsif mode==1 # Pokémon
      item=list[mode][index][choice]
      itemid=getID(PBSpecies,item)
      prizename=PBSpecies.getName(itemid)
      price=list[mode][index+3][i]
    end
  text_1="\\CN#{gendercode}#{strings[3]}#{prizename}?\\ch[2,-1,Yes,No]"
  Kernel.pbMessage(_INTL("{1}",text_1))
  yesno=$game_variables[2]
    if yesno!=1 # Unless "No"
      # Calculate price in coins
      price=list[mode][index+3][choice]
      # Not enough coins
      if price>$PokemonGlobal.coins
        text_2="\\CN#{gendercode}#{strings[4]}"
        Kernel.pbMessage(_INTL("{1}",text_2))
      # Full Bag and mode==0 (items mode)
      elsif !$PokemonBag.pbCanStore?(itemid) && mode==0
        text_3="\\CN#{gendercode}#{strings[5]}"
        Kernel.pbMessage(_INTL("{1}",text_3))
      else
      # Pay for your prize (in coins)
      $PokemonGlobal.coins-=price
      # Give prize
        # Give chosen item
        if mode==0
          Kernel.pbReceiveItem(itemid)
        # Give chosen Pokémon
        elsif mode==1
        p=PokeBattle_Pokemon.new(itemid,level,$Trainer)
          # Bonus - You may edit the Pokémon easily with a simple template
          if p.name=="Eevee" # Too lazy to check for IDs or internal names
            p.setItem(:SILKSCARF)
            p.makeFemale
            p.makeShiny
            p.pbLearnMove(:WISH)
            p.calcStats
          end
        Kernel.pbAddPokemon(p)
        end
      end
    end
  end
end
# Wahee!
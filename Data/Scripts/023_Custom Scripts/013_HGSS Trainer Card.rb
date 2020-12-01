# Overhauls the classic Trainer Card from Pokémon Essentials
class PokeBattle_Trainer
  # These need to be initialized
  # A swinging number, increases and decreases with progress
  attr_accessor(:score) 
  # Changes the Trainer Card, similar to achievements
  attr_accessor(:stars) 
  # Battle Points, if you wish to use them
  attr_accessor(:bp) 
  # Date and time
  attr_accessor(:halloffame)  
  # Fake Trainer Class
  attr_accessor(:tclass) 
  
  def score
    @score=0 if !@score
    return @score
  end
  
  def stars
    @stars=0 if !@stars
    return @stars
  end
    
  def bp
    @bp=0 if !@bp
    return @bp
  end
  
  def halloffame
    @halloffame=[] if !@halloffame
    return @halloffame
  end
  
  def tclass
    @tclass="PKMN Trainer" if !@tclass
    return @tclass
  end
  
  def publicID(id=nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end
  
  def fullname2
    return _INTL("{1} {2}",$Trainer.tclass,$Trainer.name)
  end
  
  def initialize(name,trainertype)
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @metaID=0
    @outfit=0
    @pokegear=false
    @pokedex=false
    clearPokedex
    @shadowcaught=[]
    for i in 1..PBSpecies.maxValue
      @shadowcaught[i]=false
    end
    @badges=[]
    for i in 0...8
      @badges[i]=false
    end
    @money=INITIAL_MONEY
    @party=[]
    @score=0
    @stars=0
    @bp=0
    @halloffame=[]
    @tclass="PKMN Trainer"
  end
  
  def getForeignID(number=nil)   # Random ID other than this Trainer's ID
    fid=0
    fid=number if number!=nil
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid 
  end

  def setForeignID(other,number=nil)
    @id=other.getForeignID(number)
  end
end

class HallOfFame_Scene # Minimal change to store HoF time into a variable
  
  def writeTrainerData
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    # Store time of first Hall of Fame in $Trainer.halloffame if not array is empty
    if $Trainer.halloffame=[]
      $Trainer.halloffame.push(pbGetTimeNow) 
      $Trainer.halloffame.push(totalsec)
    end
    pubid=sprintf("%05d",$Trainer.publicID($Trainer.id))
    lefttext= _INTL("Name<r>{1}<br>",$Trainer.name)
    lefttext+=_INTL("IDNo.<r>{1}<br>",pubid)
    lefttext+=_ISPRINTF("Time<r>{1:02d}:{2:02d}<br>",hour,min)
    lefttext+=_INTL("Pokédex<r>{1}/{2}<br>",
        $Trainer.pokedexOwned,$Trainer.pokedexSeen)
    @sprites["messagebox"]=Window_AdvancedTextPokemon.new(lefttext)
    @sprites["messagebox"].viewport=@viewport
    @sprites["messagebox"].width=192 if @sprites["messagebox"].width<192
    @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
        _INTL("League champion!\nCongratulations!\\^"))
  end  
  
end

class PokemonTrainerCard_Scene
  
  # Waits x frames
  def wait(frames)
    frames.times do
    Graphics.update
    end
  end
      
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"]
      @sprites["bg"].ox-=2
      @sprites["bg"].oy-=2
    end
  end

  def pbStartScene
    @front=true
    @flip=false
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites,"bg","Trainer Card/bg",@viewport)
    @sprites["card"] = IconSprite.new(336,240,@viewport)
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_#{$Trainer.stars}")
    @sprites["card"].zoom_x=2 ; @sprites["card"].zoom_y=2
    
    @sprites["card"].ox=@sprites["card"].bitmap.width/2
    @sprites["card"].oy=@sprites["card"].bitmap.height/2
    
    @sprites["bg"].zoom_x=2 ; @sprites["bg"].zoom_y=2
    @sprites["bg"].ox+=6
    @sprites["bg"].oy-=26
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay2"].bitmap)
    
    @sprites["overlay"].x=336
    @sprites["overlay"].y=240
    @sprites["overlay"].ox=@sprites["overlay"].bitmap.width/2
    @sprites["overlay"].oy=@sprites["overlay"].bitmap.height/2
    
    @sprites["help_overlay"] = IconSprite.new(0,Graphics.height-48,@viewport)
    @sprites["help_overlay"].setBitmap("Graphics/Pictures/Trainer Card/overlay_0")
    @sprites["help_overlay"].zoom_x=2 ; @sprites["help_overlay"].zoom_y=2
    @sprites["trainer"] = IconSprite.new(336,112,@viewport)
    @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2+36-4
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)+80+4
    @sprites["trainer"].x += 120+140
    @sprites["trainer"].y += 80+32
    @tx=@sprites["trainer"].x
    @ty=@sprites["trainer"].y
    
    @sprites["trainer"].ox=@sprites["trainer"].bitmap.width/2


    
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  
  def flip1
    # "Flip"
    15.times do
      @sprites["overlay"].zoom_y=1.03
      @sprites["card"].zoom_y=2.06
      @sprites["overlay"].zoom_x-=0.1
      @sprites["trainer"].zoom_x-=0.2
      @sprites["trainer"].x-=12
      @sprites["card"].zoom_x-=0.15
      pbUpdate
      wait(1)
    end
      pbUpdate
  end
  
  def flip2
    # UNDO "Flip"
    15.times do
      @sprites["overlay"].zoom_x+=0.1
      @sprites["trainer"].zoom_x+=0.2
      @sprites["trainer"].x+=12
      @sprites["card"].zoom_x+=0.15
      @sprites["overlay"].zoom_y=1
      @sprites["card"].zoom_y=2
      pbUpdate
      wait(1)
    end
      pbUpdate
  end

  def pbDrawTrainerCardFront
    flip1 if @flip==true
    @front=true
    @sprites["trainer"].visible=true
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_#{$Trainer.stars}")
    @overlay  = @sprites["overlay"].bitmap
    @overlay2 = @sprites["overlay2"].bitmap
    @overlay.clear
    @overlay2.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    baseGold = Color.new(255,198,74)
    shadowGold = Color.new(123,107,74)
    if $Trainer.stars==5
      baseColor   = baseGold
      shadowColor = shadowGold
    end
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = _ISPRINTF("{1:02d}:{2:02d}",hour,min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    textPositions = [
       [_INTL("NAME"),272+94,48,0,baseColor,shadowColor],
       [$Trainer.name,480+RXMOD,48,1,baseColor,shadowColor],
       [_INTL("ID No."),32,48,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.publicID($Trainer.id)),284,48,1,baseColor,shadowColor],
       [_INTL("MONEY"),32,96,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money.to_s_formatted),304+128,96,1,baseColor,shadowColor],
       [_INTL("STRING 1"),32,144+41,0,baseColor,shadowColor],
       [sprintf("%d",$game_variables[100]),304+128,144+41,1,baseColor,shadowColor],
       [_INTL("SCORE"),32,208+59,0,baseColor,shadowColor],
       [sprintf("%d",$Trainer.score),304+128,208+59,1,baseColor,shadowColor],
       [_INTL("TIME"),32,259+RYMOD,0,baseColor,shadowColor],
       [time,478+RXMOD,259+RYMOD,1,baseColor,shadowColor],
       [_INTL("ADVENTURE STARTED"),32,291+RYMOD,0,baseColor,shadowColor],
       [starttime,480+RXMOD,291+RYMOD,1,baseColor,shadowColor]
    ]
    @sprites["overlay"].z+=10
    pbDrawTextPositions(@overlay,textPositions)
    textPositions = [
      [_INTL("Press Z to flip the card."),16,64+280+RYMOD,0,Color.new(216,216,216),Color.new(80,80,80)]
    ]
    @sprites["overlay2"].z+=20
    pbDrawTextPositions(@overlay2,textPositions)
    flip2 if @flip==true
  end
  
  def pbDrawTrainerCardBack
    pbUpdate
    @flip=true
    flip1
    @front=false
    @sprites["trainer"].visible=false
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_#{$Trainer.stars}b")
    @overlay  = @sprites["overlay"].bitmap
    @overlay2 = @sprites["overlay2"].bitmap
    @overlay.clear
    @overlay2.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    baseGold = Color.new(255,198,74)
    shadowGold = Color.new(123,107,74)
    if $Trainer.stars==5
      baseColor   = baseGold
      shadowColor = shadowGold
    end
    hof=[]
    if $Trainer.halloffame!=[]
      hof.push(_INTL("{1} {2}, {3}",
      pbGetAbbrevMonthName($Trainer.halloffame[0].mon),
      $Trainer.halloffame[0].day,
      $Trainer.halloffame[0].year))
      hour = $Trainer.halloffame[1] / 60 / 60
      min = $Trainer.halloffame[1] / 60 % 60
      time=_ISPRINTF("{1:02d}:{2:02d}",hour,min)
      hof.push(time)
    else
      hof.push("--- --, ----")
      hof.push("--:--")
    end
    if $game_switches[45]
    textPositions = [
      [_INTL("HALL OF FAME DEBUT"),32,16,0,baseColor,shadowColor],
      [hof[0],480+RXMOD,16,1,baseColor,shadowColor],
      [hof[1],480+RXMOD,48,1,baseColor,shadowColor],
      # These are meant to be Link Battle modes, use as you wish, see below
      #[_INTL(" "),254,96,0,baseColor,shadowColor],
      #[_INTL(" "),384,96,0,baseColor,shadowColor],
      
      # Customize "$game_variables[100]" to use whatever variable you'd like
      # Some examples: eggs hatched, berries collected,
      # total steps (maybe converted to km/miles? Be creative, dunno!)
      # Pokémon defeated, shiny Pokémon encountered, etc.
      # While I do not include how to create those variables, feel free to HMU
      # if you need some support in the process, or reply to the Relic Castle
      # thread.
      
      [_INTL($Trainer.fullname2),32,96+RYMOD,0,baseColor,shadowColor],
      #[_INTL(" ",$game_variables[100]),352,96,1,baseColor,shadowColor],
      #[_INTL(" ",$game_variables[100]),480,96,1,baseColor,shadowColor],
      [_INTL("Light Path"),32,128+RYMOD,0,baseColor,shadowColor],
      [_INTL("{1}",$game_variables[74]),480+RXMOD,128+RYMOD,1,baseColor,shadowColor],
      
      [_INTL("Dark Path"),32,160+RYMOD,0,baseColor,shadowColor],
      [_INTL("{1}",$game_variables[930]),480+RXMOD,160+RYMOD,1,baseColor,shadowColor],
    ]
    else
    textPositions = [
      [_INTL("HALL OF FAME DEBUT"),32,16,0,baseColor,shadowColor],
      [hof[0],480+RXMOD,16,1,baseColor,shadowColor],
      [hof[1],480+RXMOD,48,1,baseColor,shadowColor],
      # These are meant to be Link Battle modes, use as you wish, see below
      #[_INTL(" "),254,96,0,baseColor,shadowColor],
      #[_INTL(" "),384,96,0,baseColor,shadowColor],
      
      # Customize "$game_variables[100]" to use whatever variable you'd like
      # Some examples: eggs hatched, berries collected,
      # total steps (maybe converted to km/miles? Be creative, dunno!)
      # Pokémon defeated, shiny Pokémon encountered, etc.
      # While I do not include how to create those variables, feel free to HMU
      # if you need some support in the process, or reply to the Relic Castle
      # thread.
      
      [_INTL($Trainer.fullname2),32,96+RYMOD,0,baseColor,shadowColor],
      #[_INTL(" ",$game_variables[100]),352,96,1,baseColor,shadowColor],
      #[_INTL(" ",$game_variables[100]),480,96,1,baseColor,shadowColor],
      [_INTL("Light Path"),32,128+RYMOD,0,baseColor,shadowColor],
      [_INTL("???"),480+RXMOD,128+RYMOD,1,baseColor,shadowColor],
      
      [_INTL("Dark Path"),32,160+RYMOD,0,baseColor,shadowColor],
      [_INTL("???"),480+RXMOD,160+RYMOD,1,baseColor,shadowColor],
    ]
    end
    @sprites["overlay"].z+=20
    pbDrawTextPositions(@overlay,textPositions)
    textPositions = [
      [_INTL("Press Z to flip the card."),16,64+280+RYMOD,0,Color.new(216,216,216),Color.new(80,80,80)]
    ]
    @sprites["overlay2"].z+=20
    pbDrawTextPositions(@overlay2,textPositions)
    # Draw Badges on overlay (doesn't support animations, might support .gif)
    imagepos=[]
    # Draw Region 0 badges
    x = 36
    for i in 0...7
      if $Trainer.badges[i+0*7]
        imagepos.push(["Graphics/Pictures/Trainer Card/badges0",x,208+RYMOD,i*92,0*62,48,48])
      end
      x += 92
    end
    # Draw Region 1 badges
    x = 36
    for i in 0...7
      if $Trainer.badges[i+1*7]
        imagepos.push(["Graphics/Pictures/Trainer Card/badges1",x,270+RYMOD,i*92,0*62,48,48])
      end
      x += 92
    end
    #print(@sprites["overlay"].ox,@sprites["overlay"].oy,x)
    pbDrawImagePositions(@overlay,imagepos)
    flip2
  end

  def pbTrainerCard
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::A)
        if @front==true
          pbDrawTrainerCardBack 
          wait(3)
        else
          pbDrawTrainerCardFront if @front==false
          wait(3)
        end
      end
      if Input.trigger?(Input::B)
        break
      end
    end 
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end

def pbStarCount
  $Trainer.halloffame=[]
  $Trainer.stars=0
end
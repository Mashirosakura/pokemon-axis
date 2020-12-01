################################################################################
# PokeBattle_BattlePeer                                                        #
################################################################################
#===============================================================================
# PokeBattle_RealBattlePeer
#===============================================================================
class PokeBattle_RealBattlePeer
  def pbStorePokemon(player,pkmn)
   if $Trainer.partyplus
    if player.party.length<8
      player.party[player.party.length] = pkmn
      return -1
    end
   else
    if player.party.length<6
      player.party[player.party.length] = pkmn
      return -1
    end
   end
    pkmn.heal
    oldCurBox = pbCurrentBox
    storedBox = $PokemonStorage.pbStoreCaught(pkmn)
    if storedBox<0
      # NOTE: Poké Balls can't be used if storage is full, so you shouldn't ever
      #       see this message.
      pbDisplayPaused(_INTL("Can't catch any more..."))
      return oldCurBox
    end
    return storedBox
  end
  def pbGetStorageCreatorName
    return pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    return nil
  end
  def pbCurrentBox
    return $PokemonStorage.currentBox
  end
  def pbBoxName(box)
    return (box<0) ? "" : $PokemonStorage[box].name
  end
end
################################################################################
# PField_DayCare                                                               #
################################################################################
#===============================================================================
# Manipulate Pokémon in the Day Care.
#===============================================================================
def pbDayCareWithdraw(index)
 if $Trainer.partyplus
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  elsif $Trainer.party.length>=8
    raise _INTL("Can't store the Pokémon...")
  else
    $Trainer.party[$Trainer.party.length] = $PokemonGlobal.daycare[index][0]
    $PokemonGlobal.daycare[index][0] = nil
    $PokemonGlobal.daycare[index][1] = 0
    $PokemonGlobal.daycareEgg = 0
  end
 else
  if !$PokemonGlobal.daycare[index][0]
    raise _INTL("There's no Pokémon here...")
  elsif $Trainer.party.length>=6
    raise _INTL("Can't store the Pokémon...")
  else
    $Trainer.party[$Trainer.party.length] = $PokemonGlobal.daycare[index][0]
    $PokemonGlobal.daycare[index][0] = nil
    $PokemonGlobal.daycare[index][1] = 0
    $PokemonGlobal.daycareEgg = 0
  end
 end
end
#===============================================================================
# Generate an Egg based on Pokémon in the Day Care.
#===============================================================================
def pbDayCareGenerateEgg
  return if pbDayCareDeposited!=2
  if $Trainer.partyplus
  raise _INTL("Can't store the egg") if $Trainer.party.length>=8
  else
  raise _INTL("Can't store the egg") if $Trainer.party.length>=6
  end
  pokemon0 = $PokemonGlobal.daycare[0][0]
  pokemon1 = $PokemonGlobal.daycare[1][0]
  mother = nil
  father = nil
  babyspecies = 0
  ditto0 = pbIsDitto?(pokemon0)
  ditto1 = pbIsDitto?(pokemon1)
  if pokemon0.female? || ditto0
    babyspecies = (ditto0) ? pokemon1.species : pokemon0.species
    mother = pokemon0
    father = pokemon1
  else
    babyspecies = (ditto1) ? pokemon0.species : pokemon1.species
    mother = pokemon1
    father = pokemon0
  end
  # Determine the egg's species
  babyspecies = pbGetBabySpecies(babyspecies,mother.item,father.item)
  if isConst?(babyspecies,PBSpecies,:MANAPHY) && hasConst?(PBSpecies,:PHIONE)
    babyspecies = getConst(PBSpecies,:PHIONE)
  elsif (isConst?(babyspecies,PBSpecies,:NIDORANfE) && hasConst?(PBSpecies,:NIDORANmA)) ||
        (isConst?(babyspecies,PBSpecies,:NIDORANmA) && hasConst?(PBSpecies,:NIDORANfE))
    babyspecies = [getConst(PBSpecies,:NIDORANmA),
                   getConst(PBSpecies,:NIDORANfE)][rand(2)]
  elsif (isConst?(babyspecies,PBSpecies,:VOLBEAT) && hasConst?(PBSpecies,:ILLUMISE)) ||
        (isConst?(babyspecies,PBSpecies,:ILLUMISE) && hasConst?(PBSpecies,:VOLBEAT))
    babyspecies = [getConst(PBSpecies,:VOLBEAT),
                   getConst(PBSpecies,:ILLUMISE)][rand(2)]
  end
  # Generate egg
  egg = pbNewPkmn(babyspecies,EGG_LEVEL)
  # Randomise personal ID
  pid = rand(65536)
  pid |= (rand(65536)<<16)
  egg.personalID = pid
  # Inheriting form
  if isConst?(babyspecies,PBSpecies,:BURMY) ||
     isConst?(babyspecies,PBSpecies,:SHELLOS) ||
     isConst?(babyspecies,PBSpecies,:BASCULIN) ||
     isConst?(babyspecies,PBSpecies,:FLABEBE) ||
     isConst?(babyspecies,PBSpecies,:PUMPKABOO) ||
     isConst?(babyspecies,PBSpecies,:ORICORIO) ||
     isConst?(babyspecies,PBSpecies,:ROCKRUFF) ||
     isConst?(babyspecies,PBSpecies,:MINIOR)
    newForm = mother.form
    newForm = 0 if mother.isSpecies?(:MOTHIM)
    egg.form = newForm
  end
  # Inheriting Alolan form
  if isConst?(babyspecies,PBSpecies,:RATTATA) ||
     isConst?(babyspecies,PBSpecies,:SANDSHREW) ||
     isConst?(babyspecies,PBSpecies,:VULPIX) ||
     isConst?(babyspecies,PBSpecies,:DIGLETT) ||
     isConst?(babyspecies,PBSpecies,:MEOWTH) ||
     isConst?(babyspecies,PBSpecies,:GEODUDE) ||
     isConst?(babyspecies,PBSpecies,:GRIMER)
    if mother.form==1
      egg.form = 1 if mother.hasItem?(:EVERSTONE)
    elsif pbGetBabySpecies(father.species,mother.item,father.item)==babyspecies
      egg.form = 1 if father.form==1 && father.hasItem?(:EVERSTONE)
    end
  end
  # Inheriting Moves
  moves = []
  othermoves = []
  movefather = father; movemother = mother
  if pbIsDitto?(movefather) && !mother.female?
    movefather = mother; movemother = father
  end
  # Initial Moves
  initialmoves = egg.getMoveList
  for k in initialmoves
    if k[0]<=EGG_LEVEL
      moves.push(k[1])
    else
      next if !mother.hasMove?(k[1]) || !father.hasMove?(k[1])
      othermoves.push(k[1])
    end
  end
  # Inheriting Natural Moves
  for move in othermoves
    moves.push(move)
  end
  # Inheriting Machine Moves
  if !NEWEST_BATTLE_MECHANICS
    itemsData = pbLoadItemsData
    for i in 0...itemsData.length
      next if !itemsData[i]
      atk = itemsData[i][ITEM_MACHINE]
      next if !atk || atk==0
      next if !egg.compatibleWithMove?(atk)
      next if !movefather.hasMove?(atk)
      moves.push(atk)
    end
  end
  # Inheriting Egg Moves
  babyEggMoves = pbGetSpeciesEggMoves(egg.species,egg.form)
  if movefather.male?
    babyEggMoves.each { |m| moves.push(m) if movefather.hasMove?(m) }
  end
  if NEWEST_BATTLE_MECHANICS
    babyEggMoves.each { |m| moves.push(m) if movemother.hasMove?(m) }
  end
  # Volt Tackle
  lightball = false
  if (father.isSpecies?(:PIKACHU) || father.isSpecies?(:RAICHU)) &&
      father.hasItem?(:LIGHTBALL)
    lightball = true
  end
  if (mother.isSpecies?(:PIKACHU) || mother.isSpecies?(:RAICHU)) &&
      mother.hasItem?(:LIGHTBALL)
    lightball = true
  end
  if lightball && isConst?(babyspecies,PBSpecies,:PICHU) &&
     hasConst?(PBMoves,:VOLTTACKLE)
    moves.push(getConst(PBMoves,:VOLTTACKLE))
  end
  moves = moves.reverse
  moves |= []   # remove duplicates
  moves = moves.reverse
  # Assembling move list
  finalmoves = []
  listend = moves.length-4
  listend = 0 if listend<0
  for i in listend...listend+4
    moveid = (i>=moves.length) ? 0 : moves[i]
    finalmoves[finalmoves.length] = PBMove.new(moveid)
  end
  # Inheriting Individual Values
  ivs = []
  for i in 0...6
    ivs[i] = rand(32)
  end
  ivinherit = []
  for i in 0...2
    parent = [mother,father][i]
    ivinherit[i] = PBStats::HP if parent.hasItem?(:POWERWEIGHT)
    ivinherit[i] = PBStats::ATTACK if parent.hasItem?(:POWERBRACER)
    ivinherit[i] = PBStats::DEFENSE if parent.hasItem?(:POWERBELT)
    ivinherit[i] = PBStats::SPATK if parent.hasItem?(:POWERLENS)
    ivinherit[i] = PBStats::SPDEF if parent.hasItem?(:POWERBAND)
    ivinherit[i] = PBStats::SPEED if parent.hasItem?(:POWERANKLET)
  end
  num = 0; r = rand(2)
  2.times do
    if ivinherit[r]!=nil
      parent = [mother,father][r]
      ivs[ivinherit[r]] = parent.iv[ivinherit[r]]
      num += 1
      break
    end
    r = (r+1)%2
  end
  limit = (NEWEST_BATTLE_MECHANICS && (mother.hasItem?(:DESTINYKNOT) ||
           father.hasItem?(:DESTINYKNOT))) ? 5 : 3
  loop do
    freestats = []
    PBStats.eachStat { |s| freestats.push(s) if !ivinherit.include?(s) }
    break if freestats.length==0
    r = freestats[rand(freestats.length)]
    parent = [mother,father][rand(2)]
    ivs[r] = parent.iv[r]
    ivinherit.push(r)
    num += 1
    break if num>=limit
  end
  # Inheriting nature
  newnatures = []
  newnatures.push(mother.nature) if mother.hasItem?(:EVERSTONE)
  newnatures.push(father.nature) if father.hasItem?(:EVERSTONE)
  if newnatures.length>0
    egg.setNature(newnatures[rand(newnatures.length)])
  end
  # Masuda method and Shiny Charm
  shinyretries = 0
  shinyretries += 5 if father.language!=mother.language
  shinyretries += 2 if hasConst?(PBItems,:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
  if shinyretries>0
    shinyretries.times do
      break if egg.shiny?
      egg.personalID = rand(65536)|(rand(65536)<<16)
    end
  end
  # Inheriting ability from the mother
  if !ditto0 && !ditto1
    if mother.hasHiddenAbility?
      egg.setAbility(mother.abilityIndex) if rand(10)<6
    else
      if rand(10)<8
        egg.setAbility(mother.abilityIndex)
      else
        egg.setAbility((mother.abilityIndex+1)%2)
      end
    end
  elsif !(ditto0 && ditto1) && NEWEST_BATTLE_MECHANICS
    parent = (!ditto0) ? mother : father
    if parent.hasHiddenAbility?
      egg.setAbility(parent.abilityIndex) if rand(10)<6
    end
  end
  # Inheriting Poké Ball from the mother
  if mother.female? &&
     !isConst?(pbBallTypeToItem(mother.ballused),PBItems,:MASTERBALL) &&
     !isConst?(pbBallTypeToItem(mother.ballused),PBItems,:CHERISHBALL)
    egg.ballused = mother.ballused
  end
  # Set all stats
  egg.happiness = 120
  egg.iv[0] = ivs[0]
  egg.iv[1] = ivs[1]
  egg.iv[2] = ivs[2]
  egg.iv[3] = ivs[3]
  egg.iv[4] = ivs[4]
  egg.iv[5] = ivs[5]
  egg.moves[0] = finalmoves[0]
  egg.moves[1] = finalmoves[1]
  egg.moves[2] = finalmoves[2]
  egg.moves[3] = finalmoves[3]
  egg.calcStats
  egg.obtainText = _INTL("Day-Care Couple")
  egg.name = _INTL("Egg")
  eggSteps = pbGetSpeciesData(babyspecies,egg.form,SpeciesStepsToHatch)
  egg.eggsteps = eggSteps
  egg.givePokerus if rand(65536)<POKERUS_CHANCE
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = egg
end
################################################################################
# PItem_ItemEffects                                                            #
################################################################################
ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:KYUREM)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  # Fusing
  if pkmn.fused==nil
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
    elsif !poke2.isSpecies?(:RESHIRAM) &&
          !poke2.isSpecies?(:ZEKROM)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
    end
    newForm = 0
    newForm = 1 if poke2.isSpecies?(:RESHIRAM)
    newForm = 2 if poke2.isSpecies?(:ZEKROM)
    pkmn.setForm(newForm) {
      pkmn.fused = poke2
      pbRemovePokemonAt(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.partyplus
  if $Trainer.party.length>=8
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  else
  if $Trainer.party.length>=6
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})
ItemHandlers::UseOnPokemon.add(:NSOLARIZER,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:NECROZMA) || pkmn.form==0
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  # Fusing
  if pkmn.fused==nil
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
    elsif !poke2.isSpecies?(:SOLGALEO)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
    end
    pkmn.setForm(1) {
      pkmn.fused = poke2
      pbRemovePokemonAt(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.partyplus
  if $Trainer.party.length>=8
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  else
  if $Trainer.party.length>=6
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})
ItemHandlers::UseOnPokemon.add(:NLUNARIZER,proc { |item,pkmn,scene|
  if !pkmn.isSpecies?(:NECROZMA) || pkmn.form==1
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
  end
  # Fusing
  if pkmn.fused==nil
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $Trainer.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
    elsif !poke2.isSpecies?(:LUNALA)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
    end
    pkmn.setForm(2) {
      pkmn.fused = poke2
      pbRemovePokemonAt(chosen)
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $Trainer.partyplus
  if $Trainer.party.length>=8
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  else
  if $Trainer.party.length>=6
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  end
  pkmn.setForm(0) {
    $Trainer.party[$Trainer.party.length] = pkmn.fused
    pkmn.fused = nil
    scene.pbHardRefresh
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})
################################################################################
# PItem_BattleItemEffects                                                      #
################################################################################
ItemHandlers::CanUseInBattle.addIf(proc { |item| pbIsPokeBall?(item) },   # Poké Balls
  proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
    if $Trainer.partyplus
    if battle.pbPlayer.party.length>=8 && $PokemonStorage.full?
      scene.pbDisplay(_INTL("There is no room left in the PC!")) if showMessages
      next false
    end
    else
    if battle.pbPlayer.party.length>=6 && $PokemonStorage.full?
      scene.pbDisplay(_INTL("There is no room left in the PC!")) if showMessages
      next false
    end
    end
    # NOTE: Using a Poké Ball consumes all your actions for the round. The code
    #       below is one half of making this happen; the other half is in def
    #       pbItemUsesAllActions?.
    if !firstAction
      scene.pbDisplay(_INTL("It's impossible to aim without being focused!")) if showMessages
      next false
    end
    if battler.semiInvulnerable?
      scene.pbDisplay(_INTL("It's no good! It's impossible to aim at a Pokémon that's not in sight!")) if showMessages
      next false
    end
    # NOTE: The code below stops you from throwing a Poké Ball if there is more
    #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
    #       this case, but only in trainer battles, and the trainer will deflect
    #       them if they are trying to catch a non-Shadow Pokémon.)
    if battle.pbOpposingBattlerCount>1 && !(pbIsSnagBall?(item) && battle.trainerBattle?)
      if battle.pbOpposingBattlerCount==2
        scene.pbDisplay(_INTL("It's no good! It's impossible to aim when there are two Pokémon!")) if showMessages
      else
        scene.pbDisplay(_INTL("It's no good! It's impossible to aim when there are more than one Pokémon!")) if showMessages
      end
      next false
    end
    next true
  }
)
################################################################################
# Pokemon_Evolution                                                            #
################################################################################
PBEvolution.register(:Shedinja, {
  "parameterType"  => nil,
  "afterEvolution" => proc { |pkmn, new_species, parameter, evo_species|
    if $Trainer.partyplus
    next false if $Trainer.party.length>=8
    else
    next false if $Trainer.party.length>=6
    end
    next false if !$PokemonBag.pbHasItem?(getConst(PBItems,:POKEBALL))
    PokemonEvolutionScene.pbDuplicatePokemon(pkmn, new_species)
    $PokemonBag.pbDeleteItem(getConst(PBItems,:POKEBALL))
    next true
  }
})
################################################################################
# PScreen_Party                                                                #
################################################################################
#===============================================================================
# Pokémon party buttons and menu
#===============================================================================
class PokemonPartyConfirmCancelSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,narrowbox=false,viewport=nil)
    super(viewport)
    @refreshBitmap = true
    @bgsprite = ChangelingSprite.new(0,0,viewport)
    if narrowbox
      @bgsprite.addBitmap("desel","Graphics/Pictures/Party/icon_cancel_narrow")
      @bgsprite.addBitmap("sel","Graphics/Pictures/Party/icon_cancel_narrow_sel")
    else
      @bgsprite.addBitmap("desel","Graphics/Pictures/Party/icon_cancel")
      @bgsprite.addBitmap("sel","Graphics/Pictures/Party/icon_cancel_sel")
    end
    @bgsprite.changeBitmap("desel")
    @overlaysprite = BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @overlaysprite.z = self.z+1
    pbSetSystemFont(@overlaysprite.bitmap)
    @yoffset = 8
    textpos = [[text,56,(narrowbox) ? 2 : 8,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    self.x = x
    self.y = y
  end

  def dispose
    @bgsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def selected=(value)
    if @selected!=value
      @selected = value
      refresh
    end
  end

  def refresh
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.changeBitmap((@selected) ? "sel" : "desel")
      @bgsprite.x     = self.x
      @bgsprite.y     = self.y
      @bgsprite.color = self.color
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
  end
end
class PokemonPartyCancelSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CANCEL"),398+RXMOD,328+RYMOD,false,viewport)
  end
end
class PokemonPartyConfirmSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CONFIRM"),398+RXMOD,308+RYMOD,true,viewport)
  end
end
class PokemonPartyCancelSprite2 < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CANCEL"),398+RXMOD,346+RYMOD,true,viewport)
  end
end
class Window_CommandPokemonColor < Window_CommandPokemon
  def initialize(commands,width=nil)
    @colorKey = []
    for i in 0...commands.length
      if commands[i].is_a?(Array)
        @colorKey[i] = commands[i][1]
        commands[i] = commands[i][0]
      end
    end
    super(commands,width)
  end

  def drawItem(index,_count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect = drawCursor(index,rect)
    base   = self.baseColor
    shadow = self.shadowColor
    if @colorKey[index] && @colorKey[index]==1
      base   = Color.new(0,80,160)
      shadow = Color.new(128,192,240)
    end
    pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,@commands[index],base,shadow)
  end
end
#===============================================================================
# Pokémon party panels
#===============================================================================
class PokemonPartyBlankPanel < SpriteWrapper
  attr_accessor :text
  def initialize(_pokemon,index,viewport=nil)
    super(viewport)
	if $Trainer.partyplus
    self.x = [4, 338][index%2]
    self.y = [5, 20,107,122,209,224,311,326][index]
	else
    self.x = [2, 338][index%2]
    self.y = [5, 21,137,153,269,285][index]
	end
	if $Trainer.partyplus
    @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Party/Pluspanel_blank")
	else
    @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Party/panel_blank")
	end
    self.bitmap = @panelbgsprite.bitmap
    @text = nil
  end
  def dispose
    @panelbgsprite.dispose
    super
  end
  def selected; return false; end
  def selected=(value); end
  def preselected; return false; end
  def preselected=(value); end
  def switching; return false; end
  def switching=(value); end
  def refresh; end
end
class PokemonPartyPanel < SpriteWrapper
  attr_reader :pokemon
  attr_reader :active
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :text
  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index==0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
	if $Trainer.partyplus
    self.x = [4, 338][index%2]
    self.y = [5, 20,107,122,209,224,311,326][index]
	else
    self.x = [2, 338][index%2]
    self.y = [5, 21,137,153,269,285][index]
	end
    @panelbgsprite = ChangelingSprite.new(0,0,viewport)
    @panelbgsprite.z = self.z
	if $Trainer.partyplus
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/Pluspanel_round")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/Pluspanel_round_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/Pluspanel_round_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/Pluspanel_round_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/Pluspanel_round_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/Pluspanel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/Pluspanel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/Pluspanel_rect")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/Pluspanel_rect_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/Pluspanel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/Pluspanel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/Pluspanel_rect_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/Pluspanel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/Pluspanel_rect_swap_sel2")
    end
	else
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
	end
    @hpbgsprite = ChangelingSprite.new(0,0,viewport)
    @hpbgsprite.z = self.z+1
    @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0,0,viewport)
    @ballsprite.z = self.z+1
    @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
    @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    @pkmnsprite = PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.setOffset(PictureOrigin::Center)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z+2
    @helditemsprite = HeldItemIconSprite.new(0,0,@pokemon,viewport)
    @helditemsprite.z = self.z+3
    @overlaysprite = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    @overlaysprite.z = self.z+4
    @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end
  def dispose
    @panelbgsprite.dispose
    @hpbgsprite.dispose
    @ballsprite.dispose
    @pkmnsprite.dispose
    @helditemsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end
  def x=(value)
    super
    refresh
  end
  def y=(value)
    super
    refresh
  end
  def color=(value)
    super
    refresh
  end
  def text=(value)
    if @text!=value
      @text = value
      @refreshBitmap = true
      refresh
    end
  end
  def pokemon=(value)
    @pokemon = value
    @pkmnsprite.pokemon = value if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.pokemon = value if @helditemsprite && !@helditemsprite.disposed?
    @refreshBitmap = true
    refresh
  end
  def selected=(value)
    if @selected!=value
      @selected = value
      refresh
    end
  end
  def preselected=(value)
    if @preselected!=value
      @preselected = value
      refresh
    end
  end
  def switching=(value)
    if @switching!=value
      @switching = value
      refresh
    end
  end
  def hp; return @pokemon.hp; end
  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      if self.selected
        if self.preselected;     @panelbgsprite.changeBitmap("swapsel2")
        elsif @switching;        @panelbgsprite.changeBitmap("swapsel")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("faintedsel")
        else;                    @panelbgsprite.changeBitmap("ablesel")
        end
      else
        if self.preselected;     @panelbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("fainted")
        else;                    @panelbgsprite.changeBitmap("able")
        end
      end
      @panelbgsprite.x     = self.x
      @panelbgsprite.y     = self.y
      @panelbgsprite.color = self.color
    end
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length>0))
      if @hpbgsprite.visible
        if self.preselected || (self.selected && @switching); @hpbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?;                              @hpbgsprite.changeBitmap("fainted")
        else;                                                 @hpbgsprite.changeBitmap("able")
        end
        @hpbgsprite.x     = self.x+96
        @hpbgsprite.y     = self.y+50
        @hpbgsprite.color = self.color
      end
    end
    if @ballsprite && !@ballsprite.disposed?
      @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
      @ballsprite.x     = self.x+10
      @ballsprite.y     = self.y
      @ballsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x+60
      @pkmnsprite.y        = self.y+40
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite && !@helditemsprite.disposed?
      if @helditemsprite.visible
        @helditemsprite.x     = self.x+62
        @helditemsprite.y     = self.y+48
        @helditemsprite.color = self.color
      end
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap.clear if @overlaysprite.bitmap
      basecolor   = Color.new(248,248,248)
      shadowcolor = Color.new(40,40,40)
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos = []
      # Draw Pokémon name
      textpos.push([@pokemon.name,96,16,0,basecolor,shadowcolor])
      if !@pokemon.egg?
        if !@text || @text.length==0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d",@pokemon.hp,@pokemon.totalhp),224,60,1,basecolor,shadowcolor])
          # Draw HP bar
          if @pokemon.hp>0
            w = @pokemon.hp*96*1.0/@pokemon.totalhp
            w = 1 if w<1
            w = ((w/2).round)*2
            hpzone = 0
            hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
            hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
            hprect = Rect.new(0,hpzone*8,w,8)
            @overlaysprite.bitmap.blt(128,52,@hpbar.bitmap,hprect)
          end
          # Draw status
          status = -1
          status = 6 if @pokemon.pokerusStage==1
          status = @pokemon.status-1 if @pokemon.status>0
          status = 5 if @pokemon.hp<=0
          if status>=0
            statusrect = Rect.new(0,16*status,44,16)
            @overlaysprite.bitmap.blt(78,68,@statuses.bitmap,statusrect)
          end
        end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"),224,16,0,Color.new(0,112,248),Color.new(120,184,232)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"),224,16,0,Color.new(232,32,16),Color.new(248,168,184)])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             "Graphics/Pictures/shiny",80,48,0,0,16,16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,[[
           "Graphics/Pictures/Party/overlay_lv",20,70,0,0,22,14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@pokemon.level.to_s,42,62,0,basecolor,shadowcolor]
        ])
      end
      # Draw annotation text
      if @text && @text.length>0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@text,96,58,0,basecolor,shadowcolor]
        ])
      end
    end
    @refreshing = false
  end
  def update
    super
    @panelbgsprite.update if @panelbgsprite && !@panelbgsprite.disposed?
    @hpbgsprite.update if @hpbgsprite && !@hpbgsprite.disposed?
    @ballsprite.update if @ballsprite && !@ballsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.update if @helditemsprite && !@helditemsprite.disposed?
  end
end
#===============================================================================
# Pokémon party visuals
#===============================================================================
class PokemonParty_Scene
  def pbStartScene(party,starthelptext,annotations=nil,multiselect=false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
	if $Trainer.partyplus
    addBackgroundPlane(@sprites,"partybg","Party/Plusbg",@viewport)
	else
    addBackgroundPlane(@sprites,"partybg","Party/bg",@viewport)
	end
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible  = true
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbSetHelpText(starthelptext)
    # Add party Pokémon sprites
	if $Trainer.partyplus
	    for i in 0...8
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = annotations[i] if annotations
    end
    if @multiselect
      @sprites["pokemon8"] = PokemonPartyConfirmSprite.new(@viewport)
      @sprites["pokemon9"] = PokemonPartyCancelSprite2.new(@viewport)
    else
      @sprites["pokemon8"] = PokemonPartyCancelSprite.new(@viewport)
    end
	else
	    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = annotations[i] if annotations
    end
    if @multiselect
      @sprites["pokemon6"] = PokemonPartyConfirmSprite.new(@viewport)
      @sprites["pokemon7"] = PokemonPartyCancelSprite2.new(@viewport)
    else
      @sprites["pokemon6"] = PokemonPartyCancelSprite.new(@viewport)
    end
	end
    # Select first Pokémon
    @activecmd = 0
    @sprites["pokemon0"].selected = true
    pbFadeInAndShow(@sprites) { update }
  end
  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  def pbDisplay(text)
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::C)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      else
        if Input.trigger?(Input::B) || Input.trigger?(Input::C)
          break
        end
      end
    end
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
  end
  def pbDisplayConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])) {
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      cmdwindow.z = @viewport.z+1
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        self.update
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::B)
            ret = false
            break
          elsif Input.trigger?(Input::C) && @sprites["messagebox"].resume
            ret = (cmdwindow.index==0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
    return ret
  end
  def pbShowCommands(helptext,commands,index=0)
    ret = -1
    helpwindow = @sprites["helpwindow"]
    helpwindow.visible = true
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) {
      cmdwindow.z     = @viewport.z+1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helptext,Graphics.width-cmdwindow.width)
      helpwindow.text = helptext
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        self.update
        if Input.trigger?(Input::B)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::C)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end
  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.text = helptext
    helpwindow.width = 398
    helpwindow.visible = true
  end
  def pbHasAnnotations?
    return @sprites["pokemon0"].text!=nil
  end
  def pbAnnotate(annot)
  if  $Trainer.partyplus
    for i in 0...8
      @sprites["pokemon#{i}"].text = (annot) ? annot[i] : nil
    end
  else
      for i in 0...6
      @sprites["pokemon#{i}"].text = (annot) ? annot[i] : nil
    end
  end
  end
  def pbSelect(item)
    @activecmd = item
	if $Trainer.partyplus
    numsprites = (@multiselect) ? 8 : 7
    else
	numsprites = (@multiselect) ? 8 : 7
    end
	for i in 0...numsprites
      @sprites["pokemon#{i}"].selected = (i==@activecmd)
    end
  end
  def pbPreSelect(item)
    @activecmd = item
  end
  def pbSwitchBegin(oldid,newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    timeTaken = Graphics.frame_rate*4/10
    distancePerFrame = (Graphics.width/(2.0*timeTaken)).ceil
    timeTaken.times do
      oldsprite.x += (oldid&1)==0 ? -distancePerFrame : distancePerFrame
      newsprite.x += (newid&1)==0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
  end
  def pbSwitchEnd(oldid,newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    oldsprite.pokemon = @party[oldid]
    newsprite.pokemon = @party[newid]
    timeTaken = Graphics.frame_rate*4/10
    distancePerFrame = (Graphics.width/(2.0*timeTaken)).ceil
    timeTaken.times do
      oldsprite.x -= (oldid&1)==0 ? -distancePerFrame : distancePerFrame
      newsprite.x -= (newid&1)==0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
	if $Trainer.partyplus
    for i in 0...8
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
	else
    for i in 0...6
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
	end
    pbRefresh
  end
  def pbClearSwitching
  if $Trainer.partyplus
    for i in 0...8
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
  else
    for i in 0...6
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
  end
  end
  def pbSummary(pkmnid,inbattle=false)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,inbattle)
    screen.pbStartScreen(@party,pkmnid)
    yield if block_given?
    pbFadeInAndShow(@sprites,oldsprites)
  end
  def pbChooseItem(bag)
    ret = 0
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| pbCanHoldItem?(item) })
      yield if block_given?
    }
    return ret
  end
  def pbUseItem(bag,pokemon)
    ret = 0
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item|
        next false if !pbCanUseOnPokemon?(item)
        if pbIsMachine?(item)
          move = pbGetMachine(item)
          next false if pokemon.hasMove?(move) || !pokemon.compatibleWithMove?(move)
        end
        next true
      })
      yield if block_given?
    }
    return ret
  end
  def pbChoosePokemon(switching=false,initialsel=-1,canswitch=0)
    if $Trainer.partyplus
    for i in 0...8
      @sprites["pokemon#{i}"].preselected = (switching && i==@activecmd)
      @sprites["pokemon#{i}"].switching   = switching
    end
	else
    for i in 0...6
      @sprites["pokemon#{i}"].preselected = (switching && i==@activecmd)
      @sprites["pokemon#{i}"].switching   = switching
    end
	end
    @activecmd = initialsel if initialsel>=0
    pbRefresh
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        @activecmd = pbChangeSelection(key,@activecmd)
      end
	  if $Trainer.partyplus
      if @activecmd!=oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = (@multiselect) ? 10 : 9
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i==@activecmd)
        end
      end
      cancelsprite = (@multiselect) ? 9 : 8
	  else
      if @activecmd!=oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = (@multiselect) ? 8 : 7
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i==@activecmd)
        end
      end
      cancelsprite = (@multiselect) ? 7 : 6
	  end
      if Input.trigger?(Input::A) && canswitch==1 && @activecmd!=cancelsprite
        pbPlayDecisionSE
        return [1,@activecmd]
      elsif Input.trigger?(Input::A) && canswitch==2
        return -1
      elsif Input.trigger?(Input::B)
        pbPlayCloseMenuSE if !switching
        return -1
      elsif Input.trigger?(Input::C)
        if @activecmd==cancelsprite
          (switching) ? pbPlayDecisionSE : pbPlayCloseMenuSE
          return -1
        else
          pbPlayDecisionSE
          return @activecmd
        end
      end
    end
  end
  def pbChangeSelection(key,currentsel)
  if $Trainer.partyplus
    numsprites = (@multiselect) ? 10 : 9
    case key
    when Input::LEFT
      begin
        currentsel -= 1
      end while currentsel>0 && currentsel<@party.length && !@party[currentsel]
      if currentsel>=@party.length && currentsel<8
        currentsel = @party.length-1
      end
      currentsel = numsprites-1 if currentsel<0
    when Input::RIGHT
      begin
        currentsel += 1
      end while currentsel<@party.length && !@party[currentsel]
      if currentsel==@party.length
        currentsel = 8
      elsif currentsel==numsprites
        currentsel = 0
      end
    when Input::UP
      if currentsel>=8
        begin
          currentsel -= 1
        end while currentsel>0 && !@party[currentsel]
      else
        begin
          currentsel -= 2
        end while currentsel>0 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<8
        currentsel = @party.length-1
      end
      currentsel = numsprites-1 if currentsel<0
    when Input::DOWN
      if currentsel>=7
        currentsel += 1
      else
        currentsel += 2
        currentsel = 8 if currentsel<8 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<8
        currentsel = 8
      elsif currentsel>=numsprites
        currentsel = 0
      end
    end
  else
    numsprites = (@multiselect) ? 8 : 7
    case key
    when Input::LEFT
      begin
        currentsel -= 1
      end while currentsel>0 && currentsel<@party.length && !@party[currentsel]
      if currentsel>=@party.length && currentsel<6
        currentsel = @party.length-1
      end
      currentsel = numsprites-1 if currentsel<0
    when Input::RIGHT
      begin
        currentsel += 1
      end while currentsel<@party.length && !@party[currentsel]
      if currentsel==@party.length
        currentsel = 6
      elsif currentsel==numsprites
        currentsel = 0
      end
    when Input::UP
      if currentsel>=6
        begin
          currentsel -= 1
        end while currentsel>0 && !@party[currentsel]
      else
        begin
          currentsel -= 2
        end while currentsel>0 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<6
        currentsel = @party.length-1
      end
      currentsel = numsprites-1 if currentsel<0
    when Input::DOWN
      if currentsel>=5
        currentsel += 1
      else
        currentsel += 2
        currentsel = 6 if currentsel<6 && !@party[currentsel]
      end
      if currentsel>=@party.length && currentsel<6
        currentsel = 6
      elsif currentsel>=numsprites
        currentsel = 0
      end
    end
  end
    return currentsel
  end
  def pbHardRefresh
    oldtext = []
    lastselected = -1
	if $Trainer.partyplus
    for i in 0...8
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
	else
    for i in 0...6
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
	end
    lastselected = @party.length-1 if lastselected>=@party.length
    lastselected = 0 if lastselected<0
	if $Trainer.partyplus
    for i in 0...8
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
	else
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
	end
    pbSelect(lastselected)
  end
  def pbRefresh
  if $Trainer.partyplus
    for i in 0...8
      sprite = @sprites["pokemon#{i}"]
      if sprite
        if sprite.is_a?(PokemonPartyPanel)
          sprite.pokemon = sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  else
    for i in 0...6
      sprite = @sprites["pokemon#{i}"]
      if sprite
        if sprite.is_a?(PokemonPartyPanel)
          sprite.pokemon = sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  end
  end
  def pbRefreshSingle(i)
    sprite = @sprites["pokemon#{i}"]
    if sprite
      if sprite.is_a?(PokemonPartyPanel)
        sprite.pokemon = sprite.pokemon
      else
        sprite.refresh
      end
    end
  end
  def update
    pbUpdateSpriteHash(@sprites)
  end
end
#===============================================================================
# Pokémon party mechanics
#===============================================================================
class PokemonPartyScreen
  attr_reader :scene
  attr_reader :party
  def initialize(scene,party)
    @scene = scene
    @party = party
  end
  def pbStartScene(helptext,_numBattlersOut,annotations=nil)
    @scene.pbStartScene(@party,helptext,annotations)
  end
  def pbChoosePokemon(helptext=nil)
    @scene.pbSetHelpText(helptext) if helptext
    return @scene.pbChoosePokemon
  end
  def pbPokemonGiveScreen(item)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    ret = false
    if pkmnid>=0
      ret = pbGiveItemToPokemon(item,@party[pkmnid],self,pkmnid)
    end
    pbRefreshSingle(pkmnid)
    @scene.pbEndScene
    return ret
  end
  def pbPokemonGiveMailScreen(mailIndex)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    if pkmnid>=0
      pkmn = @party[pkmnid]
      if pkmn.hasItem? || pkmn.mail
        pbDisplay(_INTL("This Pokémon is holding an item. It can't hold mail."))
      elsif pkmn.egg?
        pbDisplay(_INTL("Eggs can't hold mail."))
      else
        pbDisplay(_INTL("Mail was transferred from the Mailbox."))
        pkmn.mail = $PokemonGlobal.mailbox[mailIndex]
        pkmn.setItem(pkmn.mail.item)
        $PokemonGlobal.mailbox.delete_at(mailIndex)
        pbRefreshSingle(pkmnid)
      end
    end
    @scene.pbEndScene
  end
  def pbEndScene
    @scene.pbEndScene
  end
  def pbUpdate
    @scene.update
  end
  def pbHardRefresh
    @scene.pbHardRefresh
  end
  def pbRefresh
    @scene.pbRefresh
  end
  def pbRefreshSingle(i)
    @scene.pbRefreshSingle(i)
  end
  def pbDisplay(text)
    @scene.pbDisplay(text)
  end
  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end
  def pbShowCommands(helptext,commands,index=0)
    return @scene.pbShowCommands(helptext,commands,index)
  end
  # Checks for identical species
  def pbCheckSpecies(array)   # Unused
    for i in 0...array.length
      for j in i+1...array.length
        return false if array[i].species==array[j].species
      end
    end
    return true
  end
  # Checks for identical held items
  def pbCheckItems(array)   # Unused
    for i in 0...array.length
      next if !array[i].hasItem?
      for j in i+1...array.length
        return false if array[i].item==array[j].item
      end
    end
    return true
  end
  def pbSwitch(oldid,newid)
    if oldid!=newid
      @scene.pbSwitchBegin(oldid,newid)
      tmp = @party[oldid]
      @party[oldid] = @party[newid]
      @party[newid] = tmp
      @scene.pbSwitchEnd(oldid,newid)
    end
  end
  def pbChooseMove(pokemon,helptext,index=0)
    movenames = []
    for i in pokemon.moves
      break if i.id==0
      if i.totalpp<=0
        movenames.push(_INTL("{1} (PP: ---)",PBMoves.getName(i.id)))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",PBMoves.getName(i.id),i.pp,i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames,index)
  end
  def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
    return if !@scene.pbHasAnnotations?
    annot = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    @scene.pbAnnotate(annot)
  end
  def pbClearAnnotations
    @scene.pbAnnotate(nil)
  end
  def pbPokemonMultipleEntryScreenEx(ruleset)
    annot = []
    statuses = []
    ordinals = [
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH"),
       _INTL("SEVENTH"),
       _INTL("EIGTH")
    ]
    return nil if !ruleset.hasValidTeam?(@party)
    ret = nil
    addedEntry = false
    for i in 0...@party.length
      statuses[i] = (ruleset.isPokemonValid?(@party[i])) ? 1 : 2
    end
    for i in 0...@party.length
      annot[i] = ordinals[statuses[i]]
    end
    @scene.pbStartScene(@party,_INTL("Choose Pokémon and confirm."),annot,true)
    loop do
      realorder = []
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
	   if $Trainer.partyplus
        statuses[realorder[i]] = i+4
	   else
        statuses[realorder[i]] = i+3
	   end
      end
      for i in 0...@party.length
        annot[i] = ordinals[statuses[i]]
      end
      @scene.pbAnnotate(annot)
	  if $Trainer.partyplus
      if realorder.length==ruleset.number && addedEntry
        @scene.pbSelect(8)
      end
	  else
      if realorder.length==ruleset.number && addedEntry
        @scene.pbSelect(6)
      end
	  end
      @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      pkmnid = @scene.pbChoosePokemon
      addedEntry = false
	  if $Trainer.partyplus
      if pkmnid==8   # Confirm was chosen
        ret = []
        for i in realorder; ret.push(@party[i]); end
        error = []
        break if ruleset.isValid?(ret,error)
        pbDisplay(error[0])
        ret = nil
      end
	  else
      if pkmnid==6   # Confirm was chosen
        ret = []
        for i in realorder; ret.push(@party[i]); end
        error = []
        break if ruleset.isValid?(ret,error)
        pbDisplay(error[0])
        ret = nil
      end
	  end
      break if pkmnid<0   # Cancelled
      cmdEntry   = -1
      cmdNoEntry = -1
      cmdSummary = -1
      commands = []
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry = commands.length]   = _INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry = commands.length] = _INTL("No Entry")
      end
      pkmn = @party[pkmnid]
      commands[cmdSummary = commands.length]   = _INTL("Summary")
      commands[commands.length]                = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=ruleset.number && ruleset.number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",ruleset.number))
        else
          statuses[pkmnid] = realorder.length+3
          addedEntry = true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid] = 1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      end
    end
    @scene.pbEndScene
    return ret
  end
  def pbChooseAblePokemon(ableProc,allowIneligible=false)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid<0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret = pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end
  def pbChooseTradablePokemon(ableProc,allowIneligible=false)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      elig = false if pkmn.egg? || pkmn.shadowPokemon?
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid<0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret = pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end
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
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdMoves   = [-1,-1,-1,-1]
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      for i in 0...pkmn.moves.length
        move = pkmn.moves[i]
        # Check for hidden moves and add any that were found
        if !pkmn.egg? && (isConst?(move.id,PBMoves,:MILKDRINK) ||
                          isConst?(move.id,PBMoves,:SOFTBOILED) ||
                          HiddenMoveHandlers.hasHandler(move.id))
          commands[cmdMoves[i] = commands.length] = [PBMoves.getName(move.id),1]
        end
      end
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
          elsif pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
            if pbConfirmUseHiddenMove(pkmn,pkmn.moves[i].id)
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
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdMail>=0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail(pkmn.mail,pkmn)
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        when 1   # Take
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
          item = @scene.pbUseItem($PokemonBag,pkmn) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item>0
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
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
              elsif newitemname.starts_with_vowel?
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
def pbPokemonScreen
  pbFadeOutIn {
    sscene = PokemonParty_Scene.new
    sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
    sscreen.pbPokemonScreen
  }
end
################################################################################
# Pokemon_Storage                                                              #
################################################################################
class PokemonStorage
  attr_reader   :boxes
  attr_accessor :currentBox
  attr_writer   :unlockedWallpapers
  BASICWALLPAPERQTY = 16
  def initialize(maxBoxes=NUM_STORAGE_BOXES,maxPokemon=30)
    @boxes = []
    for i in 0...maxBoxes
      @boxes[i] = PokemonBox.new(_INTL("Box {1}",i+1),maxPokemon)
      @boxes[i].background = i%BASICWALLPAPERQTY
    end
    @currentBox = 0
    @boxmode = -1
    @unlockedWallpapers = []
    for i in 0...allWallpapers.length
      @unlockedWallpapers[i] = false
    end
  end
  def allWallpapers
    return [
       # Basic wallpapers
       _INTL("Forest"),_INTL("City"),_INTL("Desert"),_INTL("Savanna"),
       _INTL("Crag"),_INTL("Volcano"),_INTL("Snow"),_INTL("Cave"),
       _INTL("Beach"),_INTL("Seafloor"),_INTL("River"),_INTL("Sky"),
       _INTL("Poké Center"),_INTL("Machine"),_INTL("Checks"),_INTL("Simple"),
       # Special wallpapers
       _INTL("Space"),_INTL("Backyard"),_INTL("Nostalgic 1"),_INTL("Torchic"),
       _INTL("Trio 1"),_INTL("PikaPika 1"),_INTL("Legend 1"),_INTL("Team Galactic 1"),
       _INTL("Distortion"),_INTL("Contest"),_INTL("Nostalgic 2"),_INTL("Croagunk"),
       _INTL("Trio 2"),_INTL("PikaPika 2"),_INTL("Legend 2"),_INTL("Team Galactic 2"),
       _INTL("Heart"),_INTL("Soul"),_INTL("Big Brother"),_INTL("Pokéathlon"),
       _INTL("Trio 3"),_INTL("Spiky Pika"),_INTL("Kimono Girl"),_INTL("Revival")
    ]
  end
  def unlockedWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return @unlockedWallpapers
  end
  def isAvailableWallpaper?(i)
    @unlockedWallpapers = [] if !@unlockedWallpapers
    return true if i<BASICWALLPAPERQTY
    return true if @unlockedWallpapers[i]
    return false
  end
  def availableWallpapers
    ret = [[],[]]   # Names, IDs
    papers = allWallpapers
    @unlockedWallpapers = [] if !@unlockedWallpapers
    for i in 0...papers.length
      next if !isAvailableWallpaper?(i)
      ret[0].push(papers[i]); ret[1].push(i)
    end
    return ret
  end
  def party
    $Trainer.party
  end
  def party=(_value)
    raise ArgumentError.new("Not supported")
  end
  def maxBoxes
    return @boxes.length
  end
  def maxPokemon(box)
    return 0 if box>=self.maxBoxes
	if $Trainer.partyplus
    return (box<0) ? 8 : self[box].length
	else
    return (box<0) ? 6 : self[box].length
	end
  end
  def full?
    for i in 0...self.maxBoxes
      return false if !@boxes[i].full?
    end
    return true
  end
  def pbFirstFreePos(box)
    if box==-1
      ret = self.party.nitems
	  if $Trainer.partyplus
      return (ret==8) ? -1 : ret
	  else
      return (ret==6) ? -1 : ret
	  end
    else
      for i in 0...maxPokemon(box)
        return i if !self[box,i]
      end
      return -1
    end
  end
  def [](x,y=nil)
    if y==nil
      return (x==-1) ? self.party : @boxes[x]
    else
      for i in @boxes
        raise "Box is a Pokémon, not a box" if i.is_a?(PokeBattle_Pokemon)
      end
      return (x==-1) ? self.party[y] : @boxes[x][y]
    end
  end
  def []=(x,y,value)
    if x==-1
      self.party[y] = value
    else
      @boxes[x][y] = value
    end
  end
  def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    if indexDst<0 && boxDst<self.maxBoxes
      found = false
      for i in 0...maxPokemon(boxDst)
        next if self[boxDst,i]
        found = true
        indexDst = i
        break
      end
      return false if !found
    end
    if $Trainer.partyplus
    if boxDst==-1   # Copying into party
      return false if self.party.nitems>=8
      self.party[self.party.length] = self[boxSrc,indexSrc]
      self.party.compact!
    else   # Copying into box
      pkmn = self[boxSrc,indexSrc]
      raise "Trying to copy nil to storage" if !pkmn
      pkmn.formTime = nil if pkmn.respond_to?("formTime")
      pkmn.form     = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
      self[boxDst,indexDst] = pkmn
    end
    else
    if boxDst==-1   # Copying into party
      return false if self.party.nitems>=6
      self.party[self.party.length] = self[boxSrc,indexSrc]
      self.party.compact!
    else   # Copying into box
      pkmn = self[boxSrc,indexSrc]
      raise "Trying to copy nil to storage" if !pkmn
      pkmn.formTime = nil if pkmn.respond_to?("formTime")
      pkmn.form     = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
      self[boxDst,indexDst] = pkmn
    end
    end
    return true
  end
  def pbMove(boxDst,indexDst,boxSrc,indexSrc)
    return false if !pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    pbDelete(boxSrc,indexSrc)
    return true
  end
  def pbMoveCaughtToParty(pkmn)
    if $Trainer.partyplus
    return false if self.party.nitems>=8
	else
    return false if self.party.nitems>=6
	end
    self.party[self.party.length] = pkmn
  end
  def pbMoveCaughtToBox(pkmn,box)
    for i in 0...maxPokemon(box)
      if self[box,i]==nil
        if box>=0
          pkmn.formTime = nil if pkmn.respond_to?("formTime") && pkmn.formTime
          pkmn.form     = 0 if pkmn.isSpecies?(:SHAYMIN)
          pkmn.heal
        end
        self[box,i] = pkmn
        return true
      end
    end
    return false
  end
  def pbStoreCaught(pkmn)
    if @currentBox>=0
      pkmn.formTime = nil if pkmn.respond_to?("formTime")
      pkmn.form     = 0 if pkmn.isSpecies?(:SHAYMIN)
      pkmn.heal
    end
    for i in 0...maxPokemon(@currentBox)
      if self[@currentBox,i]==nil
        self[@currentBox,i] = pkmn
        return @currentBox
      end
    end
    for j in 0...self.maxBoxes
      for i in 0...maxPokemon(j)
        if self[j,i]==nil
          self[j,i] = pkmn
          @currentBox = j
          return @currentBox
        end
      end
    end
    return -1
  end
  def pbDelete(box,index)
    if self[box,index]
      self[box,index] = nil
      self.party.compact! if box==-1
    end
  end
  def clear
    for i in 0...self.maxBoxes
      @boxes[i].clear
    end
  end
end

################################################################################
# PScreen_PC                                                                   #
################################################################################
class StorageSystemPC
  def shouldShow?
    return true
  end

  def name
    if $PokemonGlobal.seenStorageCreator
      return _INTL("{1}'s PC",pbGetStorageCreator)
    else
      return _INTL("Someone's PC")
    end
  end

  def access
    pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organize Boxes"),
         _INTL("Withdraw Pokémon"),
         _INTL("Deposit Pokémon"),
         _INTL("See ya!")],
         [_INTL("Organize the Pokémon in Boxes and in your party."),
         _INTL("Move Pokémon stored in Boxes to your party."),
         _INTL("Store Pokémon in your party in Boxes."),
         _INTL("Return to the previous menu.")],-1,command
      )
      if command>=0 && command<3
        if command==1   # Withdraw
		if $Trainer.partyplus
          if $PokemonStorage.party.length>=8
            pbMessage(_INTL("Your party is full!"))
            next
          end
		else
          if $PokemonStorage.party.length>=6
            pbMessage(_INTL("Your party is full!"))
            next
          end
		end
        elsif command==2   # Deposit
          count=0
          for p in $PokemonStorage.party
            count += 1 if p && !p.egg? && p.hp>0
          end
          if count<=1
            pbMessage(_INTL("Can't deposit the last Pokémon!"))
            next
          end
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene,$PokemonStorage)
          screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  end
end

################################################################################
# PSystem_PokemonUtilities                                                     #
################################################################################
#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  if $Trainer.partyplus
  return ($Trainer.party.length==8 && $PokemonStorage.full?)
  else
  return ($Trainer.party.length==6 && $PokemonStorage.full?)
  end
end
def pbStorePokemon(pokemon)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pokemon.pbRecordFirstMoves
  if $Trainer.partyplus
  if $Trainer.party.length<8
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pokemon)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      if creator
        pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
      else
        pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
    else
      if creator
        pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
      else
        pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
      end
      pbMessage(_INTL("It was stored in box \"{1}.\"",boxname))
    end
  end
  else
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pokemon)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $PokemonGlobal.seenStorageCreator
    if storedbox!=oldcurbox
      if creator
        pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1",curboxname,creator))
      else
        pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1",curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"",pokemon.name,boxname))
    else
      if creator
        pbMessage(_INTL("{1} was transferred to {2}'s PC.\1",pokemon.name,creator))
      else
        pbMessage(_INTL("{1} was transferred to someone's PC.\1",pokemon.name))
      end
      pbMessage(_INTL("It was stored in box \"{1}.\"",boxname))
    end
  end
  end
end
#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemonSilent(pokemon,level=nil,seeform=true)
  return false if !pokemon || pbBoxesFull?
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  if $Trainer.partyplus
  if $Trainer.party.length<8
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  else
  if $Trainer.party.length<6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
  end
  end
  return true
end
#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pokemon,level=nil,seeform=true)
  if $Trainer.partyplus
  return false if !pokemon || $Trainer.party.length>=8
  else
  return false if !pokemon || $Trainer.party.length>=6
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  speciesname = PBSpecies.getName(pokemon.species)
  pbMessage(_INTL("\\me[Pkmn get]{1} obtained {2}!\1",$Trainer.name,speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end
def pbAddToPartySilent(pokemon,level=nil,seeform=true)
  if $Trainer.partyplus
  return false if !pokemon || $Trainer.party.length>=8
  else
  return false if !pokemon || $Trainer.party.length>=6
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  pokemon.pbRecordFirstMoves
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
end
def pbAddForeignPokemon(pokemon,level=nil,ownerName=nil,nickname=nil,ownerGender=0,seeform=true)
  if $Trainer.partyplus
  return false if !pokemon || $Trainer.party.length>=8
  else
  return false if !pokemon || $Trainer.party.length>=6
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,level)
  end
  # Set original trainer to a foreign one (if ID isn't already foreign)
  if pokemon.trainerID==$Trainer.id
    pokemon.trainerID = $Trainer.getForeignID
    pokemon.ot        = ownerName if ownerName && ownerName!=""
    pokemon.otgender  = ownerGender
  end
  # Set nickname
  pokemon.name = nickname[0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE] if nickname && nickname!=""
  # Recalculate stats
  pokemon.calcStats
  if ownerName
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1",$Trainer.name,ownerName))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1",$Trainer.name))
  end
  pbStorePokemon(pokemon)
  $Trainer.seen[pokemon.species]  = true
  $Trainer.owned[pokemon.species] = true
  pbSeenForm(pokemon) if seeform
  return true
end
def pbGenerateEgg(pokemon,text="")
  if $Trainer.partyplus
  return false if !pokemon || $Trainer.party.length>=8
  else
  return false if !pokemon || $Trainer.party.length>=6
  end
  pokemon = getID(PBSpecies,pokemon)
  if pokemon.is_a?(Integer)
    pokemon = pbNewPkmn(pokemon,EGG_LEVEL)
  end
  # Get egg steps
  eggSteps = pbGetSpeciesData(pokemon.species,pokemon.form,SpeciesStepsToHatch)
  # Set egg's details
  pokemon.name       = _INTL("Egg")
  pokemon.eggsteps   = eggSteps
  pokemon.obtainText = text
  pokemon.calcStats
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = pokemon
  return true
end
################################################################################
# PSystem_Utilities                                                            #
################################################################################
def pbMoveTutorAnnotations(move,movelist=nil)
  ret = []
  if $Trainer.partyplus
  for i in 0...8
    ret[i] = nil
    next if i>=$Trainer.party.length
    found = false
    for j in 0...4
      if !$Trainer.party[i].egg? && $Trainer.party[i].moves[j].id==move
        ret[i] = _INTL("LEARNED")
        found = true
      end
    end
    next if found
    species = $Trainer.party[i].species
    if !$Trainer.party[i].egg? && movelist && movelist.any? { |j| j==species }
      # Checked data from movelist
      ret[i] = _INTL("ABLE")
    elsif !$Trainer.party[i].egg? && $Trainer.party[i].compatibleWithMove?(move)
      # Checked data from PBS/tm.txt
      ret[i] = _INTL("ABLE")
    else
      ret[i] = _INTL("NOT ABLE")
    end
  end
  else
  for i in 0...6
    ret[i] = nil
    next if i>=$Trainer.party.length
    found = false
    for j in 0...4
      if !$Trainer.party[i].egg? && $Trainer.party[i].moves[j].id==move
        ret[i] = _INTL("LEARNED")
        found = true
      end
    end
    next if found
    species = $Trainer.party[i].species
    if !$Trainer.party[i].egg? && movelist && movelist.any? { |j| j==species }
      # Checked data from movelist
      ret[i] = _INTL("ABLE")
    elsif !$Trainer.party[i].egg? && $Trainer.party[i].compatibleWithMove?(move)
      # Checked data from PBS/tm.txt
      ret[i] = _INTL("ABLE")
    else
      ret[i] = _INTL("NOT ABLE")
    end
  end
  end
  return ret
end
################################################################################
# Debug_Actions                                                                #
################################################################################
#===============================================================================
# Debug Day Care screen
#===============================================================================
def pbDebugDayCare
  commands = [_INTL("Withdraw Pokémon 1"),
              _INTL("Withdraw Pokémon 2"),
              _INTL("Deposit Pokémon"),
              _INTL("Generate egg"),
              _INTL("Collect egg")]
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  addBackgroundPlane(sprites,"background","hatchbg",viewport)
  sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
  pbSetSystemFont(sprites["overlay"].bitmap)
  sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands)
  cmdwindow = sprites["cmdwindow"]
  cmdwindow.x        = 0
  cmdwindow.y        = Graphics.height-128
  cmdwindow.width    = Graphics.width
  cmdwindow.height   = 128
  cmdwindow.viewport = viewport
  cmdwindow.columns = 2
  base   = Color.new(248,248,248)
  shadow = Color.new(104,104,104)
  refresh = true
  loop do
    if refresh
      if pbEggGenerated?
        commands[3] = _INTL("Discard egg")
      else
        commands[3] = _INTL("Generate egg")
      end
      cmdwindow.commands = commands
      sprites["overlay"].bitmap.clear
      textpos = []
      for i in 0...2
        textpos.push([_INTL("Pokémon {1}",i+1),Graphics.width/4+i*Graphics.width/2,8,2,base,shadow])
      end
      for i in 0...pbDayCareDeposited
        next if !$PokemonGlobal.daycare[i][0]
        y = 40
        pkmn      = $PokemonGlobal.daycare[i][0]
        initlevel = $PokemonGlobal.daycare[i][1]
        leveldiff = pkmn.level-initlevel
        textpos.push([pkmn.name+" ("+PBSpecies.getName(pkmn.species)+")",8+i*Graphics.width/2,y,0,base,shadow])
        y += 32
        if pkmn.male?
          textpos.push([_INTL("Male ♂"),8+i*Graphics.width/2,y,0,Color.new(128,192,248),shadow])
        elsif pkmn.female?
          textpos.push([_INTL("Female ♀"),8+i*Graphics.width/2,y,0,Color.new(248,96,96),shadow])
        else
          textpos.push([_INTL("Genderless"),8+i*Graphics.width/2,y,0,base,shadow])
        end
        y += 32
        if initlevel>=PBExperience.maxLevel
          textpos.push(["Lv. #{initlevel} (max)",8+i*Graphics.width/2,y,0,base,shadow])
        elsif leveldiff>0
          textpos.push(["Lv. #{initlevel} -> #{pkmn.level} (+#{leveldiff})",
             8+i*Graphics.width/2,y,0,base,shadow])
        else
          textpos.push(["Lv. #{initlevel} (no change)",8+i*Graphics.width/2,y,0,base,shadow])
        end
        y += 32
        if pkmn.level<PBExperience.maxLevel
          endexp   = PBExperience.pbGetStartExperience(pkmn.level+1,pkmn.growthrate)
          textpos.push(["To next Lv.: #{endexp-pkmn.exp}",8+i*Graphics.width/2,y,0,base,shadow])
          y += 32
        end
        cost = pbDayCareGetCost(i)
        textpos.push(["Cost: $#{cost}",8+i*Graphics.width/2,y,0,base,shadow])
      end
      if pbEggGenerated?
        textpos.push(["Egg waiting for collection",Graphics.width/2,216,2,Color.new(248,248,0),shadow])
      elsif pbDayCareDeposited==2
        if pbDayCareGetCompat==0
          textpos.push(["Pokémon cannot breed",Graphics.width/2,216,2,Color.new(248,96,96),shadow])
        else
          textpos.push(["Pokémon can breed",Graphics.width/2,216,2,Color.new(64,248,64),shadow])
        end
      end
      pbDrawTextPositions(sprites["overlay"].bitmap,textpos)
      refresh = false
    end
    pbUpdateSpriteHash(sprites)
    Graphics.update
    Input.update
    if Input.trigger?(Input::B)
      break
    elsif Input.trigger?(Input::C)
	if $Trainer.partyplus
      case cmdwindow.index
      when 0   # Withdraw Pokémon 1
        if !$PokemonGlobal.daycare[0][0]
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=8
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(0,3,4)
          pbDayCareWithdraw(0)
          refresh = true
        end
      when 1  # Withdraw Pokémon 2
        if !$PokemonGlobal.daycare[1][0]
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=8
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(1,3,4)
          pbDayCareWithdraw(1)
          refresh = true
        end
      when 2   # Deposit Pokémon
        if pbDayCareDeposited==2
          pbPlayBuzzerSE
        elsif $Trainer.party.length==0
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is empty, can't deposit Pokémon."))
        else
          pbPlayDecisionSE
          pbChooseNonEggPokemon(1,3)
          if pbGet(1)>=0
            pbDayCareDeposit(pbGet(1))
            refresh = true
          end
        end
      when 3   # Generate/discard egg
        if pbEggGenerated?
          pbPlayDecisionSE
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          refresh = true
        else
          if pbDayCareDeposited!=2 || pbDayCareGetCompat==0
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            $PokemonGlobal.daycareEgg = 1
            refresh = true
          end
        end
      when 4   # Collect egg
        if $PokemonGlobal.daycareEgg!=1
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=8
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't collect the egg."))
        else
          pbPlayDecisionSE
          pbDayCareGenerateEgg
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          pbMessage(_INTL("Collected the {1} egg.",
             PBSpecies.getName($Trainer.lastParty.species)))
          refresh = true
        end
      end
	else
      case cmdwindow.index
      when 0   # Withdraw Pokémon 1
        if !$PokemonGlobal.daycare[0][0]
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=6
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(0,3,4)
          pbDayCareWithdraw(0)
          refresh = true
        end
      when 1  # Withdraw Pokémon 2
        if !$PokemonGlobal.daycare[1][0]
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=6
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't withdraw Pokémon."))
        else
          pbPlayDecisionSE
          pbDayCareGetDeposited(1,3,4)
          pbDayCareWithdraw(1)
          refresh = true
        end
      when 2   # Deposit Pokémon
        if pbDayCareDeposited==2
          pbPlayBuzzerSE
        elsif $Trainer.party.length==0
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is empty, can't deposit Pokémon."))
        else
          pbPlayDecisionSE
          pbChooseNonEggPokemon(1,3)
          if pbGet(1)>=0
            pbDayCareDeposit(pbGet(1))
            refresh = true
          end
        end
      when 3   # Generate/discard egg
        if pbEggGenerated?
          pbPlayDecisionSE
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          refresh = true
        else
          if pbDayCareDeposited!=2 || pbDayCareGetCompat==0
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            $PokemonGlobal.daycareEgg = 1
            refresh = true
          end
        end
      when 4   # Collect egg
        if $PokemonGlobal.daycareEgg!=1
          pbPlayBuzzerSE
        elsif $Trainer.party.length>=6
          pbPlayBuzzerSE
          pbMessage(_INTL("Party is full, can't collect the egg."))
        else
          pbPlayDecisionSE
          pbDayCareGenerateEgg
          $PokemonGlobal.daycareEgg      = 0
          $PokemonGlobal.daycareEggSteps = 0
          pbMessage(_INTL("Collected the {1} egg.",
             PBSpecies.getName($Trainer.lastParty.species)))
          refresh = true
        end
      end
	end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end
################################################################################
# PScreen_PokemonStorage                                                       #
################################################################################
#===============================================================================
# Cursor
#===============================================================================
class PokemonBoxArrow < SpriteWrapper #Modify
  attr_accessor :quickswap

  def initialize(viewport=nil)
    super(viewport)
    @frame         = 0
    @holding       = false
    @updating      = false
    @quickswap     = false
    @grabbingState = 0
    @placingState  = 0
    @heldpkmn      = nil
    @handsprite    = ChangelingSprite.new(0,0,viewport)
    @handsprite.addBitmap("point1","Graphics/Pictures/Storage/cursor_point_1")
    @handsprite.addBitmap("point2","Graphics/Pictures/Storage/cursor_point_2")
    @handsprite.addBitmap("grab","Graphics/Pictures/Storage/cursor_grab")
    @handsprite.addBitmap("fist","Graphics/Pictures/Storage/cursor_fist")
    @handsprite.addBitmap("point1q","Graphics/Pictures/Storage/cursor_point_1_q")
    @handsprite.addBitmap("point2q","Graphics/Pictures/Storage/cursor_point_2_q")
    @handsprite.addBitmap("grabq","Graphics/Pictures/Storage/cursor_grab_q")
    @handsprite.addBitmap("fistq","Graphics/Pictures/Storage/cursor_fist_q")
    @handsprite.changeBitmap("fist")
    @spriteX = self.x
    @spriteY = self.y
  end

  def dispose
    @handsprite.dispose
    @heldpkmn.dispose if @heldpkmn
    super
  end

  def heldPokemon
    @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
    @holding = false if !@heldpkmn
    return @heldpkmn
  end

  def visible=(value)
    super
    @handsprite.visible = value
    sprite = heldPokemon
    sprite.visible = value if sprite
  end

  def color=(value)
    super
    @handsprite.color = value
    sprite = heldPokemon
    sprite.color = value if sprite
  end

  def holding?
    return self.heldPokemon && @holding
  end

  def grabbing?
    return @grabbingState>0
  end

  def placing?
    return @placingState>0
  end

  def x=(value)
    super
    @handsprite.x = self.x
    @spriteX = x if !@updating
    heldPokemon.x = self.x if holding?
  end

  def y=(value)
    super
    @handsprite.y = self.y
    @spriteY = y if !@updating
    heldPokemon.y = self.y+16 if holding?
  end

  def z=(value)
    super
    @handsprite.z = value
  end

  def setSprite(sprite)
    if holding?
      @heldpkmn = sprite
      @heldpkmn.viewport = self.viewport if @heldpkmn
      @heldpkmn.z = 1 if @heldpkmn
      @holding = false if !@heldpkmn
      self.z = 2
    end
  end

  def deleteSprite
    @holding = false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn = nil
    end
  end

  def grab(sprite)
    @grabbingState = 1
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2
  end

  def place
    @placingState = 1
  end

  def release
    @heldpkmn.release if @heldpkmn
  end

  def update
    @updating = true
    super
    heldpkmn = heldPokemon
    heldpkmn.update if heldpkmn
    @handsprite.update
    @holding = false if !heldpkmn
    if @grabbingState>0
      if @grabbingState<=4*Graphics.frame_rate/20
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY+4.0*@grabbingState*20/Graphics.frame_rate
        @grabbingState += 1
      elsif @grabbingState<=8*Graphics.frame_rate/20
        @holding = true
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY+4*(8*Graphics.frame_rate/20-@grabbingState)*20/Graphics.frame_rate
        @grabbingState += 1
      else
        @grabbingState = 0
      end
    elsif @placingState>0
      if @placingState<=4*Graphics.frame_rate/20
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY+4.0*@placingState*20/Graphics.frame_rate
        @placingState += 1
      elsif @placingState<=8*Graphics.frame_rate/20
        @holding = false
        @heldpkmn = nil
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY+4*(8*Graphics.frame_rate/20-@placingState)*20/Graphics.frame_rate
        @placingState += 1
      else
        @placingState = 0
      end
    elsif holding?
      @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
    else
      self.x = @spriteX
      self.y = @spriteY
      if @frame<Graphics.frame_rate/2
        @handsprite.changeBitmap((@quickswap) ? "point1q" : "point1")
      else
        @handsprite.changeBitmap((@quickswap) ? "point2q" : "point2")
      end
    end
    @frame += 1
    @frame = 0 if @frame>=Graphics.frame_rate
    @updating = false
  end
end
#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites
  def initialize(storage,boxnumber,viewport=nil)
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @pokemonsprites = []
    for i in 0...30
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber,i]
      @pokemonsprites[i] = PokemonBoxIcon.new(pokemon,viewport)
    end
    @contents = BitmapWrapper.new(324,296)
    self.bitmap = @contents
    self.x = 184+RXMOD
    self.y = 18
    refresh
  end

  def dispose
    if !disposed?
      for i in 0...30
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @boxbitmap.dispose
      @contents.dispose
      super
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...30
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg!=@storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || (curbg.is_a?(String) && curbg.length==0)
        @bg = @boxnumber%PokemonStorage::BASICWALLPAPERQTY
      else
        if curbg.is_a?(String) && curbg[/^box(\d+)$/]
          curbg = $~[1].to_i
          @storage[@boxnumber].background = curbg
        end
        @bg = curbg
      end
      if !@storage.isAvailableWallpaper?(@bg)
        @bg = @boxnumber%PokemonStorage::BASICWALLPAPERQTY
        @storage[@boxnumber].background = @bg
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/box_#{@bg}")
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites[index].refresh
    refresh
  end

  def grabPokemon(index,arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    refresh
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,324,296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      xval = 162-(widthval/2)
      pbDrawShadowText(@contents,xval,8,widthval,32,boxname,Color.new(248,248,248),Color.new(40,48,48))
      @refreshBox = false
    end
    yval = self.y+30
    for j in 0...5
      xval = self.x+10
      for k in 0...6
        sprite = @pokemonsprites[j*6+k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.x = xval
          sprite.y = yval
          sprite.z = 0
        end
        xval += 48
      end
      yval += 48
    end
  end

  def update
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end
#===============================================================================
# Party pop-up panel
#===============================================================================
class PokemonBoxPartySprite < SpriteWrapper
  def initialize(party,viewport=nil)
    super(viewport)
    @party = party
	if $Trainer.partyplus
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/overlay_partyplus")
    @pokemonsprites = []
    for i in 0...8
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon,viewport)
      end
    end
	else
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/overlay_party")
    @pokemonsprites = []
    for i in 0...6
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon,viewport)
      end
    end
	end
    @contents = BitmapWrapper.new(172,352)
    self.bitmap = @contents
    self.x = 182+RXMOD
    self.y = Graphics.height-352
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
  if $Trainer.partyplus
    for i in 0...8
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
  else
    for i in 0...6
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
  end
    @boxbitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
	if $Trainer.partyplus
    for i in 0...8
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color,value)
      end
    end
	else
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color,value)
      end
    end
	end
  end

  def visible=(value)
    super
	if $Trainer.partyplus
    for i in 0...8
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
	else
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
	end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index,arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    @pokemonsprites.compact!
    refresh
  end

  def refresh
  if $Trainer.partyplus
    @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,172,352))
    pbDrawTextPositions(self.bitmap,[
       [_INTL("Back"),86,306,2,Color.new(248,248,248),Color.new(80,80,80),1]
    ])

    xvalues = [18,90,18,90,18,90,18,90]
    yvalues = [2,18,66,82,130,146,194,210]
    for j in 0...8
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...8
      sprite = @pokemonsprites[j]
      if sprite && !sprite.disposed?
        sprite.viewport = self.viewport
        sprite.x = self.x+xvalues[j]
        sprite.y = self.y+yvalues[j]
        sprite.z = 0
      end
    end
  else
    @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,172,352))
    pbDrawTextPositions(self.bitmap,[
       [_INTL("Back"),86,242,2,Color.new(248,248,248),Color.new(80,80,80),1]
    ])

    xvalues = [18,90,18,90,18,90]
    yvalues = [2,18,66,82,130,146]
    for j in 0...6
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...6
      sprite = @pokemonsprites[j]
      if sprite && !sprite.disposed?
        sprite.viewport = self.viewport
        sprite.x = self.x+xvalues[j]
        sprite.y = self.y+yvalues[j]
        sprite.z = 0
      end
    end
  end
  end

  def update
    super
	if $Trainer.partyplus
    for i in 0...8
      @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
    end
	else
    for i in 0...6
      @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
    end
	end
  end
end
#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
  attr_reader :quickswap

  def initialize
    @command = 1
  end

  def pbStartBox(screen,command)
    @screen = screen
    @storage = screen.storage
    @bgviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z = 99999
    @boxviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxviewport.z = 99999
    @boxsidesviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxsidesviewport.z = 99999
    @arrowviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @arrowviewport.z = 99999
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @selection = 0
    @quickswap = false
    @sprites = {}
    @choseFromParty = false
    @command = command
    addBackgroundPlane(@sprites,"background","Storage/bg",@bgviewport)
    @sprites["box"] = PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxsides"] = IconSprite.new(0,0,@boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/overlay_main")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 90
    @sprites["pokemon"].y = 134
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    if command!=2   # Drop down tab only on Deposit
      @sprites["boxparty"].x = 182+RXMOD
      @sprites["boxparty"].y = Graphics.height
    end
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/markings")
    @sprites["markingbg"] = IconSprite.new(292,68,@boxsidesviewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Storage/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@boxsidesviewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z += 1
    if command!=2
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
      pbSetMosaic(@selection)
    end
    pbSEPlay("PC access")
    pbFadeInAndShow(@sprites)
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @markingbitmap.dispose if @markingbitmap
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  def pbDisplay(message)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    msgwindow.text           = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        break
      end
      msgwindow.update
      self.update
    end
    msgwindow.dispose
    Input.update
  end

  def pbShowCommands(message,commands,index=0)
    ret = -1
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.text           = message
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible  = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height   = Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
    pbBottomRight(cmdwindow)
    cmdwindow.y        -= msgwindow.height
    cmdwindow.index    = index
    loop do
      Graphics.update
      Input.update
      msgwindow.update
      cmdwindow.update
      if Input.trigger?(Input::B)
        ret = -1
        break
      elsif Input.trigger?(Input::C)
        ret = cmdwindow.index
        break
      end
      self.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbSetArrow(arrow,selection)
    case selection
    when -1, -4, -5 # Box name, move left, move right
      arrow.x = (157*2)+RXMOD
      arrow.y = -12*2
    when -2 # Party Pokémon
      arrow.x = (119*2)+RXMOD
      arrow.y = (139*2)+RYMOD
    when -3 # Close Box
      arrow.x = (207*2)+RXMOD
      arrow.y = (139*2)+RYMOD
    else
      arrow.x = ((97+24*(selection%6))*2)+RXMOD
      arrow.y = (8+24*(selection/6))*2
    end
  end

  def pbChangeSelection(key,selection)
    case key
    when Input::UP
      if selection==-1   # Box name
        selection = -2
      elsif selection==-2   # Party
        selection = 25
      elsif selection==-3   # Close Box
        selection = 28
      else
        selection -= 6
        selection = -1 if selection<0
      end
    when Input::DOWN
      if selection==-1   # Box name
        selection = 2
      elsif selection==-2   # Party
        selection = -1
      elsif selection==-3   # Close Box
        selection = -1
      else
        selection += 6
        selection = -2 if selection==30 || selection==31 || selection==32
        selection = -3 if selection==33 || selection==34 || selection==35
      end
    when Input::LEFT
      if selection==-1   # Box name
        selection = -4   # Move to previous box
      elsif selection==-2
        selection = -3
      elsif selection==-3
        selection = -2
      else
        selection -= 1
        selection += 6 if selection==-1 || selection%6==5
      end
    when Input::RIGHT
      if selection==-1   # Box name
        selection = -5   # Move to next box
      elsif selection==-2
        selection = -3
      elsif selection==-3
        selection = -2
      else
        selection += 1
        selection -= 6 if selection%6==0
      end
    end
    return selection
  end

  def pbPartySetArrow(arrow,selection)
  if $Trainer.partyplus
    if selection>=0
      xvalues = [100,136,100,136,100,136,100,136,118]
      yvalues = [1,9,33,41,65,73,97,105,142]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = (xvalues[selection]*2)+RXMOD
      arrow.y = (yvalues[selection]*2)+RYMOD
    end
	else
	if selection>=0
      xvalues = [100,136,100,136,100,136,118]
      yvalues = [1,9,33,41,65,73,110]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = (xvalues[selection]*2)+RXMOD
      arrow.y = (yvalues[selection]*2)+RYMOD
    end
   end
  end

  def pbPartyChangeSelection(key,selection)
  if $Trainer.partyplus
    case key
    when Input::LEFT
      selection -= 1
      selection = 8 if selection<0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection>8
    when Input::UP
      if selection==8
        selection = 7
      else
        selection -= 2
        selection = 8 if selection<0
      end
    when Input::DOWN
      if selection==8
        selection = 0
      else
        selection += 2
        selection = 8 if selection>8
      end
    end
    return selection
 else
    case key
    when Input::LEFT
      selection -= 1
      selection = 6 if selection<0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection>6
    when Input::UP
      if selection==6
        selection = 5
      else
        selection -= 2
        selection = 6 if selection<0
      end
    when Input::DOWN
      if selection==6
        selection = 0
      else
        selection += 2
        selection = 6 if selection>6
      end
    end
    return selection
  end
 end

  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE
        selection = pbChangeSelection(key,selection)
        pbSetArrow(@sprites["arrow"],selection)
        if selection==-4
          nextbox = (@storage.currentBox+@storage.maxBoxes-1)%@storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection==-5
          nextbox = (@storage.currentBox+1)%@storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection==-4 || selection==-5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      self.update
      if Input.trigger?(Input::L)
        pbPlayCursorSE
        nextbox = (@storage.currentBox+@storage.maxBoxes-1)%@storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::R)
        pbPlayCursorSE
        nextbox = (@storage.currentBox+1)%@storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::F5)   # Jump to box name
        if selection!=-1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"],selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::B)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::C)
        @selection = selection
        if selection>=0
          return [@storage.currentBox,selection]
        elsif selection==-1   # Box name
          return [-4,-1]
        elsif selection==-2   # Party Pokémon
          return [-2,-1]
        elsif selection==-3   # Close Box
          return [-3,-1]
        end
      end
    end
  end

  def pbSelectBox(party)
    return pbSelectBoxInternal(party) if @command==1   # Withdraw
    ret = nil
    loop do
      if !@choseFromParty
        ret = pbSelectBoxInternal(party)
      end
      if @choseFromParty || (ret && ret[0]==-2)   # Party Pokémon
        if !@choseFromParty
          pbShowPartyTab
          @selection = 0
        end
        ret = pbSelectPartyInternal(party,false)
        if ret<0
          pbHidePartyTab
          @selection = 0
          @choseFromParty = false
        else
          @choseFromParty = true
          return [-1,ret]
        end
      else
        @choseFromParty = false
        return ret
      end
    end
  end

  def pbSelectPartyInternal(party,depositing)
    selection = @selection
    pbPartySetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection,party)
    pbSetMosaic(selection)
    lastsel = 1
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE
        newselection = pbPartyChangeSelection(key,selection)
        if newselection==-1
          return -1 if !depositing
        elsif newselection==-2
          selection = lastsel
        else
          selection = newselection
        end
        pbPartySetArrow(@sprites["arrow"],selection)
        lastsel = selection if selection>0
        pbUpdateOverlay(selection,party)
        pbSetMosaic(selection)
      end
      self.update
      if Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::B)
        @selection = selection
        return -1
      elsif Input.trigger?(Input::C)
	  if $Trainer.partyplus
        if selection>=0 && selection<8
          @selection = selection
          return selection
        elsif selection==8   # Close Box
          @selection = selection
          return (depositing) ? -3 : -1
        end
	  else
        if selection>=0 && selection<6
          @selection = selection
          return selection
        elsif selection==6   # Close Box
          @selection = selection
          return (depositing) ? -3 : -1
        end
	  end
      end
    end
  end

  def pbSelectParty(party)
    return pbSelectPartyInternal(party,true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites = false
    alpha = 0
    Graphics.update
    self.update
    timeTaken = Graphics.frame_rate*4/10
    alphaDiff = (255.0/timeTaken).ceil
    timeTaken.times do
      alpha += alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248,248,248,alpha)
      self.update
    end
    @sprites["box"].refreshBox = true
    @storage[@storage.currentBox].background = wp
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
      self.update
    end
    timeTaken.times do
      alpha -= alphaDiff
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248,248,248,alpha)
      self.update
    end
    @sprites["box"].refreshSprites = true
  end

  def pbSwitchBoxToRight(newbox)
    newbox = PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x = 520+RXMOD
    Graphics.frame_reset
    distancePerFrame = 64*20/Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x -= distancePerFrame
      newbox.x -= distancePerFrame
      self.update
      break if newbox.x<=184+RXMOD
    end
    diff = newbox.x-184+RXMOD
    newbox.x = 184+RXMOD
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
  end

  def pbSwitchBoxToLeft(newbox)
    newbox = PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x = -152+RXMOD
    Graphics.frame_reset
    distancePerFrame = 64*20/Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["box"].x += distancePerFrame
      newbox.x += distancePerFrame
      self.update
      break if newbox.x>=184+RXMOD
    end
    diff = newbox.x-184+RXMOD
    newbox.x = 184+RXMOD
    @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox!=newbox
      if newbox>@storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox = newbox
    end
  end

  def pbSetMosaic(selection)
    if !@screen.pbHeldPokemon
      if @boxForMosaic!=@storage.currentBox || @selectionForMosaic!=selection
        @sprites["pokemon"].mosaic = Graphics.frame_rate/4
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selection
      end
    end
  end

  def pbSetQuickSwap(value)
    @quickswap = value
    @sprites["arrow"].quickswap = value
  end

  def pbShowPartyTab
    pbSEPlay("GUI storage show party panel")
    distancePerFrame = 48*20/Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y -= distancePerFrame
      self.update
      break if @sprites["boxparty"].y<=Graphics.height-352
    end
    @sprites["boxparty"].y = Graphics.height-352
  end

  def pbHidePartyTab
    pbSEPlay("GUI storage hide party panel")
    distancePerFrame = 48*20/Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      @sprites["boxparty"].y += distancePerFrame
      self.update
      break if @sprites["boxparty"].y>=Graphics.height
    end
    @sprites["boxparty"].y = Graphics.height
  end

  def pbHold(selected)
    pbSEPlay("GUI storage pick up")
    if selected[0]==-1
      @sprites["boxparty"].grabPokemon(selected[1],@sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1],@sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwap(selected,_heldpoke)
    pbSEPlay("GUI storage pick up")
    heldpokesprite = @sprites["arrow"].heldPokemon
    boxpokesprite = nil
    if selected[0]==-1
      boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite = @sprites["box"].getPokemon(selected[1])
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    @sprites["pokemon"].mosaic = 10
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbPlace(selected,_heldpoke)
    pbSEPlay("GUI storage put down")
    heldpokesprite = @sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbWithdraw(selected,heldpoke,partyindex)
    pbHold(selected) if !heldpoke
    pbShowPartyTab
    pbPartySetArrow(@sprites["arrow"],partyindex)
    pbPlace([-1,partyindex],heldpoke)
    pbHidePartyTab
  end

  def pbStore(selected,heldpoke,destbox,firstfree)
    if heldpoke
      if destbox==@storage.currentBox
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree,heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite = @sprites["boxparty"].getPokemon(selected[1])
      if destbox==@storage.currentBox
        @sprites["box"].setPokemon(firstfree,sprite)
        @sprites["boxparty"].setPokemon(selected[1],nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def pbRelease(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box==-1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        self.update
      end
    end
  end

  def pbChooseBox(msg)
    commands = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        commands.push(_INTL("{1} ({2}/{3})",box.name,box.nitems,box.length))
      end
    end
    return pbShowCommands(msg,commands,@storage.currentBox)
  end

  def pbBoxName(helptext,minchars,maxchars)
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = pbEnterBoxName(helptext,minchars,maxchars)
    if ret.length>0
      @storage[@storage.currentBox].name = ret
    end
    @sprites["box"].refreshBox = true
    pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbChooseItem(bag)
    ret = 0
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| pbCanHoldItem?(item) })
    }
    return ret
  end

  def pbSummary(selected,heldpoke)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke],0)
    elsif selected[0]==-1
      @selection = screen.pbStartScreen(@storage.party,selected[1])
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
    else
      @selection = screen.pbStartScreen(@storage.boxes[selected[0]],selected[1])
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbMarkingSetArrow(arrow,selection)
    if selection>=0
      xvalues = [162,191,220,162,191,220,184,184]
      yvalues = [24,24,24,49,49,49,77,109]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection]*2
      arrow.y = yvalues[selection]*2
    end
  end

  def pbMarkingChangeSelection(key,selection)
    case key
    when Input::LEFT
      if selection<6
        selection -= 1
        selection += 3 if selection%3==2
      end
    when Input::RIGHT
      if selection<6
        selection += 1
        selection -= 3 if selection%3==0
      end
    when Input::UP
      if selection==7; selection = 6
      elsif selection==6; selection = 4
      elsif selection<3; selection = 7
      else; selection -= 3
      end
    when Input::DOWN
      if selection==7; selection = 1
      elsif selection==6; selection = 7
      elsif selection>=3; selection = 6
      else; selection += 3
      end
    end
    return selection
  end

  def pbMark(selected,heldpoke)
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    msg = _INTL("Mark your Pokémon.")
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.text           = msg
    msgwindow.resizeHeightToFit(msg,Graphics.width-180)
    pbBottomRight(msgwindow)
    base   = Color.new(248,248,248)
    shadow = Color.new(80,80,80)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0]==-1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    markings = pokemon.markings
    index = 0
    redraw = true
    markrect = Rect.new(0,0,16,16)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        for i in 0...6
          markrect.x = i*16
          markrect.y = (markings&(1<<i)!=0) ? 16 : 0
          @sprites["markingoverlay"].bitmap.blt(336+58*(i%3),106+50*(i/3),@markingbitmap.bitmap,markrect)
        end
        textpos = [
           [_INTL("OK"),402,210,2,base,shadow,1],
           [_INTL("Cancel"),402,274,2,base,shadow,1]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap,textpos)
        pbMarkingSetArrow(@sprites["arrow"],index)
        redraw = false
      end
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        oldindex = index
        index = pbMarkingChangeSelection(key,index)
        pbPlayCursorSE if index!=oldindex
        pbMarkingSetArrow(@sprites["arrow"],index)
      end
      self.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        if index==6   # OK
          pokemon.markings = markings
          break
        elsif index==7   # Cancel
          break
        else
          mask = (1<<index)
          if (markings&mask)==0
            markings |= mask
          else
            markings &= ~mask
          end
          redraw = true
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    msgwindow.dispose
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxparty"].dispose
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    @sprites["boxparty"].y = oldPartyY
  end

  def drawMarkings(bitmap,x,y,_width,_height,markings)
    markrect = Rect.new(0,0,16,16)
    for i in 0...8
      markrect.x = i*16
      markrect.y = (markings&(1<<i)!=0) ? 16 : 0
      bitmap.blt(x+i*16,y,@markingbitmap.bitmap,markrect)
    end
  end

  def pbUpdateOverlay(selection,party=nil) #Modify
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248,248,248)
    buttonshadow = Color.new(80,80,80)
    pbDrawTextPositions(overlay,[
       [_INTL("Party: {1}",(@storage.party.length rescue 0)),270+RXMOD,328+RYMOD,2,buttonbase,buttonshadow,1],
       [_INTL("Exit"),446+RXMOD,328+RYMOD,2,buttonbase,buttonshadow,1],
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
      if pokemon.male?
        textstrings.push([_INTL("♂"),148,8,false,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.female?
        textstrings.push([_INTL("♀"),148,8,false,Color.new(248,56,32),Color.new(224,152,144)])
      end
      imagepos.push(["Graphics/Pictures/Storage/overlay_lv",6,246])
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
      if pokemon.shiny?
        imagepos.push(["Graphics/Pictures/shiny",156,198])
      end
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

  def update
    pbUpdateSpriteHash(@sprites)
  end
end
#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage

  def initialize(scene,storage)
    @scene = scene
    @storage = storage
    @pbHeldPokemon = nil
  end

  def pbStartScreen(command)
    @heldpkmn = nil
    if command==0
### ORGANISE ###################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        elsif selected[0]==-3   # Close box
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected[0]==-4   # Box name
          pbBoxCommands
        else
          pokemon = @storage[selected[0],selected[1]]
          heldpoke = pbHeldPokemon
          next if !pokemon && !heldpoke
          if @scene.quickswap
            if @heldpkmn
              (pokemon) ? pbSwap(selected) : pbPlace(selected)
            else
              pbHold(selected)
            end
          else
            commands = []
            cmdMove     = -1
            cmdSummary  = -1
            cmdWithdraw = -1
            cmdItem     = -1
            cmdMark     = -1
            cmdRelease  = -1
            cmdDebug    = -1
            cmdCancel   = -1
            if heldpoke
              helptext = _INTL("{1} is selected.",heldpoke.name)
              commands[cmdMove=commands.length]   = (pokemon) ? _INTL("Shift") : _INTL("Place")
            elsif pokemon
              helptext = _INTL("{1} is selected.",pokemon.name)
              commands[cmdMove=commands.length]   = _INTL("Move")
            end
            commands[cmdSummary=commands.length]  = _INTL("Summary")
            commands[cmdWithdraw=commands.length] = (selected[0]==-1) ? _INTL("Store") : _INTL("Withdraw")
            commands[cmdItem=commands.length]     = _INTL("Item")
            commands[cmdMark=commands.length]     = _INTL("Mark")
            commands[cmdRelease=commands.length]  = _INTL("Release")
            commands[cmdDebug=commands.length]    = _INTL("Debug") if $DEBUG
            commands[cmdCancel=commands.length]   = _INTL("Cancel")
            command=pbShowCommands(helptext,commands)
            if cmdMove>=0 && command==cmdMove   # Move/Shift/Place
              if @heldpkmn
                (pokemon) ? pbSwap(selected) : pbPlace(selected)
              else
                pbHold(selected)
              end
            elsif cmdSummary>=0 && command==cmdSummary   # Summary
              pbSummary(selected,@heldpkmn)
            elsif cmdWithdraw>=0 && command==cmdWithdraw   # Store/Withdraw
              (selected[0]==-1) ? pbStore(selected,@heldpkmn) : pbWithdraw(selected,@heldpkmn)
            elsif cmdItem>=0 && command==cmdItem   # Item
              pbItem(selected,@heldpkmn)
            elsif cmdMark>=0 && command==cmdMark   # Mark
              pbMark(selected,@heldpkmn)
            elsif cmdRelease>=0 && command==cmdRelease   # Release
              pbRelease(selected,@heldpkmn)
            elsif cmdDebug>=0 && command==cmdDebug   # Debug
              pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon,selected,heldpoke)
            end
          end
        end
      end
      @scene.pbCloseBox
    elsif command==1
### WITHDRAW ###################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          case selected[0]
          when -2   # Party Pokémon
            pbDisplay(_INTL("Which one will you take?"))
            next
          when -3   # Close box
            if pbConfirm(_INTL("Exit from the Box?"))
              pbSEPlay("PC close")
              break
            end
            next
          when -4   # Box name
            pbBoxCommands
            next
          end
          pokemon = @storage[selected[0],selected[1]]
          next if !pokemon
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),[
             _INTL("Withdraw"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release"),
             _INTL("Cancel")
          ])
          case command
          when 0; pbWithdraw(selected,nil)
          when 1; pbSummary(selected,nil)
          when 2; pbMark(selected,nil)
          when 3; pbRelease(selected,nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==2
### DEPOSIT ####################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectParty(@storage.party)
        if selected==-3   # Close box
          if pbConfirm(_INTL("Exit from the Box?"))
            pbSEPlay("PC close")
            break
          end
          next
        elsif selected<0
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          pokemon = @storage[-1,selected]
          next if !pokemon
          command = pbShowCommands(_INTL("{1} is selected.",pokemon.name),[
             _INTL("Store"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release"),
             _INTL("Cancel")
          ])
          case command
          when 0; pbStore([-1,selected],nil)
          when 1; pbSummary([-1,selected],nil)
          when 2; pbMark([-1,selected],nil)
          when 3; pbRelease([-1,selected],nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==3
      @scene.pbStartBox(self,command)
      @scene.pbCloseBox
    end
  end

  def pbUpdate   # For debug
    @scene.update
  end

  def pbHardRefresh   # For debug
    @scene.pbHardRefresh
  end

  def pbRefreshSingle(i)   # For debug
    @scene.pbUpdateOverlay(i[1],(i[0]==-1) ? @storage.party : nil)
    @scene.pbHardRefresh
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbConfirm(str)
    return pbShowCommands(str,[_INTL("Yes"),_INTL("No")])==0
  end

  def pbShowCommands(msg,commands,index=0)
    return @scene.pbShowCommands(msg,commands,index)
  end

  def pbAble?(pokemon)
    pokemon && !pokemon.egg? && pokemon.hp>0
  end

  def pbAbleCount
    count = 0
    for p in @storage.party
      count += 1 if pbAble?(p)
    end
    return count
  end

  def pbHeldPokemon
    return @heldpkmn
  end

  def pbWithdraw(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if box==-1
      raise _INTL("Can't withdraw from party...");
    end
	if $Trainer.partyplus
    if @storage.party.nitems>=8
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
	else
    if @storage.party.nitems>=6
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
	end
    @scene.pbWithdraw(selected,heldpoke,@storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn = nil
    else
      @storage.pbMove(-1,-1,box,index)
    end
    @scene.pbRefresh
    return true
  end

  def pbStore(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if box!=-1
      raise _INTL("Can't deposit from box...")
    end
    if pbAbleCount<=1 && pbAble?(@storage[box,index]) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif heldpoke && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !heldpoke && @storage[box,index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox>=0
          firstfree = @storage.pbFirstFreePos(destbox)
          if firstfree<0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          if heldpoke || selected[0]==-1
            p = (heldpoke) ? heldpoke : @storage[-1,index]
            p.formTime = nil if p.respond_to?("formTime")
            p.form     = 0 if p.isSpecies?(:SHAYMIN)
            p.heal
          end
          @scene.pbStore(selected,heldpoke,destbox,firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke,destbox)
            @heldpkmn = nil
          else
            @storage.pbMove(destbox,-1,-1,index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbHold(selected)
    box = selected[0]
    index = selected[1]
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn = @storage[box,index]
    @storage.pbDelete(box,index)
    @scene.pbRefresh
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @storage[box,index]
      raise _INTL("Position {1},{2} is not empty...",box,index)
    end
    if box!=-1 && index>=@storage.maxPokemon(box)
      pbDisplay("Can't place that there.")
      return
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return
    end
    if box>=0
      @heldpkmn.formTime = nil if @heldpkmn.respond_to?("formTime")
      @heldpkmn.form     = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal
    end
    @scene.pbPlace(selected,@heldpkmn)
    @storage[box,index] = @heldpkmn
    if box==-1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]
    if !@storage[box,index]
      raise _INTL("Position {1},{2} is empty...",box,index)
    end
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1 && !pbAble?(@heldpkmn)
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return false
    end
    if box>=0
      @heldpkmn.formTime = nil if @heldpkmn.respond_to?("formTime")
      @heldpkmn.form     = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal
    end
    @scene.pbSwap(selected,@heldpkmn)
    tmp = @storage[box,index]
    @storage[box,index] = @heldpkmn
    @heldpkmn = tmp
    @scene.pbRefresh
    return true
  end

  def pbRelease(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box,index]
    return if !pokemon
    if pokemon.egg?
      pbDisplay(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box==-1 && pbAbleCount<=1 && pbAble?(pokemon) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release this Pokémon?"),[_INTL("No"),_INTL("Yes")])
    if command==1
      pkmnname = pokemon.name
      @scene.pbRelease(selected,heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box,index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.",pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!",pkmnname))
      @scene.pbRefresh
    end
    return
  end

  def pbChooseMove(pkmn,helptext,index=0)
    movenames = []
    for i in pkmn.moves
      break if i.id==0
      if i.totalpp<=0
        movenames.push(_INTL("{1} (PP: ---)",PBMoves.getName(i.id)))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",PBMoves.getName(i.id),i.pp,i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames,index)
  end

  def pbSummary(selected,heldpoke)
    @scene.pbSummary(selected,heldpoke)
  end

  def pbMark(selected,heldpoke)
    @scene.pbMark(selected,heldpoke)
  end

  def pbItem(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box,index]
    if pokemon.egg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if pokemon.item>0
      itemname = PBItems.getName(pokemon.item)
      if pbConfirm(_INTL("Take this {1}?",itemname))
        if !$PokemonBag.pbStoreItem(pokemon.item)
          pbDisplay(_INTL("Can't store the {1}.",itemname))
        else
          pbDisplay(_INTL("Took the {1}.",itemname))
          pokemon.setItem(0)
          @scene.pbHardRefresh
        end
      end
    else
      item = scene.pbChooseItem($PokemonBag)
      if item>0
        itemname = PBItems.getName(item)
        pokemon.setItem(item)
        $PokemonBag.pbDeleteItem(item)
        pbDisplay(_INTL("{1} is now being held.",itemname))
        @scene.pbHardRefresh
      end
    end
  end

  def pbBoxCommands
    commands = [
       _INTL("Jump"),
       _INTL("Wallpaper"),
       _INTL("Name"),
       _INTL("Cancel"),
    ]
    command = pbShowCommands(
       _INTL("What do you want to do?"),commands)
    case command
    when 0
      destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
      if destbox>=0
        @scene.pbJumpToBox(destbox)
      end
    when 1
      papers = @storage.availableWallpapers
      index = 0
      for i in 0...papers[1].length
        if papers[1][i]==@storage[@storage.currentBox].background
          index = i; break
        end
      end
      wpaper = pbShowCommands(_INTL("Pick the wallpaper."),papers[0],index)
      if wpaper>=0
        @scene.pbChangeBackground(papers[1][wpaper])
      end
    when 2
      @scene.pbBoxName(_INTL("Box name?"),0,12)
    end
  end

  def pbChoosePokemon(_party=nil)
    @heldpkmn = nil
    @scene.pbStartBox(self,1)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0]==-3   # Close box
        if pbConfirm(_INTL("Exit from the Box?"))
          pbSEPlay("PC close")
          break
        end
        next
      end
      if selected==nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0]==-4   # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0],selected[1]]
        next if !pokemon
        commands = [
           _INTL("Select"),
           _INTL("Summary"),
           _INTL("Withdraw"),
           _INTL("Item"),
           _INTL("Mark")
        ]
        commands.push(_INTL("Cancel"))
        commands[2] = _INTL("Store") if selected[0]==-1
        helptext = _INTL("{1} is selected.",pokemon.name)
        command = pbShowCommands(helptext,commands)
        case command
        when 0   # Select
          if pokemon
            retval = selected
            break
          end
        when 1; pbSummary(selected,nil)
        when 2   # Store/Withdraw
          if selected[0]==-1
            pbStore(selected,nil)
          else
            pbWithdraw(selected,nil)
          end
        when 3; pbItem(selected,nil)
        when 4; pbMark(selected,nil)
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end
end

################################################################################
# Trainer Battles                                                              #
################################################################################
def pbModTrBat(vsT,vsO,trainerID1,trainerName1,trainerID2=nil,trainerName2=nil,
               trainerID3=nil,trainerName3=nil,trainerID4=nil,trainerName4=nil,
              trainerPartyID1=0,trainerPartyID2=0,trainerPartyID3=0,trainerPartyID4=0,
              endSpeech1=nil,endSpeech2=nil,endSpeech3=nil,endSpeech4=nil,
              canLose=false, outcomeVar=1)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  if vsT==1
   if vsO==1
    setBattleRule("1v1")
   elsif vsO==2
    setBattleRule("1v2")
   elsif vsO==3
    setBattleRule("1v3")
   elsif vsO==4
    setBattleRule("1v4")
   end
  elsif vsT==2
   if vsO==1
    setBattleRule("2v1")
   elsif vsO==2
    setBattleRule("2v2")
   elsif vsO==3
    setBattleRule("2v3")
   elsif vsO==4
    setBattleRule("2v4")
   end
  elsif vsT==3
   if vsO==1
    setBattleRule("3v1")
   elsif vsO==2
    setBattleRule("3v2")
   elsif vsO==3
    setBattleRule("3v3")
   elsif vsO==4
    setBattleRule("3v4")
   end
  elsif vsT==4
   if vsO==1
    setBattleRule("4v1")
   elsif vsO==2
    setBattleRule("4v2")
   elsif vsO==3
    setBattleRule("4v3")
   elsif vsO==4
    setBattleRule("4v4")
   end
  end
  # Perform the battle
  if vsO==1
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1]
  )
  elsif vsO==2
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
  )
  elsif vsO==3
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
     [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
  )
  elsif vsO==4
  decision = pbTrainerBattleCore(
     [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
     [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
     [trainerID3,trainerName3,trainerPartyID3,endSpeech3],
     [trainerID4,trainerName4,trainerPartyID4,endSpeech4]
  )
  end
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end

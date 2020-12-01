NO_Z_MOVE = 35
USEMOVECATEGORY = true

class PokeBattle_Battler
  #=============================================================================
  # Turn processing
  #=============================================================================
  def pbProcessTurn(choice,tryFlee=true)
    return false if fainted?
    # Wild roaming Pokémon always flee if possible
    if tryFlee && @battle.wildBattle? && opposes? &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
      pbBeginTurn(choice)
      @battle.pbDisplay(_INTL("{1} fled from battle!",pbThis)) { pbSEPlay("Battle flee") }
      @battle.decision = 3
      pbEndTurn(choice)
      return true
    end
    # Shift with the battler next to this one
    if choice[0]==:Shift
      idxOther = -1
      case @battle.pbSideSize(@index)
      when 2
        idxOther = (@index+2)%4
      when 3
        if @index!=2 && @index!=3   # If not in middle spot already
          idxOther = ((@index%2)==0) ? 2 : 3
        end
      end
      if idxOther>=0
        @battle.pbSwapBattlers(@index,idxOther)
        case @battle.pbSideSize(@index)
        when 2
          @battle.pbDisplay(_INTL("{1} moved across!",pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1} moved to the center!",pbThis))
        end
      end
      pbBeginTurn(choice)
      pbCancelMoves
      @lastRoundMoved = @battle.turnCount   # Done something this round
      return true
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0]!=:UseMove
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    # Turn is skipped if Pursuit was used during switch
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit] = false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge
      return false
    end
    # Use the move
    if choice[2].zmove
      choice[2].zmove=false
      @battle.pbUseZMove(self.index,choice[2],self.item)
    else
      PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
      PBDebug.logonerr{
      pbUseMove(choice,choice[2]==@battle.struggle)
    }
    end
    @battle.pbJudge
    # Update priority order
    @battle.pbCalculatePriority if NEWEST_BATTLE_MECHANICS
    return true
  end

  def pbZCrystalFromType(type)
    case type
    when 0
      crystal = getID(PBItems,:NORMALIUMZ2)  
    when 1
      crystal = getID(PBItems,:FIGHTINIUMZ2)
    when 2
      crystal = getID(PBItems,:FLYINIUMZ2) 
    when 3
      crystal = getID(PBItems,:POISONIUMZ2)    
    when 4 
      crystal = getID(PBItems,:GROUNDIUMZ2)  
    when 5
      crystal = getID(PBItems,:ROCKIUMZ2)       
    when 6
      crystal = getID(PBItems,:BUGINIUMZ2)
    when 7 
      crystal = getID(PBItems,:GHOSTIUMZ2)       
    when 8
      crystal = getID(PBItems,:STEELIUMZ2)      
    when 10
      crystal = getID(PBItems,:FIRIUMZ2)   
    when 11
      crystal = getID(PBItems,:WATERIUMZ2)    
    when 12
      crystal = getID(PBItems,:GRASSIUMZ2) 
    when 13
      crystal = getID(PBItems,:ELECTRIUMZ2)       
    when 14 
      crystal = getID(PBItems,:PSYCHIUMZ2) 
    when 15
      crystal = getID(PBItems,:ICIUMZ2)           
    when 16
      crystal = getID(PBItems,:DRAGONIUMZ2)          
    when 17
      crystal = getID(PBItems,:DARKINIUMZ2)       
    when 18
      crystal = getID(PBItems,:FAIRIUMZ2)                             
    end
    return crystal
  end  
  
  def hasZMove?
    canuse=false
    pkmn=self
    case pkmn.item
    when getID(PBItems,:NORMALIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==0
          canuse=true
        end
      end   
    when getID(PBItems,:FIGHTINIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==1
          canuse=true
        end
      end 
    when getID(PBItems,:FLYINIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==2
          canuse=true
        end
      end   
    when getID(PBItems,:POISONIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==3
          canuse=true
        end
      end       
    when getID(PBItems,:GROUNDIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==4
          canuse=true
        end
      end
    when getID(PBItems,:ROCKIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==5
          canuse=true
        end
      end       
    when getID(PBItems,:BUGINIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==6
          canuse=true
        end
      end  
    when getID(PBItems,:GHOSTIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==7
          canuse=true
        end
      end       
    when getID(PBItems,:STEELIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==8
          canuse=true
        end
      end       
    when getID(PBItems,:FIRIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==10
          canuse=true
        end
      end   
    when getID(PBItems,:WATERIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==11
          canuse=true
        end
      end       
    when getID(PBItems,:GRASSIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==12
          canuse=true
        end
      end           
    when getID(PBItems,:ELECTRIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==13
          canuse=true
        end
      end      
    when getID(PBItems,:PSYCHIUMZ2)
      canuse=false   
      for move in pkmn.moves        
        if move.type==14
          canuse=true
        end
      end   
    when getID(PBItems,:ICIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==15
          canuse=true
        end
      end           
    when getID(PBItems,:DRAGONIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==16
          canuse=true
        end
      end           
    when getID(PBItems,:DARKINIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==17
          canuse=true
        end
      end       
    when getID(PBItems,:FAIRIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.type==18
          canuse=true
        end
      end                 
    when getID(PBItems,:ALORAICHIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:THUNDERBOLT)
          canuse=true
        end
      end
      if pkmn.species!=26 || pkmn.form!=1
        canuse=false
      end 
    when getID(PBItems,:DECIDIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPIRITSHACKLE)
          canuse=true
        end
      end
      if pkmn.species!=724
        canuse=false
      end      
    when getID(PBItems,:INCINIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:DARKESTLARIAT)
          canuse=true
        end
      end
      if pkmn.species!=727
        canuse=false
      end       
    when getID(PBItems,:PRIMARIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPARKLINGARIA)
          canuse=true
        end
      end
      if pkmn.species!=730
        canuse=false
      end  
    when getID(PBItems,:EEVIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:LASTRESORT)
          canuse=true
        end
      end
      if pkmn.species!=133
        canuse=false
      end       
    when getID(PBItems,:PIKANIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:VOLTTACKLE)
          canuse=true
        end
      end
      if pkmn.species!=25
        canuse=false
      end
    when getID(PBItems,:SNORLIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:GIGAIMPACT)
          canuse=true
        end
      end
      if pkmn.species!=143
        canuse=false
      end  
    when getID(PBItems,:MEWNIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:PSYCHIC)
          canuse=true
        end
      end
      if pkmn.species!=151
        canuse=false
      end   
    when getID(PBItems,:TAPUNIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:NATURESMADNESS)
          canuse=true
        end
      end
      if !(pokemon.species==785 || pokemon.species==786 || pokemon.species==787 || pokemon.species==788)
        canuse=false
      end   
    when getID(PBItems,:MARSHADIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:SPECTRALTHIEF)
          canuse=true
        end
      end 
      if pkmn.species!=802
        canuse=false
      end
    when getID(PBItems,:PIKASHUNIUMZ2)
      canuse=false   
      for move in pkmn.moves
        if move.id==getID(PBMoves,:THUNDERBOLT)
          canuse=true
        end
      end
      if pkmn.species!=25 || pkmn.form==0
        canuse=false
      end   
    end
    return canuse
  end
  
  def pbCompatibleZMoveFromMove?(move)  
    pkmn=self
    case pkmn.item
    when getID(PBItems,:NORMALIUMZ2)
        if move.type==0
          return true
        end
    when getID(PBItems,:FIGHTINIUMZ2)
        if move.type==1
          return true
        end
    when getID(PBItems,:FLYINIUMZ2)
        if move.type==2
          return true
        end    
    when getID(PBItems,:POISONIUMZ2)
        if move.type==3
          return true
        end              
    when getID(PBItems,:GROUNDIUMZ2)
        if move.type==4
          return true
        end      
    when getID(PBItems,:ROCKIUMZ2)
        if move.type==5
          return true
        end              
    when getID(PBItems,:BUGINIUMZ2)
        if move.type==6
          return true
        end    
    when getID(PBItems,:GHOSTIUMZ2)
        if move.type==7
          return true
        end              
    when getID(PBItems,:STEELIUMZ2)
        if move.type==8
          return true
        end       
    when getID(PBItems,:FIRIUMZ2)
        if move.type==10
          return true
        end    
    when getID(PBItems,:WATERIUMZ2)
        if move.type==11
          return true
        end             
    when getID(PBItems,:GRASSIUMZ2)
        if move.type==12
          return true
        end        
    when getID(PBItems,:ELECTRIUMZ2)
        if move.type==13
          return true
        end          
    when getID(PBItems,:PSYCHIUMZ2)
        if move.type==14
          return true
        end      
    when getID(PBItems,:ICIUMZ2)
        if move.type==15
          return true
        end              
    when getID(PBItems,:DRAGONIUMZ2)
        if move.type==16
          return true
        end              
    when getID(PBItems,:DARKINIUMZ2)
        if move.type==17
          return true
        end       
    when getID(PBItems,:FAIRIUMZ2)
        if move.type==18
          return true
        end                      
    when getID(PBItems,:ALORAICHIUMZ2)
        if move.id==getID(PBMoves,:THUNDERBOLT)
          return true
        end          
    when getID(PBItems,:DECIDIUMZ2)
        if move.id==getID(PBMoves,:SPIRITSHACKLE)
          return true
        end     
    when getID(PBItems,:INCINIUMZ2)
        if move.id==getID(PBMoves,:DARKESTLARIAT)
          return true
        end       
    when getID(PBItems,:PRIMARIUMZ2)
        if move.id==getID(PBMoves,:SPARKLINGARIA)
          return true
        end  
    when getID(PBItems,:EEVIUMZ2)
        if move.id==getID(PBMoves,:LASTRESORT)
          return true
        end       
    when getID(PBItems,:PIKANIUMZ2)
        if move.id==getID(PBMoves,:VOLTTACKLE)
          return true
        end
    when getID(PBItems,:SNORLIUMZ2)
        if move.id==getID(PBMoves,:GIGAIMPACT)
          return true
        end   
    when getID(PBItems,:MEWNIUMZ2)
        if move.id==getID(PBMoves,:PSYCHIC)
          return true
        end
    when getID(PBItems,:TAPUNIUMZ2)
        if move.id==getID(PBMoves,:NATURESMADNESS)
          return true
        end  
    when getID(PBItems,:MARSHADIUMZ2)
        if move.id==getID(PBMoves,:SPECTRALTHIEF)
          return true
        end  
    when getID(PBItems,:PIKASHUNIUMZ2)
        if move.id==getID(PBMoves,:THUNDERBOLT)
          return true
        end      
    end
    return false
  end
  
  def pbCompatibleZMoveFromIndex?(moveindex)  
    pkmn=self
    case pkmn.item
    when getID(PBItems,:NORMALIUMZ2)
        if pkmn.moves[moveindex].type==0
          return true
        end
    when getID(PBItems,:FIGHTINIUMZ2)
        if pkmn.moves[moveindex].type==1
          return true
        end
    when getID(PBItems,:FLYINIUMZ2)
        if pkmn.moves[moveindex].type==2
          return true
        end    
    when getID(PBItems,:POISONIUMZ2)
        if pkmn.moves[moveindex].type==3
          return true
        end              
    when getID(PBItems,:GROUNDIUMZ2)
        if pkmn.moves[moveindex].type==4
          return true
        end      
    when getID(PBItems,:ROCKIUMZ2)
        if pkmn.moves[moveindex].type==5
          return true
        end              
    when getID(PBItems,:BUGINIUMZ2)
        if pkmn.moves[moveindex].type==6
          return true
        end    
    when getID(PBItems,:GHOSTIUMZ2)
        if pkmn.moves[moveindex].type==7
          return true
        end              
    when getID(PBItems,:STEELIUMZ2)
        if pkmn.moves[moveindex].type==8
          return true
        end       
    when getID(PBItems,:FIRIUMZ2)
        if pkmn.moves[moveindex].type==10
          return true
        end    
    when getID(PBItems,:WATERIUMZ2)
        if pkmn.moves[moveindex].type==11
          return true
        end             
    when getID(PBItems,:GRASSIUMZ2)
        if pkmn.moves[moveindex].type==12
          return true
        end        
    when getID(PBItems,:ELECTRIUMZ2)
        if pkmn.moves[moveindex].type==13
          return true
        end          
    when getID(PBItems,:PSYCHIUMZ2)
        if pkmn.moves[moveindex].type==14
          return true
        end      
    when getID(PBItems,:ICIUMZ2)
        if pkmn.moves[moveindex].type==15
          return true
        end              
    when getID(PBItems,:DRAGONIUMZ2)
        if pkmn.moves[moveindex].type==16
          return true
        end              
    when getID(PBItems,:DARKINIUMZ2)
        if pkmn.moves[moveindex].type==17
          return true
        end       
    when getID(PBItems,:FAIRIUMZ2)
        if pkmn.moves[moveindex].type==18
          return true
        end                      
    when getID(PBItems,:ALORAICHIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:THUNDERBOLT)
          return true
        end          
    when getID(PBItems,:DECIDIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:SPIRITSHACKLE)
          return true
        end     
    when getID(PBItems,:INCINIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:DARKESTLARIAT)
          return true
        end       
    when getID(PBItems,:PRIMARIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:SPARKLINGARIA)
          return true
        end  
    when getID(PBItems,:EEVIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:LASTRESORT)
          return true
        end       
    when getID(PBItems,:PIKANIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:VOLTTACKLE)
          return true
        end
    when getID(PBItems,:SNORLIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:GIGAIMPACT)
          return true
        end   
    when getID(PBItems,:MEWNIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:PSYCHIC)
          return true
        end
    when getID(PBItems,:TAPUNIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:NATURESMADNESS)
          return true
        end  
    when getID(PBItems,:MARSHADIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:SPECTRALTHIEF)
          return true
        end  
    when getID(PBItems,:PIKASHUNIUMZ2)
        if pkmn.moves[moveindex].id==getID(PBMoves,:THUNDERBOLT)
          return true
        end        
    end
    return false
  end
  
  def pbUseMoveSimple(moveID,target=-1,idxMove=-1,specialUsage=true)
    choice = []
    choice[0] = :UseMove   # "Use move"
    choice[1] = idxMove    # Index of move to be used in user's moveset
    if idxMove>=0
      choice[2] = @moves[idxMove]
    else
    if choice[2].zmove
      crystal = pbZCrystalFromType(choice[2].type)
      choice[2] = PokeBattle_ZMoves.new(@battle,self,choice[2],crystal,choice)# PokeBattle_Move object
      choice[2].pp = -1
      else
      choice[2] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveID))# PokeBattle_Move object
      choice[2].pp = -1
      end
    end
    choice[3] = target     # Target (-1 means no target yet)
      PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
      pbUseMove(choice,specialUsage)
  end
end

class PokeBattle_Move
  attr_reader   :battle
  attr_reader   :realMove
  attr_accessor :id
  attr_reader   :name
  attr_reader   :function
  attr_reader   :baseDamage
  attr_reader   :type
  attr_reader   :category
  attr_reader   :accuracy
  attr_accessor :pp
  attr_writer   :totalpp
  attr_reader   :addlEffect
  attr_reader   :target
  attr_reader   :priority
  attr_reader   :flags
  attr_accessor :calcType
  attr_accessor :powerBoost
  attr_accessor :snatched
  attr_accessor :zmove

  def to_int; return @id; end

  #=============================================================================
  # Creating a move
  #=============================================================================
  def initialize(battle,move)
    @battle     = battle
    @realMove   = move
    @id         = move.id
    @name       = PBMoves.getName(@id)# Get the move's name
    # Get data on the move
    moveData = pbGetMoveData(@id)
    @function   = moveData[MOVE_FUNCTION_CODE]
    @baseDamage = moveData[MOVE_BASE_DAMAGE]
    @type       = moveData[MOVE_TYPE]
    @category   = moveData[MOVE_CATEGORY]
    @accuracy   = moveData[MOVE_ACCURACY]
    @pp         = move.pp   # Can be changed with Mimic/Transform
    @addlEffect = moveData[MOVE_EFFECT_CHANCE]
    @target     = moveData[MOVE_TARGET]
    @priority   = moveData[MOVE_PRIORITY]
    @flags      = moveData[MOVE_FLAGS]
    @calcType   = -1
    @powerBoost = false   # For Aerilate, Pixilate, Refrigerate, Galvanize
    @snatched   = false
    @zmove      = false
  end

  # This is the code actually used to generate a PokeBattle_Move object. The
  # object generated is a subclass of this one which depends on the move's
  # function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.pbFromPBMove(battle,move)
    move = PBMove.new(0) if !move
    moveFunction = pbGetMoveData(move.id,MOVE_FUNCTION_CODE) || "000"
    className = sprintf("PokeBattle_Move_%s",moveFunction)
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle,move)
    end
    return PokeBattle_UnimplementedMove.new(battle,move)
  end

  #=============================================================================
  # About the move
  #=============================================================================
  def pbTarget(_user); return @target; end

  def totalpp
    return @totalpp if @totalpp && @totalpp>0   # Usually undefined
    return @realMove.totalpp if @realMove
    return 0
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def physicalMove?(thisType=nil)
    return (@category==0) if MOVE_CATEGORY_PER_MOVE
    thisType ||= @calcType if @calcType>=0
    thisType = @type if !thisType
    return !PBTypes.isSpecialType?(thisType)
  end

  # NOTE: This method is only ever called while using a move (and also by the
  #       AI), so using @calcType here is acceptable.
  def specialMove?(thisType=nil)
    return (@category==1) if MOVE_CATEGORY_PER_MOVE
    thisType ||= @calcType if @calcType>=0
    thisType = @type if !thisType
    return PBTypes.isSpecialType?(thisType)
  end

  def damagingMove?; return @category!=2; end
  def statusMove?;   return @category==2; end

  def usableWhenAsleep?;       return false; end
  def unusableInGravity?;      return false; end
  def healingMove?;            return false; end
  def recoilMove?;             return false; end
  def flinchingMove?;          return false; end
  def callsAnotherMove?;       return false; end
  # Whether the move can/will hit more than once in the same turn (including
  # Beat Up which may instead hit just once). Not the same as pbNumHits>1.
  def multiHitMove?;           return false; end
  def chargingTurnMove?;       return false; end
  def successCheckPerHit?;     return false; end
  def hitsFlyingTargets?;      return false; end
  def hitsDiggingTargets?;     return false; end
  def hitsDivingTargets?;      return false; end
  def ignoresReflect?;         return false; end   # For Brick Break
  def cannotRedirect?;         return false; end   # For Future Sight/Doom Desire
  def worksWithNoTargets?;     return false; end   # For Explosion
  def damageReducedByBurn?;    return true;  end   # For Facade
  def triggersHyperMode?;      return false; end

  def contactMove?;       return @flags[/a/]; end
  def canProtectAgainst?; return @flags[/b/]; end
  def canMagicCoat?;      return @flags[/c/]; end
  def canSnatch?;         return @flags[/d/]; end
  def canMirrorMove?;     return @flags[/e/]; end
  def canKingsRock?;      return @flags[/f/]; end
  def thawsUser?;         return @flags[/g/]; end
  def highCriticalRate?;  return @flags[/h/]; end
  def bitingMove?;        return @flags[/i/]; end
  def punchingMove?;      return @flags[/j/]; end
  def soundMove?;         return @flags[/k/]; end
  def powderMove?;        return @flags[/l/]; end
  def pulseMove?;         return @flags[/m/]; end
  def bombMove?;          return @flags[/n/]; end
  def danceMove?;         return @flags[/o/]; end

  # Causes perfect accuracy (param=1) and double damage (param=2).
  def tramplesMinimize?(_param=1); return false; end
  def nonLethal?(_user,_target); return false; end   # For False Swipe

  def ignoresSubstitute?(user)# user is the Pokémon using this move
    if NEWEST_BATTLE_MECHANICS
      return true if soundMove?
      return true if user && user.hasActiveAbility?(:INFILTRATOR)
    end
    return false
  end

  def pbIsPhysical?(type)
    if USEMOVECATEGORY
      return @category==0
    else
      return !PBTypes.isSpecialType?(type)
    end
  end

  def pbIsSpecial?(type)
    if USEMOVECATEGORY
      return @category==1
    else
      return PBTypes.isSpecialType?(type)
    end
  end
end

class PokeBattle_ZMoves
  attr_accessor(:id)
  attr_reader(:battle)
  attr_reader(:name)
  attr_reader(:function)
  attr_accessor(:baseDamage)
  attr_reader(:type)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_reader(:flags)
  attr_reader(:category)  
  attr_reader(:thismove)
  attr_reader(:oldmove)
  attr_reader(:status)
  attr_reader(:oldname)
################################################################################
# Creating a z move
################################################################################
  def initialize(battle,battler,move,crystal,simplechoice=false)
    @status     = !(move.pbIsPhysical?(move.type) || move.pbIsSpecial?(move.type))
    @oldmove    = move
    @oldname    = move.name
    @id         = pbZMoveId(move,crystal)
    @battle     = battle
    @name       = pbZMoveName(move,crystal)
    # Get data on the move
    oldmovedata = PBMoveData.new(move.id)
    @function   = pbZMoveFunction(move,crystal)
    @baseDamage = pbZMoveBaseDamage(move,crystal)
    @type       = move.type
    @accuracy   = pbZMoveAccuracy(move,crystal)
    @addlEffect = 0 #pbZMoveAddlEffectChance(move,crystal)
    @target     = move.target
    #@priority  = movedata.priority
    @flags      = pbZMoveFlags(move,crystal)
    @category   = oldmovedata.category
    @thismove   = self #move
    battler.pbBeginTurn(self)
    if !@status
      @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",battler.pbThis))
      @battle.pbDisplayBrief(_INTL("{1}!",@name))
    end
    zchoice = @battle.choices[battler.index] #[0,0,move,move.target]
    if simplechoice!=false
      zchoice=simplechoice
    end
    ztargets = []
    user = battler.pbFindUser(zchoice,ztargets) #Problem Child
    user = battler.pbChangeUser(zchoice,ztargets,user) #Problem Child
#   ztargets = battler.pbFindTargets(zchoice,@thismove,user)
    if ztargets.length==0
      if @thismove.target==PBTargets::NearOther ||
         @thismove.target==PBTargets::RandomNearFoe ||
         @thismove.target==PBTargets::AllNearFoes ||
         @thismove.target==PBTargets::AllNearOthers ||
         @thismove.target==PBTargets::NearAlly ||
         @thismove.target==PBTargets::UserOrNearAlly ||
         @thismove.target==PBTargets::NearFoe 
       #@battle.pbDisplay(_INTL("Target was indeed found..."))
      else
        #selftarget status moves here
        pbZStatus(@id,battler)     
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      end
    else
      if @status
        #targeted status Z's here
        pbZStatus(@id,battler)
        zchoice[2].name = @name
        battler.pbUseMove(zchoice)
        @oldmove.name = @oldname
      else
        turneffects=[]
        turneffects[PBEffects::SpecialUsage]=false
        turneffects[PBEffects::PassedTrying]=false
        turneffects[PBEffects::TotalDamage]=0  
        battler.pbProcessMoveAgainstTarget(@thismove,user,ztargets[0],1,turneffects,true,nil,true)  
        battler.pbReducePPOther(@oldmove)
      end
    end
  end
  
  def pbZMoveId(oldmove,crystal)
    if @status
      return oldmove.id
    else
      case crystal
      when getID(PBItems,:NORMALIUMZ2)
        return "Z001"
      when getID(PBItems,:FIGHTINIUMZ2)
        return "Z002"
      when getID(PBItems,:FLYINIUMZ2)
        return "Z003"      
      when getID(PBItems,:POISONIUMZ2)
        return "Z004"   
      when getID(PBItems,:GROUNDIUMZ2)
        return "Z005"        
      when getID(PBItems,:ROCKIUMZ2)
        return "Z006"    
      when getID(PBItems,:BUGINIUMZ2)
        return "Z007"      
      when getID(PBItems,:GHOSTIUMZ2)
        return "Z008"      
      when getID(PBItems,:STEELIUMZ2)
        return "Z009"
      when getID(PBItems,:FIRIUMZ2)
        return "Z010"     
      when getID(PBItems,:WATERIUMZ2)
        return "Z011"        
      when getID(PBItems,:GRASSIUMZ2)
        return "Z012"   
      when getID(PBItems,:ELECTRIUMZ2)
        return "Z013"   
      when getID(PBItems,:PSYCHIUMZ2)
        return "Z014"
      when getID(PBItems,:ICIUMZ2)
        return "Z015"         
      when getID(PBItems,:DRAGONIUMZ2)
        return "Z016"       
      when getID(PBItems,:DARKINIUMZ2)
        return "Z017"  
      when getID(PBItems,:FAIRIUMZ2)
        return "Z018"                
      when getID(PBItems,:ALORAICHIUMZ2)
        return "Z019"   
      when getID(PBItems,:DECIDIUMZ2)
        return "Z020" 
      when getID(PBItems,:INCINIUMZ2)
        return "Z021"        
      when getID(PBItems,:PRIMARIUMZ2)
        return "Z022" 
      when getID(PBItems,:EEVIUMZ2)
        return "Z023"        
      when getID(PBItems,:PIKANIUMZ2)
        return "Z024"  
      when getID(PBItems,:SNORLIUMZ2)
        return "Z025"     
      when getID(PBItems,:MEWNIUMZ2)
        return "Z026"
      when getID(PBItems,:TAPUNIUMZ2)
        return "Z027"
      when getID(PBItems,:MARSHADIUMZ2)
        return "Z028"
      when getID(PBItems,:PIKASHUNIUMZ2)
        return "Z029"        
      end
    end
  end  
  
  def pbZMoveName(oldmove,crystal)
    if @status
      return "Z-" + oldmove.name
    else
      case crystal
      when getID(PBItems,:NORMALIUMZ2)
        return "Breakneck Blitz"
      when getID(PBItems,:FIGHTINIUMZ2)
        return "All-Out Pummeling"
      when getID(PBItems,:FLYINIUMZ2)
        return "Supersonic Skystrike"      
      when getID(PBItems,:POISONIUMZ2)
        return "Acid Downpour"   
      when getID(PBItems,:GROUNDIUMZ2)
        return "Tectonic Rage"        
      when getID(PBItems,:ROCKIUMZ2)
        return "Continental Crush"    
      when getID(PBItems,:BUGINIUMZ2)
        return "Savage Spin-Out"      
      when getID(PBItems,:GHOSTIUMZ2)
        return "Never-Ending Nightmare"      
      when getID(PBItems,:STEELIUMZ2)
        return "Corkscrew Crash"
      when getID(PBItems,:FIRIUMZ2)
        return "Inferno Overdrive"     
      when getID(PBItems,:WATERIUMZ2)
        return "Hydro Vortex"        
      when getID(PBItems,:GRASSIUMZ2)
        return "Bloom Doom"   
      when getID(PBItems,:ELECTRIUMZ2)
        return "Gigavolt Havoc"   
      when getID(PBItems,:PSYCHIUMZ2)
        return "Shattered Psyche"
      when getID(PBItems,:ICIUMZ2)
        return "Subzero Slammer"         
      when getID(PBItems,:DRAGONIUMZ2)
        return "Devastating Drake"       
      when getID(PBItems,:DARKINIUMZ2)
        return "Black Hole Eclipse"  
      when getID(PBItems,:FAIRIUMZ2)
        return "Twinkle Tackle"                
      when getID(PBItems,:ALORAICHIUMZ2)
        return "Stoked Sparksurfer"   
      when getID(PBItems,:DECIDIUMZ2)
        return "Sinister Arrow Raid" 
      when getID(PBItems,:INCINIUMZ2)
        return "Malicious Moonsault"        
      when getID(PBItems,:PRIMARIUMZ2)
        return "Oceanic Operetta" 
      when getID(PBItems,:EEVIUMZ2)
        return "Extreme Evoboost"        
      when getID(PBItems,:PIKANIUMZ2)
        return "Catastropika"  
      when getID(PBItems,:SNORLIUMZ2)
        return "Pulverizing Pancake"     
      when getID(PBItems,:MEWNIUMZ2)
        return "Genesis Supernova"
      when getID(PBItems,:TAPUNIUMZ2)
        return "Guardian of Alola"
      when getID(PBItems,:MARSHADIUMZ2)
        return "Soul-Stealing 7-Star Strike"
      when getID(PBItems,:PIKASHUNIUMZ2)
        return "10,000,000 Volt Tunderbolt"        
      end
    end
  end
  
  def pbZMoveFunction(oldmove,crystal)
    if @status
      return oldmove.function
    else
      "Z"
    end 
  end
  
  def pbZMoveBaseDamage(oldmove,crystal)
    if @status
      return 0
    else
      case crystal
      when getID(PBItems,:ALORAICHIUMZ2)
        return 175
      when getID(PBItems,:DECIDIUMZ2)
        return 180
      when getID(PBItems,:INCINIUMZ2)
        return 180
      when getID(PBItems,:PRIMARIUMZ2)
        return 195
      when getID(PBItems,:EEVIUMZ2)
        return 0
      when getID(PBItems,:PIKANIUMZ2)
        return 210  
      when getID(PBItems,:SNORLIUMZ2)
        return 210
      when getID(PBItems,:MEWNIUMZ2)
        return 185
      when getID(PBItems,:TAPUNIUMZ2)
        return 0
      when getID(PBItems,:MARSHADIUMZ2)
        return 195
      when getID(PBItems,:PIKASHUNIUMZ2)
        return 195        
      else
        case @oldmove.id
        when getID(PBMoves,:MEGADRAIN)
          return 120
        when getID(PBMoves,:WEATHERBALL)  
          return 160
        when getID(PBMoves,:HEX)
          return 160
        when getID(PBMoves,:GEARGRIND)  
          return 180
        when getID(PBMoves,:VCREATE)  
          return 220
        when getID(PBMoves,:FLYINGPRESS)
          return 170
        when getID(PBMoves,:COREENFORCER)
          return 140
        else
          check=@oldmove.baseDamage
          if check<56
            return 100
          elsif check<66
            return 120
          elsif check<76
            return 140
          elsif check<86
            return 160
          elsif check<96
            return 175
          elsif check<101
            return 180
          elsif check<111
            return 185
          elsif check<126
            return 190
          elsif check<131
            return 195
          elsif check>139
            return 200
          end      
        end    
      end  
    end
  end
  
  def pbZMoveAccuracy(oldmove,crystal)
    if @status
      return oldmove.accuracy
    else
      return 0 #Z Moves can't miss
    end  
  end
  
  
  def pbZMoveFlags(oldmove,crystal)
    if @status
      return oldmove.flags
    else
      case crystal
      when getID(PBItems,:NORMALIUMZ2)
        return ""
      when getID(PBItems,:FIGHTINIUMZ2)
        return ""
      when getID(PBItems,:FLYINIUMZ2)
        return ""
      when getID(PBItems,:POISONIUMZ2)
        return ""
      when getID(PBItems,:GROUNDIUMZ2)
        return ""
      when getID(PBItems,:ROCKIUMZ2)
        return ""
      when getID(PBItems,:BUGINIUMZ2)
        return ""
      when getID(PBItems,:GHOSTIUMZ2)
        return ""
      when getID(PBItems,:STEELIUMZ2)
        return ""
      when getID(PBItems,:FIRIUMZ2)
        return ""
      when getID(PBItems,:WATERIUMZ2)
        return ""
      when getID(PBItems,:GRASSIUMZ2)
        return ""
      when getID(PBItems,:ELECTRIUMZ2)
        return ""
      when getID(PBItems,:PSYCHIUMZ2)
        return ""
      when getID(PBItems,:ICIUMZ2)
        return ""
      when getID(PBItems,:DRAGONIUMZ2)
        return ""
      when getID(PBItems,:DARKINIUMZ2)
        return ""
      when getID(PBItems,:FAIRIUMZ2)
        return ""
      when getID(PBItems,:ALORAICHIUMZ2)
        return "f"
      when getID(PBItems,:DECIDIUMZ2)
        return "f"
      when getID(PBItems,:INCINIUMZ2)
        return "af"
      when getID(PBItems,:PRIMARIUMZ2)
        return "f"
      when getID(PBItems,:EEVIUMZ2)
        return ""
      when getID(PBItems,:PIKANIUMZ2)
        return "af" 
      when getID(PBItems,:SNORLIUMZ2)
        return "af"
      when getID(PBItems,:MEWNIUMZ2)
        return ""
      when getID(PBItems,:TAPUNIUMZ2)
        return "f"
      when getID(PBItems,:MARSHADIUMZ2)
        return "a"
      when getID(PBItems,:PIKASHUNIUMZ2)
        return ""        
      end  
    end
  end
  
################################################################################
# PokeBattle_Move Features needed for move use
################################################################################  
  def pbIsSpecial?(type)  
    @oldmove.pbIsSpecial?(type)
  end
  
  def pbIsPhysical?(type)  
    @oldmove.pbIsPhysical?(type)
  end  

  def pbEffectAfterHit(attacker,opponent,turneffects)
  end  
  
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if !opponent
    if @id == "Z027" # Guardian of Alola
      return pbEffectFixedDamage((opponent.hp*3/4).floor,attacker,opponent,hitnum,alltargets,showanimation)
    elsif @id == "Z023" # Extreme Evoboost  
      if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
         !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
        return -1
      end
      pbShowAnimation(@name,attacker,nil,hitnum,alltargets,showanimation)
      showanim=true
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,false,true,nil,showanim)
          showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,2,false,true,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,2,false,true,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,2,false,true,nil,showanim)
        showanim=false
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,true,nil,showanim)
        showanim=false
      end  
      attacker.lastRoundMoved=@battle.turncount
      return 0     
    end
    damage=pbCalcDamage(attacker,opponent) 
    if opponent.damagestate.typemod!=0 
      pbShowAnimation(@name,attacker,opponent,hitnum,alltargets,showanimation)  
    end
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    attacker.lastRoundMoved=@battle.turncount
    return damage   
  end  
  
  def pbEffectFixedDamage(damage,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    typemod=pbTypeModMessages(type,attacker,opponent)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    if typemod!=0
      opponent.damagestate.calcdamage=damage
      opponent.damagestate.typemod=4
      pbShowAnimation(@name,attacker,opponent,hitnum,alltargets,showanimation)
      damage=1 if damage<1 # HP reduced can't be less than 1
      damage=pbModifyDamage(damage,attacker,opponent)
      damage=pbReduceHPDamage(damage,attacker,opponent)
      pbEffectMessages(attacker,opponent)
      pbOnDamageLost(damage,attacker,opponent)
      return damage
    end
    return 0
  end  

  def pbOnDamageLost(damage,attacker,opponent)
    #Used by Counter/Mirror Coat/Revenge/Focus Punch/Bide
    type=@type  
    if opponent.effects[PBEffects::Bide]>0
      opponent.effects[PBEffects::BideDamage]+=damage
      opponent.effects[PBEffects::BideTarget]=attacker.index
    end        
    if @oldmove.pbIsPhysical?(type)
      opponent.effects[PBEffects::Counter]=damage
      opponent.effects[PBEffects::CounterTarget]=attacker.index
    end
    if @oldmove.pbIsSpecial?(type)
      opponent.effects[PBEffects::MirrorCoat]=damage
      opponent.effects[PBEffects::MirrorCoatTarget]=attacker.index
    end
    opponent.lastHPLost=damage # for Revenge/Focus Punch/Metal Burst
    opponent.tookDamage=true if damage>0 # for Assurance
    opponent.lastAttacker.push(attacker.index) # for Revenge/Metal Burst
  end 
  
  def pbEffectMessages(attacker,opponent,ignoretype=false)
    if opponent.damagestate.critical
      @battle.pbDisplay(_INTL("A critical hit!"))
    end
    if opponent.damagestate.typemod>8
      @battle.pbDisplay(_INTL("It's super effective!"))
    elsif opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<8
      @battle.pbDisplay(_INTL("It's not very effective..."))
    end
    if opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
    elsif opponent.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
      opponent.damagestate.sturdy=false
    elsif opponent.damagestate.focussash
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
    elsif opponent.damagestate.focusband
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
    end
  end  
  
  def pbReduceHPDamage(damage,attacker,opponent)
    endure=false
    if opponent.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(attacker) &&
       (!attacker || attacker.index!=opponent.index)
      PBDebug.log("[Lingering effect triggered] #{opponent.pbThis}'s Substitute took the damage")
      damage=opponent.effects[PBEffects::Substitute] if damage>opponent.effects[PBEffects::Substitute]
      opponent.effects[PBEffects::Substitute]-=damage
      opponent.damagestate.substitute=true
      @battle.scene.pbDamageAnimation(opponent,0)
      @battle.pbDisplayPaused(_INTL("The substitute took damage for {1}!",opponent.name))
      if opponent.effects[PBEffects::Substitute]<=0
        opponent.effects[PBEffects::Substitute]=0
        @battle.pbDisplayPaused(_INTL("{1}'s substitute faded!",opponent.name))
        PBDebug.log("[End of effect] #{opponent.pbThis}'s Substitute faded")
      end
      opponent.damagestate.hplost=damage
      damage=0
    else
      opponent.damagestate.substitute=false
      if damage>=opponent.hp
        damage=opponent.hp
        if @function==0xE9 # False Swipe
          damage=damage-1
        elsif opponent.effects[PBEffects::Endure]
          damage=damage-1
          opponent.damagestate.endured=true
          PBDebug.log("[Lingering effect triggered] #{opponent.pbThis}'s Endure")
        elsif damage==opponent.totalhp
          if opponent.hasWorkingAbility(:STURDY) && !attacker.hasMoldBreaker
            opponent.damagestate.sturdy=true
            damage=damage-1
            PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Sturdy")
          elsif opponent.hasWorkingItem(:FOCUSSASH) && opponent.hp==opponent.totalhp
            opponent.damagestate.focussash=true
            damage=damage-1
            PBDebug.log("[Item triggered] #{opponent.pbThis}'s Focus Sash")
          elsif opponent.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0
            opponent.damagestate.focusband=true
            damage=damage-1
            PBDebug.log("[Item triggered] #{opponent.pbThis}'s Focus Band")
          end
        end
        damage=0 if damage<0
      end
      oldhp=opponent.hp
      opponent.hp-=damage
      effectiveness=0
      if opponent.damagestate.typemod<8
        effectiveness=1   # "Not very effective"
      elsif opponent.damagestate.typemod>8
        effectiveness=2   # "Super effective"
      end
      if opponent.damagestate.typemod!=0
        @battle.scene.pbDamageAnimation(opponent,effectiveness)
      end
      @battle.scene.pbHPChanged(opponent,oldhp)
      opponent.damagestate.hplost=damage
    end
    return damage
  end 
  
  def pbType(type,attacker,opponent)
    return @type
  end  

  def isContactMove?    
    return @flags.include?("a")
  end
  
  def pbCanUseWhileAsleep?
    return false
  end  
  
  def pbTypeModifier(type,attacker,opponent)
    return 8 if type<0
    return 8 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(:FLYING) &&
                opponent.hasWorkingItem(:IRONBALL) && !NEWEST_BATTLE_MECHANICS
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    otype3=opponent.effects[PBEffects::Type3] || -1
    # Roost
    if isConst?(otype1,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      if isConst?(otype2,PBTypes,:FLYING) && isConst?(otype3,PBTypes,:FLYING)
        otype1=getConst(PBTypes,:NORMAL) || 0
      else
        otype1=otype2
      end
    end
    if isConst?(otype2,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      otype2=otype1
    end
    # Get effectivenesses
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    mod3=(otype3<0 || otype1==otype3 || otype2==otype3) ? 2 : PBTypes.getEffectiveness(atype,otype3)
    if opponent.hasWorkingItem(:RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
      mod3=2 if mod3==0
    end
    # Foresight
    if attacker.hasWorkingAbility(:SCRAPPY) || opponent.effects[PBEffects::Foresight]
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) && PBTypes.isIneffective?(atype,otype1)
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) && PBTypes.isIneffective?(atype,otype2)
      mod3=2 if isConst?(otype3,PBTypes,:GHOST) && PBTypes.isIneffective?(atype,otype3)
    end
    # Miracle Eye
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && PBTypes.isIneffective?(atype,otype1)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && PBTypes.isIneffective?(atype,otype2)
      mod3=2 if isConst?(otype3,PBTypes,:DARK) && PBTypes.isIneffective?(atype,otype3)
    end
    # Delta Stream's weather
    if @battle.pbWeather==PBWeather::STRONGWINDS
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && PBTypes.isSuperEffective?(atype,otype1)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && PBTypes.isSuperEffective?(atype,otype2)
      mod3=2 if isConst?(otype3,PBTypes,:FLYING) && PBTypes.isSuperEffective?(atype,otype3)
    end
    # Smack Down makes Ground moves work against fliers
    if (!opponent.isAirborne?(attacker.hasMoldBreaker) || @function==0x11C) && # Smack Down
       isConst?(atype,PBTypes,:GROUND)
      mod1=2 if isConst?(otype1,PBTypes,:FLYING)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING)
      mod3=2 if isConst?(otype3,PBTypes,:FLYING)
    end
    if @function==0x135 && !attacker.effects[PBEffects::Electrify] # Freeze-Dry
      mod1=4 if isConst?(otype1,PBTypes,:WATER)
      if isConst?(otype2,PBTypes,:WATER)
        mod2=(otype1==otype2) ? 2 : 4
      end
      if isConst?(otype3,PBTypes,:WATER)
        mod3=(otype1==otype3 || otype2==otype3) ? 2 : 4
      end
    end
    return mod1*mod2*mod3
  end

  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2,2,3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3,2,2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # -1 is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
      atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
      defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = [1.0, 1.0, 1.0, 1.0]
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[BASE_DMG_MULT]).round, 1].max
    atk     = [(atk     * multipliers[ATK_MULT]).round, 1].max
    defense = [(defense * multipliers[DEF_MULT]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[FINAL_DMG_MULT]).round, 1].max
    target.damageState.calcDamage = damage
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if !opponent.effects[PBEffects::ProtectNegation] && (opponent.pbOwnSide.effects[PBEffects::MatBlock] || 
      opponent.effects[PBEffects::Protect] || opponent.effects[PBEffects::SpikyShield])
      @battle.pbDisplay(_INTL("{1} couldn't fully protected itself!",opponent.pbThis))
      return (damagemult/4).floor
    else      
      return damagemult
    end
  end
  
  def pbIsCritical?(attacker,opponent)
    if !attacker.hasMoldBreaker
      if opponent.hasWorkingAbility(:BATTLEARMOR) ||
         opponent.hasWorkingAbility(:SHELLARMOR)
        return false
      end
    end
    return false if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    c=0
    ratios=(NEWEST_BATTLE_MECHANICS) ? [16,8,2,1,1] : [16,8,4,3,2]
    c+=attacker.effects[PBEffects::FocusEnergy]
    if (attacker.inHyperMode? rescue false) && isConst?(self.type,PBTypes,:SHADOW)
      c+=1
    end
    c+=1 if attacker.hasWorkingAbility(:SUPERLUCK)
    c=4 if c>4
    return @battle.pbRandom(ratios[c])==0
  end  
  
  def pbTypeModMessages(type,attacker,opponent)
    return 8 if type<0
    typemod=pbTypeModifier(type,attacker,opponent)
    if typemod==0
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
    else
      return 0 if pbTypeImmunityByAbility(type,attacker,opponent)
    end
    return typemod
  end 
  
  def pbTargetsMultiple?(attacker)
    return false
  end  
  
  def pbTypeImmunityByAbility(type,attacker,opponent)
    return false if attacker.index==opponent.index
    return false if attacker.hasMoldBreaker
    if opponent.hasWorkingAbility(:SAPSIPPER) && isConst?(type,PBTypes,:GRASS)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Sap Sipper (made #{@name} ineffective)")
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,opponent)
        opponent.pbIncreaseStatWithCause(PBStats::ATTACK,1,opponent,PBAbilities.getName(opponent.ability))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return true
    end
    if (opponent.hasWorkingAbility(:STORMDRAIN) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:LIGHTNINGROD) && isConst?(type,PBTypes,:ELECTRIC))
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s #{PBAbilities.getName(opponent.ability)} (made #{@name} ineffective)")
      if opponent.pbCanIncreaseStatStage?(PBStats::SPATK,opponent)
        opponent.pbIncreaseStatWithCause(PBStats::SPATK,1,opponent,PBAbilities.getName(opponent.ability))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return true
    end
    if opponent.hasWorkingAbility(:MOTORDRIVE) && isConst?(type,PBTypes,:ELECTRIC)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Motor Drive (made #{@name} ineffective)")
      if opponent.pbCanIncreaseStatStage?(PBStats::SPEED,opponent)
        opponent.pbIncreaseStatWithCause(PBStats::SPEED,1,opponent,PBAbilities.getName(opponent.ability))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return true
    end
    if (opponent.hasWorkingAbility(:DRYSKIN) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:VOLTABSORB) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (opponent.hasWorkingAbility(:WATERABSORB) && isConst?(type,PBTypes,:WATER))
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s #{PBAbilities.getName(opponent.ability)} (made #{@name} ineffective)")
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
             opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
             opponent.pbThis,PBAbilities.getName(opponent.ability),@name))
        end
        return true
      end
    end
    if opponent.hasWorkingAbility(:FLASHFIRE) && isConst?(type,PBTypes,:FIRE)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Flash Fire (made #{@name} ineffective)")
      if !opponent.effects[PBEffects::FlashFire]
        opponent.effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return true
    end
    if opponent.hasWorkingAbility(:TELEPATHY) && pbIsDamaging? &&
       !opponent.pbIsOpposing?(attacker.index)
      PBDebug.log("[Ability triggered] #{opponent.pbThis}'s Telepathy (made #{@name} ineffective)")
      @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",opponent.pbThis))
      return true
    end
    return false
  end  
  
################################################################################
# PokeBattle_ActualScene Feature for playing animation (based on common anims)
################################################################################    
  
  def pbShowAnimation(movename,user,target,hitnum=0,alltargets=nil,showanimation=true)
    animname=movename.delete(" ").delete("-").upcase
    animations=load_data("Data/PkmnAnimations.rxdata")
    for i in 0...animations.length
      if @battle.pbBelongsToPlayer?(user.index)
        if animations[i] && animations[i].name=="ZMove:"+animname && showanimation
          @battle.scene.pbAnimationCore(animations[i],user,(target!=nil) ? target : user)
          return
        end
      else
        if animations[i] && animations[i].name=="OppZMove:"+animname && showanimation
          @battle.scene.pbAnimationCore(animations[i],target,(user!=nil) ? user : target)
          return
        end   
      end 
    end
  end  
  
################################################################################
# Z Status Effect check
################################################################################  
  
  def pbZStatus(move,attacker)
    atk1 =   [getID(PBMoves,:BULKUP),getID(PBMoves,:HONECLAWS),getID(PBMoves,:HOWL),getID(PBMoves,:LASERFOCUS),getID(PBMoves,:LEER),getID(PBMoves,:MEDITATE),getID(PBMoves,:ODORSLEUTH),getID(PBMoves,:POWERTRICK),getID(PBMoves,:ROTOTILLER),getID(PBMoves,:SCREECH),getID(PBMoves,:SHARPEN),getID(PBMoves,:TAILWHIP),getID(PBMoves,:TAUNT),getID(PBMoves,:TOPSYTURVY),getID(PBMoves,:WILLOWISP),getID(PBMoves,:WORKUP)]
    atk2 =   [getID(PBMoves,:MIRRORMOVE)]
    atk3 =   [getID(PBMoves,:SPLASH)]
    def1 =   [getID(PBMoves,:AQUARING),getID(PBMoves,:BABYDOLLEYES),getID(PBMoves,:BANEFULBUNKER),getID(PBMoves,:BLOCK),getID(PBMoves,:CHARM),getID(PBMoves,:DEFENDORDER),getID(PBMoves,:FAIRYLOCK),getID(PBMoves,:FEATHERDANCE),getID(PBMoves,:FLOWERSHIELD),getID(PBMoves,:GRASSYTERRAIN),getID(PBMoves,:GROWL),getID(PBMoves,:HARDEN),getID(PBMoves,:MATBLOCK),getID(PBMoves,:NOBLEROAR),getID(PBMoves,:PAINSPLIT),getID(PBMoves,:PLAYNICE),getID(PBMoves,:POISONGAS),getID(PBMoves,:POISONPOWDER),getID(PBMoves,:QUICKGUARD),getID(PBMoves,:REFLECT),getID(PBMoves,:ROAR),getID(PBMoves,:SPIDERWEB),getID(PBMoves,:SPIKES),getID(PBMoves,:SPIKYSHIELD),getID(PBMoves,:STEALTHROCK),getID(PBMoves,:STRENGTHSAP),getID(PBMoves,:TEARFULLOOK),getID(PBMoves,:TICKLE),getID(PBMoves,:TORMENT),getID(PBMoves,:TOXIC),getID(PBMoves,:TOXICSPIKES),getID(PBMoves,:VENOMDRENCH),getID(PBMoves,:WIDEGUARD),getID(PBMoves,:WITHDRAW)]
    def2 =   [getID(PBMoves,:PHOTONCANNON)]
    def3 =   []
    spatk1 = [getID(PBMoves,:CONFUSERAY),getID(PBMoves,:ELECTRIFY),getID(PBMoves,:EMBARGO),getID(PBMoves,:FAKETEARS),getID(PBMoves,:GEARUP),getID(PBMoves,:GRAVITY),getID(PBMoves,:GROWTH),getID(PBMoves,:INSTRUCT),getID(PBMoves,:IONDELUGE),getID(PBMoves,:METALSOUND),getID(PBMoves,:MINDREADER),getID(PBMoves,:MIRACLEEYE),getID(PBMoves,:NIGHTMARE),getID(PBMoves,:PSYCHICTERRAIN),getID(PBMoves,:REFLECTTYPE),getID(PBMoves,:SIMPLEBEAM),getID(PBMoves,:SOAK),getID(PBMoves,:SWEETKISS),getID(PBMoves,:TEETERDANCE),getID(PBMoves,:TELEKINESIS)]
    spatk2 = [getID(PBMoves,:MENTALBURST),getID(PBMoves,:HEALBLOCK),getID(PBMoves,:PSYCHOSHIFT)]
    spatk3 = []
    spdef1 = [getID(PBMoves,:CHARGE),getID(PBMoves,:CONFIDE),getID(PBMoves,:COSMICPOWER),getID(PBMoves,:CRAFTYSHIELD),getID(PBMoves,:EERIEIMPULSE),getID(PBMoves,:ENTRAINMENT),getID(PBMoves,:FLATTER),getID(PBMoves,:GLARE),getID(PBMoves,:INGRAIN),getID(PBMoves,:LIGHTSCREEN),getID(PBMoves,:MAGICROOM),getID(PBMoves,:MAGNETICFLUX),getID(PBMoves,:MEANLOOK),getID(PBMoves,:MISTYTERRAIN),getID(PBMoves,:MUDSPORT),getID(PBMoves,:SPOTLIGHT),getID(PBMoves,:STUNSPORE),getID(PBMoves,:THUNDERWAVE),getID(PBMoves,:WATERSPORT),getID(PBMoves,:WHIRLWIND),getID(PBMoves,:WISH),getID(PBMoves,:WONDERROOM)]
    spdef2 = [getID(PBMoves,:AROMATICMIST),getID(PBMoves,:CAPTIVATE),getID(PBMoves,:IMPRISON),getID(PBMoves,:MAGICCOAT),getID(PBMoves,:POWDER)]
    spdef3 = []
    speed1 = [getID(PBMoves,:AFTERYOU),getID(PBMoves,:AURORAVEIL),getID(PBMoves,:ELECTRICTERRAIN),getID(PBMoves,:ENCORE),getID(PBMoves,:GASTROACID),getID(PBMoves,:GRASSWHISTLE),getID(PBMoves,:GUARDSPLIT),getID(PBMoves,:GUARDSWAP),getID(PBMoves,:HAIL),getID(PBMoves,:HYPNOSIS),getID(PBMoves,:LOCKON),getID(PBMoves,:LOVELYKISS),getID(PBMoves,:POWERSPLIT),getID(PBMoves,:POWERSWAP),getID(PBMoves,:QUASH),getID(PBMoves,:RAINDANCE),getID(PBMoves,:ROLEPLAY),getID(PBMoves,:SAFEGUARD),getID(PBMoves,:SANDSTORM),getID(PBMoves,:SCARYFACE),getID(PBMoves,:SING),getID(PBMoves,:SKILLSWAP),getID(PBMoves,:SLEEPPOWDER),getID(PBMoves,:SPEEDSWAP),getID(PBMoves,:STICKYWEB),getID(PBMoves,:STRINGSHOT),getID(PBMoves,:SUNNYDAY),getID(PBMoves,:SUPERSONIC),getID(PBMoves,:TOXICTHREAD),getID(PBMoves,:WORRYSEED),getID(PBMoves,:YAWN)]
    speed2 = [getID(PBMoves,:ALLYSWITCH),getID(PBMoves,:BESTOW),getID(PBMoves,:MEFIRST),getID(PBMoves,:RECYCLE),getID(PBMoves,:SNATCH),getID(PBMoves,:SWITCHEROO),getID(PBMoves,:TRICK)]
    speed3 = []
    acc1   = [getID(PBMoves,:COPYCAT),getID(PBMoves,:DEFENSECURL),getID(PBMoves,:DEFOG),getID(PBMoves,:FOCUSENERGY),getID(PBMoves,:MIMIC),getID(PBMoves,:SWEETSCENT),getID(PBMoves,:TRICKROOM)]
    acc2   = []
    acc3   = []
    eva1   = [getID(PBMoves,:CAMOFLAUGE),getID(PBMoves,:DETECT),getID(PBMoves,:FLASH),getID(PBMoves,:KINESIS),getID(PBMoves,:LUCKYCHANT),getID(PBMoves,:MAGNETRISE),getID(PBMoves,:SANDATTACK),getID(PBMoves,:SMOKESCREEN)]
    eva2   = []
    eva3   = []
    stat1  = [getID(PBMoves,:CELEBRATE),getID(PBMoves,:CONVERSION),getID(PBMoves,:FORESTSCURSE),getID(PBMoves,:GEOMANCY),getID(PBMoves,:HAPPYHOUR),getID(PBMoves,:HOLDHANDS),getID(PBMoves,:PURIFY),getID(PBMoves,:SKETCH),getID(PBMoves,:TRICKORTREAT)]
    stat2  = []
    stat3  = []
    reset  = [getID (PBMoves,:ANCHORWINGS),getID(PBMoves,:ACIDARMOR),getID(PBMoves,:AGILITY),getID(PBMoves,:AMNESIA),getID(PBMoves,:ATTRACT),getID(PBMoves,:AUTOTOMIZE),getID(PBMoves,:BARRIER),getID(PBMoves,:BATONPASS),getID(PBMoves,:CALMMIND),getID(PBMoves,:COIL),getID(PBMoves,:COTTONGUARD),getID(PBMoves,:COTTONSPORE),getID(PBMoves,:DARKVOID),getID(PBMoves,:DISABLE),getID(PBMoves,:DOUBLETEAM),getID(PBMoves,:DRAGONDANCE),getID(PBMoves,:ENDURE),getID(PBMoves,:FLORALHEALING),getID(PBMoves,:FOLLOWME),getID(PBMoves,:HEALORDER),getID(PBMoves,:HEALPULSE),getID(PBMoves,:HELPINGHAND),getID(PBMoves,:IRONDEFENSE),getID(PBMoves,:KINGSSHIELD),getID(PBMoves,:LEECHSEED),getID(PBMoves,:MILKDRINK),getID(PBMoves,:MINIMIZE),getID(PBMoves,:MOONLIGHT),getID(PBMoves,:MORNINGSUN),getID(PBMoves,:NASTYPLOT),getID(PBMoves,:PERISHSONG),getID(PBMoves,:PROTECT),getID(PBMoves,:QUIVERDANCE),getID(PBMoves,:RAGEPOWDER),getID(PBMoves,:RECOVER),getID(PBMoves,:REST),getID(PBMoves,:ROCKPOLISH),getID(PBMoves,:ROOST),getID(PBMoves,:SHELLSMASH),getID(PBMoves,:SHIFTGEAR),getID(PBMoves,:SHOREUP),getID(PBMoves,:SHELLSMASH),getID(PBMoves,:SHIFTGEAR),getID(PBMoves,:SHOREUP),getID(PBMoves,:SLACKOFF),getID(PBMoves,:SOFTBOILED),getID(PBMoves,:SPORE),getID(PBMoves,:SUBSTITUTE),getID(PBMoves,:SWAGGER),getID(PBMoves,:SWALLOW),getID(PBMoves,:SWORDSDANCE),getID(PBMoves,:SYNTHESIS),getID(PBMoves,:TAILGLOW)]
    heal   = [getID(PBMoves,:AROMATHERAPY),getID(PBMoves,:BELLYDRUM),getID(PBMoves,:CONVERSION2),getID(PBMoves,:HAZE),getID(PBMoves,:HEALBELL),getID(PBMoves,:MIST),getID(PBMoves,:PSYCHUP),getID(PBMoves,:REFRESH),getID(PBMoves,:SPITE),getID(PBMoves,:STOCKPILE),getID(PBMoves,:TELEPORT),getID(PBMoves,:TRANSFORM)]
    heal2  = [getID(PBMoves,:MEMENTO),getID(PBMoves,:PARTINGSHOT)]
    centre = [getID(PBMoves,:DESTINYBOND),getID(PBMoves,:GRUDGE)]
    if atk1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its attack!",attacker.pbThis))
      end
    elsif atk2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its attack!",attacker.pbThis))
      end
    elsif atk3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its attack!",attacker.pbThis))
      end
    elsif def1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its defense!",attacker.pbThis))
      end
    elsif def2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its defense!",attacker.pbThis))
      end
    elsif def3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its defense!",attacker.pbThis))
      end
    elsif spatk1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its special attack!",attacker.pbThis))
      end
    elsif spatk2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its special attack!",attacker.pbThis))
      end
    elsif spatk3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its special attack!",attacker.pbThis))
      end
    elsif spdef1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its special defense!",attacker.pbThis))
      end
    elsif spdef2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its special defense!",attacker.pbThis))
      end
    elsif spdef3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its special defense!",attacker.pbThis))
      end
    elsif speed1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its speed!",attacker.pbThis))
      end
    elsif speed2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its speed!",attacker.pbThis))
      end
    elsif speed3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its speed!",attacker.pbThis))
      end
    elsif acc1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
        attacker.pbIncreaseStat(PBStats::ACCURACY,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its accuracy!",attacker.pbThis))
      end
    elsif acc2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
        attacker.pbIncreaseStat(PBStats::ACCURACY,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its accuracy!",attacker.pbThis))
      end
    elsif acc3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
        attacker.pbIncreaseStat(PBStats::ACCURACY,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its accuracy!",attacker.pbThis))
      end
    elsif eva1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,1,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its evasion!",attacker.pbThis))
      end
    elsif eva2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,2,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its evasion!",attacker.pbThis))
      end
    elsif eva3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
        attacker.pbIncreaseStat(PBStats::EVASION,3,false,nil,nil,false,false,false)      
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its evasion!",attacker.pbThis))
      end
    elsif stat1.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,1,false,nil,nil,false,false,false)              
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,1,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,1,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,1,false,nil,nil,false,false,false)              
      end  
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power boosted its stats!",attacker.pbThis))
    elsif stat2.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,2,false,nil,nil,false,false,false)              
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,2,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,2,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,2,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,2,false,nil,nil,false,false,false)              
      end  
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power sharply boosted its stats!",attacker.pbThis))
    elsif stat3.include?(move)
      if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
        attacker.pbIncreaseStat(PBStats::ATTACK,3,false,nil,nil,false,false,false)              
      end
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,3,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
        attacker.pbIncreaseStat(PBStats::SPATK,3,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
        attacker.pbIncreaseStat(PBStats::SPDEF,3,false,nil,nil,false,false,false)              
      end  
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,3,false,nil,nil,false,false,false)              
      end  
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power drastically boosted its stats!",attacker.pbThis))
    elsif reset.include?(move)
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if attacker.stages[i]<0
          attacker.stages[i]=0
        end
      end
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power returned its decreased stats to normal!",attacker.pbThis))
    elsif heal.include?(move)
      attacker.pbRecoverHP(attacker.totalhp,false)
      @battle.pbDisplayBrief(_INTL("{1}'s Z-Power restored its health!",attacker.pbThis))
    elsif heal2.include?(move)
      attacker.effects[PBEffects::ZHeal]=true
    elsif centre.include?(move)
      attacker.effects[PBEffects::FollowMe]=true
      if !attacker.pbPartner.isFainted?
        attacker.pbPartner.effects[PBEffects::FollowMe]=false
        attacker.pbPartner.effects[PBEffects::RagePowder]=false  
        @battle.pbDisplayBrief(_INTL("{1}'s Z-Power made it the centre of attention!",attacker.pbThis))
      end
    end
  end
end

class PokeBattle_Battle
  attr_reader   :scene            # Scene object for this battle
  attr_reader   :peer
  attr_reader   :field            # Effects common to the whole of a battle
  attr_reader   :sides            # Effects common to each side of a battle
  attr_reader   :positions        # Effects that apply to a battler position
  attr_reader   :battlers         # Currently active Pokémon
  attr_reader   :sideSizes        # Array of number of battlers per side
  attr_accessor :backdrop         # Filename fragment used for background graphics
  attr_accessor :backdropBase     # Filename fragment used for base graphics
  attr_accessor :time             # Time of day (0=day, 1=eve, 2=night)
  attr_accessor :environment      # Battle surroundings (for mechanics purposes)
  attr_reader   :turnCount
  attr_accessor :decision         # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_reader   :player           # Player trainer (or array of trainers)
  attr_reader   :opponent         # Opponent trainer (or array of trainers)
  attr_accessor :items            # Items held by opponents
  attr_accessor :endSpeeches
  attr_accessor :endSpeechesWin
  attr_accessor :party1starts     # Array of start indexes for each player-side trainer's party
  attr_accessor :party2starts     # Array of start indexes for each opponent-side trainer's party
  attr_accessor :internalBattle   # Internal battle flag
  attr_accessor :debug            # Debug flag
  attr_accessor :canRun           # True if player can run from battle
  attr_accessor :canLose          # True if player won't black out if they lose
  attr_accessor :switchStyle      # Switch/Set "battle style" option
  attr_accessor :showAnims        # "Battle Effects" option
  attr_accessor :controlPlayer    # Whether player's Pokémon are AI controlled
  attr_accessor :expGain          # Whether Pokémon can gain Exp/EVs
  attr_accessor :moneyGain        # Whether the player can gain/lose money
  attr_accessor :rules
  attr_accessor :choices          # Choices made by each Pokémon this round
  attr_accessor :megaEvolution    # Battle index of each trainer's Pokémon to Mega Evolve
  attr_accessor :zMove            # Battle index of each trainer's Pokémon to Use a zMove
  attr_reader   :initialItems
  attr_reader   :recycleItems
  attr_reader   :belch
  attr_reader   :battleBond
  attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
  attr_reader   :successStates    # Success states
  attr_accessor :lastMoveUsed     # Last move used
  attr_accessor :lastMoveUser     # Last move user
  attr_reader   :switching        # True if during the switching phase of the round
  attr_reader   :futureSight      # True if Future Sight is hitting
  attr_reader   :endOfRound       # True during the end of round
  attr_accessor :moldBreaker      # True if Mold Breaker applies
  attr_reader   :struggle         # The Struggle move

  include PokeBattle_BattleCommon

  def pbRandom(x); return rand(x); end

  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = PokeBattle_BattlePeer.create
    @battleAI          = PokeBattle_AI.new(self)
    @field             = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [PokeBattle_ActiveSide.new,   # Player's side
                          PokeBattle_ActiveSide.new]   # Foe's side
    @positions         = []                            # Battler positions
    @battlers          = []
    @sideSizes         = [1,1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = PBEnvironment::None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of PokeBattle_Trainer objects, or nil
    @opponent          = opponent   # Array of PokeBattle_Trainer objects, or nil
    @items             = nil
    @endSpeeches       = []
    @endSpeechesWin    = []
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @zMove             = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
       Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item : 0 },
       Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item : 0 }
    ]
    @recycleItems      = [Array.new(@party1.length,0),Array.new(@party2.length,0)]
    @belch             = [Array.new(@party1.length,false),Array.new(@party2.length,false)]
    @battleBond        = [Array.new(@party1.length,false),Array.new(@party2.length,false)]
    @usedInBattle      = [Array.new(@party1.length,false),Array.new(@party2.length,false)]
    @successStates     = []
    @lastMoveUsed      = -1
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle = PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:STRUGGLE)))
    else
      @struggle = PokeBattle_Struggle.new(self,nil)
    end
  end

  #=============================================================================
  # Information about the type and size of the battle
  #=============================================================================
  def wildBattle?;    return @opponent.nil?;  end
  def trainerBattle?; return !@opponent.nil?; end

  # Sets the number of battler slots on each side of the field independently.
  # For "1v2" names, the first number is for the player's side and the second
  # number is for the opposing side.
  def setBattleMode(mode)
    @sideSizes =
      case mode
      when "quad",   "4v4"; [4,4]
      when "4v3";           [4,3]
      when "4v2";           [4,2]
      when "4v1";           [4,1]

      when "3v4";           [3,4]
      when "triple", "3v3"; [3,3]
      when "3v2";           [3,2]
      when "3v1";           [3,1]

      when "2v4";           [2,4]
      when "2v3";           [2,3]
      when "double", "2v2"; [2,2]
      when "2v1";           [2,1]

      when "1v4";           [1,4]
      when "1v3";           [1,3]
      when "1v2";           [1,2]
      else;                 [1,1]   # Single, 1v1 (default)
      end
  end

  def singleBattle?
    return pbSideSize(0)==1 && pbSideSize(1)==1
  end

  def pbSideSize(idxBattler)
    return @sideSizes[idxBattler%2]
  end

  def maxBattlerIndex
    return (pbSideSize(0)>pbSideSize(1)) ? (pbSideSize(0)-1)*2 : pbSideSize(1)*2-1
  end

  #=============================================================================
  # Trainers and owner-related methods
  #=============================================================================
  def pbPlayer; return @player[0]; end

  # Given a battler index, returns the index within @player/@opponent of the
  # trainer that controls that battler index.
  # NOTE: You shouldn't ever have more trainers on a side than there are battler
  #       positions on that side. This method doesn't account for if you do.
  def pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainer = (opposes?(idxBattler)) ? @opponent : @player
    return 0 if !trainer
    case trainer.length
    when 2
      n = pbSideSize(idxBattler%2)
      return [0,0,1][idxBattler/2] if n==3
       if $game_variables[20]==1
        return [0,1,1,1][idxBattler/2] if n==4
       elsif $game_variables[20]==3
        return [0,0,0,1][idxBattler/2] if n==4
       else
        return [0,0,1,1][idxBattler/2] if n==4
       end
      return idxBattler/2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
    when 3; return idxBattler/2
    when 4: return idxBattler/2
    end
    return 0
  end

  def pbGetOwnerFromBattlerIndex(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return (opposes?(idxBattler)) ? @opponent[idxTrainer] : @player[idxTrainer]
  end

  def pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
    ret = -1
    pbPartyStarts(idxBattler).each_with_index do |start,i|
      break if start>idxParty
      ret = i
    end
    return ret
  end

  # Only used for the purpose of an error message when one trainer tries to
  # switch another trainer's Pokémon.
  def pbGetOwnerFromPartyIndex(idxBattler,idxParty)
    idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
    return (opposes?(idxBattler)) ? @opponent[idxTrainer] : @player[idxTrainer]
  end

  def pbGetOwnerName(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @opponent[idxTrainer].fullname if opposes?(idxBattler)# Opponent
    return @player[idxTrainer].fullname if idxTrainer>0   # Ally trainer
    return @player[idxTrainer].name   # Player
  end

  def pbGetOwnerItems(idxBattler)
    return [] if !@items || !opposes?(idxBattler)
    return @items[pbGetOwnerIndexFromBattlerIndex(idxBattler)]
  end

  # Returns whether the battler in position idxBattler is owned by the same
  # trainer that owns the Pokémon in party slot idxParty. This assumes that
  # both the battler position and the party slot are from the same side.
  def pbIsOwner?(idxBattler,idxParty)
    idxTrainer1 = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    idxTrainer2 = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
    return idxTrainer1==idxTrainer2
  end

  def pbOwnedByPlayer?(idxBattler)
    return false if opposes?(idxBattler)
    return pbGetOwnerIndexFromBattlerIndex(idxBattler)==0
  end

  # Returns the number of Pokémon positions controlled by the given trainerIndex
  # on the given side of battle.
  def pbNumPositions(side,idxTrainer)
    ret = 0
    for i in 0...pbSideSize(side)
      t = pbGetOwnerIndexFromBattlerIndex(i*2+side)
      next if t!=idxTrainer
      ret += 1
    end
    return ret
  end

  #=============================================================================
  # Get party information (counts all teams on the same side)
  #=============================================================================
  def pbParty(idxBattler)
    return (opposes?(idxBattler)) ? @party2 : @party1
  end

  def pbOpposingParty(idxBattler)
    return (opposes?(idxBattler)) ? @party1 : @party2
  end

  def pbPartyOrder(idxBattler)
    return (opposes?(idxBattler)) ? @party2order : @party1order
  end

  def pbPartyStarts(idxBattler)
    return (opposes?(idxBattler)) ? @party2starts : @party1starts
  end

  # Returns the player's team in its display order. Used when showing the party
  # screen.
  def pbPlayerDisplayParty(idxBattler=0)
    partyOrders = pbPartyOrder(idxBattler)
    idxStart, _idxEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    ret = []
    eachInTeamFromBattlerIndex(idxBattler) { |pkmn,i| ret[partyOrders[i]-idxStart] = pkmn }
    return ret
  end

  def pbAbleCount(idxBattler=0)
    party = pbParty(idxBattler)
    count = 0
    party.each { |pkmn| count += 1 if pkmn && pkmn.able? }
    return count
  end

  def pbAbleNonActiveCount(idxBattler=0)
    party = pbParty(idxBattler)
    inBattleIndices = []
    eachSameSideBattler(idxBattler) { |b| inBattleIndices.push(b.pokemonIndex) }
    count = 0
    party.each_with_index do |pkmn,idxParty|
      next if !pkmn || !pkmn.able?
      next if inBattleIndices.include?(idxParty)
      count += 1
    end
    return count
  end

  def pbAllFainted?(idxBattler=0)
    return pbAbleCount(idxBattler)==0
  end

  # For the given side of the field (0=player's, 1=opponent's), returns an array
  # containing the number of able Pokémon in each team.
  def pbAbleTeamCounts(side)
    party = pbParty(side)
    partyStarts = pbPartyStarts(side)
    ret = []
    idxTeam = -1
    nextStart = 0
    party.each_with_index do |pkmn,i|
      if i>=nextStart
        idxTeam += 1
        nextStart = (idxTeam<partyStarts.length-1) ? partyStarts[idxTeam+1] : party.length
      end
      next if !pkmn || !pkmn.able?
      ret[idxTeam] = 0 if !ret[idxTeam]
      ret[idxTeam] += 1
    end
    return ret
  end

  #=============================================================================
  # Get team information (a team is only the Pokémon owned by a particular
  # trainer)
  #=============================================================================
  def pbTeamIndexRangeFromBattlerIndex(idxBattler)
    partyStarts = pbPartyStarts(idxBattler)
    idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : pbParty(idxBattler).length
    return idxPartyStart, idxPartyEnd
  end

  def pbTeamLengthFromBattlerIndex(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    return idxPartyEnd-idxPartyStart
  end

  def eachInTeamFromBattlerIndex(idxBattler)
    party = pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    party.each_with_index { |pkmn,i| yield pkmn,i if pkmn && i>=idxPartyStart && i<idxPartyEnd }
  end

  def eachInTeam(side,idxTrainer)
    party       = pbParty(side)
    partyStarts = pbPartyStarts(side)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : party.length
    party.each_with_index { |pkmn,i| yield pkmn,i if pkmn && i>=idxPartyStart && i<idxPartyEnd }
  end

  # Used for Illusion.
  # NOTE: This cares about the temporary rearranged order of the team. That is,
  #       if you do some switching, the last Pokémon in the team could change
  #       and the Illusion could be a different Pokémon.
  def pbLastInTeam(idxBattler)
    party       = pbParty(idxBattler)
    partyOrders = pbPartyOrder(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    ret = -1
    party.each_with_index do |pkmn,i|
      next if i<idxPartyStart || i>=idxPartyEnd   # Check the team only
      next if !pkmn || !pkmn.able?   # Can't copy a non-fainted Pokémon or egg
      ret = i if partyOrders[i]>partyOrders[ret]
    end
    return ret
  end

  # Used to calculate money gained/lost after winning/losing a battle.
  def pbMaxLevelInTeam(side,idxTrainer)
    ret = 1
    eachInTeam(side,idxTrainer) do |pkmn,_i|
      ret = pkmn.level if pkmn.level>ret
    end
    return ret
  end

  #=============================================================================
  # Iterate through battlers
  #=============================================================================
  def eachBattler
    @battlers.each { |b| yield b if b && !b.fainted? }
  end

  def eachSameSideBattler(idxBattler=0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    @battlers.each { |b| yield b if b && !b.fainted? && !b.opposes?(idxBattler) }
  end

  def eachOtherSideBattler(idxBattler=0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    @battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(idxBattler) }
  end

  def pbSideBattlerCount(idxBattler=0)
    ret = 0
    eachSameSideBattler(idxBattler) { |_b| ret += 1 }
    return ret
  end

  def pbOpposingBattlerCount(idxBattler=0)
    ret = 0
    eachOtherSideBattler(idxBattler) { |_b| ret += 1 }
    return ret
  end

  # This method only counts the player's Pokémon, not a partner trainer's.
  def pbPlayerBattlerCount
    ret = 0
    eachSameSideBattler { |b| ret += 1 if b.pbOwnedByPlayer? }
    return ret
  end

  def pbCheckGlobalAbility(abil)
    eachBattler { |b| return b if b.hasActiveAbility?(abil) }
    return nil
  end

  def pbCheckOpposingAbility(abil,idxBattler=0,nearOnly=false)
    eachOtherSideBattler(idxBattler) do |b|
      next if nearOnly && !b.near?(idxBattler)
      return b if b.hasActiveAbility?(abil)
    end
    return nil
  end

  # Given a battler index, and using battle side sizes, returns an array of
  # battler indices from the opposing side that are in order of most "opposite".
  # Used when choosing a target and pressing up/down to move the cursor to the
  # opposite side, and also when deciding which target to select first for some
  # moves.
  def pbGetOpposingIndicesInOrder(idxBattler)
    case pbSideSize(0)
    when 1
      case pbSideSize(1)
      when 1   # 1v1 single
        return [0] if opposes?(idxBattler)
        return [1]
      when 2   # 1v2
        return  [0] if opposes?(idxBattler)
        return [3,1]
      when 3   # 1v3
        return   [0] if opposes?(idxBattler)
        return [5,3,1]
      when 4   # 1v4
        return    [0] if opposes?(idxBattler)
        return [7,5,3,1]
      end
    when 2
      case pbSideSize(1)
      when 1   # 2v1
        return [0,2] if opposes?(idxBattler)
        return  [1]
      when 2   # 2v2 double
        return [[3,1],[2,0],[1,3],[0,2]][idxBattler]
      when 3   # 2v3
        return [[5,3,1],[2,0],[3,1,5]][idxBattler] if idxBattler<3
        return [0,2]
      when 4   # 2v4
        return   [0,2] if opposes?(idxBattler)
        return [7,5,3,1]
      end
    when 3
      case pbSideSize(1)
      when 1   # 3v1
        return [0,2,4] if opposes?(idxBattler)
        return   [1]
      when 2   # 3v2
        return [[3,1],[2,4,0],[3,1],[2,0,4],[1,3]][idxBattler]
      when 3   # 3v3 triple
        return [[5,3,1],[4,2,0],[3,5,1],[2,0,4],[1,3,5],[0,2,4]][idxBattler]
      when 4   # 3v4
        return  [0,2,4] if opposes?(idxBattler)
        return [7,5,3,1]
      end
    when 4
      case pbSideSize(1)
      when 1   # 4v1
        return [0,2,4,6] if opposes?(idxBattler)
        return    [1]
      when 2   # 4v2
        return [0,2,4,6] if opposes?(idxBattler)
        return   [3,1]
      when 3   # 4v3
        return [0,2,4,6] if opposes?(idxBattler)
        return  [5,3,1]
      when 4   # 4v4 quad
        return [0,2,4,6] if opposes?(idxBattler)
        return [7,5,3,1]
      end
    end
    return [idxBattler]
  end

  #=============================================================================
  # Comparing the positions of two battlers
  #=============================================================================
  def opposes?(idxBattler1,idxBattler2=0)
    idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
    idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
    return (idxBattler1&1)!=(idxBattler2&1)
  end

  def nearBattlers?(idxBattler1,idxBattler2)
    return false if idxBattler1==idxBattler2
    return true if pbSideSize(0)<=2 && pbSideSize(1)<=2
    # Get all pairs of battler positions that are not close to each other
    pairsArray = []   # Covers 3v1 and 1v3
    case pbSideSize(0)
    when 4
      case pbSideSize(1)
      when 4 #4v4
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,1])
        pairsArray.push([4,7])
        pairsArray.push([6,5])
        pairsArray.push([6,7])
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([0,6])
        pairsArray.push([6,2])
        pairsArray.push([7,5])
        pairsArray.push([7,3])
        pairsArray.push([1,3])
      when 3 #4v3
        pairsArray.push([1,0])
        pairsArray.push([1,2])
        pairsArray.push([3,0])
        pairsArray.push([3,6])
        pairsArray.push([5,4])
        pairsArray.push([5,6])
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([0,6])
        pairsArray.push([2,6])
        pairsArray.push([5,1])
      when 2 #4v2
        pairsArray.push([0,1])
        pairsArray.push([6,3])
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([0,6])
        pairsArray.push([2,6])
      when 1
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([0,6])
        pairsArray.push([6,2])
      end
    when 3
      case pbSideSize(1)
      when 4 #3v4
        pairsArray.push([0,1])
        pairsArray.push([0,3])
        pairsArray.push([2,1])
        pairsArray.push([2,7])
        pairsArray.push([4,5])
        pairsArray.push([4,7])
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([7,3])
        pairsArray.push([7,1])
        pairsArray.push([5,1])
      when 3 #3v3
        pairsArray.push([0,1])
        pairsArray.push([4,5])
      # Same Sides
        pairsArray.push([0,4])
        pairsArray.push([1,5])
      when 2 #3v2
        pairsArray.push([0,1])
        pairsArray.push([3,4])
      # Same Sides
        pairsArray.push([0,4])
      when 1
      # Same Sides
        pairsArray.push([0,4])
      end
    when 2
      case pbSideSize(1)
      when 4 #2v4
      pairsArray.push([0,1])
      pairsArray.push([2,7])
      # Same Sides
      pairsArray.push([7,5])
      pairsArray.push([7,3])
      pairsArray.push([1,3])
      when 3 #2v3
      pairsArray.push([0,1])
      pairsArray.push([2,5])
      # Same Sides
      pairsArray.push([1,5])
      end
    end
    # See if any pair matches the two battlers being assessed
    pairsArray.each do |pair|
      return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
    end
    return true
  end

  #=============================================================================
  # Altering a party or rearranging battlers
  #=============================================================================
  def pbRemoveFromParty(idxBattler,idxParty)
    party = pbParty(idxBattler)
    # Erase the Pokémon from the party
    party[idxParty] = nil
    # Rearrange the display order of the team to place the erased Pokémon last
    # in it (to avoid gaps)
    partyOrders = pbPartyOrder(idxBattler)
    partyStarts = pbPartyStarts(idxBattler)
    idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
    idxPartyStart = partyStarts[idxTrainer]
    idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : party.length
    origPartyPos = partyOrders[idxParty]   # Position of erased Pokémon initially
    partyOrders[idxParty] = idxPartyEnd   # Put erased Pokémon last in the team
    party.each_with_index do |_pkmn,i|
      next if i<idxPartyStart || i>=idxPartyEnd   # Only check the team
      next if partyOrders[i]<origPartyPos   # Appeared before erased Pokémon
      partyOrders[i] -= 1   # Appeared after erased Pokémon; bump it up by 1
    end
  end

  def pbSwapBattlers(idxA,idxB)
    return false if !@battlers[idxA] || !@battlers[idxB]
    # Can't swap if battlers aren't owned by the same trainer
    return false if opposes?(idxA,idxB)
    return false if pbGetOwnerIndexFromBattlerIndex(idxA)!=pbGetOwnerIndexFromBattlerIndex(idxB)
    @battlers[idxA],       @battlers[idxB]       = @battlers[idxB],       @battlers[idxA]
    @battlers[idxA].index, @battlers[idxB].index = @battlers[idxB].index, @battlers[idxA].index
    @choices[idxA],        @choices[idxB]        = @choices[idxB],        @choices[idxA]
    @scene.pbSwapBattlerSprites(idxA,idxB)
    # Swap the target of any battlers' effects that point at either of the
    # swapped battlers, to ensure they still point at the correct target
    # NOTE: LeechSeed is not swapped, because drained HP goes to whichever
    #       Pokémon is in the position that Leech Seed was used from.
    # NOTE: PerishSongUser doesn't need to change, as it's only used to
    #       determine which side the Perish Song user was on, and a battler
    #       can't change sides.
    effectsToSwap = [PBEffects::Attract,
                     PBEffects::BideTarget,
                     PBEffects::CounterTarget,
                     PBEffects::LockOnPos,
                     PBEffects::MeanLook,
                     PBEffects::MirrorCoatTarget,
                     PBEffects::SkyDrop,
                     PBEffects::TrappingUser]
    eachBattler do |b|
      for i in effectsToSwap
        next if b.effects[i]!=idxA && b.effects[i]!=idxB
        b.effects[i] = (b.effects[i]==idxA) ? idxB : idxA
      end
    end
    return true
  end

  #=============================================================================
  #
  #=============================================================================
  # Returns the battler representing the Pokémon at index idxParty in its party,
  # on the same side as a battler with battler index of idxBattlerOther.
  def pbFindBattler(idxParty,idxBattlerOther=0)
    eachSameSideBattler(idxBattlerOther) { |b| return b if b.pokemonIndex==idxParty }
    return nil
  end

  # Only used for Wish, as the Wishing Pokémon will no longer be in battle.
  def pbThisEx(idxBattler,idxParty)
    party = pbParty(idxBattler)
    if opposes?(idxBattler)
      return _INTL("The opposing {1}",party[idxParty].name) if trainerBattle?
      return _INTL("The wild {1}",party[idxParty].name)
    end
    return _INTL("The ally {1}",party[idxParty].name) if !pbOwnedByPlayer?(idxBattler)
    return party[idxParty].name
  end

  def pbSetSeen(battler)
    return if !battler || !@internalBattle
    pbPlayer.seen[battler.displaySpecies] = true
    pbSeenForm(battler.displaySpecies,battler.displayGender,battler.displayForm)
  end

  def nextPickupUse
    @nextPickupUse += 1
    return @nextPickupUse
  end

  #=============================================================================
  # Weather and terrain
  #=============================================================================
  def defaultWeather=(value)
    @field.defaultWeather  = value
    @field.weather         = value
    @field.weatherDuration = -1
  end

  # Returns the effective weather (note that weather effects can be negated)
  def pbWeather
    eachBattler { |b| return PBWeather::None if b.hasActiveAbility?([:CLOUDNINE,:AIRLOCK]) }
    return @field.weather
  end

  # Used for causing weather by a move or by an ability.
  def pbStartWeather(user,newWeather,fixedDuration=false,showAnim=true)
    return if @field.weather==newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerWeatherExtenderItem(user.item,
         @field.weather,duration,user,self)
    end
    @field.weatherDuration = duration
    pbCommonAnimation(PBWeather.animationName(@field.weather)) if showAnim
    pbHideAbilitySplash(user) if user
    case @field.weather
    when PBWeather::Sun;         pbDisplay(_INTL("The sunlight turned harsh!"))
    when PBWeather::Rain;        pbDisplay(_INTL("It started to rain!"))
    when PBWeather::Sandstorm;   pbDisplay(_INTL("A sandstorm brewed!"))
    when PBWeather::Hail;        pbDisplay(_INTL("It started to hail!"))
    when PBWeather::HarshSun;    pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when PBWeather::HeavyRain;   pbDisplay(_INTL("A heavy rain began to fall!"))
    when PBWeather::StrongWinds; pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when PBWeather::ShadowSky;   pbDisplay(_INTL("A shadow sky appeared!"))
    end
    # Check for end of primordial weather, and weather-triggered form changes
    eachBattler { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end

  def pbEndPrimordialWeather
    oldWeather = @field.weather
    # End Primordial Sea, Desolate Land, Delta Stream
    case @field.weather
    when PBWeather::HarshSun
      if !pbCheckGlobalAbility(:DESOLATELAND)
        @field.weather = PBWeather::None
        pbDisplay("The harsh sunlight faded!")
      end
    when PBWeather::HeavyRain
      if !pbCheckGlobalAbility(:PRIMORDIALSEA)
        @field.weather = PBWeather::None
        pbDisplay("The heavy rain has lifted!")
      end
    when PBWeather::StrongWinds
      if !pbCheckGlobalAbility(:DELTASTREAM)
        @field.weather = PBWeather::None
        pbDisplay("The mysterious air current has dissipated!")
      end
    end
    if @field.weather!=oldWeather
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather!=PBWeather::None
    end
  end

  def defaultTerrain=(value)
    @field.defaultTerrain  = value
    @field.terrain         = value
    @field.terrainDuration = -1
  end

  def pbStartTerrain(user,newTerrain,fixedDuration=true)
    return if @field.terrain==newTerrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerTerrainExtenderItem(user.item,
         newTerrain,duration,user,self)
    end
    @field.terrainDuration = duration
    pbCommonAnimation(PBBattleTerrains.animationName(@field.terrain))
    pbHideAbilitySplash(user) if user
    case @field.terrain
    when PBBattleTerrains::Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when PBBattleTerrains::Grassy
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when PBBattleTerrains::Misty
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when PBBattleTerrains::Psychic
      pbDisplay(_INTL("The battlefield got weird!"))
    end
    # Check for terrain seeds that boost stats in a terrain
    eachBattler { |b| b.pbItemTerrainStatBoostCheck }
  end

  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg,&block)
    @scene.pbDisplayMessage(msg,&block)
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true)
  end

  def pbDisplayPaused(msg,&block)
    @scene.pbDisplayPausedMessage(msg,&block)
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg)
  end

  def pbShowCommands(msg,commands,canCancel=true)
    @scene.pbShowCommands(msg,commands,canCancel)
  end

  def pbAnimation(move,user,targets,hitNum=0)
    @scene.pbAnimation(move,user,targets,hitNum) if @showAnims
  end

  def pbCommonAnimation(name,user=nil,targets=nil)
    @scene.pbCommonAnimation(name,user,targets) if @showAnims
  end

  def pbShowAbilitySplash(battler,delay=false,logTrigger=true)
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}") if logTrigger
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler)
    if delay
      Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
    end
  end

  def pbHideAbilitySplash(battler)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbHideAbilitySplash(battler)
  end

  def pbReplaceAbilitySplash(battler)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbReplaceAbilitySplash(battler)
  end

  #=============================================================================
  # Shifting a battler to another position in a battle larger than double
  #=============================================================================
  def pbCanShift?(idxBattler)
    return false if pbSideSize(0)<=2 && pbSideSize(1)<=2   # Double battle or smaller
    idxOther = -1
    case pbSideSize(idxBattler)
    when 1
      return false   # Only one battler on that side
    when 2
      idxOther = (idxBattler+2)%4
    when 3
      return false if idxBattler==2 || idxBattler==3   # In middle spot already
      idxOther = ((idxBattler%2)==0) ? 2 : 3
    end
    return false if pbGetOwnerIndexFromBattlerIndex(idxBattler)!=pbGetOwnerIndexFromBattlerIndex(idxOther)
    return true
  end

  def pbRegisterShift(idxBattler)
    @choices[idxBattler][0] = :Shift
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  #=============================================================================
  # Calling at a battler
  #=============================================================================
  def pbRegisterCall(idxBattler)
    @choices[idxBattler][0] = :Call
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  def pbCall(idxBattler)
    battler = @battlers[idxBattler]
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} called {2}!",trainerName,battler.pbThis(true)))
    pbDisplay(_INTL("{1}!",battler.name))
    if battler.shadowPokemon?
      if battler.inHyperMode?
        battler.pokemon.hypermode = false
        battler.pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",battler.pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif battler.status==PBStatuses::SLEEP
      battler.pbCureStatus
    elsif battler.pbCanRaiseStatStage?(PBStats::ACCURACY,battler)
      battler.pbRaiseStatStage(PBStats::ACCURACY,1,battler)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

  #=============================================================================
  # Choosing to Mega Evolve a battler
  #=============================================================================
  def pbHasMegaRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)# Assume AI trainer have a ring
    MEGA_RINGS.each do |item|
      return true if hasConst?(PBItems,item) && $PokemonBag.pbHasItem?(item)
    end
    return false
  end

  def pbGetMegaRingName(idxBattler)
    if pbOwnedByPlayer?(idxBattler)
      MEGA_RINGS.each do |i|
        next if !hasConst?(PBItems,i)
        return PBItems.getName(getConst(PBItems,i)) if $PokemonBag.pbHasItem?(i)
      end
    end
    # NOTE: Add your own Mega objects for particular NPC trainers here.
#    if isConst?(pbGetOwnerFromBattlerIndex(idxBattler).trainertype,PBTrainers,:BUGCATCHER)
#      return _INTL("Mega Net")
#    end
    return _INTL("Mega Ring")
  end

  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end

  def pbRegisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = idxBattler
  end

  def pbUnregisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -1 if @megaEvolution[side][owner]==idxBattler
  end

  def pbToggleRegisteredMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @megaEvolution[side][owner]==idxBattler
      @megaEvolution[side][owner] = -1
    else
      @megaEvolution[side][owner] = idxBattler
    end
  end

  def pbRegisteredMegaEvolution?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==idxBattler
  end

################################################################################
# Use Z-Move.
################################################################################

  def pbCanZMove?(idxBattler)
    return false if $game_switches[NO_Z_MOVE]
    return false if !@battlers[idxBattler].hasZMove?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if !pbHasMegaRing?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @zMove[side][owner]==-1
  end

  def pbRegisterZMove(idxBattler)
    side=(pbIsOpposing?(idxBattler)) ? 1 : 0
    owner=pbGetOwnerIndex(idxBattler)
    @zMove[side][owner]=index
  end

  def pbUseZMove(index,move,crystal)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasZMove? rescue false)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",@battlers[index].pbThis))      
    pbCommonAnimation("ZPower",@battlers[index],nil)     
    PokeBattle_ZMoves.new(self,@battlers[index],move,crystal)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @zMove[side][owner]=-2
  end

  def pbToggleRegisteredZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @zMove[side][owner]==idxBattler
      @zMove[side][owner] = -1
    else
      @zMove[side][owner] = idxBattler
    end
  end

  def pbRegisteredZMove?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @zMove[side][owner]==idxBattler
  end

  #=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Mega Evolve
    case battler.pokemon.megaMessage
    when 1   # Rayquaza
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
         battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeMega
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    if !megaName || megaName==""
      megaName = _INTL("Mega {1}",PBSpecies.getName(battler.pokemon.species))
    end
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    pbCalculatePriority(false,[idxBattler]) if NEWEST_BATTLE_MECHANICS
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end

  #=============================================================================
  # Primal Reverting a battler
  #=============================================================================
  def pbPrimalReversion(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasPrimal? || battler.primal?
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon",battler)
    end
    battler.pokemon.makePrimal
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre2",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon2",battler)
    end
    pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal form!",battler.pbThis))
  end

  def pbCommandPhase
    @scene.pbBeginCommandPhase
    # Reset choices if commands can be shown
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    for i in 0...@zMove[0].length
      @zMove[0][i]=-1 if @zMove[0][i]>=0
    end
    for i in 0...@zMove[1].length
      @zMove[1][i]=-1 if @zMove[1][i]>=0
    end
    # Choose actions for the round (player first, then AI)
    pbCommandPhaseLoop(true) # Player chooses their actions
    return if @decision!=0   # Battle ended, stop choosing actions
    pbCommandPhaseLoop(false)# AI chooses their actions
  end

  def pbFightMenu(idxBattler)
    # Auto-use Encored move or no moves choosable, so auto-use Struggle
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    # Battle Palace only
    return true if pbAutoFightMenu(idxBattler)
    # Regular move selection
    ret = false
    @scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler),pbCanZMove?(idxBattler)) { |cmd|
      case cmd
      when -1   # Cancel
      when -2   # Toggle Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when -3
        pbToggleRegisteredZMove(idxBattler)
        next false
      when -4   # Shift
        pbUnregisterMegaEvolution(idxBattler)
        pbRegisterShift(idxBattler)
        ret = true
      else      # Chose a move to use
        next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
                                @battlers[idxBattler].moves[cmd].id<=0
        next false if !pbRegisterMove(idxBattler,cmd)
        next false if !singleBattle? &&
           !pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    }
    return ret
  end

  def pbAttackPhaseZMoves
    pbPriority.each do |b|
      idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @zMove[b.idxOwnSide][owner]!=b.index
      @choices[b.index][2].zmove=true
    end
  end

  def pbAttackPhaseMoves
    # Show charging messages (Focus Punch)
    pbPriority.each do |b|
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      next if b.movedThisRound?
      @choices[b.index][2].pbDisplayChargeMessage(b)
    end
    # Main move processing loop
    loop do
      priority = pbPriority
      # Forced to go next
      advance = false
      priority.each do |b|
        next unless b.effects[PBEffects::MoveNext] && !b.fainted?
        next unless @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
        next if b.movedThisRound?
        advance = b.pbProcessTurn(@choices[b.index])
        break if advance
      end
      return if @decision>0
      next if advance
      # Regular priority order
      priority.each do |b|
        next if b.effects[PBEffects::Quash]>0 || b.fainted?
        next unless @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
        next if b.movedThisRound?
        advance = b.pbProcessTurn(@choices[b.index])
        break if advance
      end
      return if @decision>0
      next if advance
      # Quashed
      quashLevel = 0
      loop do
        quashLevel += 1
        moreQuash = false
        priority.each do |b|
          moreQuash = true if b.effects[PBEffects::Quash]>quashLevel
          next unless b.effects[PBEffects::Quash]==quashLevel && !b.fainted?
          next unless @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
          next if b.movedThisRound?
          advance = b.pbProcessTurn(@choices[b.index],useZMoveVal)
          break
        end
        break if advance || !moreQuash
      end
      return if @decision>0
      next if advance
      # Check for all done
      priority.each do |b|
        if !b.fainted? && !b.movedThisRound?
          advance = true if @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
        end
        break if advance
      end
      next if advance
      # All Pokémon have moved; end the loop
      break
    end
  end

  def pbAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")# Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseZMoves
    pbAttackPhaseMoves
  end

  def pbGetOwner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[0] : @opponent[1]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[0] : @player[1]
      else
        return @player
      end
    end
  end

  def pbGetOwnerIndex(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return (@opponent.is_a?(Array)) ? ((battlerIndex==1) ? 0 : 1) : 0
    else
      return (@player.is_a?(Array)) ? ((battlerIndex==0) ? 0 : 1) : 0
    end
  end

  def pbBelongsToPlayer?(battlerIndex)
    if @player.is_a?(Array) && @player.length>1
      return battlerIndex==0
    else
      return (battlerIndex%2)==0
    end
    return false
  end

  def pbPartyGetOwner(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return @player if !@player || !@player.is_a?(Array)
      return (partyIndex<secondParty) ? @player[0] : @player[1]
    else
      return @opponent if !@opponent || !@opponent.is_a?(Array)
      return (partyIndex<secondParty) ? @opponent[0] : @opponent[1]
    end
  end

  def pbIsOpposing?(index)
    return (index%2)==1
  end

end

class PokeBattle_AI
  def initialize(battle)
    @battle = battle
  end

  def pbAIRandom(x); return rand(x); end

  def pbStdDev(choices)
    sum = 0
    n   = 0
    choices.each do |c|
      sum += c[1]
      n   += 1
    end
    return 0 if n<2
    mean = sum.to_f/n.to_f
    varianceTimesN = 0
    choices.each do |c|
      next if c[1]<=0
      deviation = c[1].to_f-mean
      varianceTimesN += deviation*deviation
    end
    # Using population standard deviation
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN/n)
  end

  #=============================================================================
  # Decide whether the opponent should Mega Evolve their Pokémon
  #=============================================================================
  def pbEnemyShouldMegaEvolve?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanMegaEvolve?(idxBattler)# Simple "always should if possible"
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Mega Evolve")
      return true
    end
    return false
  end

  #=============================================================================
  # Decide whether the opponent should Use a ZMove
  #=============================================================================
  def pbEnemyShouldZMove?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanZMove?(idxBattler)# Simple "always should if possible"
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use a ZMove")
      return true
    end
    return false
  end

  #=============================================================================
  # Choose an action
  #=============================================================================
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
      if pbEnemyShouldZMove?(idxBattler)
        return pbChooseEnemyZMove(idxBattler)
      end  
    pbChooseMoves(idxBattler)
  end

  def pbChooseEnemyZMove(idxBattler)  #Put specific cases for trainers using status Z-Moves
    chosenmove=false
    chosenindex=-1
    for i in 0..3
      move=@battlers[idxBattler].moves[i]
      if @battlers[idxBattler].pbCompatibleZMoveFromMove?(move)
        if move.id == getID(PBMoves,:CONVERSION) ||  move.id == getID(PBMoves,:SPLASH)
          pbRegisterZMove(idxBattler)
          pbRegisterMove(idxBattler,i,false)
          pbRegisterTarget(idxBattler,opponent.index)
          return
        end
        if !chosenmove
          chosenindex = i
          chosenmove=move
        else
          if move.baseDamage>chosenmove.baseDamage
            chosenindex=i
            chosenmove=move
          end
        end
      end
    end
    attacker = @battlers[idxBattler]
    skill=pbGetOwner(attacker.idxBattler).skill || 0
    opponent=attacker.pbOppositeOpposing
    otheropp=opponent.pbPartner 
    #oppeff1 = chosenmove.pbTypeModifier(chosenmove.type,attacker,opponent)
    oppeff1 = pbTypeModNoMessages(chosenmove.type,attacker,opponent,chosenmove,skill)
    #oppeff2 = chosenmove.pbTypeModifier(chosenmove.type,attacker,otheropp)
    oppeff2 = pbTypeModNoMessages(chosenmove.type,attacker,otheropp,chosenmove,skill)
    oppeff1 = 0 if opponent.hp<(opponent.totalhp/2).round
    oppeff2 = 0 if otheropp.hp<(otheropp.totalhp/2).round
    if (oppeff1<4) && (oppeff2<4)
      pbChooseMoves(idxBattler)
    elsif oppeff1>oppeff2
      pbRegisterZMove(idxBattler)
      pbRegisterMove(idxBattler,chosenindex,false)
      pbRegisterTarget(idxBattler,opponent.index)
    elsif oppeff1<oppeff2
      pbRegisterZMove(idxBattler)
      pbRegisterMove(idxBattler,chosenindex,false)
      pbRegisterTarget(idxBattler,otheropp.index)   
    elsif oppeff1==oppeff2
      pbRegisterZMove(idxBattler)
      pbRegisterMove(idxBattler,chosenindex,false)
      pbRegisterTarget(idxBattler,opponent.index)   
    end  
  end  
end

class FightMenuDisplay < BattleMenuBase
  attr_reader :battler
  attr_reader :shiftMode

  # If true, displays graphics from Graphics/Pictures/Battle/overlay_fight.png
  #     and Graphics/Pictures/Battle/cursor_fight.png.
  # If false, just displays text and the command window over the graphic
  #     Graphics/Pictures/Battle/overlay_message.png. You will need to edit def
  #     pbShowWindow to make the graphic appear while the command menu is being
  #     displayed.
  USE_GRAPHICS     = true
  TYPE_ICON_HEIGHT = 28
  # Text colours of PP of selected move
  PP_COLORS = [
     Color.new(248,72,72),Color.new(136,48,48),    # Red, zero PP
     Color.new(248,136,32),Color.new(144,72,24),   # Orange, 1/4 of total PP or less
     Color.new(248,192,0),Color.new(144,104,0),    # Yellow, 1/2 of total PP or less
     TEXT_BASE_COLOR,TEXT_SHADOW_COLOR             # Black, more than 1/2 of total PP
  ]
  MAX_MOVES = 4   # Number of moves to display at once

  def initialize(viewport,z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height-96
    @battler   = nil
    @shiftMode = 0
    # NOTE: @mode is for the display of the Mega Evolution button.
    #       0=don't show, 1=show unpressed, 2=show pressed
    if USE_GRAPHICS
      # Create bitmaps
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @megaEvoBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      @zMoveBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_zmove"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      # Create background graphic
      background = IconSprite.new(0,Graphics.height-96,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background",background)
      # Create move buttons
      @buttons = Array.new(MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+4
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+4
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-2)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
      # Create overlay for buttons (shows move names)
      @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay",@overlay)
      # Create overlay for selected move's info (shows move's PP)
      @infoOverlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay",@infoOverlay)
      # Create type icon
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x+416
      @typeIcon.y      = self.y+20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon",@typeIcon)
      # Create Mega Evolution button
      @megaButton = SpriteWrapper.new(viewport)
      @megaButton.bitmap = @megaEvoBitmap.bitmap
      @megaButton.x      = self.x+146
      @megaButton.y      = self.y-@megaEvoBitmap.height/2
      @megaButton.src_rect.height = @megaEvoBitmap.height/2
      addSprite("megaButton",@megaButton)
      # Create Z Move button
      @zMButton = SpriteWrapper.new(viewport)
      @zMButton.bitmap = @zMoveBitmap.bitmap
      @zMButton.x      = self.x+146
      @zMButton.y      = self.y-@zMoveBitmap.height/2
      @zMButton.src_rect.height = @zMoveBitmap.height/2
      addSprite("zMButton",@zMButton)
      # Create Shift button
      @shiftButton = SpriteWrapper.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x+4
      @shiftButton.y      = self.y-@shiftBitmap.height
      addSprite("shiftButton",@shiftButton)
    else
      # Create message box (shows type and PP of selected move)
      @msgBox = Window_AdvancedTextPokemon.newWithSize("",
         self.x+320,self.y,Graphics.width-320,Graphics.height-self.y,viewport)
      @msgBox.baseColor   = TEXT_BASE_COLOR
      @msgBox.shadowColor = TEXT_SHADOW_COLOR
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox",@msgBox)
      # Create command window (shows moves)
      @cmdWindow = Window_CommandPokemon.newWithSize([],
         self.x,self.y,320,Graphics.height-self.y,viewport)
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow",@cmdWindow)
    end
    self.z = z
  end

  def dispose
    super
    @buttonBitmap.dispose if @buttonBitmap
    @typeBitmap.dispose if @typeBitmap
    @megaEvoBitmap.dispose if @megaEvoBitmap
    @shiftBitmap.dispose if @shiftBitmap
  end

  def z=(value)
    super
    @msgBox.z      += 1 if @msgBox
    @cmdWindow.z   += 2 if @cmdWindow
    @overlay.z     += 5 if @overlay
    @infoOverlay.z += 6 if @infoOverlay
    @typeIcon.z    += 1 if @typeIcon
  end

  def battler=(value)
    @battler = value
    refresh
    refreshButtonNames
  end

  def shiftMode=(value)
    oldValue = @shiftMode
    @shiftMode = value
    refreshShiftButton if @shiftMode!=oldValue
  end

  def refreshButtonNames
    moves = (@battler) ? @battler.moves : []
    if !USE_GRAPHICS
      # Fill in command window
      commands = []
      moves.each { |m| commands.push((m && m.id>0) ? m.name : "-") }
      @cmdWindow.commands = commands
      return
    end
    # Draw move names onto overlay
    @overlay.bitmap.clear
    textPos = []
    moves.each_with_index do |m,i|
      button = @buttons[i]
      next if !@visibility["button_#{i}"]
      x = button.x-self.x+button.src_rect.width/2
      y = button.y-self.y+8
      moveNameBase = TEXT_BASE_COLOR
      if m.type>=0
        # NOTE: This takes a colour from a particular pixel in the button
        #       graphic and makes the move name's base colour that same colour.
        #       The pixel is at coordinates 10,34 in the button box. If you
        #       change the graphic, you may want to change/remove the below line
        #       of code to ensure the font is an appropriate colour.
       #moveNameBase = button.bitmap.get_pixel(10,button.src_rect.y+34)
      end
      textPos.push([m.name,x,y,2,moveNameBase,TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap,textPos)
  end

  def refreshSelection
    moves = (@battler) ? @battler.moves : []
    if USE_GRAPHICS
      # Choose appropriate button graphics and z positions
      @buttons.each_with_index do |button,i|
        if !moves[i] || moves[i].id==0
          @visibility["button_#{i}"] = false
          next
        end
        @visibility["button_#{i}"] = true
        button.src_rect.x = (i==@index) ? @buttonBitmap.width/2 : 0
        button.src_rect.y = moves[i].type*BUTTON_HEIGHT
        button.z          = self.z + ((i==@index) ? 4 : 3)
      end
    end
    refreshMoveData(moves[@index])
  end

  def refreshMoveData(move)
    # Write PP and type of the selected move
    if !USE_GRAPHICS
      moveType = PBTypes.getName(move.type)
      if move.totalpp<=0
        @msgBox.text = _INTL("PP: ---<br>TYPE/{1}",moveType)
      else
        @msgBox.text = _ISPRINTF("PP: {1: 2d}/{2: 2d}<br>TYPE/{3:s}",
           move.pp,move.totalpp,moveType)
      end
      return
    end
    @infoOverlay.bitmap.clear
    if !move || move.id==0
      @visibility["typeIcon"] = false
      return
    end
    @visibility["typeIcon"] = true
    # Type icon
    @typeIcon.src_rect.y = move.type*TYPE_ICON_HEIGHT
    # PP text
    if move.totalpp>0
      ppFraction = [(4.0*move.pp/move.totalpp).ceil,3].min
      textPos = []
      textPos.push([_INTL("PP: {1}/{2}",move.pp,move.totalpp),
         448,50,2,PP_COLORS[ppFraction*2],PP_COLORS[ppFraction*2+1]])
      pbDrawTextPositions(@infoOverlay.bitmap,textPos)
    end
  end

  def refreshMegaEvolutionButton
    return if !USE_GRAPHICS
    @megaButton.src_rect.y    = (@mode - 1) * @megaEvoBitmap.height / 2
    @megaButton.z             = self.z - 1
    @visibility["megaButton"] = (@mode > 0)
  end

  def refreshZMoveButton
    return if !USE_GRAPHICS
    @zMButton.src_rect.y    = (@mode - 1) * @zMoveBitmap.height / 2
    @zMButton.z             = self.z - 1
    @visibility["zMButton"] = (@mode > 0)
  end

  def refreshShiftButton
    return if !USE_GRAPHICS
    @shiftButton.src_rect.y    = (@shiftMode - 1) * @shiftBitmap.height
    @shiftButton.z             = self.z - 1
    @visibility["shiftButton"] = (@shiftMode > 0)
  end

  def refresh
    return if !@battler
    refreshSelection
    refreshMegaEvolutionButton
    refreshShiftButton
	  refreshZMoveButton
  end
end

class PokeBattle_Scene
  #=============================================================================
  # The player chooses a main command for a Pokémon
  # Return values: -1=Cancel, 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  #=============================================================================
  def pbCommandMenu(idxBattler,firstAction)
    shadowTrainer = (hasConst?(PBTypes,:SHADOW) && @battle.trainerBattle?)
    cmds = [
       _INTL("What will\n{1} do?",@battle.battlers[idxBattler].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       (shadowTrainer) ? _INTL("Call") : (firstAction) ? _INTL("Run") : _INTL("Cancel")
    ]
    ret = pbCommandMenuEx(idxBattler,cmds,(shadowTrainer) ? 2 : (firstAction) ? 0 : 1)
    ret = 4 if ret==3 && shadowTrainer   # Convert "Run" to "Call"
    ret = -1 if ret==3 && !firstAction   # Convert "Run" to "Cancel"
    return ret
  end

  # Mode: 0 = regular battle with "Run" (first choosable action in the round only)
  #       1 = regular battle with "Cancel"
  #       2 = regular battle with "Call" (for Shadow Pokémon battles)
  #       3 = Safari Zone
  #       4 = Bug Catching Contest
  def pbCommandMenuEx(idxBattler,texts,mode=0)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler],mode)
    pbSelectBattler(idxBattler)
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index&1)==0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index&2)==0
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::C)              # Confirm choice
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::B) && mode==1   # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG    # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    return ret
  end

  #=============================================================================
  # The player chooses a move for a Pokémon to use
  #=============================================================================
  def pbFightMenu(idxBattler,megaEvoPossible=false,zMovePossible=false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id>0
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    cw.setIndexAndMode(moveIndex,(megaEvoPossible) ? 1 : 0)
    cw.setIndexAndMode(moveIndex,(zMovePossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      # Refresh view if necessary
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if zMovePossible
          newMode = (@battle.pbRegisteredZMove?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      # General update
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id>0
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id>0
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::C)   # Confirm choice
	   ret=cw.index
	   if cw.mode==2
	    if battler.pbCompatibleZMoveFromIndex?(ret)
         pbPlayDecisionSE
         break if yield cw.index
         needFullRefresh = true
         needRefresh = true
		else
         @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",PBMoves.getName(battler.moves[ret]),PBItems.getName(battler.item)))
#        @lastmove[idxBattler]=cw.index
         return -1
        end
	   else
         pbPlayDecisionSE
         break if yield cw.index
         needFullRefresh = true
         needRefresh = true
	   end
      elsif Input.trigger?(Input::B)# Cancel fight menu
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
      elsif Input.trigger?(Input::A)# Toggle Mega Evolution
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
        if zMovePossible
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
      elsif Input.trigger?(Input::F5)# Shift
        if cw.shiftMode>0
          pbPlayDecisionSE
          break if yield -4
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end

  #=============================================================================
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens)
  #=============================================================================
  def pbPartyScreen(idxBattler,canCancel=false)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Choose a Pokémon."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      idxParty = switchScreen.pbChoosePokemon
      if idxParty<0
        next if !canCancel
        break
      end
      # Choose a command for the selected Pokémon
      cmdSwitch  = -1
      cmdSummary = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if modParty[idxParty].able?
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      if cmdSwitch>=0 && command==cmdSwitch        # Switch In
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary>=0 && command==cmdSummary   # Summary
        scene.pbSummary(idxParty,true)
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
  end

  #=============================================================================
  # Opens the Bag screen and chooses an item to use
  #=============================================================================
  def pbItemMenu(idxBattler,_firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $PokemonBag.lastpocket
    oldChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = @bagLastPocket if @bagLastPocket!=nil
    $PokemonBag.setAllChoices(@bagChoices) if @bagChoices!=nil
    # Start Bag screen
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($PokemonBag,true,Proc.new { |item|
      useType = pbGetItemData(item,ITEM_BATTLE_USE)
      next useType && useType>0
      },false)
    # Loop while in Bag screen
    wasTargeting = false
    loop do
      # Select an item
      item = itemScene.pbChooseItem
      break if item==0
      # Choose a command for the selected item
      itemName = PBItems.getName(item)
      useType = pbGetItemData(item,ITEM_BATTLE_USE)
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType!=0
      commands[commands.length]          = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.",itemName),commands)
      next unless cmdUse>=0 && command==cmdUse   # Use
      # Use types:
      # 0 = not usable in battle
      # 1 = use on Pokémon (lots of items), consumed
      # 2 = use on Pokémon's move (Ethers), consumed
      # 3 = use on battler (X items, Persim Berry), consumed
      # 4 = use on opposing battler (Poké Balls), consumed
      # 5 = use no target (Poké Doll, Guard Spec., Launcher items), consumed
      # 6 = use on Pokémon (Blue Flute), not consumed
      # 7 = use on Pokémon's move, not consumed
      # 8 = use on battler (Red/Yellow Flutes), not consumed
      # 9 = use on opposing battler, not consumed
      # 10 = use no target (Poké Flute), not consumed
      case useType
      when 1, 2, 3, 6, 7, 8   # Use on Pokémon/Pokémon's move/battler
        # Auto-choose the Pokémon/battler whose action is being decided if they
        # are the only available Pokémon/battler to use the item on
        case useType
        when 1, 6   # Use on Pokémon
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler)==1
            break if yield item, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3, 8   # Use on battler
          if @battle.pbPlayerBattlerCount==1
            break if yield item, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        # Fade out and hide Bag screen
        itemScene.pbFadeOutScene
        # Get player's party
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start party screen
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene,modParty)
        pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.pbNumPositions(0,0))
        idxParty = -1
        # Loop while in party screen
        loop do
          # Select a Pokémon
          pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          idxParty = pkmnScreen.pbChoosePokemon
          break if idxParty<0
          idxPartyRet = -1
          partyPos.each_with_index do |pos,i|
            next if pos!=idxParty+partyStart
            idxPartyRet = i
            break
          end
          next if idxPartyRet<0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType==2 || useType==7   # Use on Pokémon's move
            idxMove = pkmnScreen.pbChooseMove(pkmn,_INTL("Restore which move?"))
            next if idxMove<0
          end
          break if yield item, useType, idxPartyRet, idxMove, pkmnScene
        end
        pkmnScene.pbEndScene
        break if idxParty>=0
        # Cancelled choosing a Pokémon; show the Bag screen again
        itemScene.pbFadeInScene
      when 4, 9   # Use on opposing battler (Poké Balls)
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler)==1
          @battle.eachOtherSideBattler(idxBattler) { |b| idxTarget = b.index }
          break if yield item, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          # Fade out and hide Bag screen
          itemScene.pbFadeOutScene
          # Fade in and show the battle screen, choosing a target
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler,PBTargets::NearFoe,tempVisibleSprites)
          if idxTarget>=0
            break if yield item, useType, idxTarget, -1, self
          end
          # Target invalid/cancelled choosing a target; show the Bag screen again
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          itemScene.pbFadeInScene
        end
      when 5, 10   # Use with no target
        break if yield item, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $PokemonBag.lastpocket
    @bagChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = oldLastPocket
    $PokemonBag.setAllChoices(oldChoices)
    # Close Bag screen
    itemScene.pbEndScene
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites,visibleSprites) if !wasTargeting
  end

  #=============================================================================
  # The player chooses a target battler for a move/item (non-single battles only)
  #=============================================================================
  # Returns an array containing battler names to display when choosing a move's
  # target.
  # nil means can't select that position, "" means can select that position but
  # there is no battler there, otherwise is a battler's name.
  def pbCreateTargetTexts(idxBattler,targetType)
    texts = Array.new(@battle.battlers.length) do |i|
      next nil if !@battle.battlers[i]
      showName = false
      case targetType
      when PBTargets::None, PBTargets::User, PBTargets::RandomNearFoe
        showName = (i==idxBattler)
      when PBTargets::UserSide, PBTargets::UserAndAllies
        showName = !@battle.opposes?(i,idxBattler)
      when PBTargets::FoeSide, PBTargets::AllFoes
        showName = @battle.opposes?(i,idxBattler)
      when PBTargets::BothSides, PBTargets::AllBattlers
        showName = true
      else
        showName = @battle.pbMoveCanTarget?(i,idxBattler,targetType)
      end
      next nil if !showName
      next (@battle.battlers[i].fainted?) ? "" : @battle.battlers[i].name
    end
    return texts
  end

  # Returns the initial position of the cursor when choosing a target for a move
  # in a non-single battle.
  def pbFirstTarget(idxBattler,targetType)
    case targetType
    when PBTargets::NearAlly
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        next if b.fainted?
        return b.index
      end
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        return b.index
      end
    when PBTargets::NearFoe, PBTargets::NearOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) && !@battle.battlers[i].fainted? }
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) }
    end
    return idxBattler
  end

  def pbChooseTarget(idxBattler,targetType,visibleSprites=nil)
    pbShowWindow(TARGET_BOX)
    cw = @sprites["targetWindow"]
    # Create an array of battler names (only valid targets are named)
    texts = pbCreateTargetTexts(idxBattler,targetType)
    # Determine mode based on targetType
    mode = (PBTargets.oneTarget?(targetType)) ? 0 : 1
    cw.setDetails(texts,mode)
    cw.index = pbFirstTarget(idxBattler,targetType)
    pbSelectBattler((mode==0) ? cw.index : texts,2)# Select initial battler/data box
    pbFadeInAndShow(@sprites,visibleSprites) if visibleSprites
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if mode==0   # Choosing just one target, can change index
        if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
          inc = ((cw.index%2)==0) ? -2 : 2
          inc *= -1 if Input.trigger?(Input::RIGHT)
          indexLength = @battle.sideSizes[cw.index%2]*2
          newIndex = cw.index
          loop do
            newIndex += inc
            break if newIndex<0 || newIndex>=indexLength
            next if texts[newIndex].nil?
            cw.index = newIndex
            break
          end
        elsif (Input.trigger?(Input::UP) && (cw.index%2)==0) ||
              (Input.trigger?(Input::DOWN) && (cw.index%2)==1)
          tryIndex = @battle.pbGetOpposingIndicesInOrder(cw.index)
          tryIndex.each do |idxBattlerTry|
            next if texts[idxBattlerTry].nil?
            cw.index = idxBattlerTry
            break
          end
        end
        if cw.index!=oldIndex
          pbPlayCursorSE
          pbSelectBattler(cw.index,2)# Select the new battler/data box
        end
      end
      if Input.trigger?(Input::C)# Confirm
        ret = cw.index
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::B)# Cancel
        ret = -1
        pbPlayCancelSE
        break
      end
    end
    pbSelectBattler(-1)# Deselect all battlers/data boxes
    return ret
  end

  #=============================================================================
  # Opens a Pokémon's summary screen to try to learn a new move
  #=============================================================================
  # Called whenever a Pokémon should forget a move. It should return -1 if the
  # selection is canceled, or 0 to 3 to indicate the move to forget. It should
  # not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,moveToLearn)
    ret = -1
    pbFadeOutIn {
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      ret = screen.pbStartForgetScreen([pkmn],0,moveToLearn)
    }
    return ret
  end

  #=============================================================================
  # Opens the nicknaming screen for a newly caught Pokémon
  #=============================================================================
  def pbNameEntry(helpText,pkmn)
    return pbEnterPokemonName(helpText,0,PokeBattle_Pokemon::MAX_POKEMON_NAME_SIZE,"",pkmn)
  end

  #=============================================================================
  # Shows the Pokédex entry screen for a newly caught Pokémon
  #=============================================================================
  def pbShowPokedex(species)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(species)
    }
  end
end

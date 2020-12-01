#===============================================================================
# Adds Ice type effectiveness to a move (Frost Strike, Hocus Pocus)
#===============================================================================
class PokeBattle_Move_300 < PokeBattle_Move
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = super
    if hasConst?(PBTypes,:ICE)
      iceEff = PBTypes.getEffectiveness(getConst(PBTypes,:ICE),defType)
      ret *= iceEff.to_f/PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end
end


#===============================================================================
# Adds Ice type effectiveness to a move (Frost Strike, Hocus Pocus)
#===============================================================================
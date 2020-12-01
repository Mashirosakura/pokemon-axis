#===============================================================================
# * Battle Points by Aurum / SunakazeKun with edit by Zerokid
#===============================================================================
# * Global Metadata
#===============================================================================
class PokemonGlobalMetadata
  attr_writer :bpoints

  def bpoints
    @bpoints ||= 0
    return @bpoints
  end
end

#===============================================================================
# * Point Card Item
#===============================================================================
ItemHandlers::UseFromBag.add(:POINTCARD,proc{|item|
   Kernel.pbMessage(_INTL("Battle Points:\n{1}",$PokemonGlobal.bpoints))
   next 1 # Continue
})

ItemHandlers::UseInField.add(:POINTCARD,proc{|item|
   Kernel.pbMessage(_INTL("Battle Points:\n{1}",$PokemonGlobal.bpoints))
   next 1 # Continue
})
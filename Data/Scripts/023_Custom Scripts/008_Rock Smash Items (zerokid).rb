#===============================================================================
# Rock Smash Items Script by Zerokid
#===============================================================================

module Kernel
  alias inv_pbRockSmashRandomEncounter pbRockSmashRandomEncounter
  def self.pbRockSmashRandomEncounter
    prob=rand(4)
    # 25% chance to get a random item from this list
    if prob<1
      possibleItems=[:BIGPEARL,:ETHER,:HARDSTONE,:HEARTSCALE,:MAXETHER,
                     :MAXREVIVE,:NORMALGEM,:PEARL,:REVIVE,:SOFTSAND,
                     :STARPIECE]
      itemIndex=rand(possibleItems.length)
      item=possibleItems[itemIndex]
      Kernel.pbItemBall(item)
    # 25% chance to encounter a pokemon
    elsif prob<2
      pbEncounter(EncounterTypes::RockSmash)
    end
    # 50% chance of nothing
  end
end
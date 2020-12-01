module PBTargets
  # NOTE: These numbers are all over the place because of backwards
  #       compatibility. As untidy as they are, they need to be left like this.
  NearOther      = 0
  None           = 1     # Bide, Counter, Metal Burst, Mirror Coat (calculate a target)
  RandomNearFoe  = 2     # Petal Dance, Outrage, Struggle, Thrash, Uproar
  Other          = 3     # Most Flying-type moves, pulse moves (hits non-near targets)
  AllNearFoes    = 4
  UserAndAllies  = 5     # Aromatherapy, Gear Up, Heal Bell, Life Dew, Magnetic Flux, Howl (in Gen 8+)
  AllFoes        = 6     # Unused (for completeness)
  AllBattlers    = 7     # Flower Shield, Perish Song, Rototiller, Teatime
  AllNearOthers  = 8
  Foe            = 9     # For throwing a Poké Ball
  User           = 10
  BothSides      = 20
  UserSide       = 40
  FoeSide        = 80    # Entry hazards
  NearAlly       = 100   # Aromatic Mist, Helping Hand, Hold Hands
  UserOrNearAlly = 200   # Acupressure
  NearFoe        = 400   # Me First

  def self.noTargets?(target)
    return target==None ||
           target==User ||
           target==UserSide ||
           target==FoeSide ||
           target==BothSides
  end

  # Used to determine if you are able to choose a target for the move.
  def self.oneTarget?(target)
    return !PBTargets.noTargets?(target) &&
           !PBTargets.multipleTargets?(target)
  end

  def self.multipleTargets?(target)
    return target==AllNearFoes ||
           target==AllNearOthers ||
           target==UserAndAllies ||
           target==AllFoes ||
           target==AllBattlers
  end

  # These moves do not target specific Pokémon but are still affected by Pressure.
  def self.targetsFoeSide?(target)
    return target==FoeSide ||
           target==BothSides
  end

  def self.canChooseDistantTarget?(target)
    return target==Other
  end

  # These moves can be redirected to a different target.
  def self.canChooseOneFoeTarget?(target)
    return target==NearFoe ||
           target==NearOther ||
           target==Other ||
           target==RandomNearFoe
  end

  # Used by the AI to avoid targeting an ally with a move if that move could
  # target an opponent instead.
  def self.canChooseFoeTarget?(target)
    return target==NearFoe ||
           target==NearOther ||
           target==Other ||
           target==RandomNearFoe
  end
end

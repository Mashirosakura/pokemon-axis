#===============================================================================
#
#  Birthsigns Journal - By Lucidious89
#  For -Pokémon Essentials v17-
#  Add-On for -Pokémon Birthsigns-
#
#===============================================================================
# This script is meant as an add-on to the Pokémon Birthsigns script.
# This may cause errors if Pokémon Birthsigns is not installed.
#===============================================================================
#  ~Installation~
#===============================================================================
# To install, insert a new section below  the Pokemon Birthsigns script, and 
# paste this there. This is a plug-n-play addition, and doesn't require any 
# other changes.
#
# Use "pbOpenJournal" in an event to call this script.
# Use "pbOpenJournalMini(sign)" in an event to open directly to a specific page
# in the Journal, where "sign" is equal to the desired month number.
#
# This script edits part of PScreen_Pokegear, to allow the Journal to be 
# accessed via the Pokegear. If you have changes to the Pokegear in your project,
# make sure make the necessary adjustments.
#
# Everything below is written for Pokémon Essentials v.17
#===============================================================================

BOSS_RESET = 47

#===============================================================================
# Lore Text
#===============================================================================
def pbGetJournalLore(sign)
  return [_INTL("A world without starlight. An emptiness that spans for eternity. This realm is simply known as The Void. Legends say that Arceus itself was born in this realm, and our universe exploded into being when It burst through The Void and into the realm of matter. That explosion was so immense, that it formed every star in the night sky."),
          _INTL("Prophecy speaks of a trainer who will one day become the very best, like no one ever was. He goes by many names, and his voice is never heard - yet all know who he is. One thing known for sure is that he always has a Pikachu by his side. Many aspiring trainers follow in these footsteps; in hopes to one day fulfill the prophecy."),
          _INTL("An old myth tells of a Luvdisc that swims in the sky, with scales made of stars. These scales would grant its owner everlasting happiness. This tale started a tradition that exists to this day; where lovers would exchange Heart Scales as a symbol of eternal happiness together. In modern times, people use Sweet Hearts instead."),
          _INTL("There is a tale that speaks of an ancient king; lost in the chaos of a great battle. The sky was clouded with smoke; blotting out all but one of the stars in the sky. That one grand star led the king back to his kingdom, where he declared this constellation forever be known as 'The Beacon', and all who are born under it shall bring light to the world."),
          _INTL("A feral Pokémon once preyed upon people in ancient times. Its rage called thunderbolts from the heavens, and its great fangs tore through foes. Battle after battle was waged, but the beast stood undefeated. Until one day, a child skipping pebbles struck the beast by chance. The great beast then fell, and its rampage was no more."),
          _INTL("There were eight brothers who each claimed mastery over an element. Together, they held the world in balance. One day a ninth brother was born, but with no apparent power. Until there was a cataclysm that none of the eight brothers could stop. Out of nowhere the ninth brother appeared and revealed his power - mastery of all elements."),
          _INTL("There was once a traveler who collapsed of starvation. A Pokémon appeared, and shared with her a strange egg. She was revitalized within moments, but the health of the Pokémon declined. The woman did all she could do...but it was too late. As if to honor its memory, the woman went on to become the first Pokémon physician in the world."),
          _INTL("Folklore tells of a beautiful maiden and a mighty gladiator who were deeply in love. But one day a jealous witch wanted the gladiator for herself, so she trapped the maiden in the sky as stardust. The maiden appeared every night to shine as brightly as she could; hoping he would look at her again in the same way he once did. She does so to this day."),
          _INTL("After trapping his lover in the sky, the witch's advances were rejected by the gladiator's iron will. He then traveled the world seeking his beloved; never finding her. Every night, he would look up into the sky and feel her gentle gaze. It's said that upon his passing, he was reborn by Arceus as stardust, to be reunited with his lost love."),
          _INTL("There have been sightings of otherworldly beings throughout history. One ancient region known as Silphonia claimed to have met one such visitor who traveled from a faraway planet (mistakenly thought to be a star in this constellation). Coincidentally, this was the first civilization to develop both Pokéball and warp panel technology."),
          _INTL("Thievery has existed for as long as there have been things to steal. Secret cults dedicated to thievery are found in history. The few that survived all have one thing in common: founding their guild under the starlight of this sign. This superstition has become so pervasive, that it is still practiced by modern gangs such as Team Rocket."),
          _INTL("There lived a king with an appetite so large, his whole kingdom went hungry. The people revolted, but the king had become so fat that no blade could pierce him. But he also couldn't move. The townspeople decided to leave and build a new home, while the old fat king forever reigned on the throne of his empty kingdom; unable to ever leave."),
          _INTL("There is a legend that states that there lives a Pokémon who grants a wish every 1,000 years. Only one such instance has ever been recorded, dating back thousands of years. A ruthless trainer wished for his Pokémon to be immortal. In response, the legendary Pokémon turned all of the man's Pokémon into constellations in the sky."),
          _INTL("One of the myths that is spoken of in the Johto region tells the story of three Pokémon who perished within a burning tower. But there was a majestic bird Pokémon who brought them back to life with its mysterious abilities. Some believe that this Pokémon can still be found flying among the stars; and will grant new life to true believers."),
          _INTL("There was once a particularly dim-witted Slowpoke who forgot how to fish. Confusing his head for his tail, he dunked his face in the water. But as all his friends became Slowbro, he became something else. He was smarter in this form, but no longer belonged. He spent hours theorizing his new purpose as his friends spent their days lounging in peace."),
          _INTL("Rumors of a famous cat burglar known as ‘The Silver Vulpix’ say that there wasn’t any lock she couldn’t break. Recorded instances of her capture describe her escape moments later. No safe could keep her out, and no cage could keep her in. Some say the secret to her lock picking skill was actually the work of a Pokémon."),
          _INTL("Meowth has been revered by many in the past. A symbol of great fortune, and common among nobility. One particularly cruel nobleman was said to order his Meowth to toss coins at peasants for his own entertainment. Despite the injuries, most kept quiet as they picked up the thrown coins. This move was later named ‘Pay Day’."),
          _INTL("Pokémon with healing capabilities have always been held in high esteem throughout history. Even before the first Pokémon Centers, the sick and wounded would meet with a particular Pokémon in town who would treat them. Every town had its own ‘Cleric’, as they became known, and they were perhaps the most respected members of society."),
          _INTL("There lives a sect of monks who secludes themselves from the world. High atop the peaks of Mt. Silver, they take vows of silence and dedicate themselves to meditation. Years go by as they meditate to discover lost knowledge. Rumors say one particularly strong trainer took this vow, and still trains there to this day."),
          _INTL("In forgotten Pokémon lore, there exists ancient warrior bloodlines that date back centuries. It's said that descendants of these bloodlines carry on the battle scars of their ancestors, as well as their strength. Those memories of fierce battles are passed down in an unbroken chain; preparing new generations for war."),
          _INTL("Espionage was a common practice in war, even before the days of modern technology. Spies would carry with them a Pokémon for every situation. However, one of the greatest spies in history only carried a single Pokémon to carry out his missions. That one Pokémon somehow always had the exact tool it needed for the job."),
          _INTL("There are some legends that people fear to this day. One such myth surrounds a dark assassin whose method of attack is impossible to defend against. It attacks you in your dreams. This bogeyman has haunted people for eons. It’s said that when a victim is chosen, the assassin stalks you in the sky; waiting for you to fall asleep."),
          _INTL("There is an old story of a mother who was desperately awaiting her egg to hatch. Centuries passed as she waited atop her egg; completely motionless. One day a great wind pushed the mother off the egg, and the egg rolled from its nest. Frantically, the mother picked up the egg…and with a single step, the egg hatched."),
          _INTL("A Pokémon once lived that evaded all attempts at capture. It out-witted even the most skilled trackers, and would often turn their own traps against them. A bounty was placed on this Pokémon, but it was never turned in. Some think that the Pokémon never even existed. Others say that it was a god in Pokémon form."),
          _INTL("In the primitive times, people made sacrifices to appease the gods. It was believed that if one was truly devout, the gods would bring them back; reborn as new life. The ancient Pokémon, Mew, was the basis of this belief, as it could change into new forms at will. As time went on, the practice was abandoned, but the belief remains."),
          _INTL("Since the early days of music, Pokémon have inspired musicians of all genres. Even in modern times, it is not uncommon to find Pokémon among orchestras and bands to capture a unique sound that no instrument could match. It's thought that Pokémon themselves are innately musical beings, and are the source of all of nature's melodies."),
          _INTL("Before modern medicine, healers would often use the powers of empaths to diagnose illness. Empaths have the ability to share the same feelings and emotions of others. By using this power on patients, it not only helped narrow down symptoms, but it gave people a greater sense of compassion for those they treated."),
          _INTL("A noble prince was once trapped in a mirror by a powerful sorcerer. The sorcerer intended to steal the prince's image, so that he may rule in his place. However, he overlooked a small detail. The sorcerer's disguise was mirrored. Thus, his imitation of the prince's uniquely colored eyes were inverted, and exposed him as a fraud."),
          _INTL("A strategist's greatest skill is knowing when to retreat. There's no better example than the battle for Snowpoint City during the Great War. As invaders pushed past Mt.Coronet, the remaining Sinnohian forces fled north. The invaders took the bait, and gave chase. They would learn too late the harsh northern climates of Sinnoh..."),
          _INTL("It was once said that those born under this sign were born cursed; destined to bring misfortune upon themselves their entire lives. Over the years, this superstition became less ominous, and in fact many born with this sign think of it as an ironic badge of pride. This softer take on the lore was the inspiration for many early comedies."),
          _INTL("Alchemy is a lost art that is equal parts science and mysticism. By utilizing Stardust, alchemists could transmute ordinary stones into golden nuggets. However, people saw alchemy as an evil witchcraft, so the practice was soon lost. Experts believe that Poké Ball craftsmanship is actually the lone surviving branch of alchemy."),
          _INTL("Records date back centuries of a rare illness that plagued small villages. No one knows where it came from, but the symptoms are clear. The paleness of the skin. Aversion to sunlight. An unquenchable thirst. Some truly gruesome folktales behind this mysterious illness trickled down through the ages. We can only hope none of it is true."),
          _INTL("Though actually two constellations, they are always referred to as a single unit. Astronomers have always been fascinated by the bizarre perfection the two share. So much so that if just one of the stars were subtly moved out of position, the gravity of both clusters would rip themselves into dust. One simply could not exist without the other."),
          _INTL("Humanity has always looked up at the stars for guidance. Many learn to find their way by following the light. Others, however, instead find the darkness. The void between the lights. It's in this darkness that ancient horrors lurk, waiting to be called into the realm of light. Some such fools invite the darkness in, and pay the ultimate price."),
          _INTL("This sign once held a lot of respect, and was thought to be a sign of nobility. However, its reputation soured as it became associated with former Kanto Gym Leader, Giovanni, who secretly ran a criminal empire. After being exposed to the public, the superstitious claimed that this sign marked a proclivity towards criminal behavior."),
          _INTL("Back in times of old, this sign was known as ‘The Imp’, and was often blamed for all kinds of witchcraft. Over time, attitudes towards this sign changed, and its original name was forgotten. Today, it's perceived as more mischievous than evil. Some even find that it brings them good luck in mundane ways, such as finding a lost sock or loose change."),
          _INTL("This constellation is mentioned in the earliest records of history. Legends associated with it have stood the test of time. Curiously, the constellation seems to spontaneously change shape and appearance in the sky from one record to the next. Most agree that the historians of old must simply have been mistaken. Perhaps not. Who knows...")
          ][sign]
end

#===============================================================================
# Effect Text
#===============================================================================
def pbGetJournalEffect(sign)
  return [_INTL("No effects."),
          _INTL("The Pokémon inherits a strong work ethic. Gains double EV's from battle."),
          _INTL("The Pokémon inherits a joyful presence; doubling the base happiness of wild Pokémon."),
          _INTL("The Pokémon inherits the 'Starlight' skill; lighting dark areas with the glow of stars."),
          _INTL("The Pokémon inherits the maximum IV's in Attack, Sp.Atk, & Speed; but the HP IV is 0."),
          _INTL("The Pokémon inherits the 'Ability Swap' skill; allowing it to swap abilities if able."),
          _INTL("The Pokémon inherits the 'Charity' skill; sacrificing its own HP to restore an ally's."),
          _INTL("The Pokémon inherits striking beauty. Grants 150 Sp.Atk EV's. Likely to be female."),
          _INTL("The Pokémon inherits a mighty presence. Grants 150 Attack EV's. Likely to be male."),
          _INTL("The Pokémon inherits the 'Navigate' skill; using stars to lead its trainer to safety."),
          _INTL("The Pokémon inherits an eye for treasure. May find wild Pokémon holding rare loot."),
          _INTL("The Pokémon inherits the maximum IV's in Defense, Sp.Def, & HP; but the Speed IV is 0."),
          _INTL("The Pokémon inherits extreme luck, and has higher than normal odds of being shiny."),
          _INTL("The Pokémon inherits the 'Rebirth' skill; allowing it to restore itself from fainting."),
          _INTL("The Pokémon inherits exponential growth. It gains 20% more experience from battles."),
          _INTL("The Pokémon inherits the 'Escape' skill; allowing it to flee from any dungeon."),
          _INTL("The Pokémon inherits insatiable greed. Increases prize money from battles by 20%."),
          _INTL("The Pokémon inherits the 'Cure' skill; sacrificing its own HP to heal an ally's status."),
          _INTL("The Pokémon inherits the 'Trance' skill; allowing it to meditate to alter its moves."),
          _INTL("The Pokémon inherits the 'Endow' skill; allowing it to pass on its EV's to an ally."),
          _INTL("The Pokémon inherits the 'Re-roll' skill; allowing it to roll for a new Hidden Power."),
          _INTL("The Pokémon inherits a silent disposition. Wild Pokémon it encounters may be asleep."),
          _INTL("The Pokémon inherits the 'Incubate' skill; allowing it to immediately hatch eggs."),
          _INTL("The Pokémon inherits keen tracking skills. Boosts capture rates by 20% when leading."),
          _INTL("The Pokémon inherits the 'Reincarnate' skill. It may start over under a new birthsign!"), 
          _INTL("The Pokémon inherits the 'Harmonize' skill; luring or repelling wild Pokémon with song."),
          _INTL("The Pokémon inherits the 'Bond' skill; allowing it to take on a party member's Nature."),
          _INTL("The Pokémon inherits adaptive qualities. It may find wild Pokémon with similar IV's."),
          _INTL("The Pokémon inherits the 'Gambit' skill; allowing it to reallocate its EV's."),
          _INTL("The Pokémon inherits the 'Lunacy' skill; raising an ally's level by reducing its own."),
          _INTL("The Pokémon inherits the 'Transmute' skill; morphing its held item into a new one."),
          _INTL("The Pokémon inherits a weakness to daylight, but heals while walking at night."),
          _INTL("The Pokémon inherits a friendly aura. Easily finds wild Pokémon with partner signs."),
          _INTL("The Pokémon inherits the 'Summon' skill; letting it call shadow Pokémon from the void."),
          _INTL("The Pokémon inherits a ruthlessness that cuts you a 25% cash bonus when shopping."),
          _INTL("The Pokémon inherits the 'Sniff Out' skill; detecting the number of nearby items."),
          _INTL("The Pokémon inherits the 'Timeskip' skill, & may skip through its evolutionary history.")
          ][sign]
end 

def pbGetJournalExtra(sign)
  return [_INTL(""),
          _INTL("*Bonuses from this sign stacks with similar effects."),
          _INTL("*The user's base happiness is also doubled."),
          _INTL("*This will replace 'Flash' in the menu if both are present."),
          _INTL("*When hatched with this sign, IV inheritance may be overridden by this effect."),
          _INTL("*Otherwise gets 'Ability Lure', which may lure wild Pokémon with their Hidden Ability."),
          _INTL("*Certain Pokémon may sacrifice PP to recover the party's HP instead."),
          _INTL("*May also encounter male Pokémon in the wild more frequently if the user is female."),
          _INTL("*May also encounter female Pokémon in the wild more frequently if the user is male."),
          _INTL("*This will replace 'Teleport' in the menu if both are present."),
          _INTL("*May also automatically obtain items held by wild Pokémon upon defeating them."),
          _INTL("*When hatched with this sign, IV inheritance may be overridden by this effect."),
          _INTL("*Bonuses from this sign stacks with similar effects."),
          _INTL("*May occasionally revive with full HP. May also find Sacred Ash upon reviving."),
          _INTL("*Bonuses from this sign stacks with similar effects."),
          _INTL("*This will replace 'Dig' in the menu if both are present."),
          _INTL("*Stacks with similar effects. May also find money after wild battles."),
          _INTL("*Certain Pokémon may sacrifice PP to restore the party's status instead."),
          _INTL("*May select one of three mantras to restore PP, relearn moves, or delete one."),
          _INTL("*If able, eggs yielded by the Pokémon will also inherit its EV's."),
          _INTL("*The quality of re-rolled IV's improves when used at higher levels."),
          _INTL("*The odds of encountering sleeping Pokémon are higher during nighttime."),
          _INTL("*Eggs will also hatch at a faster rate when a Pokémon with this sign is in the party."),
          _INTL("*Bonuses from this sign stacks with similar effects."),
          _INTL("*Reincarnating resets many of the user's attributes."), 
          _INTL("*May select one of three songs to lure, repel, or seek out rare species."),
          _INTL("*May encounter wild Pokémon that share the same nature as the user when leading."),
          _INTL("*Each IV of the encountered Pokémon has a 50% chance to be shared by the user."),
          _INTL("*The user's EV's must already be maxed to utilize this skill."),
          _INTL("*The minimum level required to utilize this skill scales with your progress."),
          _INTL("*The new item created depends on the initial item. Some items may not be morphed."),
          _INTL("*Leading in the day hurts & burns. At night, Pokémon with this sign recover HP/PP."),
          _INTL("*This effect overrides whatever sign wild Pokémon would otherwise have normally."),
          _INTL("*The Pokémon summoned depends on user's Summon Rank, determined by level/IV's."),
          _INTL("*The minimum level required to maintain this bonus scales with your progress."),
          _INTL("*While walking, Pokémon with this sign may also find items based on the environment."),
          _INTL("*Pokémon that cannot evolve may learn moves one level earlier during battles.")
          ][sign]
end 

#=============================================================================
# Zodiac Power Text
#=============================================================================
def pbGetJournalPower(sign)
  return [_INTL("The user makes an unconvincing display of power that has no actual effect."),
          _INTL("The user copies its partner's stat changes; otherwise targets the nearest foe."),
          _INTL("Skips turn to give its partner a Helping Hand & negates foe's Protect effects."),
          _INTL("The user lowers accuracy of foes by 1 stage and causes them to flinch."),
          _INTL("The user sacrifices up to half its HP to boost Attack, Sp.Atk, and Speed."),
          _INTL("The user copies a foe's Ability, and then suppresses the abilities of foes."),
          _INTL("The user gives 50% of its max HP to heal its partner, or 100% to heal an incoming ally."),
          _INTL("Increases the user's Sp.Atk & Sp.Def. Either infatuates or confuses foes, if able."),
          _INTL("Increases the user's Attack & Defense. Challenges foes with a taunt for two turns."),
          _INTL("The user forces the nearest viable foe to switch out. Immediately ends wild battles."),
          _INTL("The user attempts to steal an foe's item. Speed increases if successful."),
          _INTL("The user gorges itself on random berries, consecutively activating their effects."),
          _INTL("Randomly boosts one of the user's stats by two stages."),
          _INTL("The user cuts its Attack & Speed in order to maximize Defense and fully replenish HP."),
          _INTL("The user cleverly reverses its status onto foes, and snatches their status moves."),
          _INTL("The user switches out upon acting. This still works even if the action failed."),
          _INTL("The user prevents foes from utilizing item effects for 5 turns."),
          _INTL("The user consecrates the ground with Misty Terrain, & heals any status conditions."),
          _INTL("Fully restores PP, and cures mental afflictions. Opponents become identified."),
          _INTL("The party gains the effects of Reflect and Light Screen for 5 turns."),
          _INTL("Any moves foes share with the user become sealed, and may not be used."),
          _INTL("Damages all foes by up to 1/4th their max HP. Double damage on sleeping foes."),
          _INTL("The user redirects attacks to itself in a double battle, and gains Parental Bond."),
          _INTL("The user strikes quickly with its selected move, before the opponent switches out."),
          _INTL("The user triggers the effect of another birthsign's Zodiac Power at random."),
          _INTL("The user sings a song based on its highest stat which lowers the stats of foes."),
          _INTL("The user splits the pain of all Pokémon on the field to be shared equally."),
          _INTL("The user transforms its appearance to match the a foe, but keeps its moves."),
          _INTL("Lowered stats of allies and raised stats of foes return to normal."),
          _INTL("Randomly lowers a stat & raises another by 2 stages each for both the user & a foe."),
          _INTL("Morphs the held items of foes into potentially useless or harmful ones."),
          _INTL("Halves a foe's HP and heals the user by the same amount of damage dealt."),
          _INTL("If allies have partner signs: Rainbow effect & gain Plus/Minus. Perish Song if rivals."),
          _INTL("The user sacrifices half of its total HP to lay a curse on all foes."),
          _INTL("The user pays off a foe with a monetary bribe to ensure it won't act this turn."),
          _INTL("The user adapts itself to its environment; changing its type, ability, and item."),
          _INTL("The user borrows attributes from future/past evolutionary forms. Heals otherwise.")
          ][sign]
end 

#=============================================================================
# Effect Type Text (Passive, Skill, etc.)
#=============================================================================
def pbGetEffectType(sign)
  return [_INTL("None"),             # Void
          _INTL("Passive"),          # Apprentice
          _INTL("Party Lead"),       # Companion
          _INTL("Command"),          # Beacon
          _INTL("Passive"),          # Savage
          _INTL("Command"),          # Prodigy
          _INTL("Command"),          # Martyr
          _INTL("Passive"),          # Maiden
          _INTL("Passive"),          # Gladiator
          _INTL("Command"),          # Voyager
          _INTL("Party Lead"),       # Thief
          _INTL("Passive"),          # Glutton
          _INTL("Passive"),          # Wishmaker
          _INTL("Command"),          # Phoenix
          _INTL("Passive"),          # Scholar
          _INTL("Command"),          # Fugitive
          _INTL("Party Lead"),       # Aristocrat
          _INTL("Command"),          # Cleric
          _INTL("Command"),          # Monk
          _INTL("Command"),          # Ancestor
          _INTL("Command"),          # Specialist
          _INTL("Party Lead"),       # Assassin
          _INTL("Command"),          # Parent
          _INTL("Party Lead"),       # Hunter
          _INTL("Command"),          # Eternal
          _INTL("Command"),          # Bard
          _INTL("Command"),          # Empath
          _INTL("Party Lead"),       # Mirror
          _INTL("Command"),          # Tactician
          _INTL("Command"),          # Fool
          _INTL("Command"),          # Alchemist
          _INTL("Movement"),         # Vampire
          _INTL("Party Lead"),       # Soulmate
          _INTL("Command"),          # Cultist
          _INTL("Party Lead"),       # Racketeer
          _INTL("Command"),          # Scavenger
          _INTL("Command")           # Timelord
          ][sign]
end 
  
#=============================================================================
# Zodiac Target text (Self, Partner, Foe, etc)
#=============================================================================
def pbGetPowerTarget(sign)
  return [_INTL("None"),             # Void
          _INTL("Partner; Foe"),     # Apprentice
          _INTL("Partner, Foes"),    # Companion
          _INTL("Foes"),             # Beacon
          _INTL("Self"),             # Savage
          _INTL("Foes"),             # Prodigy
          _INTL("Partner; Ally"),    # Martyr
          _INTL("Self, Foes"),       # Maiden
          _INTL("Self, Foes"),       # Gladiator
          _INTL("Foe"),              # Voyager
          _INTL("Foe"),              # Thief
          _INTL("Self"),             # Glutton
          _INTL("Self"),             # Wishmaker
          _INTL("Self"),             # Phoenix
          _INTL("Foes"),             # Scholar
          _INTL("Self"),             # Fugitive
          _INTL("Foes"),             # Aristocrat
          _INTL("Self, Partner"),    # Cleric
          _INTL("Self"),             # Monk
          _INTL("Party"),            # Ancestor
          _INTL("Foes"),             # Specialist
          _INTL("Foes"),             # Assassin
          _INTL("Partner, Self"),    # Parent
          _INTL("Foe"),              # Hunter
          _INTL("???"),              # Eternal
          _INTL("Foes"),             # Bard
          _INTL("All"),              # Empath
          _INTL("Foe, Self"),        # Mirror
          _INTL("All"),              # Tactician
          _INTL("Self, Foe"),        # Fool
          _INTL("Foes"),             # Alchemist
          _INTL("Foe"),              # Vampire
          _INTL("Party; All"),       # Soulmate
          _INTL("Foes"),             # Cultist
          _INTL("Foe"),              # Racketeer
          _INTL("Self"),             # Scavenger
          _INTL("Self")              # Timelord
          ][sign]
end 

#===============================================================================
# Birthsign Journal
#===============================================================================
class BirthsignJournalScene
  BASECOLOR  = Color.new(248,248,248)
  SHADOWCOLOR = Color.new(0,0,0)
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    return
  end
  
  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    blesstoken="Graphics/Pictures/Birthsigns/bless_token%02d"
    @sprites["bg"] = IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalbg")
    @sprites["ball"] = IconSprite.new(0,0,@viewport)
    @sprites["ball"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalball")
    janCelestial=false
    febCelestial=false
    marCelestial=false
    aprCelestial=false
    mayCelestial=false
    junCelestial=false
    julCelestial=false
    augCelestial=false
    sepCelestial=false
    octCelestial=false
    novCelestial=false
    decCelestial=false
    for i in 0...12
      janCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[0]
      febCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[1]
      marCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[2]
      aprCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[3]
      mayCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[4]
      junCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[5]
      julCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[6]
      augCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[7]
      sepCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[8]
      octCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[9]
      novCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[10]
      decCelestial=true if $PokemonGlobal.celestialboss[i]==$PokemonGlobal.zodiacset[11]
    end
    if $PokemonGlobal.omegaboss==true
      @sprites["starlines"] = IconSprite.new(0,0,@viewport)
      @sprites["starlines"].setBitmap("Graphics/Pictures/Birthsigns/Other/starlines")
      @sprites["omega"] = IconSprite.new(0,0,@viewport)
      @sprites["omega"].setBitmap("Graphics/Pictures/Birthsigns/Other/omega")
      @sprites["omegasel"] = IconSprite.new(0,0,@viewport)
      @sprites["omegasel"].visible=false
      @sprites["omegasel"].setBitmap("Graphics/Pictures/Birthsigns/Other/omegaselect")
      @sprites["omegatitle"] = IconSprite.new(0,0,@viewport)
      @sprites["omegatitle"].setBitmap("Graphics/Pictures/Birthsigns/Other/omegatitle")
    end
    @sprites["jan"] = IconSprite.new(221+(RXMOD/2),-6+(RYMOD/2),@viewport)
    @sprites["jan"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[0]))
    @sprites["jan"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[0])) if janCelestial
    @sprites["feb"] = IconSprite.new(300+(RXMOD/2),19+(RYMOD/2),@viewport)
    @sprites["feb"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[1]))
    @sprites["feb"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[1])) if febCelestial
    @sprites["mar"] = IconSprite.new(361+(RXMOD/2),77+(RYMOD/2),@viewport)
    @sprites["mar"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[2]))
    @sprites["mar"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[2])) if marCelestial
    @sprites["apr"] = IconSprite.new(382+(RXMOD/2),157+(RYMOD/2),@viewport)
    @sprites["apr"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[3]))
    @sprites["apr"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[3])) if aprCelestial
    @sprites["may"] = IconSprite.new(361+(RXMOD/2),236+(RYMOD/2),@viewport)
    @sprites["may"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[4]))
    @sprites["may"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[4])) if mayCelestial
    @sprites["jun"] = IconSprite.new(300+(RXMOD/2),295+(RYMOD/2),@viewport)
    @sprites["jun"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[5]))
    @sprites["jun"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[5])) if junCelestial
    @sprites["jul"] = IconSprite.new(221+(RXMOD/2),320+(RYMOD/2),@viewport)
    @sprites["jul"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[6]))
    @sprites["jul"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[6])) if julCelestial
    @sprites["aug"] = IconSprite.new(142+(RXMOD/2),295+(RYMOD/2),@viewport)
    @sprites["aug"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[7]))
    @sprites["aug"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[7])) if augCelestial
    @sprites["sep"] = IconSprite.new(81+(RXMOD/2),236+(RYMOD/2),@viewport)
    @sprites["sep"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[8]))
    @sprites["sep"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[8])) if sepCelestial
    @sprites["oct"] = IconSprite.new(60+(RXMOD/2),157+(RYMOD/2),@viewport)
    @sprites["oct"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[9]))
    @sprites["oct"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[9])) if octCelestial
    @sprites["nov"] = IconSprite.new(81+(RXMOD/2),78+(RYMOD/2),@viewport)
    @sprites["nov"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[10]))
    @sprites["nov"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[10])) if novCelestial
    @sprites["dec"] = IconSprite.new(142+(RXMOD/2),19+(RYMOD/2),@viewport)
    @sprites["dec"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[11]))
    @sprites["dec"].setBitmap(sprintf(blesstoken,$PokemonGlobal.zodiacset[11])) if decCelestial
    #===========================================================================
    # Draws highlights, arrows, and names
    #===========================================================================
    @sprites["select"] = IconSprite.new(-100,0,@viewport)
    @sprites["selrival"] = IconSprite.new(-100,0,@viewport)
    @sprites["selpartner1"] = IconSprite.new(-100,0,@viewport)
    @sprites["selpartner2"] = IconSprite.new(-100,0,@viewport)
    @sprites["arrow"] = IconSprite.new(-100,0,@viewport)
    @sprites["select"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalselect")
    @sprites["selrival"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalsel_rival")
    @sprites["selpartner1"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalsel_partner")
    @sprites["selpartner2"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalsel_partner")
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize("",0+RXMOD,159+RYMOD,300,64,@viewport)
    @sprites["title"].baseColor=BASECOLOR
    @sprites["title"].shadowColor=SHADOWCOLOR
    @sprites["title"].windowskin=nil
    #===========================================================================
    # Draws extra data
    #===========================================================================
    @sprites["info"] = IconSprite.new(0,0,@viewport)
    @sprites["info"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalinfo")
    @sprites["time"]=Window_AdvancedTextPokemon.newWithSize("",-8,-18,300,64,@viewport)
    @sprites["time"].baseColor=BASECOLOR
    @sprites["time"].shadowColor=SHADOWCOLOR
    @sprites["time"].windowskin=nil
    pbSetExtraSmallFont(@sprites["time"].contents)
    @sprites["time"].text=_INTL("{1} {2}, {3}",pbGetMonthName(Time.now.mon),Time.now.day,Time.now.year)
    @sprites["bosscount"]=Window_AdvancedTextPokemon.newWithSize("",-14,7,300,64,@viewport)
    @sprites["bosscount"].baseColor=BASECOLOR
    @sprites["bosscount"].shadowColor=SHADOWCOLOR
    @sprites["bosscount"].windowskin=nil
    pbSetExtraSmallFont(@sprites["bosscount"].contents)
    @sprites["bosscount"].text=_INTL("Celestials Battled: {1}",getBossNum) if getBossNum>0
    @sprites["bossname"]=Window_AdvancedTextPokemon.newWithSize("",-14,23,300,64,@viewport)
    @sprites["bossname"].baseColor=BASECOLOR
    @sprites["bossname"].shadowColor=SHADOWCOLOR
    @sprites["bossname"].windowskin=nil
    pbSetExtraSmallFont(@sprites["bossname"].contents)
    @sprites["current"]=Window_AdvancedTextPokemon.newWithSize("",418+RXMOD,-22,300,64,@viewport)
    @sprites["current"].baseColor=BASECOLOR
    @sprites["current"].shadowColor=SHADOWCOLOR
    @sprites["current"].windowskin=nil
    pbSetExtraSmallFont(@sprites["current"].contents)
    @sprites["current"].text=_INTL("Current Sign")
    @sprites["trainer"]=Window_AdvancedTextPokemon.newWithSize("",-14,342+RYMOD,300,64,@viewport)
    @sprites["trainer"].baseColor=BASECOLOR
    @sprites["trainer"].shadowColor=SHADOWCOLOR
    @sprites["trainer"].windowskin=nil
    pbSetExtraSmallFont(@sprites["trainer"].contents)
    @sprites["trainer"].text=_INTL("{1}'s Sign",$Trainer.name)
    @sprites["party"]=Window_AdvancedTextPokemon.newWithSize("",384+RXMOD,312+RYMOD,300,64,@viewport)
    @sprites["party"].baseColor=BASECOLOR
    @sprites["party"].shadowColor=SHADOWCOLOR
    @sprites["party"].windowskin=nil
    pbSetExtraSmallFont(@sprites["party"].contents)
    @sprites["party"].text=_INTL("Pokémon with sign")
    @sprites["curtoken"] = IconSprite.new(445+RXMOD,11,@viewport)
    @sprites["curtoken"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[Time.now.mon-1]))
    @sprites["trtoken"] = IconSprite.new(-3,303+RYMOD,@viewport)
    @sprites["trtoken"].setBitmap(sprintf(tokenpath,$Trainer.birthsign))
    @sprites["trtoken"].setBitmap(sprintf(blesstoken,$Trainer.birthsign)) if $Trainer.isBlessed?
    @sprites["select2"] = IconSprite.new(-100,0,@viewport)
    @sprites["select2"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalselect")
    @sprites["select3"] = IconSprite.new(-100,0,@viewport)
    @sprites["select3"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalselect")
    @sprites["select4"] = IconSprite.new(-100,0,@viewport)
    @sprites["select4"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalselect")
    for i in 0...$Trainer.party.length
      @sprites["pkmnsprite#{i}"]=PokemonIconSprite.new($Trainer.party[i],@viewport)
      @sprites["pkmnsprite#{i}"].visible=false
      @sprites["pkmnsprite#{i}"].x=(182*2+12*2*(i))+RXMOD-48
      @sprites["pkmnsprite#{i}"].y=352+RYMOD
      @sprites["pkmnsprite#{i}"].zoom_x=0.5
      @sprites["pkmnsprite#{i}"].zoom_y=0.5
    end
  end
  
#===============================================================================
# Draws Zodiac Wheel
#===============================================================================
  def pbBirthsignJournal(menu_index = 0)
    @menu_index = menu_index
    @choices=[
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
        _INTL("Exit")
    ]
    @sprites["list"] = Window_CommandPokemon.new(@choices,0)
    @sprites["list"].index = @menu_index
    @sprites["list"].visible = false
    #===========================================================================
    # Selection loop
    #===========================================================================
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      pbUpdate
      signlist=@sprites["list"].index
      for i in 0...$Trainer.party.length
        if $Trainer.party[i].birthsign==$PokemonGlobal.zodiacset[signlist]
          @sprites["pkmnsprite#{i}"].visible=true
        else
          @sprites["pkmnsprite#{i}"].visible=false
        end
      end
      arrow000="Graphics/Pictures/Birthsigns/Other/journalArrow0"
      arrow030="Graphics/Pictures/Birthsigns/Other/journalArrow30"
      arrow060="Graphics/Pictures/Birthsigns/Other/journalArrow60"
      arrow090="Graphics/Pictures/Birthsigns/Other/journalArrow90"
      arrow120="Graphics/Pictures/Birthsigns/Other/journalArrow120"
      arrow150="Graphics/Pictures/Birthsigns/Other/journalArrow150"
      arrow180="Graphics/Pictures/Birthsigns/Other/journalArrow180"
      @sprites["arrow"].setBitmap(arrow000) if signlist==0
      @sprites["arrow"].setBitmap(arrow030) if signlist==1 || signlist==11
      @sprites["arrow"].setBitmap(arrow060) if signlist==2 || signlist==10
      @sprites["arrow"].setBitmap(arrow090) if signlist==3 || signlist==9
      @sprites["arrow"].setBitmap(arrow120) if signlist==4 || signlist==8
      @sprites["arrow"].setBitmap(arrow150) if signlist==5 || signlist==7
      @sprites["arrow"].setBitmap(arrow180) if signlist==6
      @sprites["arrow"].mirror     = false if signlist<6
      @sprites["arrow"].mirror     = true if signlist>6
      @sprites["select2"].x        = -100
      @sprites["select2"].y        = 0
      @sprites["select3"].x        = -100
      @sprites["select3"].y        = 0
      @sprites["select4"].x        = -100
      @sprites["select4"].y        = 0
      @sprites["omegasel"].visible = false if $PokemonGlobal.omegaboss==true
      if signlist>11 || signlist==nil
        if $PokemonGlobal.omegaboss==true
          @sprites["omegasel"].visible=true
          @sprites["select"].x       = -100
          @sprites["select"].y       = 0
        else
          @sprites["select"].x       = 222+(RXMOD/2)
          @sprites["select"].y       = 155+(RYMOD/2)
        end
        @sprites["selrival"].x     = -100
        @sprites["selrival"].y     = 0
        @sprites["selpartner1"].x  = -100
        @sprites["selpartner1"].y  = 0
        @sprites["selpartner2"].x  = -100
        @sprites["selpartner2"].y  = 0
        @sprites["arrow"].x        = -100
        @sprites["arrow"].y        = 0
        @sprites["title"].x        = 220+(RXMOD/2)
        @sprites["title"].text     =_INTL("Exit")
        @sprites["bossname"].text  =_INTL("")
        if Input.trigger?(Input::C)
          pbPlayCancelSE
          pbFadeOutIn(99999) {
          Input.update
          pbEndScene
          }
          return
        end
      else
        rx=RXMOD/2
        ry=RYMOD/2
        arrowvaluesx=[241+rx,296+rx,343+rx,356+rx,339+rx,297+rx,241+rx,182+rx,143+rx,127+rx,141+rx,186+rx]
        arrowvaluesy=[63+ry,79+ry,125+ry,182+ry,236+ry,271+ry,286+ry,271+ry,234+ry,182+ry,123+ry,78+ry]
        selectvaluesx=[221+rx,300+rx,361+rx,382+rx,361+rx,300+rx,221+rx,142+rx,81+rx,60+rx,81+rx,142+rx]
        selectvaluesy=[-6+ry,19+ry,77+ry,157+ry,236+ry,295+ry,320+ry,295+ry,236+ry,157+ry,78+ry,19+ry]
        rivalsel=(signlist+6)%12
        partner1sel=(signlist+4)%12
        partner2sel=(signlist+8)%12
        cursignsel=Time.now.mon-1
        trsignsel=$Trainer.monthsign
        bossname=$PokemonGlobal.zodiacset[signlist]
        bossbattled=$PokemonGlobal.celestialboss[signlist]
        @sprites["arrow"].x        = arrowvaluesx[signlist]
        @sprites["arrow"].y        = arrowvaluesy[signlist]
        @sprites["select"].x       = selectvaluesx[signlist]
        @sprites["select"].y       = selectvaluesy[signlist]
        @sprites["selrival"].x     = selectvaluesx[rivalsel]
        @sprites["selrival"].y     = selectvaluesy[rivalsel]
        @sprites["selpartner1"].x  = selectvaluesx[partner1sel]
        @sprites["selpartner1"].y  = selectvaluesy[partner1sel]
        @sprites["selpartner2"].x  = selectvaluesx[partner2sel]
        @sprites["selpartner2"].y  = selectvaluesy[partner2sel]
        @sprites["title"].text     = PBBirthsigns.getName($PokemonGlobal.zodiacset[signlist])
        textlength                 = @sprites["title"].text.length
        @sprites["title"].x        = (242-textlength*6)+RXMOD/2
        for i in 0...textlength; @sprites["title"].x+=1; end
        for i in 1...textlength
          if ['i','j','l','1','!'].include?(@sprites["title"].text[i,1])
            @sprites["title"].x += 2
          end
          if [' '].include?(@sprites["title"].text[i,1])
            @sprites["title"].x -= 4
          end
        end
        @sprites["select3"].x      = @sprites["curtoken"].x if signlist==cursignsel
        @sprites["select3"].y      = @sprites["curtoken"].y if signlist==cursignsel
        @sprites["select4"].x      = @sprites["trtoken"].x if signlist==trsignsel
        @sprites["select4"].y      = @sprites["trtoken"].y if signlist==trsignsel
        if getBossNum>0
          @sprites["bossname"].text=_INTL("Celestial: {1}",pbGetBossName(bossname))
          @sprites["bossname"].text=_INTL("Celestial: ??????") if bossbattled==nil
          @sprites["omegasel"].visible=false if $PokemonGlobal.omegaboss==true
        end
        if Input.trigger?(Input::C)
          pbOpenBirthsignPage
        end
      end
      if Input.trigger?(Input::LEFT)
        pbPlayDecisionSE
        @sprites["list"].index=(@sprites["list"].index+=6)%12
      elsif Input.trigger?(Input::RIGHT)
        pbPlayDecisionSE
        @sprites["list"].index=(@sprites["list"].index+=4)%12
      end
      if Input.trigger?(Input::B) 
        pbPlayCancelSE
        pbFadeOutIn(99999) {
        Input.update
        pbEndScene
        }
        return
      end
      # Boss Counter Toggle
      if Input.trigger?(Input::CTRL) && $DEBUG
        if getBossNum==0
          for i in 0...12; $PokemonGlobal.celestialboss[i]=$PokemonGlobal.zodiacset[i]; end
          Kernel.pbMessage(_INTL("Boss counter maxed."))
        else
          pbBossCountReset
          $PokemonGlobal.omegaboss=false
          Kernel.pbMessage(_INTL("Boss counter reset."))
        end
        pbFadeOutIn(99999) {
        Input.update
        pbEndScene
        }
        return
      end
      #=========================================================================
      # Mouse Module compatibility
      #=========================================================================
      if defined?($mouse)
        oldsign=@sprites["list"].index
        if $mouse.over?(@sprites["curtoken"])
          if signlist!=(Time.now.mon-1)
            @sprites["select2"].x       = @sprites["curtoken"].x
            @sprites["select2"].y       = @sprites["curtoken"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=(Time.now.mon-1)
            pbOpenBirthsignPage if signlist==(Time.now.mon-1)
            @sprites["list"].index=(Time.now.mon-1)
          end
        elsif $mouse.over?(@sprites["trtoken"]) && $Trainer.hasZodiacsign?
          if signlist!=$Trainer.monthsign
            @sprites["select2"].x       = @sprites["trtoken"].x
            @sprites["select2"].y       = @sprites["trtoken"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=$Trainer.monthsign
            pbOpenBirthsignPage if signlist==$Trainer.monthsign
            @sprites["list"].index=$Trainer.monthsign
          end
        elsif $mouse.over?(@sprites["jan"])
          if signlist!=0
            @sprites["select2"].x       = @sprites["jan"].x
            @sprites["select2"].y       = @sprites["jan"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=0
            pbOpenBirthsignPage if signlist==0
            @sprites["list"].index=0
          end
        elsif $mouse.over?(@sprites["feb"])
          if signlist!=1
            @sprites["select2"].x       = @sprites["feb"].x
            @sprites["select2"].y       = @sprites["feb"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=1
            pbOpenBirthsignPage if signlist==1
            @sprites["list"].index=1
          end
        elsif $mouse.over?(@sprites["mar"])
          if signlist!=2
            @sprites["select2"].x       = @sprites["mar"].x
            @sprites["select2"].y       = @sprites["mar"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=2
            pbOpenBirthsignPage if signlist==2
            @sprites["list"].index=2
          end
        elsif $mouse.over?(@sprites["apr"])
          if signlist!=3
            @sprites["select2"].x       = @sprites["apr"].x
            @sprites["select2"].y       = @sprites["apr"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=3
            pbOpenBirthsignPage if signlist==3
            @sprites["list"].index=3
          end
        elsif $mouse.over?(@sprites["may"])
          if signlist!=4
            @sprites["select2"].x       = @sprites["may"].x
            @sprites["select2"].y       = @sprites["may"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=4
            pbOpenBirthsignPage if signlist==4
            @sprites["list"].index=4
          end
        elsif $mouse.over?(@sprites["jun"])
          if signlist!=5
            @sprites["select2"].x       = @sprites["jun"].x
            @sprites["select2"].y       = @sprites["jun"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=5
            pbOpenBirthsignPage if signlist==5
            @sprites["list"].index=5
          end
        elsif $mouse.over?(@sprites["jul"])
          if signlist!=6
            @sprites["select2"].x       = @sprites["jul"].x
            @sprites["select2"].y       = @sprites["jul"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=6
            pbOpenBirthsignPage if signlist==6
            @sprites["list"].index=6
          end
        elsif $mouse.over?(@sprites["aug"])
          if signlist!=7
            @sprites["select2"].x       = @sprites["aug"].x
            @sprites["select2"].y       = @sprites["aug"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=7
            pbOpenBirthsignPage if signlist==7
            @sprites["list"].index=7
          end
        elsif $mouse.over?(@sprites["sep"])
          if signlist!=8
            @sprites["select2"].x       = @sprites["sep"].x
            @sprites["select2"].y       = @sprites["sep"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=8
            pbOpenBirthsignPage if signlist==8
            @sprites["list"].index=8
          end
        elsif $mouse.over?(@sprites["oct"])
          if signlist!=9
            @sprites["select2"].x       = @sprites["oct"].x
            @sprites["select2"].y       = @sprites["oct"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=9
            pbOpenBirthsignPage if signlist==9
            @sprites["list"].index=9
          end
        elsif $mouse.over?(@sprites["nov"])
          if signlist!=10
            @sprites["select2"].x       = @sprites["nov"].x
            @sprites["select2"].y       = @sprites["nov"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=10
            pbOpenBirthsignPage if signlist==10
            @sprites["list"].index=10
          end
        elsif $mouse.over?(@sprites["dec"])
          if signlist!=11
            @sprites["select2"].x       = @sprites["dec"].x
            @sprites["select2"].y       = @sprites["dec"].y
          end
          if $mouse.click?
            pbPlayDecisionSE if signlist!=11
            pbOpenBirthsignPage if signlist==11
            @sprites["list"].index=11
          end
        end
        if $PokemonGlobal.omegaboss==true && $mouse.overPixel?(@sprites["omega"])
          if signlist!=12
            @sprites["omegasel"].visible=true
            @sprites["select2"].x       = -100
            @sprites["select2"].y       = 0
            @sprites["title"].x         = 220+(RXMOD/2)
            @sprites["title"].text      =_INTL("Exit")
          end
          if $mouse.click?
            @sprites["list"].index=12
            pbPlayCancelSE
            pbFadeOutIn(99999) {
            Input.update
            pbEndScene
            }
            return
          end
        elsif $mouse.inArea?(222,155,55,55)
          if signlist!=12
            @sprites["select2"].x       = 222
            @sprites["select2"].y       = 155
            @sprites["title"].x         = 220+RXMOD/2
            @sprites["title"].text      =_INTL("Exit")
          end
          if $mouse.areaClick?(222,155,55,55)
            @sprites["list"].index=12
            pbPlayCancelSE
            pbFadeOutIn(99999) {
            Input.update
            pbEndScene
            }
            return
          end
        end
        for i in 0...$Trainer.party.length
          if $mouse.click?(@sprites["pkmnsprite#{i}"]) &&
             @sprites["pkmnsprite#{i}"].visible==true
            pbPlayCry($Trainer.party[i])
          end
        end
      end
      #=========================================================================
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
#===============================================================================
# Draws Birthsign info pages
#===============================================================================
  def pbSetSignInfo
    @sprites["birthsign"]=IconSprite.new(0,0,@viewport)
    @sprites["display"]=IconSprite.new(0,0,@viewport)
    @sprites["display"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalboarder2")
    @sprites["cancelbutton"]=IconSprite.new(482+RXMOD,278+RYMOD,@viewport)
    @sprites["zodiacbutton"]=IconSprite.new(482+RXMOD,278+RYMOD,@viewport)
    if defined?(INCLUDEZPOWER)
      @sprites["cancelbutton"].x-=34
      @sprites["zodiacbutton"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalbutton2")
    end
    @sprites["cancelbutton"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalbutton1")
    @sprites["rival"]=IconSprite.new(323+RXMOD,-8,@viewport)
    @sprites["partner1"]=IconSprite.new(396+RXMOD,-8,@viewport)
    @sprites["partner2"]=IconSprite.new(449+RXMOD,-8,@viewport)
    @sprites["highlight"]=IconSprite.new(-100,-8,@viewport)
    @sprites["highlight"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalselect")
    @sprites["name"]=Window_UnformattedTextPokemon.newWithSize("",0,-6,300,64,@viewport)
    @sprites["name"].baseColor=BASECOLOR
    @sprites["name"].shadowColor=SHADOWCOLOR
    @sprites["name"].windowskin=nil
    pbSetSmallFont(@sprites["name"].contents)
    @sprites["effect"]=Window_AdvancedTextPokemon.newWithSize("",-10,322+RYMOD,532,64,@viewport)
    @sprites["effect"].baseColor=BASECOLOR
    @sprites["effect"].shadowColor=SHADOWCOLOR
    @sprites["effect"].windowskin=nil
    pbSetExtraSmallFont(@sprites["effect"].contents)
    @sprites["effect2"]=Window_AdvancedTextPokemon.newWithSize("",-10,342+RYMOD,532,64,@viewport)
    @sprites["effect2"].baseColor=BASECOLOR
    @sprites["effect2"].shadowColor=SHADOWCOLOR
    @sprites["effect2"].windowskin=nil
    pbSetExtraSmallFont(@sprites["effect2"].contents)
    @sprites["type"]=Window_AdvancedTextPokemon.newWithSize("",-10,288+RYMOD,300,64,@viewport)
    @sprites["type"].baseColor=BASECOLOR
    @sprites["type"].shadowColor=SHADOWCOLOR
    @sprites["type"].windowskin=nil
    pbSetExtraSmallFont(@sprites["type"].contents)
    @sprites["month"]=Window_AdvancedTextPokemon.newWithSize("",378+RXMOD,288+RYMOD,300,64,@viewport)
    @sprites["month"].baseColor=BASECOLOR
    @sprites["month"].shadowColor=SHADOWCOLOR
    @sprites["month"].windowskin=nil
    pbSetExtraSmallFont(@sprites["month"].contents)
    @sprites["lore"]=Window_AdvancedTextPokemon.newWithSize("",4,35,300,290,@viewport)
    @sprites["lore"].baseColor=BASECOLOR
    @sprites["lore"].shadowColor=SHADOWCOLOR
    @sprites["lore"].windowskin=nil
    pbSetExtraSmallFont(@sprites["lore"].contents)
  end
  
  def pbDrawSignInfo(sign)
    pagepath ="Graphics/Pictures/Birthsigns/birthsign%02d" 
    tokenpath="Graphics/Pictures/Birthsigns/token%02d"
    signpage=$PokemonGlobal.zodiacset[sign]
    @sprites["birthsign"].setBitmap(sprintf(pagepath,signpage))
    @sprites["rival"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[(sign+6)%12]))
    @sprites["partner1"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[(sign+4)%12]))
    @sprites["partner2"].setBitmap(sprintf(tokenpath,$PokemonGlobal.zodiacset[(sign+8)%12]))
    @sprites["effect"].text=pbGetJournalEffect(signpage)
    @sprites["effect2"].text=pbGetJournalExtra(signpage)
    @sprites["type"].text=_INTL("Effect: {1}",pbGetEffectType(signpage))
    @sprites["month"].text=_INTL("Month: {1}",pbGetMonthName(sign+1))
    @sprites["lore"].text=pbGetJournalLore(signpage)
    @sprites["name"].text=PBBirthsigns.getName(signpage)
    textlength                = @sprites["name"].text.length
    @sprites["name"].x        = 142-textlength*6
    for i in 0...textlength; @sprites["name"].x+=1; end
    for i in 1...textlength
      if ['i','j','l','1','!'].include?(@sprites["name"].text[i,1])
        @sprites["name"].x += 2
      end
      if [' '].include?(@sprites["name"].text[i,1])
        @sprites["name"].x -= 4
      end
    end
  end
    
  def pbDisposeSignInfo
    @sprites["birthsign"].dispose
    @sprites["display"].dispose
    @sprites["cancelbutton"].dispose
    @sprites["zodiacbutton"].dispose if defined?(INCLUDEZPOWER)
    @sprites["rival"].dispose
    @sprites["partner1"].dispose
    @sprites["partner2"].dispose
    @sprites["highlight"].dispose
    @sprites["name"].dispose
    @sprites["effect"].dispose
    @sprites["effect2"].dispose
    @sprites["type"].dispose
    @sprites["month"].dispose
    @sprites["lore"].dispose
  end
  
  def pbOpenBirthsignPage
    pbPlayDecisionSE()
    pbFadeOutIn(99999) {
    @sprites["title"].visible=false
    @sprites["time"].visible=false
    @sprites["bosscount"].visible=false
    @sprites["bossname"].visible=false
    @sprites["current"].visible=false
    @sprites["trainer"].visible=false
    @sprites["party"].visible=false
    pbDeactivateWindows(@sprites)
    pbSetSignInfo
    pbDrawSignInfo(@sprites["list"].index)
    @sprites["arrowup"]=IconSprite.new(30,10,@viewport)
    @sprites["arrowup"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalArrow0")
    @sprites["arrowup"].z=101
    @sprites["arrowdwn"]=IconSprite.new(247,6,@viewport)
    @sprites["arrowdwn"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalArrow180")
    @sprites["arrowdwn"].z=101
    }
    loop do
      Input.update
      Graphics.update
      # Mouseover highlights
      if defined?($mouse)
        if $mouse.over?(@sprites["rival"])
          @sprites["highlight"].x=@sprites["rival"].x
        elsif $mouse.over?(@sprites["partner1"])
          @sprites["highlight"].x=@sprites["partner1"].x
        elsif $mouse.over?(@sprites["partner2"])
          @sprites["highlight"].x=@sprites["partner2"].x
        else
          @sprites["highlight"].x=-100
        end
        if $mouse.over?(@sprites["arrowup"])
          @sprites["arrowup"].zoom_x=1.2
          @sprites["arrowup"].zoom_y=1.2
          @sprites["arrowup"].x=28
          @sprites["arrowup"].y=8
        else
          @sprites["arrowup"].zoom_x=1
          @sprites["arrowup"].zoom_y=1
          @sprites["arrowup"].x=30
          @sprites["arrowup"].y=10
        end
        if $mouse.over?(@sprites["arrowdwn"])
          @sprites["arrowdwn"].zoom_x=1.2
          @sprites["arrowdwn"].zoom_y=1.2
          @sprites["arrowdwn"].x=243
          @sprites["arrowdwn"].y=4
        else
          @sprites["arrowdwn"].zoom_x=1
          @sprites["arrowdwn"].zoom_y=1
          @sprites["arrowdwn"].x=247
          @sprites["arrowdwn"].y=6
        end
        if $mouse.over?(@sprites["cancelbutton"])
          @sprites["cancelbutton"].zoom_x=1.2
          @sprites["cancelbutton"].zoom_y=1.2
          @sprites["cancelbutton"].x=478+RXMOD
          @sprites["cancelbutton"].x=446+RXMOD if defined?(INCLUDEZPOWER)
          @sprites["cancelbutton"].y=276+RYMOD
        else
          @sprites["cancelbutton"].zoom_x=1
          @sprites["cancelbutton"].zoom_y=1
          @sprites["cancelbutton"].x=482+RXMOD
          @sprites["cancelbutton"].x=448+RXMOD if defined?(INCLUDEZPOWER)
          @sprites["cancelbutton"].y=278+RYMOD
        end
        if defined?(INCLUDEZPOWER) && $mouse.over?(@sprites["zodiacbutton"])
          @sprites["zodiacbutton"].zoom_x=1.2
          @sprites["zodiacbutton"].zoom_y=1.2
          @sprites["zodiacbutton"].x=478
          @sprites["zodiacbutton"].y=276+RYMOD
        else
          @sprites["zodiacbutton"].zoom_x=1
          @sprites["zodiacbutton"].zoom_y=1
          @sprites["zodiacbutton"].x=482
          @sprites["zodiacbutton"].y=278+RYMOD
        end
      end
      if defined?(INCLUDEZPOWER)
        if Input.trigger?(Input::A) ||
           (defined?($mouse) && $mouse.click?(@sprites["zodiacbutton"]))
           @sprites["zodiacbutton"].zoom_x=1.2
          @sprites["zodiacbutton"].zoom_y=1.2
          @sprites["zodiacbutton"].x=478
          @sprites["zodiacbutton"].y=276+RYMOD
          pbPlayDecisionSE
          pbZodiacPowerPage(@sprites["list"].index)
        end
      end
      # Scrolls backwards
      if Input.trigger?(Input::UP) ||
         (defined?($mouse) && ($mouse.click?(@sprites["arrowup"]) || $mouse.scroll_up?))
        @sprites["arrowup"].zoom_x=1.2
        @sprites["arrowup"].zoom_y=1.2
        @sprites["arrowup"].x=26
        @sprites["arrowup"].y=8
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        if @sprites["list"].index<=0
          @sprites["list"].index=11 
        else
          @sprites["list"].index-=1
        end
        pbSetSignInfo
        pbDrawSignInfo(@sprites["list"].index)
        }
      # Scrolls forwards
      elsif Input.trigger?(Input::DOWN) ||
            (defined?($mouse) && ($mouse.click?(@sprites["arrowdwn"]) || $mouse.scroll_down?))
        @sprites["arrowdwn"].zoom_x=1.2
        @sprites["arrowdwn"].zoom_y=1.2
        @sprites["arrowdwn"].x=243
        @sprites["arrowdwn"].y=4
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        if @sprites["list"].index>=11
          @sprites["list"].index=0
        else
          @sprites["list"].index+=1
        end
        pbSetSignInfo
        pbDrawSignInfo(@sprites["list"].index)
        }
      end
      # Scrolls to next rival
      if Input.trigger?(Input::LEFT) || 
            (defined?($mouse) && $mouse.click?(@sprites["rival"]))
        @sprites["highlight"].x=@sprites["rival"].x
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        @sprites["list"].index=(@sprites["list"].index+=6)%12
        pbSetSignInfo
        pbDrawSignInfo(@sprites["list"].index)
        }
      # Scrolls to next partner
      elsif Input.trigger?(Input::RIGHT) ||
            (defined?($mouse) && $mouse.click?(@sprites["partner1"]))
        @sprites["highlight"].x=@sprites["partner1"].x
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        @sprites["list"].index=(@sprites["list"].index+=4)%12
        pbSetSignInfo
        pbDrawSignInfo(@sprites["list"].index)
        }
      elsif defined?($mouse) && $mouse.click?(@sprites["partner2"])
        @sprites["highlight"].x=@sprites["partner2"].x
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        @sprites["list"].index=(@sprites["list"].index+=8)%12
        pbSetSignInfo
        pbDrawSignInfo(@sprites["list"].index)
        }
      end
      # Exits page
      if Input.trigger?(Input::B) || Input.trigger?(Input::C) ||
         (defined?($mouse) && $mouse.click?(@sprites["cancelbutton"]))
        @sprites["cancelbutton"].zoom_x=1.2
        @sprites["cancelbutton"].zoom_y=1.2
        @sprites["cancelbutton"].x=478+RXMOD
        @sprites["cancelbutton"].x=446+RXMOD if defined?(INCLUDEZPOWER)
        @sprites["cancelbutton"].y=276+RYMOD
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        @sprites["arrowup"].dispose
        @sprites["arrowdwn"].dispose
        @sprites["title"].visible=true
        @sprites["time"].visible=true
        @sprites["bosscount"].visible=true
        @sprites["bossname"].visible=true
        @sprites["current"].visible=true
        @sprites["trainer"].visible=true
        @sprites["party"].visible=true
        pbActivateWindow(@sprites,"list")
        Input.update
        }
        return
      end
      pbUpdate
    end
  end
  
  def pbOpenSignPageMini(sign)
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    pbSetSignInfo
    pbDrawSignInfo(sign)
    loop do
      Input.update
      Graphics.update
      # Mouseover
      if defined?($mouse)
        if $mouse.over?(@sprites["cancelbutton"])
          @sprites["cancelbutton"].zoom_x=1.2
          @sprites["cancelbutton"].zoom_y=1.2
          @sprites["cancelbutton"].x=478
          @sprites["cancelbutton"].x=446 if defined?(INCLUDEZPOWER)
          @sprites["cancelbutton"].y=276 
        else
          @sprites["cancelbutton"].zoom_x=1
          @sprites["cancelbutton"].zoom_y=1
          @sprites["cancelbutton"].x=482
          @sprites["cancelbutton"].x=448 if defined?(INCLUDEZPOWER)
          @sprites["cancelbutton"].y=278
        end
        if defined?(INCLUDEZPOWER) && $mouse.over?(@sprites["zodiacbutton"])
          @sprites["zodiacbutton"].zoom_x=1.2
          @sprites["zodiacbutton"].zoom_y=1.2
          @sprites["zodiacbutton"].x=478+RXMOD
          @sprites["zodiacbutton"].y=276+RYMOD
        else
          @sprites["zodiacbutton"].zoom_x=1
          @sprites["zodiacbutton"].zoom_y=1
          @sprites["zodiacbutton"].x=482+RXMOD
          @sprites["zodiacbutton"].y=278+RYMOD
        end
      end
      # Zodiac Panel
      if defined?(INCLUDEZPOWER)
        if Input.trigger?(Input::A) ||
           (defined?($mouse) && $mouse.click?(@sprites["zodiacbutton"]))
           @sprites["zodiacbutton"].zoom_x=1.2
          @sprites["zodiacbutton"].zoom_y=1.2
          @sprites["zodiacbutton"].x=478+RXMOD
          @sprites["zodiacbutton"].y=276+RYMOD
          pbPlayDecisionSE
          pbZodiacPowerPage(sign)
        end
      end
      # Exits page
      if Input.trigger?(Input::B) || Input.trigger?(Input::C) ||
         (defined?($mouse) && $mouse.click?(@sprites["cancelbutton"]))
        @sprites["cancelbutton"].zoom_x=1.2
        @sprites["cancelbutton"].zoom_y=1.2
        @sprites["cancelbutton"].x=478
        @sprites["cancelbutton"].x=446 if defined?(INCLUDEZPOWER)
        @sprites["cancelbutton"].y=276 
        pbPlayCancelSE()
        pbFadeOutIn(99999) {
        pbDisposeSignInfo
        Input.update
        }
        return
      end
      pbUpdate
    end
  end

#===============================================================================
# Draws Zodiac Power panel
#===============================================================================
  def pbZodiacPowerPage(sign)
    signpage =$PokemonGlobal.zodiacset[sign]
    zodiacgem=getZodiacGem(sign)
    @sprites["panel"]=IconSprite.new(0,0,@viewport)
    @sprites["panel"].setBitmap("Graphics/Pictures/Birthsigns/Other/journalpanel")
    @sprites["panel"].z=+100
    @sprites["powname"]=Window_AdvancedTextPokemon.newWithSize("",0,313,300,64,@viewport)
    @sprites["powname"].baseColor=BASECOLOR
    @sprites["powname"].shadowColor=SHADOWCOLOR
    @sprites["powname"].windowskin=nil
    @sprites["powname"].z=+101
    pbSetSmallFont(@sprites["powname"].contents)
    @sprites["powname"].text=pbGetPowerName(signpage)
    textlength                = @sprites["powname"].text.length
    @sprites["powname"].x     = 242-textlength*6
    for i in 0...textlength; @sprites["powname"].x+=1; end
    for i in 1...textlength
      if ['i','j','l','1','!'].include?(@sprites["powname"].text[i,1])
        @sprites["powname"].x += 2
        if [' '].include?(@sprites["powname"].text[i,1])
          @sprites["powname"].x += 2
        end
      elsif [' '].include?(@sprites["powname"].text[i,1])
        @sprites["powname"].x += 3
      end
    end
    @sprites["power"]=Window_AdvancedTextPokemon.newWithSize("",-10,336,532,64,@viewport)
    @sprites["power"].baseColor=BASECOLOR
    @sprites["power"].shadowColor=SHADOWCOLOR
    @sprites["power"].windowskin=nil
    @sprites["power"].z=+101
    pbSetExtraSmallFont(@sprites["power"].contents)
    @sprites["power"].text=pbGetJournalPower(signpage)
    @sprites["target"]=Window_AdvancedTextPokemon.newWithSize("",-10,288,300,64,@viewport)
    @sprites["target"].baseColor=BASECOLOR
    @sprites["target"].shadowColor=SHADOWCOLOR
    @sprites["target"].windowskin=nil
    @sprites["target"].z=+101
    pbSetExtraSmallFont(@sprites["target"].contents)
    @sprites["target"].text=_INTL("Target: {1}",pbGetPowerTarget(signpage))
    @sprites["item"]=Window_AdvancedTextPokemon.newWithSize("",378,288,300,64,@viewport)
    @sprites["item"].baseColor=BASECOLOR
    @sprites["item"].shadowColor=SHADOWCOLOR
    @sprites["item"].windowskin=nil
    @sprites["item"].z=+101
    pbSetExtraSmallFont(@sprites["item"].contents)
    @sprites["item"].text=_INTL("Gem: {1}",PBItems.getName(zodiacgem))
    @sprites["gem"]=ItemIconSprite.new(475,276,zodiacgem,@viewport)
    @sprites["gem"].z=+101
    loop do
      Input.update
      Graphics.update
      # Toggles Zodiac panel on/off with the Z button
      # Exits back to the main menu with the Cancel button
      if Input.trigger?(Input::B)  || Input.trigger?(Input::A) ||
        (defined?($mouse) && $mouse.click?(@sprites["panel"]))
        @sprites["powname"].visible=false
        @sprites["power"].visible  =false
        @sprites["target"].visible =false
        @sprites["item"].visible   =false
        @sprites["panel"].visible  =false
        @sprites["gem"].visible    =false
        return
      end
      pbUpdate
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Used to open the birthsign journal
#===============================================================================
class BirthsignJournalScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbBirthsignJournal
    @scene.pbEndScene
  end
end

def pbOpenJournal
  pbFadeOutIn(99999){
    scene = BirthsignJournalScene.new
    screen = BirthsignJournalScreen.new(scene)
    screen.pbStartScreen
  }
end

#===============================================================================
# Used to open directly to a single page of the journal
#===============================================================================
class BirthsignScreenMini
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(sign)
    @scene.pbOpenSignPageMini(sign)
    @scene.pbEndScene
  end
end

def pbOpenJournalMini(sign)
  sign-=1
  pbFadeOutIn(99999){ 
    scene = BirthsignJournalScene.new
    screen = BirthsignScreenMini.new(scene)
    screen.pbStartScreen(sign)
  }
end

#===============================================================================
# Extra Small text font for info page text
#===============================================================================
# Gets the name of the system extra small font.
def pbExtraSmallFontName()
  return MessageConfig.pbTryFonts("Power Clear",
    "Arial Narrow","Arial")
end

# Sets a bitmap's font to the system extra small font.
def pbSetExtraSmallFont(bitmap)
  bitmap.font.name=pbExtraSmallFontName()
  bitmap.font.size=18
end

#===============================================================================
# Adds Pokegear access
# Alters code in the PScreen_Pokegear section
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMap        = -1
    cmdBirthsigns = -1 if ZODIACSET!=0
    commands[cmdMap = commands.length]     = ["map",_INTL("Map")]
    if $Trainer.gearBirthsigns = true
    commands[cmdBirthsigns = commands.length] = ["birthsigns",_INTL("Birthsigns")]
    end
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        pbPlayCancelSE
        break
      elsif cmdMap>=0 && cmd==cmdMap
        pbPlayDecisionSE
        pbShowMap(-1,false)
      elsif ZODIACSET!=0 && (cmdBirthsigns>=0 && cmd==cmdBirthsigns)
        if $game_switches[BOSS_RESET]==false
          #resetting Boss Array
          $PokemonGlobal.celestialboss = [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]
          $game_switches[BOSS_RESET] = true
        end
        pbPlayDecisionSE
        pbOpenJournal
      end
    end
    @scene.pbEndScene
  end
end
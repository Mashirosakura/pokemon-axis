

def pbLoadMount
        savefile = "Transfer/MountedSave.rxdata"
        File.open(savefile){|f|
#          Marshal.load(f) # Trainer already loaded
           $Trainer             = Marshal.load(f)
#          Graphics.frame_count = Marshal.load(f)
#          $game_system         = Marshal.load(f)
#          Marshal.load(f) # PokemonSystem already loaded
#          Marshal.load(f) # Current map id no longer needed
           $game_switches       = Marshal.load(f)
           $game_variables      = Marshal.load(f)
           $game_self_switches  = Marshal.load(f)
#          $game_screen         = Marshal.load(f)
#          $MapFactory          = Marshal.load(f)
#          $game_map            = $MapFactory.map
#          $game_player         = Marshal.load(f)
           $PokemonGlobal       = Marshal.load(f)
           metadata             = Marshal.load(f)
#          $ItemData            = readItemList("Data/items.dat")
           $PokemonBag          = Marshal.load(f)
           $PokemonStorage      = Marshal.load(f)
#          magicNumberMatches=false
        }
end

def pbMountSave(safesave=false)
  $Trainer.metaID=$PokemonGlobal.playerID
      savename="MountedSave.rxdata"
  begin  
      File.open(RTP.getMountFileName(savename),"wb"){|f|
       Marshal.dump($Trainer,f)
#      Marshal.dump(Graphics.frame_count,f)
#      if $data_system.respond_to?("magic_number")
#        $game_system.magic_number = $data_system.magic_number
#      else
#        $game_system.magic_number = $data_system.version_id
#      end
#      $game_system.save_count+=1
#      Marshal.dump($game_system,f)
#      Marshal.dump($PokemonSystem,f)
#      Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
#      Marshal.dump($game_screen,f)
#      Marshal.dump($MapFactory,f)
#      Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
     }
     Graphics.frame_reset
    rescue
    return false
  end
end


def pbCanMount
 if File.exist?("Transfer/MountedSave.rxdata")
  $game_switches[MOUNT_SWITCH] = true 
 end
end
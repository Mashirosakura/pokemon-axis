# Name-box by By Theo/MrGela @ theo#7722
# Expected behaviour and use: 
# Use in a text command, with an added keyword like "/xn["Test"]" in order to 
# display a small box to the top-left of the message window, displaying "Test".
# Use "\dxn" instead to use a dark skin (white text), the skin's filename should
# end in " xn dark" like "speech hgss 1 xn dark". 
# This window will rely on the user's choice of text frame.
#===============================================================================
# Quick editing values
# Off-set for adjusting the namewindow's Y and X
# Make it a negative number; the code currently adds it
OFFSET_NAMEWINDOW_Y=0
OFFSET_NAMEWINDOW_X=0
# End configuration
# Why do you hate Mario
# Wahee
# 

# NEW
def pbDisplayNameWindow(msgwindow,dark,param)
  namewindow=Window_AdvancedTextPokemon.new(_INTL("<ac>{1}</ac>",param))
  if dark==true
    namewindow.setSkin("Graphics/Windowskins/"+MessageConfig::TextSkinName+" xn dark")
    colortag=getSkinColor(msgwindow.windowskin,0,true)
    namewindow.text=colortag+namewindow.text
  else
    namewindow.setSkin("Graphics/Windowskins/"+MessageConfig::TextSkinName+" xn")
  end
  namewindow.resizeToFit(namewindow.text,Graphics.width)
  namewindow.width=180 if namewindow.width<=180
  namewindow.width = namewindow.width
  namewindow.y=msgwindow.y-namewindow.height
  namewindow.y+=OFFSET_NAMEWINDOW_Y
  namewindow.x+=OFFSET_NAMEWINDOW_X
  namewindow.viewport=msgwindow.viewport
  namewindow.z=msgwindow.z
  return namewindow
end

def pbMessageDisplay(msgwindow,message,letterbyletter=true,commandProc=nil)
  return if !msgwindow
  oldletterbyletter=msgwindow.letterbyletter
  msgwindow.letterbyletter=(letterbyletter) ? true : false
  ret=nil
  count=0
  commands=nil
  facewindow=nil
  goldwindow=nil
  coinwindow=nil
  # NEW
  namewindow=nil
  cmdvariable=0
  cmdIfCancel=0
  msgwindow.waitcount=0
  autoresume=false
  text=message.clone
  msgback=nil
  linecount=(Graphics.height>400) ? 3 : 2
  ### Text replacement
  text.gsub!(/\\\\/,"\5")
  if $game_actors
    text.gsub!(/\\[Nn]\[([1-8])\]/){ 
       m=$1.to_i
       next $game_actors[m].name
    }
  end
  text.gsub!(/\\[Ss][Ii][Gg][Nn]\[([^\]]*)\]/){ 
     next "\\op\\cl\\ts[]\\w["+$1+"]"
  }
  text.gsub!(/\\[Pp][Nn]/,$Trainer.name) if $Trainer
  text.gsub!(/\\[Pp][Mm]/,_INTL("${1}",$Trainer.money.to_s_formatted)) if $Trainer
  text.gsub!(/\\[Nn]/,"\n")
  text.gsub!(/\\\[([0-9A-Fa-f]{8,8})\]/){ "<c2="+$1+">" }
  text.gsub!(/\\[Pp][Gg]/,"\\b") if $Trainer && $Trainer.isMale?
  text.gsub!(/\\[Pp][Gg]/,"\\r") if $Trainer && $Trainer.isFemale?
  text.gsub!(/\\[Pp][Oo][Gg]/,"\\r") if $Trainer && $Trainer.isMale?
  text.gsub!(/\\[Pp][Oo][Gg]/,"\\b") if $Trainer && $Trainer.isFemale?
  text.gsub!(/\\[Pp][Gg]/,"")
  text.gsub!(/\\[Pp][Oo][Gg]/,"")
  text.gsub!(/\\[Bb]/,"<c2=6546675A>")
  text.gsub!(/\\[Rr]/,"<c2=043C675A>")
  text.gsub!(/\\1/,"\1")
  colortag=""
  isDarkSkin=isDarkWindowskin(msgwindow.windowskin)
  if ($game_message && $game_message.background>0) ||
     ($game_system && $game_system.respond_to?("message_frame") &&
      $game_system.message_frame != 0)
    colortag=getSkinColor(msgwindow.windowskin,0,true)
  else
    colortag=getSkinColor(msgwindow.windowskin,0,isDarkSkin)
  end
  text.gsub!(/\\[Cc]\[([0-9]+)\]/){ 
     m=$1.to_i
     next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
  }
  begin
    last_text = text.clone
    text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
  end until text == last_text
  begin
    last_text = text.clone
    text.gsub!(/\\[Ll]\[([0-9]+)\]/) { 
       linecount=[1,$1.to_i].max;
       next "" 
    }
  end until text == last_text
  text=colortag+text
  ### Controls
  textchunks=[]
  controls=[]
  # NEW
  while text[/(?:\\([Xn][Nn]|[DdXxNn][Xx][Nn]|[WwFf]|[Ff][Ff]|[Tt][Ss]|[Cc][Ll]|[Mm][Ee]|[Ss][Ee]|[Ww][Tt]|[Ww][Tt][Nn][Pp]|[Cc][Hh])\[([^\]]*)\]|\\([Gg]|[Cc][Nn]|[Ww][Dd]|[Ww][Mm]|[Oo][Pp]|[Cc][Ll]|[Ww][Uu]|[\.]|[\|]|[\!]|[\x5E])())/i]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase,$~[2],-1])
    else
      controls.push([$~[3].downcase,"",-1])
    end
    text=$~.post_match
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/\005/,"\\")
  end
  textlen=0
  for i in 0...controls.length
    control=controls[i][0]
    if control=="wt" || control=="wtnp" || control=="." || control=="|"
      textchunks[i]+="\2"
    elsif control=="!"
      textchunks[i]+="\1"
    end
    textlen+=toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2]=textlen
  end
  text=textchunks.join("")
  unformattedText=toUnformattedText(text)
  signWaitCount=0
  haveSpecialClose=false
  specialCloseSE=""
  for i in 0...controls.length
    control=controls[i][0]
    param=controls[i][1]
    if control=="f"
      facewindow.dispose if facewindow
      facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
    elsif control=="op"
      signWaitCount=21
    elsif control=="cl"
      text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
      haveSpecialClose=true
      specialCloseSE=param
    elsif control=="se" && controls[i][2]==0
      startSE=param
      controls[i]=nil
    elsif control=="ff"
      facewindow.dispose if facewindow
      facewindow=FaceWindowVX.new(param)
    elsif control=="ch"
      cmds=param.clone
      cmdvariable=pbCsvPosInt!(cmds)
      cmdIfCancel=pbCsvField!(cmds).to_i
      commands=[]
      while cmds.length>0
        commands.push(pbCsvField!(cmds))
      end
    elsif control=="wtnp" || control=="^"
      text=text.sub(/\001\z/,"") # fix: '$' can match end of line as well
    end
  end
  if startSE!=nil
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif signWaitCount==0 && letterbyletter
    pbPlayDecisionSE()
  end
  ########## Position message window  ##############
  pbRepositionMessageWindow(msgwindow,linecount)
  if $game_message && $game_message.background==1
    msgback=IconSprite.new(0,msgwindow.y,msgwindow.viewport)
    msgback.z=msgwindow.z-1
    msgback.setBitmap("Graphics/System/MessageBack")
  end
  if facewindow
    pbPositionNearMsgWindow(facewindow,msgwindow,:left)
    facewindow.viewport=msgwindow.viewport
    facewindow.z=msgwindow.z
  end
  atTop=(msgwindow.y==0)
  ########## Show text #############################
  msgwindow.text=text
  Graphics.frame_reset if Graphics.frame_rate>40
  begin
    if signWaitCount>0
      signWaitCount-=1
      if atTop
        msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
      else
        msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
      end
    end
    for i in 0...controls.length
      if controls[i] && controls[i][2]<=msgwindow.position && msgwindow.waitcount==0
        control=controls[i][0]
        param=controls[i][1]
        case control
        # NEW
        when "xn"
          # Show name box, based on #{param}
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow(msgwindow,dark=false,param)
        when "dxn"
          # Show name box, based on #{param}
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow(msgwindow,dark=true,param)
        when "f"
          facewindow.dispose if facewindow
          facewindow=PictureWindow.new("Graphics/Pictures/#{param}")
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport=msgwindow.viewport
          facewindow.z=msgwindow.z
        when "ts"
          if param==""
            msgwindow.textspeed=-999
          else
            msgwindow.textspeed=param.to_i
          end
        when "ff"
          facewindow.dispose if facewindow
          facewindow=FaceWindowVX.new(param)
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport=msgwindow.viewport
          facewindow.z=msgwindow.z
        when "g" # Display gold window
          goldwindow.dispose if goldwindow
          goldwindow=pbDisplayGoldWindow(msgwindow)
        when "cn" # Display coins window
          coinwindow.dispose if coinwindow
          coinwindow=pbDisplayCoinsWindow(msgwindow,goldwindow)
        when "wu"
          msgwindow.y=0
          atTop=true
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y=-(msgwindow.height*(signWaitCount)/20)
        when "wm"
          atTop=false
          msgwindow.y=(Graphics.height/2)-(msgwindow.height/2)
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        when "wd"
          atTop=false
          msgwindow.y=(Graphics.height)-(msgwindow.height)
          msgback.y=msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y=Graphics.height-(msgwindow.height*(20-signWaitCount)/20)
        when "."
          msgwindow.waitcount+=Graphics.frame_rate/4
        when "|"
          msgwindow.waitcount+=Graphics.frame_rate
        when "wt" # Wait
          param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount+=param.to_i*2
        when "w" # Windowskin
          if param==""
            msgwindow.windowskin=nil
          else
            msgwindow.setSkin("Graphics/Windowskins/#{param}")
          end
          msgwindow.width=msgwindow.width  # Necessary evil
        when "^" # Wait, no pause
          autoresume=true
        when "wtnp" # Wait, no pause
          param=param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount=param.to_i*2
          autoresume=true
        when "se" # Play SE
          pbSEPlay(pbStringToAudioFile(param))
        when "me" # Play ME
          pbMEPlay(pbStringToAudioFile(param))
        end
        controls[i]=nil
      end
    end
    break if !letterbyletter
    Graphics.update
    Input.update
    facewindow.update if facewindow
    if $DEBUG && Input.trigger?(Input::F6)
      pbRecord(unformattedText)
    end
    if autoresume && msgwindow.waitcount==0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
    if (Input.trigger?(Input::C) || Input.trigger?(Input::B))
      if msgwindow.busy?
        pbPlayDecisionSE() if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
  end until (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  Input.update # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter=oldletterbyletter
  if commands
    $game_variables[cmdvariable]=pbShowCommands(
       msgwindow,commands,cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  if commandProc
    ret=commandProc.call(msgwindow)
  end
  msgback.dispose if msgback
  # NEW
  namewindow.dispose if namewindow
  goldwindow.dispose if goldwindow
  coinwindow.dispose if coinwindow
  facewindow.dispose if facewindow
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop=(msgwindow.y==0)
    for i in 0..20
      if atTop
        msgwindow.y=-(msgwindow.height*(i)/20)
      else
        msgwindow.y=Graphics.height-(msgwindow.height*(20-i)/20)
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
    end
  end
  return ret
end
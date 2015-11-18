--  Michael Pilyavskiy AU VST Replacer --

test_t = {}
function test(x) table.insert(test_t, x) end

fontsize  = 16

vrs = "0.1"
 
changelog =                   
[===[
            Changelog:          
15.11.2015  0.1 alpha 
]===]


about = 'AU VST Replacer by Michael Pilyavskiy'..'\n'..'Version '..vrs..'\n'..
[===[    
            Contacts:
   
            Soundcloud - http://soundcloud.com/mp57
            PromoDJ -  http://pdj.com/michaelpilyavskiy
            VK -  http://vk.com/michael_pilyavskiy         
            GitHub -  http://github.com/MichaelPilyavskiy/ReaScripts
            ReaperForum - http://forum.cockos.com/member.php?u=70694
  
 ]===]
   
  -----------------------------------------------------------------------
  function F_add_to_list(config_path)
    file = io.open (config_path, 'r')
    if file ~= nil then 
      for line in io.lines(reaper.GetResourcePath()..'/reaper-vstplugins.ini') do 
        if string.find(line, '[[]') ~= 1 then table.insert(plugins_list, line) end
      end
    end
  end
  
 ----------------------------------------------------------------------- 
 function VAR_default_GUI()
    main_w = 320
    main_h = 240
    
    offset = 5
    
    font = 'Arial'
    fontsize_objects = fontsize - 2
    
    COL1 = {0.2, 0.2, 0.2}
    COL2 = {0.4, 1, 0.4} -- green
    COL3 = {1, 1, 1} -- white
    
    h_b = (main_h)/4-6
    b_1 = {offset,offset,main_w-offset*2,h_b}
    b_2 = {offset,offset+h_b+5,main_w-offset*2,h_b}
    b_3 = {offset,offset+h_b*2+10,main_w-offset*2,h_b}
    b_4 = {offset,offset+h_b*3+15,main_w-offset*2,h_b}
        
    b_1_name = "Dump AU plugins parameters to project file"
    b_2_name = "Replace VST from stored AU parameters"
    --[[
    
    Dump VST plugins parameters to project file
    Replace AU from stored VST parameters]]
    
    
        
    --[[color6_t = {0.2, 0.25, 0.22} -- back2
          color2_t = {0.5, 0.8, 1} -- blue      
          color3_t = {1, 1, 1}-- white
          color4_t = {0.8, 0.3, 0.2} -- red
          color7_t = {0.4, 0.6, 0.4} -- green dark]]
  end

-----------------------------------------------------------------------
  function F_extract_table(table,use)
    if table ~= nil then
      a = table[1]
      b = table[2]
      c = table[3]
      d = table[4]
    end  
    if use == 'rgb' then gfx.r,gfx.g,gfx.b = a,b,c end
    if use == 'xywh' then x,y,w,h = a,b,c,d end
    return a,b,c,d
  end 
  
 ----------------------------------------------------------------------- 
  function GUI_button(b_name,xywh_t, frame)
    gfx.a = 0.1
    F_extract_table(COL3,'rgb')
    F_extract_table(xywh_t,'xywh')
    gfx.rect(x,y,w,h)
    
    F_extract_table(xywh_t,'xywh')
    gfx.setfont(1,font,fontsize)
    gfx.x = x + (w - gfx.measurestr(b_name))/2
    gfx.y = y + (h - fontsize_objects)/2
    gfx.a = 1    
    gfx.drawstr(b_name)
    
    if frame then
      gfx.a = 1
      F_extract_table(COL2,'rgb')
      F_extract_table(xywh_t,'xywh')
      gfx.roundrect(x,y,w,h,false,1)
    end
    
  end
  
-----------------------------------------------------------------------
  function GUI_DRAW()
    -- background --
      gfx.a = 1
      F_extract_table(COL1,'rgb')
      gfx.rect(0,0,main_w,main_h)
    
    -- buttons
      GUI_button(b_1_name, b_1, b_1_frame)
      GUI_button(b_2_name, b_2, b_2_frame)
      --GUI_button(b_3_name, b_3, b_3_frame)
      --GUI_button(b_4_name, b_4, b_4_frame)
    gfx.update()
  end
    
-----------------------------------------------------------------------  
  function ENGINE1_dump_AU_to_project()
  
    -- get data
    
      plugdata = {}  
      counttracks = reaper.CountTracks(0)
      for i = 1, counttracks do
        tr = reaper.GetTrack(0,i-1)
        if tr ~= nil then
          tr_guid = reaper.GetTrackGUID(tr)
          fx_count = reaper.TrackFX_GetCount(tr)        
          if fx_count ~= nil then
            for j = 1, fx_count do
              _, fx_name = reaper.TrackFX_GetFXName(tr, j-1, '')
              fx_guid = reaper.TrackFX_GetFXGUID(tr, j-1)
              s_find1,s_find2 = fx_name:find('AU')
              if s_find1 == 1 and s_find2 == 2 then
                params_count = reaper.TrackFX_GetNumParams(tr, j-1)
                if params_count ~= nil then
                  for k =1, params_count do
                    val = reaper.TrackFX_GetParam(tr, j-1, k-1)
                    val = val..' '..tostring(val)..' '
                  end
                  div = "||"
                  outstr = tr_guid..div..
                           (j-1)..div..
                           fx_name:sub(5)..div..
                           val
                  table.insert(plugdata, outstr)
                end
              end
            end
          end
        end 
      end
    
    -- send data to proj ext state
    
      if #plugdata > 0 then 
        plug_count = #plugdata 
        for i =1, #plugdata do reaper.SetProjExtState(0, 'AUVST_replacer', 'AU_dump_'..i, plugdata[i]) end 
       else 
        plug_count = 0  
      end
    
    -- show info message 
    
      if #plugdata > 0 then
        reaper.MB(plug_count..' AU plugin parameter sets dumped to project file:', 'AU VST Replacer', 0)
       else
        reaper.MB('There is no any AU plugins in this project', 'AU VST Replacer Error', 0)
      end
    
  end

  -----------------------------------------------------------------------  
  function ENGINE1_restore_VST_from_AU()
    
    -- Extract data from project ext state
    
      i = 0
      plugdata_AU_ret = {}
      repeat
        temp_t = {}
        i=i+1
        retval, key, val = reaper.EnumProjExtState(0, "AUVST_replacer", i-1)
        if key ~= '' then 
          for word in string.gmatch(val, "[^||]+") do
            table.insert(temp_t, word)
          end 
          table.insert(plugdata_AU_ret, temp_t)
        end
      until retval == false
    
    -- Get list of possible vst      
      
      plugins_list  ={}
      F_add_to_list(reaper.GetResourcePath()..'/reaper-vstplugins.ini')
      F_add_to_list(reaper.GetResourcePath()..'/reaper-vstplugins64.ini')
      
    -- Loop main action
    
      if #plugdata_AU_ret > 0 then
      
        has_plugins = ''
        has_plugins2 = ''
        for i = 1, #plugdata_AU_ret do
          has_plugins2 = string.gsub(has_plugins,'%p','')
          str2 = string.gsub(plugdata_AU_ret[i][3],'%p','')
          if string.find(has_plugins2,str2) == nil then          
            has_plugins = has_plugins..'\n'..plugdata_AU_ret[i][3]
          end          
        end
        
        ret_user = reaper.MB('Are you REALLY SURE you have VST analogs of this AU plugins'..'\n'..
        '(otherwise THEY WILL BE DELETED):'..'\n'..
        has_plugins..'?', '', 4)
        
        if ret_user == 6 then          
          reaper.Undo_BeginBlock2(0)
---vvvvvvvvvv----------------------------------------------          
          if reaper.CountTracks(0) ~= nil then
            for i = 1, #plugdata_AU_ret do
            
              t_track_guid = plugdata_AU_ret[i][1]
              t_fx_id = tonumber(plugdata_AU_ret[i][2])
              t_fx_name = plugdata_AU_ret[i][3]
              t_fx_params = plugdata_AU_ret[i][4]
              
              insert_fx = find_insert(t_fx_name)
              test({insert_fx,t_fx_name})
              for j=1, reaper.CountTracks(0) do
                track = reaper.GetTrack(0,j-1)
                trackguid = reaper.GetTrackGUID(track)
                --)
                if t_track_guid == trackguid then
                  --reaper.SNM_MoveOrRemoveTrackFX(track, t_fx_id, 0)
                end
              end  
                          
            end--loop ret data            
          end -- if cnt tracks ~= nil
--^^^^^^^^^----------------------------------------------- 
          reaper.Undo_EndBlock2(0, 'AU VST replacer - NO UNDO', 1)
        end --ret user 6
        
      end -- if # ret AU data > 0
      
    --[[ search for
      --reaper.ShowConsoleMsg(content)
      
      Lua: boolean 
      
      Python: Boolean SNM_MoveOrRemoveTrackFX(MediaTrack tr, Int fxId, Int what)
      
      [S&M] Move or removes a track FX. Returns true if tr has been updated.
      fxId: fx index in chain or -1 for the selected fx. what: 0 to remove, -1 to move fx up in chain, 1 to move fx down in chain.
      
      ]]
  end
  
  -----------------------------------------------------------------------
    function MOUSE_gate(mb, b)
      local state    
      if MOUSE_match_xy(b) then       
       if mb == 1 then if LMB_state and not last_LMB_state then state = true else state = false end end
       if mb == 2 then if RMB_state and not last_RMB_state then state = true else state = false end end 
       if mb == 64 then if MMB_state and not last_MMB_state then state = true else state = false end end        
      end   
      return state
    end
    
  -----------------------------------------------------------------------
  function MOUSE_match_xy(b)
    if    mx > b[1] 
      and mx < b[1]+b[3]
      and my > b[2]
      and my < b[2]+b[4] then
     return true 
    end 
  end
      
  -----------------------------------------------------------------------  
  function MOUSE_get()
      LMB_state = gfx.mouse_cap&1 == 1 
      RMB_state = gfx.mouse_cap&2 == 2 
      MMB_state = gfx.mouse_cap&64 == 64  
      mx, my = gfx.mouse_x, gfx.mouse_y
          
      if MOUSE_gate(1, b_1) then  ENGINE1_dump_AU_to_project()   end      
      if MOUSE_match_xy(b_1) then b_1_frame = true else b_1_frame = false end
      
      if MOUSE_gate(1, b_2) then  ENGINE1_restore_VST_from_AU()   end  
      if MOUSE_match_xy(b_2) then b_2_frame = true else b_2_frame = false end
      
      last_LMB_state = LMB_state    
      last_RMB_state = RMB_state
      last_MMB_state = MMB_state 
  end
  
-----------------------------------------------------------------------
  function F_exit() gfx.quit() end
  
-----------------------------------------------------------------------
  function run()    
    GUI_DRAW()
    MOUSE_get()
    char = gfx.getchar()
    if char == 27 then exit() end     
    if char ~= -1 then reaper.defer(run) else F_exit() end
  end 
  
-----------------------------------------------------------------------
  
  VAR_default_GUI()
  gfx.init("mpl AU VST Replacer // ".."Version "..vrs, main_w, main_h)
  reaper.atexit(F_exit) 
  
  run()
  
  

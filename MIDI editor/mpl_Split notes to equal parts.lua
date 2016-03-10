  --[[
     * ReaScript Name: Split notes to equal parts
     * Lua script for Cockos REAPER
     * Author: Michael Pilyavskiy (mpl)
     * Author URI: http://forum.cockos.com/member.php?u=70694
     * Licence: GPL v3
     * Version: 1.0
    ]]
    
  --[[
    * Changelog: 
    * v1.0 (2016-03-10)
      + init release
  --]]
  
  
  function SplitNotes(div)
    if div == nil or div <= 0 then return end
    local midieditor, take, notes, notes_t, len, len_div
    midieditor = reaper.MIDIEditor_GetActive()
    if midieditor == nil then return end
    take = reaper.MIDIEditor_GetTake(midieditor)
    if take == nil then return end
    _, notes = reaper.MIDI_CountEvts(take)
    if notes > 0 then
      notes_t = {}
      for i = 1, notes do
        notes_t[i] = {}
        _, notes_t[i].sel, notes_t[i].muted, notes_t[i].start, notes_t[i].ending, notes_t[i].chan, notes_t[i].pitch, notes_t[i].vel = reaper.MIDI_GetNote(take, i-1)
      end
      
      for i = 1, notes do reaper.MIDI_DeleteNote(take, 0) end
      
      for i = 1, #notes_t do
        len = notes_t[i].ending - notes_t[i].start
        len_div = len / div
        for j = 1, div do
          reaper.MIDI_InsertNote(take, 
                                notes_t[i].sel, 
                                notes_t[i].muted, 
                                notes_t[i].start + (j-1) * len_div , 
                                notes_t[i].start + (j-1) * len_div + len_div, 
                                notes_t[i].chan, 
                                notes_t[i].pitch, 
                                notes_t[i].vel)          
        end
        reaper.MIDI_Sort(take)
      end    
      
    end
  end
  
  script_title = "Split notes to equal parts"
  
  _, div_ret = reaper.GetUserInputs('Split notes to equal parts', 1, 'Divide each notes by', '')
  div = tonumber(div_ret)
  
  if div ~= nil then
    reaper.Undo_BeginBlock()  
    SplitNotes(div)
    reaper.Undo_EndBlock(script_title, 0)
  end

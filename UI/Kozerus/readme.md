# Kozerus UI Library

_Credit to [Jxereas](https://github.com/Jxereas) for [Cerebus UI](https://github.com/Jxereas/UI-Libraries) which this is based off of._ 
<br>
_Yeah I suppose I could have done it as a fork..._
<br>
<br>
_I may update this readme to a bit more helpful later on..._
<br>

Changes made: 
- added executor checks and normalization to ensure support needed, kicks if any of the below fail to resolve
  - executor funcs needed:
    - syn_context_get / syn.get_thread_identity / getidentity / getthreadidentity / getthreadcontext
    - syn_context_set / syn.set_thread_identity / setidentity / setthreadidentity / setthreadcontext
    - hookmetamethod
    - hookfunction / hookfunc / detour_function / replaceclosure
    - getnamecallmethod
    - setnamecallmethod
    - getconnections / get_signal_connections
    - gethui / hiddenUI / get_hidden_gui / syn.protect_gui
- ensures safe gui via exploit syn.protectgui or gethui, kicks player if not supported (left below hook stuff in there cuz it still works ig...)
- changed the red ascents to be cyan ascents because i dont like all the red. didnt make it param cuz i didnt care to.
- added 'closeCallback' param to 'Library.init', so calling script knows when close button pressed. called like: closeCallback()
- added 'Window:Shutdown(doCallback:boolean):nil', so calling script can close the UI 
- added 'Window:SetVisibilityKeybind(keybind:string):nil', to change the show/hide keybind after creation. can be set to nil to remove the input connection. can be re-added. if removed, window is set to visible. 
- added 'textFont' param to 'elementHandler:Label', to use different font for labels
- fixed 'labelHandler:ChangeText' so it calculates text bounds correctly based on text size
- added 'labelHandler:ChangeTextSize(textSize:number):nil' to edit size of text after creation 
- added 'labelHandler:ChangeTextFont(textFont:Font):nil' to edit font after creation 
- added 'labelHandler:ChangeTextColor(textColor:Color3):nil' to edit text color after creation 
- fixed 'elementHandler:Button' to return the button table 
- added 'expanded:boolean' param to 'elementHandler:Dropdown' to force dropdown to be expanded upon creation 
- added 'Dropdown:SetExpanded(expanded):nil' to allow changing dropdown expand/collapse from calling script 
- added 'initialValue:number' param to 'elementHandler:Slider' to give slider bar a starting value 
- added 'Slider:SetEnabled(enabled:boolean):nil' so you can disable/enable a slider from calling script 
- added 'Slider:SetMaximum(max:number):nil' so you can edit the max on a slider after creation 
- added 'Slider:Set(value:number,doCallback:boolean):nil' to edit slider bar value after creation 
- added 'ColorWheel:Set(color:Color3):nil' to be able to give it a value from calling script 
- added 'toggleHandler:ChangeText(toggleText:string):nil' to edit toggle display text after creation
- added 'richText' param to 'elementHandler:Label', to use richtext for labels 
- added 'labelHandler:SetRichText(richText:boolean):nil' to edit label richtext after creation
- added 'sectionHandler:ChangeText(sectionTitle:string):nil' to edit section title after creation
- added 'includeBottomFrame' boolean param to 'windowHandler:Tab', to include a bottom scrolling frame on the tab page
- added 'bottomFrameYScale' number param to 'windowHandler:Tab', to set how large bottom frame should be, left/right frames adjust accordingly
- added 'tabHandler:MinimizeBottom():nil', to shrink the bottom frame's Y Size to only show top section name, left/right frames adjust accordingly
- added 'tabHandler:MaximizeBottom():nil', to restore the bottom frame to its full Y scale, left/right frames adjust accordingly 
- added 'tabHandler:UpdateFrameScale():nil' to update the page frame scaling for min/max on bottom frame
- added 'resizeCallback' param to 'tabHandler:Section' so calling script knows when a section is minimized/maximized. called like: resizeCallback(isMaximized:boolean)

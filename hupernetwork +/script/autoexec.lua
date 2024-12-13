-- AUTOEXEC.LUA
-- Victoria2 AutoExec
-- This file is run on app start after exports are done inside the engine (once per context created)

-- check for user mod files
package.path = package.path .. ";script\\?.lua;script\\country\\?.lua"

if CCurrentGameState.HasCommonExtension() then
	local modDir = tostring(CCurrentGameState.GetCommonModDirectory())
	package.path = package.path .. ";" .. modDir .. "\\?.lua"
end

package.path = package.path .. ";common\\?.lua"

-- Disable checksum changing behavior
function OnGameStart()
	-- Do nothing
end

--require('hoi') -- already imported by game, contains all exported classes
require('tweaks')
require('utils')
require('defines')
require('ai_country')
require('custom_functions')


-- load country specific AI modules.
--require('ENG')

-- Define the event
function modifyNationalFocus(event)
    -- Replace 'TAG' with your country's tag
    local countryTag = "AUS"
    
    -- Replace 'X' with the desired number of national focus points
    local newFocusPoints = promote_soldiers
    
    -- Get the country by tag
    local country = getCountryByTag(countryTag)
    
    -- Check if the country exists
    if country then
        -- Set the new number of national focus points
        country:setNationalFocusPoints(newFocusPoints)
        
        -- Optional: Print a message to the console (for debugging)
        print("National focus points updated for country " .. countryTag .. " to " .. newFocusPoints)
    else
        -- Print an error message if the country tag is invalid
        print("Error: Country with tag " .. countryTag .. " not found.")
    end
end

-- Register the event (this function should be called when the event is triggered)
function onEventTriggered(event)
    modifyNationalFocus(event)
end

-- Add your event to the event system
-- Replace 'your_event_id' with the ID you want for this event
registerEvent("12345", onEventTriggered)
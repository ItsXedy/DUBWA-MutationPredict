local Workspace = game:GetService("Workspace")

-- Filtered list containing ONLY public mutation events
local PUBLIC_EVENTS = {
    "Nen",
    "Dragonborn",
    "Beast",
    "Arrancar",
    "Titan",
    "Buhara"
}

local function extractPublicTimeStrings()
    local currentActive = Workspace:GetAttribute("MutationEvent")
    local eventList = {}

    for _, name in ipairs(PUBLIC_EVENTS) do
        local rawValue = Workspace:GetAttribute(name)
        local numTime = tonumber(rawValue)

        if numTime then
            -- Convert Unix absolute timestamps to remaining seconds
            local secondsLeft = numTime
            if numTime > 1000000000 then 
                secondsLeft = numTime - os.time()
            end

            -- Convert to clean total minutes
            local minutesLeft = math.floor(secondsLeft / 60)
            if minutesLeft < 0 then minutesLeft = 0 end

            table.insert(eventList, {
                Name = name,
                Minutes = minutesLeft,
                IsActive = (name == currentActive)
            })
        end
    end

    -- Sort the active public queue chronologically from lowest to highest minute count
    table.sort(eventList, function(a, b)
        return a.Minutes < b.Minutes
    end)

    -- Output pure raw text strings
    print("\n--- EXTRACTED START TIMES ---")
    if #eventList == 0 then
        print("No public event timers found active in Workspace.")
    else
        for _, event in ipairs(eventList) do
            local displayName = event.Name
            
            -- Keep the specific naming sequence for the Buhara/Nen chain
            if displayName == "Nen" or displayName == "Buhara" then
                displayName = "Buhara / Nen Event"
            else
                displayName = displayName .. " Mutation"
            end

            if event.IsActive then
                print(string.format("0 Minutes = %s (ACTIVE NOW)", displayName))
            else
                print(string.format("%d Minutes = %s", event.Minutes, displayName))
            end
        end
    end
    print("-----------------------------\n")
end

extractPublicTimeStrings()

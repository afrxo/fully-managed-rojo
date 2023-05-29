-- publish.luau

local fs = require("@lune/fs")
local net = require("@lune/net")
local roblox = require("@lune/roblox")

local throwError = require("./throwError")
local getRbxApiKey = require("./auth/getRbxApiKey")

local function getUniverseId(place)
    return place:FindFirstChild("UniverseId").Value
end

local function getPlaceIds(place)
    return place:FindFirstChild("PlaceIds").Value
end

local function tryPost(place_id, universe_id)
    local api_key = getRbxApiKey()
    assert(api_key ~= nil, "Failed to get roblox api key")

    local success, response = pcall(function()
        return net.request {
            url = `https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions?versionType=Published`,
            method = "POST",
            headers = {
                ["x-api-key"] = api_key,
                ["Content-Type"] = "application/octet-stream"
            },
            body = fs.readFile(PLACE_FILE)
        }
    end)

    if (not success) then
        error(response)
    end
end

function main()
    local rbxlFile = roblox.readPlaceFile(PLACE_FILE)
    local placeIds = getPlaceIds(rbxlFile)
    local universeId = getUniverseId(rbxlFile)

    for _, placeId in ipairs(string.split(placeIds, ",")) do
        tryPost(placeId, universeId)
    end
end

if #process.args == 1 then
    PLACE_FILE = process.args[1]
    return main()
else
	throwError(process.args[1], "string", 1, "Place File")
end
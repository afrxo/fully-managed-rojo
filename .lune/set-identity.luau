-- set-identity.luau

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")

local throwError = require("./throwError")

local function main()
    local placeFile = roblox.readPlaceFile(PLACE_FILE)
    local placesJSON = serde.decode("json", fs.readFile(PLACES_JSON))

    local universeId = roblox.Instance.new("IntValue")
    universeId.Name = "UniverseId"
    universeId.Value = placesJSON.universeId[BRANCH]
    universeId.Parent = placeFile

    local placeIds = roblox.Instance.new("StringValue")
    placeIds.Name = "PlaceIds"
    placeIds.Value = table.concat(placesJSON.placeId[BRANCH][PLACE], ",")
    placeIds.Parent = placeFile

    roblox.writePlaceFile(PLACE_FILE, placeFile)
end

if #process.args == 4 then
    PLACES_JSON = process.args[1]
    PLACE_FILE = process.args[2]
    PLACE = process.args[3]
    BRANCH = process.args[4]
    return main()
else
    throwError(process.args[1], "string", 1, "Places Json")
    throwError(process.args[2], "string", 2, "Place File")
    throwError(process.args[3], "string", 3, "Place")
    throwError(process.args[4], "string", 4, "Release")
end
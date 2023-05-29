-- retrieve-assets.luau

local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")

local throwError = require("./throwError")
local getAuthCookie = require("./auth/getAuthCookie")

local function tryGet(place_id)
    local cookie = getAuthCookie()
    assert(cookie ~= nil, "Failed to get roblox auth cookie")

    local success, response = pcall(function()
        local assetApiResponse = net.request({
            url = `https://assetdelivery.roblox.com/v2/assetId/{place_id}`,
            headers = {
                Accept = "application/json",
                Cookie = cookie,
            },
        })

        local parsedResponse = serde.decode("json", assetApiResponse.body)

        if (parsedResponse.errors) then
            error(parsedResponse.errors[1].message)
        end

        local cdnDownloadUrl = parsedResponse.locations[1].location
        local cdnResponse = net.request({
            url = cdnDownloadUrl,
            headers = {
                Cookie = cookie,
            },
        })

        return cdnResponse.body
    end)

    if (not success) then
        error(response)
    end

    return response
end

function main()
    local places = serde.decode("json", fs.readFile(PLACES_JSON))
    fs.writeFile("temp/assets.rbxl", tryGet(places.assets))
end

if #process.args == 2 then
    PLACES_JSON = process.args[1]
    WRITE_PATH = process.args[2]
    return main()
else
    throwError(process.args[1], "string", 1, "Places Json")
    throwError(process.args[2], "string", 2, "Write Path")
end
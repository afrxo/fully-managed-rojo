-- sync-assets.luau

local roblox = require("@lune/roblox")

local throwError = require("./throwError")

local function copy_children(from, to)
    if (not from) or (not to) then return end
    for _, child in ipairs(from:GetChildren()) do
        if (child.Name == "_properties") then continue end
        child.Parent = to;
    end
end

-- replicate_properties
-- source: Instance
-- target: Instance
local function replicate_properties(source, target)
    if (not target) or (not source) then return end
    if (not source:FindFirstChild("_properties")) then return end

    local properties = source:FindFirstChild("_properties")

    for property, value in pairs(properties:GetAttributes()) do
        -- This would only ever throw, if the property doesn't exist.
        local success = pcall(function()
            target[property] = value
        end)

        if (not success) then
            error(`'{property}' is not a valid property of {target.ClassName}!`)
        end
    end
end

-- is_blacklisted
-- directory: Instance
-- target: string
local function is_blacklisted(directory, target)
    if (not directory:GetAttribute("blacklist")) then return false end;
    for _, place in string.split(directory:GetAttribute("blacklist"), ",") do
        if (place == target) then
            return true;
        end
    end

    return false
end

-- sync_assets
-- mirror: string
-- sync: Instance
-- target: Instance
local function sync_assets(mirror, sync, target)
    for _, directory in sync[mirror]:GetChildren() do
        if (is_blacklisted(directory, target.Name)) then continue end;
        copy_children(directory, target:FindFirstChild(directory.Name));
        replicate_properties(directory, target:FindFirstChild(directory.Name));
    end
end


function main()
    -- Use local asset place / fetch using readPlaceAsset
    local assetPlace = roblox.readPlaceFile(ASSET_FILE);
    local rojoBuild = roblox.readPlaceFile(PLACE_FILE);

    local sync = assetPlace.Workspace.sync;

    rojoBuild.Name = PLACE

    -- Sync assets shared across places
    sync_assets("shared", sync, rojoBuild);
    roblox.writePlaceFile(PLACE_FILE, rojoBuild);

    -- Sync place specific assets
    if (sync:FindFirstChild(PLACE)) then
        sync_assets(PLACE, sync, rojoBuild);
        roblox.writePlaceFile(PLACE_FILE, rojoBuild);
    end;

    print(`Synced assets to {PLACE}.rbxl`);
end

if #process.args == 3 then
    PLACE = process.args[1]
    PLACE_FILE = process.args[2]
    ASSET_FILE = process.args[3]
    return main()
else
	throwError(process.args[1], "string", 1, "Place")
    throwError(process.args[2], "string", 2, "Place File")
end
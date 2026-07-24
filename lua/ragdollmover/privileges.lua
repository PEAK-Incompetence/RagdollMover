-- CAMI privileges
AddCSLuaFile("sh_cami.lua")
include("sh_cami.lua")

if not CAMI then return end 

local RGMPrivileges = {
    ragdollmover_xray = {
        Name = "ragdollmover_xray",
        MinAccess = "admin",
        Description = "Allow users to select or manipulate entities through walls"
    }
}

for name, privilege in pairs(RGMPrivileges) do
    CAMI.RegisterPrivilege(privilege)
end

RAGDOLLMOVER_PRIVILEGES = RAGDOLLMOVER_PRIVILEGES or {}

local function updatePrivileges(pl)
    RAGDOLLMOVER_PRIVILEGES[pl] = RAGDOLLMOVER_PRIVILEGES[pl]  or {}
    for name, _ in pairs(RGMPrivileges) do
        CAMI.PlayerHasAccess(pl, name, function(hasAccess, reason)
            RAGDOLLMOVER_PRIVILEGES[pl][name] = hasAccess
        end)
    end
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "rgmReportPrivileges", function (data)
    if data then
        local pl = Player(data.userid)
        RAGDOLLMOVER[pl] = {}
        updatePrivileges(pl)
    end
end)

hook.Add("PlayerDisconnected", "rgmClearPrivileges", function(pl)
    RAGDOLLMOVER_PRIVILEGES[pl] = nil
end)

hook.Add("CAMI.PlayerUsergroupChanged", "rgmUpdatePrivileges", updatePrivileges)

for _, player in ipairs(player.GetAll()) do
    updatePrivileges(player)
end
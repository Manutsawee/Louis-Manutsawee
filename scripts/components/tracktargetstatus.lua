local SpawnUtil = require("utils/spawnutil")
local CreateLight = SpawnUtil.CreateLight
local datingmanager = TheWorld.components.datingmanager
local isdatingrelationship = datingmanager ~= nil and datingmanager:GetIsDatingRelationship() or false

local TrackTargetStatus = Class(function(self, inst)
    self.inst = inst

    inst:DoTaskInTime(0, self.DoWorldStateInit)
end)

local function OnSanityDelta(inst, data)
    local honey = inst:TheHoney()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then
        inst:PushEvent("")
    end
end

local function OnHungerDelta(inst, data)
    local honey = inst:TheHoney()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then

    end
end

local function OnHealthDelta(inst, data)
    local honey = inst:TheHoney()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then

    end
end

local function OnMoistureDelta(inst, data)
    local honey = inst:TheHoney()
    local newpercent = data.newpercent

    if newpercent >= 0.5 then

    end
end

local function OnTemperatureDelta(inst, data)
    local honey = inst:TheHoney()
    local newpercent = data.newpercent

    if newpercent <= 5 then

    end
end

local function OnHearGrue(inst)
    local honey = inst:TheHoney()
    if honey ~= nil then
        local fx_book_light_upgraded = SpawnPrefab("fx_book_light_upgraded")
        local x, y, z = honey.Transform:GetWorldPosition()
        fx_book_light_upgraded.Transform:SetScale(.9, 2.5, 1)
        fx_book_light_upgraded.Transform:SetPosition(x, y, z)

        -- before Charlie's attack, set the light to be released after 0.5 seconds
        honey:DoTaskInTime(0.5, function()
            if honey.momo_light == nil then
                honey.momo_light = CreateLight(true)
                honey.momo_light.Follower:FollowSymbol(honey.GUID)
            else
                honey.momo_light.Light:Enable(true)
            end
        end)
    end
end

local function OnTeleported(inst)
    local honey = inst:TheHoney()
    if honey ~= nil then
        inst:PushEvent("useteleport")
    end
end

local function OnIsDay(self, active)
    if active then
        if self.honey.momo_light ~= nil then
            self.honey.momo_light:Remove()
        end
    end
end

local function ToggleLunarHail(self, active)
    local onimpact_canttags = TheWorld.components.lunarhailmanager.onimpact_canttags
    if active then
        table.insert(onimpact_canttags, "manutsawee")
    else
        RemoveByValue(onimpact_canttags, "manutsawee")
    end
end

local function ToggleAcidRain(self, active)
    local honey = self.inst:TheHoney()
    if honey ~= nil then
        if active then
            honey:AddTag("acidrainimmune")
        else
            honey:RemoveTag("acidrainimmune")
        end
    end
end

local AddEventListeners = function(inst, honey)
    honey:ListenForEvent("sanitydelta", OnSanityDelta, inst)
    honey:ListenForEvent("hungerdelta", OnHungerDelta, inst)
    honey:ListenForEvent("healthdelta", OnHealthDelta, inst)
    honey:ListenForEvent("moisturedelta", OnMoistureDelta, inst)
    honey:ListenForEvent("temperaturedelta", OnTemperatureDelta, inst)
    honey:ListenForEvent("heargrue", OnHearGrue, inst)
    honey:ListenForEvent("teleported", OnTeleported, inst)
end

local AddWorldStateWatchers = function(self, honey)
    self:WatchWorldState("islunarhailing", ToggleLunarHail)
    self:WatchWorldState("isacidraining", ToggleAcidRain)
    self:WatchWorldState("isday", OnIsDay)
end

function TrackTargetStatus:StartTrack(honey)
    if honey ~= nil and isdatingrelationship then
        AddEventListeners(self.inst, honey)
        AddWorldStateWatchers(self, honey)
    end
end

-- function TrackTargetStatus:OnUpdate(dt)

-- end

local RemoveEventListeners = function(inst, honey)
    inst:RemoveEventCallback("sanitydelta", OnSanityDelta, honey)
    inst:RemoveEventCallback("hungerdelta", OnHungerDelta, honey)
    inst:RemoveEventCallback("healthdelta", OnHealthDelta, honey)
    inst:RemoveEventCallback("moisturedelta", OnMoistureDelta, honey)
    inst:RemoveEventCallback("temperaturedelta", OnTemperatureDelta, honey)
    inst:RemoveEventCallback("heargrue", OnHearGrue, honey)
    inst:RemoveEventCallback("teleported", OnTeleported, honey)
end

local RemoveWorldStateWatchers = function(self, honey)
    self:StopWatchingWorldState("isday", OnIsDay)
    self:StopWatchingWorldState("islunarhailing", ToggleLunarHail)
    self:StopWatchingWorldState("isacidraining", ToggleAcidRain)
end

function TrackTargetStatus:StopTrack(honey)
    if honey ~= nil then
        RemoveEventListeners(self.inst, honey)
        RemoveWorldStateWatchers(self, honey)
    end
end

function TrackTargetStatus:DoWorldStateInit()
    OnIsDay(self, TheWorld.state.isday)
    ToggleLunarHail(self, TheWorld.state.islunarhailing)
    ToggleAcidRain(self, TheWorld.state.isacidraining)
end

TrackTargetStatus.OnRemoveEntity = TrackTargetStatus.StopTrack
TrackTargetStatus.OnRemoveFromEntity = TrackTargetStatus.StopTrack

-- function TrackTargetStatus:OnLoad()
--     local honey = self.inst:TheHoney()
--     if honey ~= nil then
--         self.inst.components.tracktargetstatus:StartTrack(honey)
--     end
-- end

return TrackTargetStatus

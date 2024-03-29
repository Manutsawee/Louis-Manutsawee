local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
    local radius_override = 8
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, radius_override, 12, true, true, NoHoles)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function DoSpawnMomo(inst, bait, summoner)
    local pt = inst:GetPosition()
    local spawn_pt = GetSpawnPoint(pt)

    if spawn_pt ~= nil then
        local momo = SpawnPrefab("momo")
        if momo ~= nil then
            momo.Transform:SetPosition(spawn_pt:Get())
            momo:FacePoint(pt)
            momo.honey = summoner
            momo.honey_userid = summoner.userid
            momo.components.health:SetInvincible(false)
            momo:PushEvent("start_dialogue")

            TheWorld:PushEvent("ms_momo_spawn")
        end
    end
end

local function TrySpawnMomo(inst, bait, summoner)
    inst:DoTaskInTime(3, function() DoSpawnMomo(inst, bait, summoner) end)
end

local function OnBaitedFn(inst, bait, summoner)
    local datingmanager = TheWorld.components.datingmanager
    local momo_in_the_world = datingmanager ~= nil and datingmanager:GetMomoInTheWorld() or false
    if bait ~= nil and bait.prefab == "m_pantsu" and summoner ~= nil then
        if summoner:HasTag("naughtychild") then
            TrySpawnMomo(inst, bait, summoner)
        end
    end
end

AddPrefabPostInit("trap", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.trap:SetOnBaitedFn(OnBaitedFn)
end)

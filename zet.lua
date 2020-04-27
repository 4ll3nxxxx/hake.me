local arcwarden = {
    button = Menu.AddKeyOption({"Hero Specific", "Arc Warden"}, "Arc Warden Combo Button", Enum.ButtonCode.KEY_SPACE),
    magnetic_field_pos = nil,
    sleeptick = 0,
    pout = 0,
    clicked_unit = nil,
    arcwarden = nil,
    comboing = false
}

function arcwarden.OnUpdate()
    me = Heroes.GetLocal()
    if me and NPC.GetUnitName(me) ~= "npc_dota_hero_arc_warden" or os.clock() < arcwarden.sleeptick then return end
    flux = NPC.GetAbility(me, "arc_warden_flux")
    arc_warden_magnetic_field = NPC.GetAbility(me, "arc_warden_magnetic_field")
    spark_wraith = NPC.GetAbility(me, "arc_warden_spark_wraith")
    if NPC.GetItem(me, "item_ultimate_scepter") or NPC.HasModifier(me, "modifier_item_ultimate_scepter_consumed") then
        scepter = NPC.GetAbility(me, "arc_warden_scepter")
    end
    tempest_double = NPC.GetAbility(me, "arc_warden_tempest_double")
    control_table = {}
    enemies = {}
    creeps = {}
    builds = {}
    team_creeps = {}
    tp_target = {}
    for i = 1, NPCs.Count() do
        local npc = NPCs.Get(i)
        if me and npc and me ~= npc and Entity.IsAlive(npc) then
            if  ((NPC.GetUnitName(npc) == "npc_dota_necronomicon_warrior_1" or NPC.GetUnitName(npc) == "npc_dota_necronomicon_warrior_2" or NPC.GetUnitName(npc) == "npc_dota_necronomicon_warrior_3" or NPC.GetUnitName(npc) == "npc_dota_necronomicon_archer_1" or NPC.GetUnitName(npc) == "npc_dota_necronomicon_archer_2" or NPC.GetUnitName(npc) == "npc_dota_necronomicon_archer_3") and (arcwarden.arcwarden and Entity.OwnedBy(npc, arcwarden.arcwarden) or Entity.OwnedBy(npc, me))) or (NPC.GetUnitName(npc) == "npc_dota_hero_arc_warden" and (Entity.GetOwner(me) == Entity.GetOwner(npc) or Entity.OwnedBy(npc, me))) then
                table.insert(control_table, npc)
            end
        end
    end
    if Menu.IsKeyDown(arcwarden.button) then
        if not target and Input.GetNearestHeroToCursor(Entity.GetTeamNum(me), Enum.TeamType.TEAM_ENEMY) and NPC.IsPositionInRange(Input.GetNearestHeroToCursor(Entity.GetTeamNum(me), Enum.TeamType.TEAM_ENEMY), Input.GetWorldCursorPos(), 250) then
            target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(me), Enum.TeamType.TEAM_ENEMY)
        elseif target and (not Entity.IsAlive(me) or not Entity.IsAlive(target) or Entity.IsDormant(target)) then
            target = nil
        end
    else
        if target then
            if arcwarden.clicked_unit == target then
                arcwarden.clicked_unit = nil
            end
            target = nil
        end
        arcwarden.comboing = false
    end
    if Entity.GetTeamNum(me) == 2 then
        fountain_pos = Vector(6900.0, 6649.96875, 512.0)
    else
        fountain_pos = Vector(-6700.0, -6700.03125, 512.0)
    end
    if target then
        if tempest_double and Ability.IsReady(tempest_double) then
            if Entity.GetAbsOrigin(me):Distance(Entity.GetAbsOrigin(target)):Length2D() < 2000 then
                Ability.CastNoTarget(tempest_double)
            end
        end
        if not NPC.IsAttacking(me) then
            Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Entity.GetAbsOrigin(target), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, me)
        end
        if flux and Ability.IsReady(flux) then
            Ability.CastTarget(flux, target)
        end
        if arc_warden_magnetic_field and Ability.IsReady(arc_warden_magnetic_field) then
            if Entity.GetAbsOrigin(me):Distance(Entity.GetAbsOrigin(target)):Length2D() < NPC.GetAttackRange(me) and (not arcwarden.magnetic_field_pos or arcwarden.magnetic_field_pos and Entity.GetAbsOrigin(me):Distance(arcwarden.magnetic_field_pos):Length2D() > 300) then
                Ability.CastPosition(arc_warden_magnetic_field, Entity.GetAbsOrigin(me) + Entity.GetRotation(me):GetForward():Normalized():Scaled(100))
            end
        end
        if spark_wraith and Ability.IsReady(spark_wraith) then
            if NPC.IsRunning(target) then
                Ability.CastPosition(spark_wraith, Entity.GetAbsOrigin(target) + Entity.GetRotation(target):GetForward():Normalized():Scaled(150 + NPC.GetMoveSpeed(target)))
            else
                Ability.CastPosition(spark_wraith, Entity.GetAbsOrigin(target))
            end
        end
        arcwarden.comboing = true
    end
    if next(control_table) then
        for _, unit in ipairs(control_table) do
            if unit then
                if NPC.GetUnitName(unit) == "npc_dota_hero_arc_warden" and not NPC.HasModifier(unit, "modifier_illusion") then
                    arcwarden.arcwarden = unit
                    double_flux = NPC.GetAbility(unit, "arc_warden_flux")
                    double_arc_warden_magnetic_field = NPC.GetAbility(unit, "arc_warden_magnetic_field")
                    double_spark_wraith = NPC.GetAbility(unit, "arc_warden_spark_wraith")
                    if NPC.GetItem(unit, "item_ultimate_scepter") or NPC.HasModifier(unit, "modifier_item_ultimate_scepter_consumed") then
                        double_scepter = NPC.GetAbility(unit, "arc_warden_scepter")
                    else
                        double_scepter = nil
                    end
                    tpscroll = NPC.GetItemByIndex(unit, 15)
                    --manta = NPC.GetItem(unit, "item_manta")
                    --necronomicon = NPC.GetItem(unit, "item_necronomicon_3")
                    --sheepstick = NPC.GetItem(unit, "item_sheepstick")
                    --bloodthorn = NPC.GetItem(unit, "item_bloodthorn")
                    --diffusal_blade = NPC.GetItem(unit, "item_diffusal_blade")
                    --orchid = NPC.GetItem(unit, "item_orchid")
                    invis_item = NPC.GetItem(unit, "item_invis_sword") or NPC.GetItem(unit, "item_silver_edge")
                end
                if NPC.GetUnitName(unit) == "npc_dota_necronomicon_archer_3" then
                    necronomicon_archer_purge = NPC.GetAbility(unit, "necronomicon_archer_purge")
                end
                for i, v in pairs(Entity.GetHeroesInRadius(unit, 2000, Enum.TeamType.TEAM_ENEMY)) do
                    if v and Entity.IsAlive(v) --[[and not Entity.IsDormant(v)]] then
                        table.insert(enemies, v)
                        if #enemies < 2 then
                            table.sort(enemies, function (a, b) return Entity.GetAbsOrigin(a) > Entity.GetAbsOrigin(b) end)
                        end
                    end
                end
                for i, v in pairs(Entity.GetUnitsInRadius(unit, 2000, Enum.TeamType.TEAM_ENEMY)) do
                    if v and Entity.IsAlive(v) and not Entity.IsDormant(v) and not NPC.IsWaitingToSpawn(v) and NPC.GetUnitName(v) ~= nil and (NPC.IsLaneCreep(v) or NPC.IsNeutral(v) or NPC.IsRoshan(v)) then
                        table.insert(creeps, v)
                        if #creeps < 2 then
                            table.sort(creeps, function (a, b) return Entity.GetAbsOrigin(a) > Entity.GetAbsOrigin(b) end)
                        end
                    end
                end
                for i, v in pairs(Entity.GetUnitsInRadius(unit, 2000, Enum.TeamType.TEAM_ENEMY)) do
                    if v and Entity.IsAlive(v) and (NPC.IsBarracks(v) or NPC.IsTower(v)) then
                        table.insert(builds, v)
                        if #builds < 2 then
                            table.sort(builds, function (a, b) return Entity.GetAbsOrigin(a) > Entity.GetAbsOrigin(b) end)
                        end
                    end
                end
                for i, v in pairs(Entity.GetUnitsInRadius(unit, 2000, Enum.TeamType.TEAM_FRIEND)) do
                    if v and Entity.IsAlive(v) and not Entity.IsDormant(v) and NPC.IsLaneCreep(v) and not NPC.IsWaitingToSpawn(v) then
                        table.insert(team_creeps, v)
                        if #team_creeps < 2 then
                            table.sort(team_creeps, function (a, b) return Entity.GetAbsOrigin(a) < Entity.GetAbsOrigin(b) end)
                        end
                    end
                end
                local tp_unit = NPCs.InRadius(fountain_pos, 16500, Entity.GetTeamNum(me), Enum.TeamType.TEAM_FRIEND)
                for i = 1, #tp_unit do
                    if tp_unit[i] and Entity.GetHealth(tp_unit[i]) > 573 and #Heroes.InRadius(Entity.GetAbsOrigin(tp_unit[i]), 1000, Entity.GetTeamNum(me), Enum.TeamType.TEAM_ENEMY) == 0 and  Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(tp_unit[i])):Length2D() > 2000 then
                         table.insert(tp_target, tp_unit[i])
                    end
                end
                if #tp_target < 2 then
                    table.sort(tp_target, function (a, b) return Entity.GetAbsOrigin(a) > Entity.GetAbsOrigin(b) end)
                end
                if double_scepter and Ability.IsReady(double_scepter) and not Ability.IsHidden(double_scepter) then
                    if Entity.GetAbsOrigin(me):Distance(Entity.GetAbsOrigin(unit)):Length2D() < 500 then
                        Ability.CastNoTarget(double_scepter)
                    end
                end
                if manta and Ability.IsReady(manta) then
                    --if Entity.GetAbsOrigin(me):Distance(Entity.GetAbsOrigin(unit)):Length2D() < 500 then
                        Ability.CastNoTarget(manta)
                    --end
                end
                if necronomicon and Ability.IsReady(necronomicon) then
                    --if Entity.GetAbsOrigin(me):Distance(Entity.GetAbsOrigin(unit)):Length2D() < 500 then
                        Ability.CastNoTarget(necronomicon)
                    --end
                end
                if target then
                    if not NPC.HasModifier(unit, "modifier_teleporting") then
                        if (not arcwarden.hasActivity(unit, target) or arcwarden.clicked_unit ~= target) and not arcwarden.isAttacking(unit, target) then
                            Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_PING_ABILITY , target, Entity.GetAbsOrigin(target), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                        end
                        if double_flux and Ability.IsReady(double_flux) then
                            Ability.CastTarget(double_flux, target)
                        end
                        if double_arc_warden_magnetic_field and Ability.IsReady(double_arc_warden_magnetic_field) then
                            if Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(target)):Length2D() < NPC.GetAttackRange(unit) then
                                Ability.CastPosition(double_arc_warden_magnetic_field, Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100))
                                arcwarden.magnetic_field_pos = Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100)
                            end
                        end
                        if double_spark_wraith and Ability.IsReady(double_spark_wraith) then
                            if NPC.IsRunning(target) then
                                Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(target) + Entity.GetRotation(target):GetForward():Normalized():Scaled(150 + NPC.GetMoveSpeed(target)))
                            else
                                Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(target))
                            end
                        end
                        if necronomicon_archer_purge and Ability.IsReady(necronomicon_archer_purge) then
                            Ability.CastTarget(necronomicon_archer_purge, target)
                        end
                        arcwarden.clicked_unit = target
                    end
                else
                    if enemies[1] then
                        if invis_item and Ability.IsReady(invis_item) then
                           if not NPC.HasModifier(unit, "modifier_truesight") then
                                Ability.CastNoTarget(invis_item)
                           end
                        end
                        if (not invis_item or invis_item and Ability.SecondsSinceLastUse(invis_item) > 1) and not NPC.HasState(unit, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) or NPC.HasModifier(unit, "modifier_truesight") then
                            if sheepstick and Ability.IsReady(sheepstick) then
                                Ability.CastTarget(sheepstick, enemies[1])
                            end
                            if bloodthorn and Ability.IsReady(bloodthorn) then
                                Ability.CastTarget(bloodthorn, enemies[1])
                            end
                            if double_flux and Ability.IsReady(double_flux) then
                                Ability.CastTarget(double_flux, enemies[1])
                            end
                            if double_arc_warden_magnetic_field and Ability.IsReady(double_arc_warden_magnetic_field) then
                                if Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(enemies[1])):Length2D() < NPC.GetAttackRange(unit) then
                                    Ability.CastPosition(double_arc_warden_magnetic_field, Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100))
                                    arcwarden.magnetic_field_pos = Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100)
                                end
                            end
                            if double_spark_wraith and Ability.IsReady(double_spark_wraith) then
                                if NPC.IsRunning(enemies[1]) then
                                    Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(enemies[1]) + Entity.GetRotation(enemies[1]):GetForward():Normalized():Scaled(150 + NPC.GetMoveSpeed(enemies[1])))
                                else
                                    Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(enemies[1]))
                                end
                            end
                            if necronomicon_archer_purge and Ability.IsReady(necronomicon_archer_purge) then
                                Ability.CastTarget(necronomicon_archer_purge, enemies[1])
                            end
                        end
                        if NPC.HasState(unit, Enum.ModifierState.MODIFIER_STATE_INVISIBLE) then
                            if Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(enemies[1])):Length2D() > 300 and not NPC.HasModifier(unit, "modifier_truesight") then
                                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, Entity.GetAbsOrigin(enemies[1]), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                            else
                                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemies[1], Entity.GetAbsOrigin(enemies[1]), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                            end
                        else
                            if (not arcwarden.hasActivity(unit, enemies[1]) or arcwarden.clicked_unit ~= enemies[1]) and not arcwarden.isAttacking(unit, enemies[1]) then
                                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, enemies[1], Entity.GetAbsOrigin(enemies[1]), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                            end
                        end
                        arcwarden.clicked_unit = enemies[1]
                    else
                        if tp_target[1] and tpscroll and Ability.IsReady(tpscroll) and Input.IsKeyDown(Enum.ButtonCode.KEY_SPACE) and not arcwarden.comboing  then
                            Ability.CastTarget(tpscroll, tp_target[1])
                        else
                            if creeps[1] then
                                if double_flux and Ability.IsReady(double_flux) then
                                    --Ability.CastTarget(double_flux, creeps[1])
                                end
                                if double_arc_warden_magnetic_field and Ability.IsReady(double_arc_warden_magnetic_field) then
                                    if Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(creeps[1])):Length2D() < NPC.GetAttackRange(unit) then
                                        Ability.CastPosition(double_arc_warden_magnetic_field, Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100))
                                        arcwarden.magnetic_field_pos = Entity.GetAbsOrigin(unit) + Entity.GetRotation(unit):GetForward():Normalized():Scaled(100)
                                    end
                                end
                                if double_spark_wraith and Ability.IsReady(double_spark_wraith) then
                                    if NPC.IsRunning(creeps[1]) then
                                        Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(creeps[1]) + Entity.GetRotation(creeps[1]):GetForward():Normalized():Scaled(150 + NPC.GetMoveSpeed(creeps[1])))
                                    else
                                        Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(creeps[1]))
                                    end
                                end
                                if (not arcwarden.hasActivity(unit, creeps[1]) or arcwarden.clicked_unit ~= creeps[1]) and not arcwarden.blockedActivity(unit) and not arcwarden.isAttacking(unit, creeps[1]) then
                                    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, creeps[1], Entity.GetAbsOrigin(creeps[1]), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                                end
                                arcwarden.clicked_unit = creeps[1]
                            else
                                if builds[1] then
                                    if double_spark_wraith and Ability.IsReady(double_spark_wraith) then
                                        Ability.CastPosition(double_spark_wraith, Entity.GetAbsOrigin(builds[1]) + ((fountain_pos - Entity.GetAbsOrigin(builds[1])):Normalized():Scaled(arcwarden.pout)))
                                        if NPC.GetActivity(unit) == Enum.GameActivity.ACT_DOTA_CAST_ABILITY_3 then
                                            arcwarden.pout = arcwarden.pout + 375
                                        end
                                    end
                                    if (not arcwarden.hasActivity(unit, builds[1]) or arcwarden.clicked_unit ~= builds[1]) and not arcwarden.blockedActivity(unit) then
                                        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, builds[1], Entity.GetAbsOrigin(builds[1]), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                                    end
                                    arcwarden.clicked_unit = builds[1]
                                else
                                    if Entity.GetAbsOrigin(unit):Distance(Entity.GetAbsOrigin(me)):Length2D() < 2000 and Input.IsKeyDown(Enum.ButtonCode.MOUSE_RIGHT) then
                                        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, nil, Input.GetWorldCursorPos(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                                    else
                                        if team_creeps[1] then
                                            if not arcwarden.hasActivity(unit, team_creeps[1]) or arcwarden.clicked_unit ~= team_creeps[1] then
                                                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, nil, Entity.GetAbsOrigin(team_creeps[1]) + Entity.GetRotation(team_creeps[1]):GetForward():Normalized():Scaled(600), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, unit)
                                            end
                                            arcwarden.clicked_unit = team_creeps[1]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        arcwarden.arcwarden = nil
        arcwarden.pout = 0
    end
    arcwarden.sleeptick = os.clock() + 0.35
end

function arcwarden.OnGameEnd()
    arcwarden.comboing = false
    control_table = {}
    enemies = {}
    creeps = {}
    builds = {}
    team_creeps = {}
    tp_target = {}
end

function arcwarden.hasActivity(npc)
    return NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_ATTACK or NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_ATTACK2 or NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_RUN 
end

function arcwarden.blockedActivity(npc)
    return NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_CAST_ABILITY_1 or NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_CAST_ABILITY_2 or NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_CAST_ABILITY_3 
end

function arcwarden.isAttacking(npc, target)
    return NPC.GetActivity(npc) == Enum.GameActivity.ACT_DOTA_IDLE and NPC.FindFacingNPC(npc) == target and Entity.GetAbsOrigin(npc):Distance(Entity.GetAbsOrigin(target)):Length2D() < NPC.GetAttackRange(npc)
end

return arcwarden

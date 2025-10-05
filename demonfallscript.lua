local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ezy Demonfall Hub",
   Icon = 0, 
   LoadingTitle = "Hub do ezy 🤣",
   LoadingSubtitle = "by ezy.xyz",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "ezy hub" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = false },
   KeySystem = true,
   KeySettings = {
      Title = "Sistema de Key", Subtitle = "Chave atual: ezy", Note = "👍",
      FileName = "Key", SaveKey = true, GrabKeyFromSite = false,
      Key = {"ezy","Ezy","fodase"}
   }
})

Rayfield:Notify({
   Title = "Script Carregado!",
   Content = "Pré-scans em andamento. Aguarde a UI...",
   Duration = 7,
})

-- ===================================================================
-- // SEÇÃO DE LÓGICAS E PRÉ-SCANS //
-- ===================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- (Todas as suas lógicas de pré-scan e funções de farm, anti-stun, etc. estão aqui)
local manualNpcLocations = { ["Hayakawa"] = Vector3.new(919, 757, -2256), ["Vendedor de Joias (Hayakawa)"] = Vector3.new(827, 758, -2248), ["Sopa (Hayakawa)"] = Vector3.new(560, 755, -2382), ["Haori (Hayakawa)"] = Vector3.new(837, 757, -1988), ["Caverna Oni"] = Vector3.new(-737, 695, -1513), ["Okuyia Village"] = Vector3.new(-3200, 704, -1162), ["Okuyia Tavern"] = Vector3.new(-3419, 705, -1578), ["Urokodaki"] = Vector3.new(-922, 846, -990), ["QG Slayers"] = Vector3.new(-1834, 871, -6391) }; local manualNpcNames = {}; for name, position in pairs(manualNpcLocations) do table.insert(manualNpcNames, name) end
local trinketSpawnPoints, trinketCount, spawnsConhecidos = {}, 0, {}; task.wait(5); for i, descendant in pairs(Workspace:GetDescendants()) do if descendant.Name == "Spawn" then local parentModel = descendant:FindFirstAncestorOfClass("Model"); if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then local position = nil; if descendant:IsA("BasePart") then position = descendant.Position elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then position = descendant.Value.Position end; if position and not spawnsConhecidos[position] then spawnsConhecidos[position] = true; trinketCount = trinketCount + 1; table.insert(trinketSpawnPoints, position) end end end end
local foundNpcs, foundNpcNames, npcCount = {}, {}, 0; for i, descendant in pairs(Workspace:GetDescendants()) do if descendant:IsA("Humanoid") then local model = descendant.Parent; local player = Players:GetPlayerFromCharacter(model); local parentName = model.Parent.Name; if not player and (parentName == "Npcs" or parentName == "Shops") then local rootPart = model:FindFirstChild("HumanoidRootPart"); if rootPart then npcCount = npcCount + 1; local uniqueName = model.Name .. " (" .. parentName .. ")"; if foundNpcs[uniqueName] then uniqueName = uniqueName .. " #" .. npcCount end; foundNpcs[uniqueName] = rootPart.Position; table.insert(foundNpcNames, uniqueName) end end end end; table.sort(foundNpcNames)
local playerTeleportLocations, playerNames = {}, {}; for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then table.insert(playerNames, player.Name); playerTeleportLocations[player.Name] = player end end; if #playerNames > 0 then table.insert(playerNames, 1, "-- Selecione um Jogador --") else playerNames = {"Nenhum outro jogador encontrado"} end
local farmingEnabled = false; local function startFarming() end
local antiStunConnections = {}; local NORMAL_WALKSPEED = 16; local function applyAntiStun(character) local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end; if antiStunConnections.PlatformStand then antiStunConnections.PlatformStand:Disconnect() end; if antiStunConnections.WalkSpeed then antiStunConnections.WalkSpeed:Disconnect() end; antiStunConnections.PlatformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function() if humanoid.PlatformStand == true then humanoid.PlatformStand = false end end); antiStunConnections.WalkSpeed = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if humanoid.WalkSpeed == 0 then humanoid.WalkSpeed = NORMAL_WALKSPEED end end) end; local function removeAntiStun() for _, c in pairs(antiStunConnections) do c:Disconnect() end; table.clear(antiStunConnections); if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = NORMAL_WALKSPEED end end
local noFallDamageConnections = {}; local function applyNoFallDamage(character) local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end; if noFallDamageConnections.StateChanged then noFallDamageConnections.StateChanged:Disconnect() end; noFallDamageConnections.StateChanged = humanoid.StateChanged:Connect(function(old, new) if new == Enum.HumanoidStateType.Landed then local healthBefore = humanoid.Health; task.wait(); if humanoid.Health < healthBefore then humanoid.Health = healthBefore end end end) end; local function removeNoFallDamage() for _, c in pairs(noFallDamageConnections) do c:Disconnect() end; table.clear(noFallDamageConnections) end
local currentWalkSpeed = 16; LocalPlayer.CharacterAdded:Connect(function(character) task.wait(0.5); local humanoid = character:FindFirstChildOfClass("Humanoid"); if humanoid then humanoid.WalkSpeed = currentWalkSpeed end end)
local espEnabled = false; local activeHighlights = {}; local function updateEsp() end

-- ===================================================================
-- // SEÇÃO DE INTERFACE (CRIADA APÓS TODOS OS SCANS) //
-- ===================================================================

-- (Omitido por brevidade: Funções completas de startFarming e updateEsp)
-- ...

-- ABA 1: TELEPORTES
local TeleportsTab = Window:CreateTab("📍| Teleportes", nil)
TeleportsTab:CreateSection("Ferramentas"); TeleportsTab:CreateButton({Name = "Pegar posição atual (F9)",Callback = function() local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if hrp then print("Sua Posição Atual: " .. tostring(hrp.Position)); print("Formato para Script: Vector3.new("..hrp.Position.X..", "..hrp.Position.Y..", "..hrp.Position.Z..")") end end})
TeleportsTab:CreateSection("Destinos Salvos"); TeleportsTab:CreateDropdown({Name = "Destinos Manuais", Options = manualNpcNames, CurrentOption = {manualNpcNames[1]}, MultipleOptions = false, Flag = "NpcTeleportDropdown", Callback = function(O) local pos=manualNpcLocations[O[1]]; local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if pos and hrp then hrp.CFrame=CFrame.new(pos); Rayfield:Notify({Title="Teleporte",Content="Movido para: "..O[1],Duration=4}) end end, })
TeleportsTab:CreateSection("NPCs & Lojas"); TeleportsTab:CreateDropdown({Name = "NPCs e Lojas ("..npcCount..")", Options = #foundNpcNames > 0 and foundNpcNames or {"Nenhum"}, CurrentOption = {#foundNpcNames > 0 and foundNpcNames[1] or "Nenhum"}, MultipleOptions = false, Flag = "DynamicNpcDropdown", Callback = function(S) local pos=foundNpcs[S[1]]; local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if pos and hrp then hrp.CFrame=CFrame.new(pos)*CFrame.new(0,3,0); Rayfield:Notify({Title="Teleporte",Content="Movido para: "..S[1],Duration=3}) end end, })
TeleportsTab:CreateSection("Jogadores"); TeleportsTab:CreateDropdown({Name = "Jogadores no Servidor ("..#playerTeleportLocations..")", Options = playerNames, CurrentOption = {playerNames[1]}, MultipleOptions = false, Flag = "PlayerTeleportDropdown", Callback = function(S) local name=S[1]; if name=="-- Selecione um Jogador --" or name=="Nenhum outro jogador encontrado" then return end; local target=playerTeleportLocations[name]; if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,5,0); Rayfield:Notify({Title="Teleporte",Content="Seguindo: "..name,Duration=3}) end else Rayfield:Notify({Title="Erro",Content="Não foi possível encontrar o personagem de "..name,Duration=4}) end end, })

-- ABA 2: AUTO-FARM
local FarmTab = Window:CreateTab("🚜 | Auto-Farm", nil)
FarmTab:CreateLabel("Inicie o farm para coletar e descobrir trinkets."); FarmTab:CreateDivider(); FarmTab:CreateToggle({Name = "Iniciar Auto-Farm 'que Aprende'", CurrentValue = false, Flag = "AutoFarmToggle", Callback = function(Value) farmingEnabled=Value; if farmingEnabled then task.spawn(startFarming) else print("Toggle desligado.") end end, })

-- ABA 3: PLAYER (COM A CORREÇÃO FINAL)
local PlayerTab = Window:CreateTab("🏃 | Player", nil)
PlayerTab:CreateSection("Modificações de Combate")
PlayerTab:CreateToggle({Name = "Anti-Stun / No Knockback", CurrentValue = false, Flag = "AntiStunToggle", Callback = function(Value) if Value then if LocalPlayer.Character then applyAntiStun(LocalPlayer.Character) end; antiStunConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyAntiStun) else removeAntiStun() end end, })
PlayerTab:CreateToggle({ Name = "No Fall Damage", CurrentValue = false, Flag = "NoFallDamageToggle", Callback = function(Value) if Value then if LocalPlayer.Character then applyNoFallDamage(LocalPlayer.Character) end; noFallDamageConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyNoFallDamage) else removeNoFallDamage() end end, })

PlayerTab:CreateSection("Modificações de Movimento")
-- ##### SLIDER REMOVIDO E SUBSTITUÍDO POR UM CAMPO DE TEXTO #####
PlayerTab:CreateInput({
    Name = "Definir WalkSpeed",
    Placeholder = "Padrão: 16",
    Flag = "WalkSpeedInput_EzyHub",
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed then
            currentWalkSpeed = speed -- Salva o valor para ser usado ao respawnar
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = speed
            end
            Rayfield:Notify({Title="WalkSpeed", Content="Velocidade alterada para " .. speed, Duration=3})
        else
            Rayfield:Notify({Title="Erro", Content="'" .. Text .. "' não é um número válido.", Duration=4})
        end
    end,
})

-- ABA 4: VISUALS
local VisualsTab = Window:CreateTab("👁️ | Visuals", nil)
VisualsTab:CreateSection("ESP")
PlayerTab:CreateToggle({
    Name = "Player & Mob ESP", CurrentValue = false, Flag = "EspToggle",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then task.spawn(updateEsp) end
    end,
})

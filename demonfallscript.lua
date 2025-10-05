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
print("==============================================")
print("--- [ INICIANDO PRÉ-SCANS GLOBAIS ] ---")
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
-- Lógica de Super Resistência (agora com valor fixo)
local damageReductionEnabled = false; local resistancePercent = 0.5; local drConnection = {}; local lastHealth = 100; local function applyDamageReduction(character) local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end; lastHealth = humanoid.Health; if drConnection.HealthChanged then drConnection.HealthChanged:Disconnect() end; drConnection.HealthChanged = humanoid.HealthChanged:Connect(function(newHealth) if damageReductionEnabled and newHealth < lastHealth then local damageTaken = lastHealth - newHealth; local healthToHeal = damageTaken * resistancePercent; humanoid.Health = humanoid.Health + healthToHeal end; lastHealth = humanoid.Health end); drConnection.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function() lastHealth = humanoid.Health end) end; local function removeDamageReduction() for _, c in pairs(drConnection) do c:Disconnect() end; table.clear(drConnection) end
local espEnabled = false; local activeHighlights = {}; local function updateEsp() end

-- (Redefinição das funções completas de startFarming e updateEsp omitidas para economizar espaço)
function startFarming() print(">> AUTO-FARM 'QUE APRENDE' INICIADO! <<"); while farmingEnabled do for i, spawnPos in pairs(trinketSpawnPoints) do if not farmingEnabled then print("Farm interrompido."); return end; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then print("Personagem não encontrado."); task.wait(5); continue end; hrp.CFrame = CFrame.new(spawnPos) * CFrame.new(0, 3, 0); task.wait(1); local trinketFound = false; for _, descendant in pairs(Workspace:GetDescendants()) do if not farmingEnabled then break end; if descendant:IsA("ProximityPrompt") then local itemModel = descendant:FindFirstAncestorOfClass("Model") or descendant.Parent; local itemPart = descendant.Parent; if itemPart and itemPart:IsA("BasePart") and (itemPart.Position - spawnPos).Magnitude < 30 and not itemModel:FindFirstChildOfClass("Humanoid") then print("Trinket '"..itemModel.Name.."' encontrada. Coletando..."); hrp.CFrame = itemPart.CFrame * CFrame.new(0, -2, 0); task.wait(0.3); descendant:InputHoldBegin(); Rayfield:Notify({ Title = "Item Coletado!", Content = "Você pegou: " .. itemModel.Name, Duration = 4 }); task.wait(delayAfterCollect); trinketFound = true; break end end; if descendant.Name == "Spawn" then local parentModel = descendant:FindFirstAncestorOfClass("Model"); if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then local position = nil; if descendant:IsA("BasePart") then position = descendant.Position elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then position = descendant.Value.Position end; if position and not spawnsConhecidos[position] then spawnsConhecidos[position] = true; table.insert(trinketSpawnPoints, position); print("+++ NOVO PONTO DE SPAWN DESCOBERTO! Total: " .. #trinketSpawnPoints .. " +++") end end end end; end; print("Ciclo completo. Aguardando " .. delayAfterCycle .. "s..."); for i = delayAfterCycle, 1, -1 do if not farmingEnabled then print("Farm interrompido."); return end; task.wait(1) end end end
function updateEsp() local healthBarSize = UDim2.new(0, 125, 0, 18); local healthBarOffset = Vector3.new(0, 2.5, 0); local healthBarBackgroundColor = Color3.fromRGB(20, 20, 20); local playerHealthColor = Color3.fromRGB(80, 80, 255); local mobHealthColor = Color3.fromRGB(255, 50, 50); local textColor = Color3.fromRGB(255, 255, 255); while espEnabled do local charactersInView = {}; local function createHealthBar(character, healthColor) local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return nil end; local gui = Instance.new("BillboardGui"); gui.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"); gui.Size = healthBarSize; gui.StudsOffset = healthBarOffset; gui.AlwaysOnTop = true; local bg = Instance.new("Frame", gui); bg.Name = "Background"; bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = healthBarBackgroundColor; bg.BorderSizePixel = 0; local bar = Instance.new("Frame", bg); bar.Name = "HealthBar"; bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0); bar.BackgroundColor3 = healthColor; bar.BorderSizePixel = 0; local text = Instance.new("TextLabel", bg); text.Name = "HealthText"; text.Size = UDim2.new(1, 0, 1, 0); text.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth); text.TextColor3 = textColor; text.BackgroundTransparency = 1; text.Font = Enum.Font.SourceSansBold; text.TextScaled = true; gui.Parent = game:GetService("CoreGui"); return gui end; local targets = {}; for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character then table.insert(targets, { Target=player.Character, Color=playerHealthColor }) end end; for _, model in pairs(Workspace:GetChildren()) do local humanoid = model:FindFirstChildOfClass("Humanoid"); if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(model) and model.Parent == Workspace then table.insert(targets, { Target=model, Color=mobHealthColor }) end end; for _, data in pairs(targets) do local character = data.Target; table.insert(charactersInView, character); if not activeHighlights[character] then local highlight = Instance.new("Highlight"); highlight.FillColor = data.Color; highlight.OutlineColor = data.Color; highlight.Parent = character; local healthGui = createHealthBar(character, data.Color); activeHighlights[character] = { Highlight = highlight, HealthGui = healthGui } end end; for character, data in pairs(activeHighlights) do local humanoid = character:FindFirstChildOfClass("Humanoid"); if humanoid and data.HealthGui then local bar = data.HealthGui:FindFirstChild("HealthBar", true); local text = data.HealthGui:FindFirstChild("HealthText", true); if bar and text then local healthPercent = humanoid.Health / humanoid.MaxHealth; bar.Size = UDim2.new(healthPercent, 0, 1, 0); text.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) end end end; for character, data in pairs(activeHighlights) do if not table.find(charactersInView, character) or not character.Parent or character:FindFirstChildOfClass("Humanoid").Health <= 0 then if data.Highlight then data.Highlight:Destroy() end; if data.HealthGui then data.HealthGui:Destroy() end; activeHighlights[character] = nil end end; task.wait(0.25) end; for _, data in pairs(activeHighlights) do if data.Highlight then data.Highlight:Destroy() end; if data.HealthGui then data.HealthGui:Destroy() end end; activeHighlights = {} end

-- ===================================================================
-- // SEÇÃO DE INTERFACE (CRIADA APÓS TODOS OS SCANS) //
-- ===================================================================

-- ABA 1: TELEPORTES
local TeleportsTab = Window:CreateTab("📍| Teleportes", nil)
TeleportsTab:CreateSection("Ferramentas"); TeleportsTab:CreateButton({Name = "Pegar posição atual (F9)",Callback = function() local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if hrp then print("Sua Posição Atual: " .. tostring(hrp.Position)); print("Formato para Script: Vector3.new("..hrp.Position.X..", "..hrp.Position.Y..", "..hrp.Position.Z..")") end end})
TeleportsTab:CreateSection("Destinos Salvos"); TeleportsTab:CreateDropdown({Name = "Destinos Manuais", Options = manualNpcNames, CurrentOption = {manualNpcNames[1]}, MultipleOptions = false, Flag = "NpcTeleportDropdown", Callback = function(O) local pos=manualNpcLocations[O[1]]; local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if pos and hrp then hrp.CFrame=CFrame.new(pos); Rayfield:Notify({Title="Teleporte",Content="Movido para: "..O[1],Duration=4}) end end, })
TeleportsTab:CreateSection("NPCs & Lojas"); TeleportsTab:CreateDropdown({Name = "NPCs e Lojas ("..npcCount..")", Options = #foundNpcNames > 0 and foundNpcNames or {"Nenhum"}, CurrentOption = {#foundNpcNames > 0 and foundNpcNames[1] or "Nenhum"}, MultipleOptions = false, Flag = "DynamicNpcDropdown", Callback = function(S) local pos=foundNpcs[S[1]]; local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if pos and hrp then hrp.CFrame=CFrame.new(pos)*CFrame.new(0,3,0); Rayfield:Notify({Title="Teleporte",Content="Movido para: "..S[1],Duration=3}) end end, })
TeleportsTab:CreateSection("Jogadores"); TeleportsTab:CreateDropdown({Name = "Jogadores no Servidor ("..#playerTeleportLocations..")", Options = playerNames, CurrentOption = {playerNames[1]}, MultipleOptions = false, Flag = "PlayerTeleportDropdown", Callback = function(S) local name=S[1]; if name=="-- Selecione um Jogador --" or name=="Nenhum outro jogador encontrado" then return end; local target=playerTeleportLocations[name]; if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,5,0); Rayfield:Notify({Title="Teleporte",Content="Seguindo: "..name,Duration=3}) end else Rayfield:Notify({Title="Erro",Content="Não foi possível encontrar o personagem de "..name,Duration=4}) end end, })

-- ABA 2: AUTO-FARM
local FarmTab = Window:CreateTab("🚜 | Auto-Farm", nil)
FarmTab:CreateLabel("Inicie o farm para coletar e descobrir trinkets."); FarmTab:CreateDivider(); FarmTab:CreateToggle({Name = "Iniciar Auto-Farm 'que Aprende'", CurrentValue = false, Flag = "AutoFarmToggle", Callback = function(Value) farmingEnabled=Value; if farmingEnabled then task.spawn(startFarming) else print("Toggle desligado.") end end, })

-- ABA 3: PLAYER (COM A CORREÇÃO FINAL - SEM SLIDERS)
local PlayerTab = Window:CreateTab("🏃 | Player", nil)
PlayerTab:CreateSection("Modificações de Combate")
PlayerTab:CreateToggle({Name = "Anti-Stun / No Knockback", CurrentValue = false, Flag = "AntiStunToggle", Callback = function(Value) if Value then if LocalPlayer.Character then applyAntiStun(LocalPlayer.Character) end; antiStunConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyAntiStun) else removeAntiStun() end end, })
PlayerTab:CreateToggle({ Name = "No Fall Damage", CurrentValue = false, Flag = "NoFallDamageToggle", Callback = function(Value) if Value then if LocalPlayer.Character then applyNoFallDamage(LocalPlayer.Character) end; noFallDamageConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyNoFallDamage) else removeNoFallDamage() end end, })
PlayerTab:CreateToggle({ Name = "Ativar Resistência (50%)", CurrentValue = false, Flag = "DamageReductionToggle", Callback = function(Value) damageReductionEnabled = Value; if Value then resistancePercent = 0.5; if LocalPlayer.Character then applyDamageReduction(LocalPlayer.Character) end; drConnection.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyDamageReduction) else removeDamageReduction() end end })

PlayerTab:CreateSection("Modificações de Movimento")
PlayerTab:CreateInput({
    Name = "Definir WalkSpeed",
    Placeholder = "Padrão: 16",
    Flag = "WalkSpeedInput_EzyHub",
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed then
            currentWalkSpeed = speed
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
VisualsTab:CreateToggle({
    Name = "Player & Mob ESP", CurrentValue = false, Flag = "EspToggle",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then task.spawn(updateEsp) end
    end,
})

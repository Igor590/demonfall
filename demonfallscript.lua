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

-- PRÉ-SCAN 1: TELEPORTES MANUAIS
local manualNpcLocations = {
    ["Hayakawa"] = Vector3.new(919, 757, -2256), ["Vendedor de Joias (Hayakawa)"] = Vector3.new(827, 758, -2248),
    ["Sopa (Hayakawa)"] = Vector3.new(560, 755, -2382), ["Haori (Hayakawa)"] = Vector3.new(837, 757, -1988),
    ["Caverna Oni"] = Vector3.new(-737, 695, -1513), ["Okuyia Village"] = Vector3.new(-3200, 704, -1162),
    ["Okuyia Tavern"] = Vector3.new(-3419, 705, -1578), ["Urokodaki"] = Vector3.new(-922, 846, -990),
    ["QG Slayers"] = Vector3.new(-1834, 871, -6391), ["💥 Raid 💥"] = Vector3.new(7136, 1752, 1447)
}
local manualNpcNames = {}
for name, position in pairs(manualNpcLocations) do table.insert(manualNpcNames, name) end

-- PRÉ-SCAN 2: PONTOS DE FARM DE TRINKETS
local trinketSpawnPoints, trinketCount = {}, 0
task.wait(5)
for i, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
    if descendant.Name == "Spawn" then
        local parentModel = descendant:FindFirstAncestorOfClass("Model")
        if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then
            local position = nil
            if descendant:IsA("BasePart") then position = descendant.Position
            elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then position = descendant.Value.Position end
            if position then trinketCount = trinketCount + 1; table.insert(trinketSpawnPoints, position) end
        end
    end
end
print("--- [ PRÉ-SCAN DE TRINKETS FINALIZADO: " .. trinketCount .. " PONTOS ENCONTRADOS ] ---")

-- PRÉ-SCAN 3: NPCS E LOJAS DINÂMICOS
local foundNpcs = {}
local foundNpcNames = {}
local npcCount = 0
for i, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
    if descendant:IsA("Humanoid") then
        local model = descendant.Parent
        local player = Players:GetPlayerFromCharacter(model)
        local parentName = model.Parent.Name
        if not player and (parentName == "Npcs" or parentName == "Shops") then
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            if rootPart then
                npcCount = npcCount + 1
                local uniqueName = model.Name .. " (" .. parentName .. ")"
                if foundNpcs[uniqueName] then uniqueName = uniqueName .. " #" .. npcCount end
                foundNpcs[uniqueName] = rootPart.Position
                table.insert(foundNpcNames, uniqueName)
            end
        end
    end
end
table.sort(foundNpcNames)
print("--- [ PRÉ-SCAN DE NPCS FINALIZADO: " .. npcCount .. " ALVOS ENCONTRADOS ] ---")

local antiStunConnections = {} -- Tabela para guardar nossas conexões de eventos
local NORMAL_WALKSPEED = 16 -- Velocidade de caminhada padrão, ajuste se for diferente no jogo

local function applyAntiStun(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Remove conexões antigas se existirem, para evitar duplicatas
    if antiStunConnections.PlatformStand then antiStunConnections.PlatformStand:Disconnect() end
    if antiStunConnections.WalkSpeed then antiStunConnections.WalkSpeed:Disconnect() end

    -- Vigia a propriedade PlatformStand
    antiStunConnections.PlatformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if humanoid.PlatformStand == true then
            humanoid.PlatformStand = false
            print("Anti-Stun: Efeito de PlatformStand bloqueado.")
        end
    end)

    -- Vigia a propriedade WalkSpeed
    antiStunConnections.WalkSpeed = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed == 0 then
            humanoid.WalkSpeed = NORMAL_WALKSPEED
            print("Anti-Stun: Efeito de WalkSpeed = 0 bloqueado.")
        end
    end)
end

local function removeAntiStun()
    for _, connection in pairs(antiStunConnections) do
        connection:Disconnect()
    end
    table.clear(antiStunConnections)
    -- Restaura a velocidade para o padrão caso o jogador desative o script enquanto estiver travado
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = NORMAL_WALKSPEED
    end
    print("Anti-Stun Desativado.")
end

-- PRÉ-SCAN 4: JOGADORES NO SERVIDOR
local playerTeleportLocations = {}
local playerNames = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerNames, player.Name)
        playerTeleportLocations[player.Name] = player
    end
end
if #playerNames > 0 then
    table.insert(playerNames, 1, "-- Selecione um Jogador --")
else
    playerNames = {"Nenhum outro jogador encontrado"}
end
print("--- [ PRÉ-SCAN DE JOGADORES FINALIZADO: " .. #playerTeleportLocations .. " JOGADORES ENCONTRADOS ] ---")


-- LÓGICA DO AUTO-FARM "QUE APRENDE"
local farmingEnabled = false
local delayAfterCollect = 1.5
local delayAfterCycle = 120
local spawnsConhecidos = {} -- Adicionado para a lógica de aprendizado

local function startFarming()
    print(">> AUTO-FARM 'QUE APRENDE' INICIADO! <<")
    local player = game:GetService("Players").LocalPlayer
    while farmingEnabled do
        print("==============================================")
        print("Iniciando novo ciclo de farm em " .. #trinketSpawnPoints .. " pontos conhecidos.")
        for i, spawnPos in pairs(trinketSpawnPoints) do
            if not farmingEnabled then print("Farm interrompido."); return end
            
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then print("Personagem não encontrado."); task.wait(5); continue end
            
            humanoidRootPart.CFrame = CFrame.new(spawnPos) * CFrame.new(0, 3, 0)
            task.wait(1)
            
            local trinketFound = false
            for _, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
                if not farmingEnabled then break end
                
                if descendant:IsA("ProximityPrompt") then
                    local itemModel = descendant:FindFirstAncestorOfClass("Model") or descendant.Parent
                    local itemPart = descendant.Parent
                    if itemPart and itemPart:IsA("BasePart") and (itemPart.Position - spawnPos).Magnitude < 30 and not itemModel:FindFirstChildOfClass("Humanoid") then
                        print("Trinket '"..itemModel.Name.."' encontrada no ponto #"..i..". Coletando...")
                        humanoidRootPart.CFrame = itemPart.CFrame * CFrame.new(0, -2, 0); task.wait(0.3)
                        descendant:InputHoldBegin()
                        Rayfield:Notify({ Title = "Item Coletado!", Content = "Você pegou: " .. itemModel.Name, Duration = 4 })
                        task.wait(delayAfterCollect)
                        trinketFound = true
                        break
                    end
                end

                if descendant.Name == "Spawn" then
                    local parentModel = descendant:FindFirstAncestorOfClass("Model")
                    if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then
                        local position = nil
                        if descendant:IsA("BasePart") then position = descendant.Position
                        elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then position = descendant.Value.Position end
                        if position and not spawnsConhecidos[position] then
                            spawnsConhecidos[position] = true
                            table.insert(trinketSpawnPoints, position)
                            print("+++ NOVO PONTO DE SPAWN DESCOBERTO! Total agora: " .. #trinketSpawnPoints .. " +++")
                        end
                    end
                end
            end
            if not trinketFound then print("Nenhuma trinket no ponto #"..i..". Próximo.") end
        end
        
        print("==============================================")
        print("Ciclo completo. Aguardando " .. delayAfterCycle .. " segundos...")
        for i = delayAfterCycle, 1, -1 do if not farmingEnabled then print("Farm interrompido."); return end; task.wait(1) end
    end
    print(">> AUTO-FARM FINALIZADO. <<")
end

local espEnabled = false
local activeHighlights = {}

local function updateEsp()
    -- Configurações da Barra de Vida
    local healthBarSize = UDim2.new(1.5, 0, 0.2, 0)
    local healthBarOffset = Vector3.new(0, 1.5, 0)
    local healthBarBackgroundColor = Color3.fromRGB(20, 20, 20)
    local playerHealthColor = Color3.fromRGB(80, 80, 255) -- Um azul para vida de players
    local mobHealthColor = Color3.fromRGB(255, 50, 50) -- O vermelho que você pediu
    local textColor = Color3.fromRGB(255, 255, 255)

    while espEnabled do
        local charactersInView = {}

        -- Função interna para criar a barra de vida
        local function createHealthBar(character, healthColor)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return nil, nil end
            
            local gui = Instance.new("BillboardGui")
            gui.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            gui.Size = healthBarSize
            gui.StudsOffset = healthBarOffset
            gui.AlwaysOnTop = true
            
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = healthBarBackgroundColor
            bg.BorderSizePixel = 0
            bg.Parent = gui
            
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            bar.BackgroundColor3 = healthColor
            bar.BorderSizePixel = 0
            bar.Parent = bg
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            text.TextColor3 = textColor
            text.BackgroundTransparency = 1
            text.Font = Enum.Font.SourceSansBold
            text.TextScaled = true
            text.Parent = bg
            
            -- Conecta o evento para atualizar a vida em tempo real
            local connection = humanoid.HealthChanged:Connect(function(newHealth)
                if not gui.Parent then return end -- Se a GUI já foi destruída, não faz nada
                bar.Size = UDim2.new(newHealth / humanoid.MaxHealth, 0, 1, 0)
                text.Text = math.floor(newHealth) .. "/" .. math.floor(humanoid.MaxHealth)
            end)
            
            gui.Parent = game:GetService("CoreGui")
            return gui, connection
        end

        -- Passo 1: Escanear Players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                table.insert(charactersInView, character)
                if not activeHighlights[character] then
                    local highlight = Instance.new("Highlight"); highlight.FillColor = Color3.fromRGB(0, 170, 255); highlight.OutlineColor = Color3.fromRGB(170, 213, 255); highlight.Parent = character
                    local healthGui, healthConnection = createHealthBar(character, playerHealthColor)
                    activeHighlights[character] = { Highlight = highlight, HealthGui = healthGui, Connection = healthConnection }
                end
            end
        end

        -- Passo 2: Escanear Mobs
        for _, model in pairs(Workspace:GetChildren()) do
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(model) then
                if model.Parent == Workspace then
                    table.insert(charactersInView, model)
                    if not activeHighlights[model] then
                        local highlight = Instance.new("Highlight"); highlight.FillColor = Color3.fromRGB(255, 0, 0); highlight.OutlineColor = Color3.fromRGB(255, 129, 129); highlight.Parent = model
                        local healthGui, healthConnection = createHealthBar(model, mobHealthColor)
                        activeHighlights[model] = { Highlight = highlight, HealthGui = healthGui, Connection = healthConnection }
                    end
                end
            end
        end

        -- Passo 3: Limpar tudo de alvos que não existem mais
        for character, data in pairs(activeHighlights) do
            if not table.find(charactersInView, character) or not character.Parent or character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                if data.Highlight then data.Highlight:Destroy() end
                if data.HealthGui then data.HealthGui:Destroy() end
                if data.Connection then data.Connection:Disconnect() end
                activeHighlights[character] = nil
            end
        end
        task.wait(0.5)
    end

    -- Limpeza final quando o toggle é desligado
    for character, data in pairs(activeHighlights) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.HealthGui then data.HealthGui:Destroy() end
        if data.Connection then data.Connection:Disconnect() end
    end
    activeHighlights = {}
    print("ESP Desativado. Highlights e Barras de Vida removidos.")
end

-- ===================================================================
-- // SEÇÃO DE INTERFACE (CRIADA APÓS TODOS OS SCANS) //
-- ===================================================================

-- ABA 1: TELEPORTES (AGORA COMPLETA)
local TeleportsTab = Window:CreateTab("📍| Teleportes", nil)

TeleportsTab:CreateSection("Ferramentas")
TeleportsTab:CreateButton({
   Name = "Pegar posição atual (F9)",
   Callback = function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            print("Sua Posição Atual: " .. tostring(humanoidRootPart.Position))
            print("Formato para Script: Vector3.new(" .. humanoidRootPart.Position.X .. ", " .. humanoidRootPart.Position.Y .. ", " .. humanoidRootPart.Position.Z .. ")")
        end
    end
})

TeleportsTab:CreateSection("Destinos Salvos")
TeleportsTab:CreateDropdown({
    Name = "Destinos Manuais", Options = manualNpcNames, CurrentOption = {manualNpcNames[1]},
    MultipleOptions = false, Flag = "NpcTeleportDropdown",
    Callback = function(Options)
        local targetPosition = manualNpcLocations[Options[1]]
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if targetPosition and humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
            Rayfield:Notify({ Title = "Teleporte", Content = "Movido para: " .. Options[1], Duration = 4 })
        end
    end,
})

TeleportsTab:CreateSection("NPCs & Lojas")
TeleportsTab:CreateDropdown({
    Name = "NPCs e Lojas ("..npcCount..")", Options = #foundNpcNames > 0 and foundNpcNames or {"Nenhum encontrado"}, 
    CurrentOption = {#foundNpcNames > 0 and foundNpcNames[1] or "Nenhum encontrado"},
    MultipleOptions = false, Flag = "DynamicNpcDropdown",
    Callback = function(Selected)
        local targetPosition = foundNpcs[Selected[1]]
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if targetPosition and humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(targetPosition) * CFrame.new(0, 3, 0)
            Rayfield:Notify({ Title = "Teleporte", Content = "Movido para: " .. Selected[1], Duration = 3 })
        end
    end,
})

TeleportsTab:CreateSection("Jogadores")
TeleportsTab:CreateDropdown({
    Name = "Jogadores no Servidor ("..#playerTeleportLocations..")", Options = playerNames, 
    CurrentOption = {playerNames[1]},
    MultipleOptions = false, Flag = "PlayerTeleportDropdown",
    Callback = function(Selected)
        local targetPlayerName = Selected[1]
        
        if targetPlayerName == "-- Selecione um Jogador --" or targetPlayerName == "Nenhum outro jogador encontrado" then
            return
        end

        local targetPlayer = playerTeleportLocations[targetPlayerName]
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local targetRootPart = targetPlayer.Character.HumanoidRootPart
                humanoidRootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 5, 0)
                Rayfield:Notify({ Title = "Teleporte", Content = "Seguindo: " .. targetPlayerName, Duration = 3 })
            end
        else
            Rayfield:Notify({ Title = "Erro", Content = "Não foi possível encontrar o personagem de " .. targetPlayerName, Duration = 4 })
        end
    end,
})

-- ABA 2: AUTO-FARM
local FarmTab = Window:CreateTab("🚜 | Auto-Farm", nil)
FarmTab:CreateLabel("Inicie o farm para coletar e descobrir trinkets.")
FarmTab:CreateDivider()
FarmTab:CreateToggle({
   Name = "Iniciar Auto-Farm 'que Aprende'", CurrentValue = false, Flag = "AutoFarmToggle", 
   Callback = function(Value)
        farmingEnabled = Value
        if farmingEnabled then task.spawn(startFarming)
        else print("Toggle desligado. O farm irá parar no próximo ciclo.") end
   end,
})

local PlayerTab = Window:CreateTab("🏃 | Player", nil)
PlayerTab:CreateSection("Modificações de Combate")

PlayerTab:CreateToggle({
    Name = "Anti-Stun / No Knockback",
    CurrentValue = false,
    Flag = "AntiStunToggle",
    Callback = function(Value)
        if Value == true then
            -- Se o personagem já existir, aplica o anti-stun nele
            if LocalPlayer.Character then
                applyAntiStun(LocalPlayer.Character)
            end
            -- Conecta uma função para reaplicar o anti-stun toda vez que o personagem respawnar
            antiStunConnections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(applyAntiStun)
            print("Anti-Stun Ativado.")
        else
            -- Desativa e limpa todas as conexões
            removeAntiStun()
        end
    end,
})

local VisualsTab = Window:CreateTab("👁️ | Visuals", nil)
VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({
    Name = "Player & Mob ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            task.spawn(updateEsp)
        end
        -- A limpeza agora acontece naturalmente quando o loop termina
    end,
})

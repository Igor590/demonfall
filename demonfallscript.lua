local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ezy Demonfall Hub",
   Icon = 0, 
   LoadingTitle = "Hub do ezy 🤣",
   LoadingSubtitle = "by ezy.xyz",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "ezy hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Sistema de Key",
      Subtitle = "Chave atual: ezy",
      Note = "👍", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"ezy","Ezy","fodase"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Rayfield:Notify({
   Title = "Script Carregado!",
   Content = "usa saporra direito",
   Duration = 5,
   Image = nil,
})

-- ===================================================================
-- // SEÇÃO DE LÓGICAS (DEFINIÇÕES) //
-- ===================================================================

-- LÓGICA 1: TELEPORTES DE NPCS
local npcLocations = {
    ["Hayakawa"] = Vector3.new(919, 757, -2256),
    ["Vendedor de Joias (Hayakawa)"] = Vector3.new(827, 758, -2248),
    ["Sopa (Hayakawa)"] = Vector3.new(560, 755, -2382),
    ["Haori (Hayakawa)"] = Vector3.new(837, 757, -1988),
    ["Caverna Oni"] = Vector3.new(-737, 695, -1513),
    ["Okuyia Village"] = Vector3.new(-3200, 704, -1162),
    ["Okuyia Tavern"] = Vector3.new(-3419, 705, -1578),
    ["Urokodaki"] = Vector3.new(-922, 846, -990),
}
local npcNames = {}
for name, position in pairs(npcLocations) do
    table.insert(npcNames, name)
end

-- LÓGICA 2: AUTO-FARM DE TRINKETS
-- ETAPA 1 DO FARM: FAZER O PRÉ-SCAN RÁPIDO
print("==============================================")
print("--- [ INICIANDO PRÉ-SCAN DE PONTOS DE FARM ] ---")
local trinketSpawnPoints = {}
local spawnsConhecidos = {}
task.wait(5)

for i, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
    if descendant.Name == "Spawn" then
        local parentModel = descendant:FindFirstAncestorOfClass("Model")
        if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then
            local position = nil
            if descendant:IsA("BasePart") then
                position = descendant.Position
            elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then
                position = descendant.Value.Position
            end
            if position and not spawnsConhecidos[position] then
                spawnsConhecidos[position] = true
                table.insert(trinketSpawnPoints, position)
            end
        end
    end
end
print("--- [ PRÉ-SCAN FINALIZADO: " .. #trinketSpawnPoints .. " PONTOS INICIAIS ENCONTRADOS ] ---")

-- ETAPA 2 DO FARM: LÓGICA DO LOOP "QUE APRENDE"
local farmingEnabled = false
local delayAfterCollect = 0.5
local delayAfterCycle = 30

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

            -- LÓGICA DE COLETA E DESCOBERTA
            for _, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
                if not farmingEnabled then break end

                if descendant:IsA("ProximityPrompt") then
                    local itemModel = descendant:FindFirstAncestorOfClass("Model") or descendant.Parent
                    local itemPart = descendant.Parent
                    if itemPart and itemPart:IsA("BasePart") and (itemPart.Position - spawnPos).Magnitude < 30 and not itemModel:FindFirstChildOfClass("Humanoid") then
                        print("Trinket '"..itemModel.Name.."' encontrada no ponto #"..i..". Coletando...")
                        humanoidRootPart.CFrame = itemPart.CFrame * CFrame.new(0, -2, 0)
                        task.wait(0.3)
                        descendant:InputHoldBegin()
                        Rayfield:Notify({ Title = "Item Coletado!", Content = "Você pegou: " .. itemModel.Name, Duration = 4 })
                        task.wait(delayAfterCollect)
                        break
                    end
                end

                if descendant.Name == "Spawn" then
                    local parentModel = descendant:FindFirstAncestorOfClass("Model")
                    if parentModel and not parentModel:FindFirstChildOfClass("Humanoid") then
                        local position = nil
                        if descendant:IsA("BasePart") then
                            position = descendant.Position
                        elseif descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then
                            position = descendant.Value.Position
                        end
                        
                        if position and not spawnsConhecidos[position] then
                            spawnsConhecidos[position] = true
                            table.insert(trinketSpawnPoints, position)
                            print("+++ NOVO PONTO DE SPAWN DESCOBERTO! Total agora: " .. #trinketSpawnPoints .. " +++")
                            -- NOTIFICAÇÃO REMOVIDA, CONFORME PEDIDO
                        end
                    end
                end
            end
        end
        
        print("==============================================")
        print("Ciclo completo. Aguardando " .. delayAfterCycle .. " segundos...")
        for i = delayAfterCycle, 1, -1 do
            if not farmingEnabled then print("Farm interrompido."); return end
            task.wait(1)
        end
    end
    print(">> AUTO-FARM FINALIZADO. <<")
end


-- ===================================================================
-- // SEÇÃO DE INTERFACE (CRIAÇÃO DAS ABAS E BOTÕES) //
-- ===================================================================

-- ABA 1: TELEPORTES
local TeleportsTab = Window:CreateTab("🚄|Teleports", nil)
local TeleportsSection = TeleportsTab:CreateSection("Ferramentas")
TeleportsTab:CreateButton({
   Name = "Pegar posição atual (F9)",
   Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local position = humanoidRootPart.Position
            print("Sua Posição Atual: " .. tostring(position))
            print("Formato para Script: Vector3.new(" .. position.X .. ", " .. position.Y .. ", " .. position.Z .. ")")
        else
            print("Erro: Personagem não encontrado. Tente se mover e executar novamente.")
        end
    end
})
TeleportsTab:CreateDropdown({
    Name = "NPC Teleports",
    Options = npcNames,
    CurrentOption = {npcNames[1]},
    MultipleOptions = false,
    Flag = "NpcTeleportDropdown",
    Callback = function(Options)
        local selectedNpcName = Options[1]
        local targetPosition = npcLocations[selectedNpcName]
        if targetPosition then
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(targetPosition)
                Rayfield:Notify({ Title = "Teleporte", Content = "Movido para: " .. selectedNpcName, Duration = 4 })
            else
                print("Erro: Seu personagem não foi encontrado.")
            end
        end
    end,
})

-- ABA 2: AUTO-FARM
local FarmTab = Window:CreateTab("🚜 | Auto-Farm", nil)
FarmTab:CreateDivider()
FarmTab:CreateToggle({
   Name = "Iniciar Auto-Farm Inteligente",
   CurrentValue = false,
   Flag = "AutoFarmToggle", 
   Callback = function(Value)
        farmingEnabled = Value
        if farmingEnabled then
            task.spawn(startFarming)
        else
            print("Toggle desligado. O farm irá parar no próximo ciclo.")
        end
   end,
})

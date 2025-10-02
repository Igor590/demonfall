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
    ["Caverna Oni"] = Vector3.new(-737, 695, -1513)
}
local npcNames = {}
for name, position in pairs(npcLocations) do
    table.insert(npcNames, name)
end

-- LÓGICA 2: AUTO-FARM DE TRINKETS
-- ETAPA 1 DO FARM: FAZER O PRÉ-SCAN FILTRADO
print("==============================================")
print("--- [ INICIANDO PRÉ-SCAN DE PONTOS DE FARM ] ---")
print("Aguarde a interface aparecer...")

local trinketSpawnPoints = {}
local trinketCount = 0

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
            if position then
                trinketCount = trinketCount + 1
                table.insert(trinketSpawnPoints, position)
            end
        end
    end
end

print("--- [ PRÉ-SCAN FINALIZADO: " .. trinketCount .. " PONTOS DE FARM ENCONTRADOS ] ---")

-- ETAPA 2 DO FARM: LÓGICA DO LOOP
local farmingEnabled = false
local delayAfterCollect = 1.5   -- Delay em segundos após coletar um item
local delayAfterCycle = 120   -- Delay em segundos após verificar TODOS os pontos (2 minutos)

local function startFarming()
    print(">> AUTO-FARM INICIADO! <<")
    local player = game:GetService("Players").LocalPlayer
    
    while farmingEnabled do
        print("==============================================")
        print("Iniciando novo ciclo de farm em " .. #trinketSpawnPoints .. " pontos.")
        
        for i, spawnPos in pairs(trinketSpawnPoints) do
            if not farmingEnabled then print("Farm interrompido pelo usuário."); return end
            
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then print("Personagem não encontrado, aguardando..."); task.wait(5); continue end

            humanoidRootPart.CFrame = CFrame.new(spawnPos) * CFrame.new(0, 3, 0)
            task.wait(0.5)

            local trinketFound = false
            for _, item in pairs(game:GetService("Workspace"):GetChildren()) do
                if (item.Position - spawnPos).Magnitude < 30 then
                    local prompt = item:FindFirstDescendantOfClass("ProximityPrompt")
                    if prompt and item.PrimaryPart and not item:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
                        print("Trinket '"..item.Name.."' encontrada no ponto #"..i..". Forçando coleta...")
                        
                        humanoidRootPart.CFrame = item.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
                        task.wait(0.3)
                        
                        prompt:InputHoldBegin()
                        
                        task.wait(delayAfterCollect)
                        trinketFound = true
                        break
                    end
                end
            end
            if not trinketFound then print("Nenhuma trinket no ponto #"..i..". Próximo.") end
        end
        
        print("==============================================")
        print("Ciclo completo. Aguardando " .. delayAfterCycle .. " segundos para o respawn...")
        task.wait(delayAfterCycle)
    end
    print(">> AUTO-FARM FINALIZADO. <<")
end


-- ===================================================================
-- // SEÇÃO DE INTERFACE (CRIAÇÃO DAS ABAS E BOTÕES) //
-- ===================================================================

-- ABA 1: TELEPORTES
local MainTab = Window:CreateTab("🚄|Teleports", nil)

local MainSection = MainTab:CreateSection("Ferramentas")

MainTab:CreateButton({
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

MainTab:CreateDropdown({
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
                
                Rayfield:Notify({
                    Title = "Teleporte",
                    Content = "Movido para: " .. selectedNpcName,
                    Duration = 4,
                })
            else
                print("Erro: Seu personagem não foi encontrado.")
            end
        end
    end,
})

-- ABA 2: AUTO-FARM
local FarmTab = Window:CreateTab("🚜 | Auto-Farm", nil)

FarmTab:CreateLabel("Encontrados " .. trinketCount .. " pontos de spawn de trinkets.")
FarmTab:CreateDivider()

FarmTab:CreateToggle({
   Name = "Iniciar Auto-Farm de Trinkets",
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

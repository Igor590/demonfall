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

local MainTab = Window:CreateTab("🚄|Teleports", nil) -- Title, Image

Rayfield:Notify({
   Title = "Script Carregado!",
   Content = "usa saporra direito",
   Duration = 5,
   Image = nil,
})

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

local MainSection = MainTab:CreateSection("Main")

local Button = MainTab:CreateButton({
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

local Dropdown = MainTab:CreateDropdown({
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

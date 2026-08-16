local function loadWindUI()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and result then return result end
    local ok2, result2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok2 and result2 then return result2 end
    return nil
end

local WindUI = loadWindUI()
if not WindUI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

local function waitForChildSafe(parent, name, timeout)
    if not parent then return nil end

    local found = parent:FindFirstChild(name)
    if found then return found end

    local deadline = os.clock() + (timeout or 8)

    while parent.Parent and os.clock() < deadline do
        found = parent:FindFirstChild(name)
        if found then return found end
        task.wait(0.1)
    end

    return nil
end

local function getCharacterData(character, timeout)
    if not character then return nil end

    local data = character:FindFirstChild("CharacterData")
    if data then return data end

    data = character:FindFirstChild("CharacterData", true)
    if data then return data end

    local deadline = os.clock() + (timeout or 8)

    while character.Parent and os.clock() < deadline do
        data = character:FindFirstChild("CharacterData")
        if data then return data end

        data = character:FindFirstChild("CharacterData", true)
        if data then return data end

        task.wait(0.1)
    end

    return nil
end

local iconUrl = "https://i.ibb.co/fYdF9KCn/douyin-img-1783071831074.jpg"
local Folder = "超市生存"
local iconFileName = "float_icon.jpg"
local iconPath = "WindUI/" .. Folder .. "/assets/" .. iconFileName

local function ensureIcon()
    if not isfile or not isfolder or not makefolder or not writefile or not getcustomasset then return false end
    if isfile(iconPath) then return true end
    local assetsDir = "WindUI/" .. Folder .. "/assets"
    if not isfolder(assetsDir) then makefolder(assetsDir) end
    local success, data = pcall(game.HttpGet, game, iconUrl)
    if success and data then writefile(iconPath, data) return true end
    return false
end

local iconAsset
if ensureIcon() then iconAsset = getcustomasset(iconPath) else iconAsset = "rbxassetid://10709791437" end

local icons = {"skull","star","heart","crown","shield","wrench","rocket","fire","bolt","moon","sun","globe","terminal","gamepad","dollar-sign","gift","plane","ship","car","bicycle","tree","flower","snowflake","rainbow","flask","atom","satellite","wifi","folder","calendar","clock","alarm","mail","phone","laptop","play","pause","infinity","thumbs-up","pray","yinyang","earth-americas","volcano","campfire","medkit","ambulance","wheelchair","universal-access","bug","lightbulb","coffee"}

local Window = WindUI:CreateWindow({
    Title = "超市生存",
    Icon = icons[math.random(#icons)],
    Author = "作者 R18WenHuiSchool",
    Folder = Folder,
    Size = UDim2.fromOffset(540, 460),
    Theme = "Dark",
    SideBarWidth = 200,
    Transparent = true,
    BackgroundImageTransparency = 0.3,
    User = { Enabled = false },
})

WindUI:SetNotificationLower(true)

Window:EditOpenButton({
    Title = "打开/关闭",
    Icon = iconAsset,
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2.5,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }),
    Draggable = true,
})

Window:Tag({
    Title = "超市生存定制版",
    Icon = "",
    Color = Color3.fromRGB(180, 255, 255),
    Radius = 13,
})

local MainTab = Window:Tab({ Title = "主要", Icon = "" })
local GetItemTab = Window:Tab({ Title = "获取物品", Icon = "" })
local Tab = Window:Tab({ Title = "角色", Icon = "" })
local MoveTab = Window:Tab({ Title = "移动", Icon = "" })
local FarmTab = Window:Tab({ Title = "挂机", Icon = "" })

local sprintEnabled = false
local sprintSpeed = 50
local staminaConnection, speedConnection

local selectedChinese = "全部"
local itemStatusParagraph = nil

local function createItemListGui()
    local existingGui = player.PlayerGui:FindFirstChild("ItemSelector")
    if existingGui then existingGui:Destroy() end

    local itemListGui = Instance.new("ScreenGui")
    itemListGui.Name = "ItemSelector"
    itemListGui.ResetOnSpawn = false
    itemListGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 180, 0, 240)
    frame.Position = UDim2.new(0.5, -90, 0.4, -120)
    frame.Parent = itemListGui

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.Size = UDim2.new(1, -10, 1, -30)
    scroll.Position = UDim2.new(0, 5, 0, 25)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "选择物品"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -20, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextSize = 12
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function() itemListGui:Destroy() end)

    local yOffset = 0
    local folder = Workspace.Map.Util.Items
    local seen = {}
    table.insert(seen, "全部")
    if folder then
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Tool") then
                local cn = obj.Name
                if not table.find(seen, cn) then
                    table.insert(seen, cn)
                end
            end
        end
    end

    for _, name in ipairs(seen) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.Size = UDim2.new(1, -10, 0, 22)
        btn.Position = UDim2.new(0, 5, 0, yOffset)
        btn.Text = name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(function()
            selectedChinese = name
            itemListGui:Destroy()
            if itemStatusParagraph then
                itemStatusParagraph:SetDesc("当前目标: " .. selectedChinese)
            end
        end)
        yOffset = yOffset + 24
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

MainTab:Section({ Title = "拾取设置" })
itemStatusParagraph = MainTab:Paragraph({
    Title = "当前目标",
    Desc = "当前目标: 全部"
})

MainTab:Button({
    Title = "选择物品",
    Desc = "点击打开物品列表进行选择",
    Callback = function()
        createItemListGui()
    end
})

GetItemTab:Section({ Title = "获取物品" })

local GetItemTarget = "Burger"
local GetItemDropdown

local GetItemNames = {
    "Cola",
    "Burger",
    "AmmoARBasic",
    "AmmoShotgunBasic",
    "AmmoShotgun",
    "BasicAmmoShotgunBasic",
    "BasicFlashlight",
    "BigBasicFlashlight",
    "StandardBasicFlashlight",
    "Ham",
    "Hotdog",
    "Katana",
    "GreenCube",
    "PumpShotgun",
    "Plank",
    "RedCube",
    "BasicFlashlight_Standard",
    "Meshes/flashlights_Cylinder.001(1)",
    "AmmoPistolBasic"
}

local function GetItemsFolderSafe()
    local Map = Workspace:FindFirstChild("Map")
    local Util = Map and Map:FindFirstChild("Util")
    return Util and Util:FindFirstChild("Items")
end

local function GetItemWorldPart(Item)
    if not Item then return nil end
    local Handle = Item:FindFirstChild("Handle", true)
    if Handle and Handle:IsA("BasePart") then
        return Handle
    end
    local Prompt = Item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if Prompt and Prompt.Parent and Prompt.Parent:IsA("BasePart") then
        return Prompt.Parent
    end
    return Item:FindFirstChildWhichIsA("BasePart", true)
end

local function FindItemByName(Name)
    local Folder = GetItemsFolderSafe()
    if not Folder then return nil end
    for _, Item in ipairs(Folder:GetDescendants()) do
        if Item:IsA("Tool") and Item.Name == Name then
            return Item
        end
    end
    return nil
end

local function GetAllItemNames()
    local Result = {}
    local Seen = {}
    for _, Name in ipairs(GetItemNames) do
        if not Seen[Name] then
            Seen[Name] = true
            table.insert(Result, Name)
        end
    end
    local Folder = GetItemsFolderSafe()
    if Folder then
        for _, Item in ipairs(Folder:GetDescendants()) do
            if Item:IsA("Tool") and not Seen[Item.Name] then
                Seen[Item.Name] = true
                table.insert(Result, Item.Name)
            end
        end
    end
    table.sort(Result)
    return Result
end

GetItemDropdown = GetItemTab:Dropdown({
    Title = "物品",
    Values = GetAllItemNames(),
    Value = GetItemTarget,
    SearchBarEnabled = true,
    Callback = function(Value)
        if typeof(Value) == "table" then
            GetItemTarget = Value.Title or GetItemTarget
        else
            GetItemTarget = Value or GetItemTarget
        end
    end
})


local function TeleportToItem(Item)
    local Character = player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Part = GetItemWorldPart(Item)
    if not Root or not Part then return false end

    local Prompt = Item:FindFirstChildWhichIsA("ProximityPrompt", true)
    local TargetCFrame = Part.CFrame * CFrame.new(0, 1.25, -2.75)

    if Prompt and Prompt.Parent == Part then
        TargetCFrame = Part.CFrame * CFrame.new(0, 1.25, -(math.max(2.75, Prompt.MaxActivationDistance * 0.5)))
    end

    Character:PivotTo(TargetCFrame)
    return true
end

local function RequestGetItem(Item)
    if not Item or not Item.Parent then return false end
    local Character = player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Character:FindFirstChildWhichIsA("Tool") then
        Humanoid:UnequipTools()
        task.wait(0.03)
    end

    if not TeleportToItem(Item) then return false end
    task.wait(0.04)

    local Prompt = Item:FindFirstChildWhichIsA("ProximityPrompt", true)
    if Prompt and Prompt.Enabled then
        pcall(function() Prompt:InputHoldBegin() end)
        task.wait(math.max(0.03, Prompt.HoldDuration + 0.03))
        pcall(function() Prompt:InputHoldEnd() end)
        task.wait(0.05)
    end

    local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RequestPickupItem")
    if Remote then
        pcall(function() Remote:FireServer(Item) end)
    end

    local Deadline = os.clock() + 1.2
    while os.clock() < Deadline do
        if not Item.Parent or Item:FindFirstAncestorOfClass("Backpack") then
            return true
        end
        task.wait(0.04)
    end

    return Item:FindFirstAncestorOfClass("Backpack") ~= nil
end

GetItemTab:Button({
    Title = "获取物品",
    Desc = "传送到选中的物品并立即尝试获取",
    Callback = function()
        local Item = FindItemByName(GetItemTarget)
        if not Item then
            WindUI:Notify({ Title = "获取物品", Content = "当前没有找到 " .. tostring(GetItemTarget), Duration = 2 })
            return
        end
        local Success = RequestGetItem(Item)
        WindUI:Notify({
            Title = "获取物品",
            Content = Success and ("已获取 " .. tostring(GetItemTarget)) or ("无法获取 " .. tostring(GetItemTarget)),
            Duration = 2
        })
    end
})

GetItemTab:Button({
    Title = "获取所有项目",
    Desc = "按当前地图顺序传送并尝试获取所有可获取物品",
    Callback = function()
        task.spawn(function()
            local Folder = GetItemsFolderSafe()
            if not Folder then return end
            local Items = {}
            local Seen = {}
            for _, Item in ipairs(Folder:GetDescendants()) do
                if Item:IsA("Tool") and not Seen[Item] then
                    Seen[Item] = true
                    table.insert(Items, Item)
                end
            end
            table.sort(Items, function(A, B) return A.Name < B.Name end)
            for _, Item in ipairs(Items) do
                if not Item.Parent then continue end
                if getBackpackCount() >= maxSlots then break end
                RequestGetItem(Item)
                task.wait(0.04)
            end
        end)
    end
})

local maxSlots = 5
local npcSafeDistance = 10

local function getBackpackCount()
    local count = 0
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                count = count + 1
            end
        end
    end
    return count
end

local function isNearNPC(position)
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - position).Magnitude
            if dist <= npcSafeDistance then
                return true
            end
        end
    end
    return false
end

MainTab:Toggle({
    Title = "自动拾取",
    Default = false,
    Callback = function(state)
        autoLootEnabled = state
        if state then
            autoLootThread = task.spawn(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart")
                local humanoid = char:WaitForChild("Humanoid")
                local RequestPickupItem = ReplicatedStorage.Remotes.RequestPickupItem
                local ItemEquipped = ReplicatedStorage.Remotes.Item.Equipped
                local TARGET_FOLDER = Workspace.Map.Util.Items

                while autoLootEnabled do
                    if getBackpackCount() >= maxSlots then
                        task.wait(1)
                        continue
                    end

                    local targets = {}
                    if TARGET_FOLDER then
                        for _, obj in ipairs(TARGET_FOLDER:GetDescendants()) do
                            if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
                                local cn = obj.Name
                                if selectedChinese == "全部" or cn == selectedChinese then
                                    local handle = obj:FindFirstChild("Handle")
                                    if handle and not isNearNPC(handle.Position) then
                                        table.insert(targets, obj)
                                    end
                                end
                            end
                        end
                    end

                    for _, tool in ipairs(targets) do
                        if not autoLootEnabled then break end
                        if not tool or tool.Parent ~= TARGET_FOLDER then continue end

                        if char:FindFirstChildWhichIsA("Tool") then
                            humanoid:UnequipTools()
                            task.wait(0.05)
                        end

                        local handle = tool:FindFirstChild("Handle")
                        local targetPos = handle and handle.Position or tool:GetPivot().Position
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 2))
                        task.wait(0.05)

                        RequestPickupItem:FireServer(tool)

                        local picked = false
                        local startTime = tick()
                        while tick() - startTime < 2 and autoLootEnabled do
                            if not tool.Parent or tool:FindFirstAncestorOfClass("Backpack") then
                                picked = true
                                break
                            end
                            task.wait(0.05)
                        end

                        if picked then
                            local toolInBag = player.Backpack:FindFirstChild(tool.Name)
                            if toolInBag then ItemEquipped:FireServer(toolInBag) end
                        end
                        task.wait(0.05)
                    end
                    task.wait(0.5)
                end
            end)
        else
            if autoLootThread then task.cancel(autoLootThread) autoLootThread = nil end
        end
    end
})

Tab:Toggle({
    Title = "无限体力",
    Default = false,
    Callback = function(state)
        if staminaConnection then
            staminaConnection:Disconnect()
            staminaConnection = nil
        end

        if not state then return end

        task.spawn(function()
            local char = player.Character
            if not char then return end

            local charData = getCharacterData(char, 8)
            if not charData then
                WindUI:Notify({
                    Title = "无限体力",
                    Content = "未找到 CharacterData，请确认角色数据路径",
                    Duration = 3
                })
                return
            end

            local stamina = waitForChildSafe(charData, "Stamina", 5)
            local maxStamina = waitForChildSafe(charData, "MaxStamina", 5)

            if not stamina or not maxStamina then
                WindUI:Notify({
                    Title = "无限体力",
                    Content = "未找到 Stamina / MaxStamina",
                    Duration = 3
                })
                return
            end

            staminaConnection = RunService.Heartbeat:Connect(function()
                if stamina.Parent and maxStamina.Parent then
                    stamina.Value = maxStamina.Value
                end
            end)

            stamina.Value = maxStamina.Value
        end)
    end
})

Tab:Toggle({
    Title = "夜视",
    Default = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            for _, effect in ipairs(Lighting:GetDescendants()) do
                if effect:IsA("PostEffect") then effect.Enabled = false end
                if effect:IsA("Atmosphere") then effect:Destroy() end
            end
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

Tab:Toggle({
    Title = "快速互动",
    Default = false,
    Callback = function(state)
        quickInteractEnabled = state
        if state then
            quickInteractConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                prompt.HoldDuration = 0
            end)
        else
            if quickInteractConnection then
                quickInteractConnection:Disconnect()
                quickInteractConnection = nil
            end
        end
    end
})

MoveTab:Toggle({
    Title = "冲刺加速",
    Default = false,
    Callback = function(state)
        sprintEnabled = state

        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end

        if not state then return end

        task.spawn(function()
            local char = player.Character
            if not char then return end

            local charData = getCharacterData(char, 8)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local sprintingAndMoving = charData and waitForChildSafe(charData, "SprintingAndMoving", 5)

            if not charData or not sprintingAndMoving or not humanoid then
                WindUI:Notify({
                    Title = "冲刺加速",
                    Content = "未找到角色冲刺数据",
                    Duration = 3
                })
                return
            end

            speedConnection = RunService.RenderStepped:Connect(function()
                if humanoid.Parent and sprintingAndMoving.Parent and sprintingAndMoving.Value == true then
                    humanoid.WalkSpeed = sprintSpeed
                end
            end)
        end)
    end
})

MoveTab:Slider({
    Title = "冲刺速度",
    Value = { Min = 20, Max = 200, Default = 50 },
    Callback = function(value) sprintSpeed = value end
})

local noClipEnabled = false
local noClipConnection = nil
MoveTab:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(state)
        noClipEnabled = state
        if state then
            noClipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

local infiniteJumpEnabled = false
local infJumpConnection = nil
MoveTab:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJumpEnabled then
                    local char = player.Character
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState("Jumping")
                        end
                    end
                end
            end)
        else
            if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
        end
    end
})

local autoJumpEnabled = false
local autoJumpInterval = 1.0
local autoJumpThread = nil

local function stopAutoJump()
    autoJumpEnabled = false
    if autoJumpThread then
        task.cancel(autoJumpThread)
        autoJumpThread = nil
    end
end

local function startAutoJump()
    if autoJumpThread then
        task.cancel(autoJumpThread)
    end
    autoJumpThread = task.spawn(function()
        while autoJumpEnabled do
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Jump = true
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
            task.wait(math.max(0.05, autoJumpInterval))
        end
        autoJumpThread = nil
    end)
end

MoveTab:Toggle({
    Title = "自动跳跃",
    Desc = "按设定频率持续原地跳跃",
    Default = false,
    Callback = function(state)
        autoJumpEnabled = state
        if state then
            startAutoJump()
        else
            stopAutoJump()
        end
    end
})

MoveTab:Slider({
    Title = "自动跳跃频率",
    Desc = "数值越小跳得越频繁",
    Value = { Min = 0.1, Max = 5, Default = 1, Step = 0.1 },
    Callback = function(value)
        autoJumpInterval = math.max(0.1, tonumber(value) or 1)
    end
})

local flyGui = Instance.new("ScreenGui")
flyGui.Name = "FlyControl"
flyGui.ResetOnSpawn = false
flyGui.Parent = player:WaitForChild("PlayerGui")
flyGui.Enabled = false

local flyFrame = Instance.new("Frame")
flyFrame.Parent = flyGui
flyFrame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
flyFrame.BorderColor3 = Color3.fromRGB(103, 221, 213)
flyFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
flyFrame.Size = UDim2.new(0, 190, 0, 57)
flyFrame.Active = true
flyFrame.Draggable = true

local function createFlyButton(text, position, size, color)
    local btn = Instance.new("TextButton")
    btn.Parent = flyFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(79, 255, 152)
    btn.Position = position or UDim2.new(0, 0, 0, 0)
    btn.Size = size or UDim2.new(0, 44, 0, 28)
    btn.Font = Enum.Font.SourceSans
    btn.Text = text
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.TextSize = 14
    return btn
end

local upBtn = createFlyButton("上", UDim2.new(0, 0, 0, 0), UDim2.new(0, 44, 0, 28), Color3.fromRGB(79, 255, 152))
local downBtn = createFlyButton("下", UDim2.new(0, 0, 0.5, 0), UDim2.new(0, 44, 0, 28), Color3.fromRGB(215, 255, 121))
local flyToggleBtn = createFlyButton("飞行", UDim2.new(0.7, 0, 0.5, 0), UDim2.new(0, 56, 0, 28), Color3.fromRGB(255, 249, 74))
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = flyFrame
speedLabel.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedLabel.Position = UDim2.new(0.47, 0, 0.5, 0)
speedLabel.Size = UDim2.new(0, 44, 0, 28)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Text = "1"
speedLabel.TextColor3 = Color3.new(0, 0, 0)
speedLabel.TextScaled = true
speedLabel.TextSize = 14

local plusBtn = createFlyButton("加速", UDim2.new(0.23, 0, 0, 0), UDim2.new(0, 45, 0, 28), Color3.fromRGB(133, 145, 255))
local minusBtn = createFlyButton("减速", UDim2.new(0.23, 0, 0.5, 0), UDim2.new(0, 45, 0, 29), Color3.fromRGB(123, 255, 247))

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = flyFrame
closeBtn.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closeBtn.Font = "SourceSans"
closeBtn.Size = UDim2.new(0, 45, 0, 28)
closeBtn.Text = "关闭"
closeBtn.TextSize = 30
closeBtn.Position = UDim2.new(0, 0, -1, 27)

local flyNowe = false
local flySpeeds = 1
local flyTpwalking = false
local flyBodyGyro, flyBodyVelocity, flyHeartbeat

local function stopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyHeartbeat then flyHeartbeat:Disconnect() flyHeartbeat = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            char.Animate.Disabled = false
        end
    end
    flyTpwalking = false
    flyNowe = false
end

local function startFly()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    flyNowe = true

    for _, state in ipairs({
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    char.Animate.Disabled = true

    flyTpwalking = true
    task.spawn(function()
        while flyTpwalking and char and hum and hum.Parent do
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                char:TranslateBy(dir * flySpeeds)
            end
            task.wait()
        end
    end)

    local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if rootPart then
        flyBodyGyro = Instance.new("BodyGyro", rootPart)
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.P = 9e4
        flyBodyVelocity = Instance.new("BodyVelocity", rootPart)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVelocity.Velocity = Vector3.zero

        hum.PlatformStand = true
        local camera = Workspace.CurrentCamera
        flyHeartbeat = RunService.RenderStepped:Connect(function()
            if not flyNowe or not char or not char.Parent or not hum or hum.Health <= 0 then
                stopFly()
                flyToggleBtn.Text = "飞行"
                return
            end
            if camera and flyBodyGyro and flyBodyVelocity then
                local moveDir = hum.MoveDirection
                local velocity = Vector3.zero
                if moveDir.Magnitude > 0 then
                    velocity = camera.CFrame.LookVector * moveDir.Z + camera.CFrame.RightVector * moveDir.X
                    velocity = velocity * 50
                end
                local upDown = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then upDown = 50 end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then upDown = -50 end
                velocity = velocity + Vector3.new(0, upDown, 0)
                flyBodyVelocity.Velocity = velocity
                flyBodyGyro.CFrame = camera.CFrame
            end
        end)
    end
end

flyToggleBtn.MouseButton1Down:Connect(function()
    if flyNowe then
        stopFly()
        flyToggleBtn.Text = "飞行"
    else
        startFly()
        flyToggleBtn.Text = "停止"
    end
end)

upBtn.MouseButton1Down:Connect(function()
    local tis
    tis = upBtn.MouseEnter:Connect(function()
        while tis do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
            end
            task.wait()
        end
    end)
    upBtn.MouseLeave:Connect(function()
        if tis then tis:Disconnect() tis = nil end
    end)
end)

downBtn.MouseButton1Down:Connect(function()
    local dis
    dis = downBtn.MouseEnter:Connect(function()
        while dis do
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
            end
            task.wait()
        end
    end)
    downBtn.MouseLeave:Connect(function()
        if dis then dis:Disconnect() dis = nil end
    end)
end)

plusBtn.MouseButton1Down:Connect(function()
    flySpeeds = flySpeeds + 1
    speedLabel.Text = flySpeeds
end)

minusBtn.MouseButton1Down:Connect(function()
    if flySpeeds > 1 then
        flySpeeds = flySpeeds - 1
        speedLabel.Text = flySpeeds
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    flyGui.Enabled = false
    stopFly()
    flyToggleBtn.Text = "飞行"
end)

player.CharacterAdded:Connect(function()
    stopFly()
    flyToggleBtn.Text = "飞行"
    flyNowe = false
    flyGui.Enabled = false
end)

MoveTab:Button({
    Title = "飞行",
    Desc = "",
    Callback = function()
        flyGui.Enabled = true
    end
})

player.CharacterAdded:Connect(function()
    task.wait(1)
    local char = player.Character
    if not char then return end
    if staminaConnection then
        staminaConnection:Disconnect()
        staminaConnection = nil

        task.spawn(function()
            local charData = getCharacterData(char, 8)
            if not charData then return end

            local stamina = waitForChildSafe(charData, "Stamina", 5)
            local maxStamina = waitForChildSafe(charData, "MaxStamina", 5)

            if stamina and maxStamina then
                staminaConnection = RunService.Heartbeat:Connect(function()
                    if stamina.Parent and maxStamina.Parent then
                        stamina.Value = maxStamina.Value
                    end
                end)
            end
        end)
    end

    if sprintEnabled then
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end

        task.spawn(function()
            local charData = getCharacterData(char, 8)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local sprintingAndMoving = charData and waitForChildSafe(charData, "SprintingAndMoving", 5)

            if not charData or not sprintingAndMoving or not humanoid then return end

            speedConnection = RunService.RenderStepped:Connect(function()
                if humanoid.Parent and sprintingAndMoving.Parent and sprintingAndMoving.Value == true then
                    humanoid.WalkSpeed = sprintSpeed
                end
            end)
        end)
    end
    if infiniteJumpEnabled then
        if infJumpConnection then infJumpConnection:Disconnect() end
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState("Jumping") end
            end
        end)
    end
end)

local lowRenderEnabled = false
local lowRenderConnections = {}
local lowRenderSaved = {}
local savedTerrainDecoration = nil
local savedGlobalShadows = nil

local function saveAndDisable(obj, property)
    if not obj or not obj.Parent then return end
    local ok, value = pcall(function() return obj[property] end)
    if not ok then return end
    local key = obj
    lowRenderSaved[key] = lowRenderSaved[key] or {}
    if lowRenderSaved[key][property] == nil then
        lowRenderSaved[key][property] = value
    end
    pcall(function()
        obj[property] = false
    end)
end

local function optimizeRenderObject(obj)
    if not obj or not obj.Parent then return end

    if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
        or obj:IsA("Light") then
        saveAndDisable(obj, "Enabled")
    elseif obj:IsA("PostEffect") then
        saveAndDisable(obj, "Enabled")
    elseif obj:IsA("BasePart") then
        local key = obj
        lowRenderSaved[key] = lowRenderSaved[key] or {}

        if lowRenderSaved[key].CastShadow == nil then
            lowRenderSaved[key].CastShadow = obj.CastShadow
        end
        obj.CastShadow = false

        if obj:IsA("MeshPart") then
            pcall(function()
                if lowRenderSaved[key].RenderFidelity == nil then
                    lowRenderSaved[key].RenderFidelity = obj.RenderFidelity
                end
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            end)
        end
    end
end

local function clearLowRender()
    for name, connection in pairs(lowRenderConnections) do
        if connection then
            connection:Disconnect()
        end
        lowRenderConnections[name] = nil
    end

    for obj, states in pairs(lowRenderSaved) do
        if obj and obj.Parent then
            for property, value in pairs(states) do
                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end

    pcall(function()
        if Workspace.Terrain and savedTerrainDecoration ~= nil then
            Workspace.Terrain.Decoration = savedTerrainDecoration
        end
    end)

    pcall(function()
        if savedGlobalShadows ~= nil then
            Lighting.GlobalShadows = savedGlobalShadows
        end
    end)

    lowRenderSaved = {}
    savedTerrainDecoration = nil
    savedGlobalShadows = nil
end

local function enableLowRender()
    clearLowRender()
    lowRenderEnabled = true

    pcall(function()
        if Workspace.Terrain then
            savedTerrainDecoration = Workspace.Terrain.Decoration
            Workspace.Terrain.Decoration = false
        end
    end)

    pcall(function()
        savedGlobalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    end)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        optimizeRenderObject(obj)
    end

    for _, obj in ipairs(Lighting:GetDescendants()) do
        optimizeRenderObject(obj)
    end

    lowRenderConnections.Workspace = Workspace.DescendantAdded:Connect(function(obj)
        if lowRenderEnabled then
            task.defer(function()
                if lowRenderEnabled then
                    optimizeRenderObject(obj)
                end
            end)
        end
    end)

    lowRenderConnections.Lighting = Lighting.DescendantAdded:Connect(function(obj)
        if lowRenderEnabled then
            task.defer(function()
                if lowRenderEnabled then
                    optimizeRenderObject(obj)
                end
            end)
        end
    end)
end

MainTab:Toggle({
    Title = "本地低渲染",
    Desc = "保留透视与标记，只关闭高开销本地特效和阴影",
    Default = false,
    Callback = function(state)
        lowRenderEnabled = state
        if state then
            enableLowRender()
        else
            clearLowRender()
        end
    end
})

local homePosition = nil
local isAvoiding = false
local busy = false

local function isNearNPC(position)
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            if (npc.HumanoidRootPart.Position - position).Magnitude <= 15 then
                return true
            end
        end
    end
    return false
end

local function isPlayerNearNPC()
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return false end
    for _, npc in ipairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= 10 then return true end
        end
    end
    return false
end

local function getHealthPercent()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    return (hum.Health / hum.MaxHealth) * 100
end

local function getEnergy()
    local char = player.Character
    if not char then return nil end
    local charData = char:FindFirstChild("CharacterData")
    if not charData then return nil end
    local energy = charData:FindFirstChild("Energy")
    if not energy then return nil end
    return energy.Value
end

local function findSafeFood()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local best = nil
    local bestDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local stats = obj:FindFirstChild("ToolStats")
            if stats and (stats:FindFirstChild("HungerRestore") or stats:FindFirstChild("ThirstRestore")) then
                local handle = obj:FindFirstChild("Handle")
                if handle and not isNearNPC(handle.Position) then
                    local dist = (handle.Position - root.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = obj
                    end
                end
            end
        end
    end
    return best
end

local function findSafeMedical()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local bestMedkit = nil
    local bestBandage = nil
    local bestMedkitDist = math.huge
    local bestBandageDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local handle = obj:FindFirstChild("Handle")
            if not handle or isNearNPC(handle.Position) then continue end
            local dist = (handle.Position - root.Position).Magnitude
            if obj.Name == "Medkit" and dist < bestMedkitDist then
                bestMedkitDist = dist
                bestMedkit = obj
            elseif obj.Name == "Bandage" and dist < bestBandageDist then
                bestBandageDist = dist
                bestBandage = obj
            end
        end
    end

    if bestMedkit then return bestMedkit end
    if bestBandage then return bestBandage end
    return nil
end

local function findNearestToken()
    local folder = Workspace.Map.Util.Items
    if not folder then return nil end
    local best = nil
    local bestDist = math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local name = obj.Name
            if name == "Token" or name:find("Token") then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local dist = (handle.Position - root.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = obj
                    end
                end
            end
        end
    end
    return best
end

local function pickupItem(target)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return false end

    if char:FindFirstChildWhichIsA("Tool") then
        humanoid:UnequipTools()
        task.wait(0.05)
    end

    local handle = target:FindFirstChild("Handle")
    local pos = handle and handle.Position or target:GetPivot().Position
    root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 2))
    task.wait(0.05)

    ReplicatedStorage.Remotes.RequestPickupItem:FireServer(target)

    local start = tick()
    while tick() - start < 2 do
        if not target.Parent or target:FindFirstAncestorOfClass("Backpack") then break end
        task.wait(0.05)
    end

    local toolInBag = player.Backpack:FindFirstChild(target.Name)
    if toolInBag then
        ReplicatedStorage.Remotes.Item.Equipped:FireServer(toolInBag)
        return true
    end
    return false
end

local function goHome()
    local char = player.Character
    if not char or not homePosition then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        root.CFrame = CFrame.new(homePosition)
    end
end

local function waitForRespawn()
    repeat task.wait(1) until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    task.wait(0.05)
    goHome()
end

local function forceTeleportToSafeZone()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(371.58, 36.46, -540.39)
    end
end

local function cleanTrash()
    local folder = Workspace.Map.Util.Items
    if not folder then return end
    local keepNames = {"Ham", "Hotdog", "Burger", "Drink"}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Tool") and not obj:FindFirstAncestorOfClass("Backpack") then
            local keep = false
            for _, kw in ipairs(keepNames) do
                if obj.Name:lower() == kw:lower() then
                    keep = true
                    break
                end
            end
            if not keep then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

local cleanEnabled = false
local cleanThread = nil

FarmTab:Toggle({
    Title = "定时清理",
    Desc = "每5秒清除无用物品（只留火腿/热狗/汉堡/饮料）",
    Default = false,
    Callback = function(state)
        cleanEnabled = state
        if state then
            cleanThread = task.spawn(function()
                while cleanEnabled do
                    cleanTrash()
                    task.wait(5)
                end
            end)
        else
            if cleanThread then
                task.cancel(cleanThread)
                cleanThread = nil
            end
        end
    end
})

FarmTab:Button({
    Title = "传送到 TeleportAway",
    Desc = "传送到地图 TeleportAway",
    Callback = function()
        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

        Character:PivotTo(
            workspace.Map.Util.TeleportAway.CFrame + Vector3.new(0, 3, 0)
        )
    end
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Enabled = false
local Thread = nil

local FoodThreshold = 60
local MAX_SLOTS = 5

local ItemsFolder = workspace.Map.Util.Items
local PickupRemote = ReplicatedStorage.Remotes.RequestPickupItem
local EquipRemote = ReplicatedStorage.Remotes.Item.Equipped

local function GetCharacter()
    local Character = Player.Character
    if not Character then
        Character = Player.CharacterAdded:Wait()
    end
    return Character
end

local function GetCharacterData()
    local Character = GetCharacter()
    return Character:FindFirstChild("CharacterData")
end

local function GetEnergyData()
    local Data = GetCharacterData()

    if not Data then
        return nil, nil
    end

    return Data:FindFirstChild("Energy"), Data:FindFirstChild("MaxEnergy")
end

local function GetEnergy()
    local Energy, MaxEnergy = GetEnergyData()

    if not Energy or not MaxEnergy then
        return nil, nil
    end

    return Energy.Value, MaxEnergy.Value
end

local function GetBackpack()
    return Player:FindFirstChildOfClass("Backpack")
end

local function GetBackpackCount()
    local Backpack = GetBackpack()

    if not Backpack then
        return 0
    end

    local Count = 0

    for _, Item in ipairs(Backpack:GetChildren()) do
        if Item:IsA("Tool") then
            Count += 1
        end
    end

    return Count
end

local function IsFood(Tool)
    if not Tool or not Tool:IsA("Tool") then
        return false
    end

    local Stats = Tool:FindFirstChild("ToolStats")

    if not Stats then
        return false
    end

    return
        Stats:FindFirstChild("HungerRestore") ~= nil
        or
        Stats:FindFirstChild("ThirstRestore") ~= nil
end

local function GetHeldFood()
    local Character = GetCharacter()

    for _, Item in ipairs(Character:GetChildren()) do
        if IsFood(Item) then
            return Item
        end
    end

    return nil
end

local function GetStoredFood()
    local Held = GetHeldFood()

    if Held then
        return Held
    end

    local Backpack = GetBackpack()

    if not Backpack then
        return nil
    end

    for _, Item in ipairs(Backpack:GetChildren()) do
        if IsFood(Item) then
            return Item
        end
    end

    return nil
end

local function TeleportHome()
    local Character = GetCharacter()

    local Target = workspace.Map
        and workspace.Map:FindFirstChild("Util")
        and workspace.Map.Util:FindFirstChild("TeleportAway")

    if not Target then
        return false
    end

    Character:PivotTo(Target.CFrame + Vector3.new(0, 3, 0))

    return true
end

local function Unequip()
    local Character = GetCharacter()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if Humanoid and Character:FindFirstChildWhichIsA("Tool") then
        Humanoid:UnequipTools()
        task.wait()
    end
end

local function GetFoodPart(Object)
    if not Object then
        return nil
    end

    local Handle = Object:FindFirstChild("Handle", true)
    if Handle and Handle:IsA("BasePart") then
        return Handle
    end

    local Prompt = Object:FindFirstChildWhichIsA("ProximityPrompt", true)
    if Prompt then
        local Parent = Prompt.Parent
        if Parent and Parent:IsA("BasePart") then
            return Parent
        end
    end

    return Object:FindFirstChildWhichIsA("BasePart", true)
end

local function GetFoodPrompt(Object)
    return Object and Object:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function GetFoodTargetCFrame(Object, Part)
    if not Part then
        return nil
    end

    local Prompt = GetFoodPrompt(Object)
    if Prompt and Prompt.Parent == Part then
        return Part.CFrame * CFrame.new(0, 1.5, -2.5)
    end

    return Part.CFrame * CFrame.new(0, 1.5, -2.5)
end

local function FindNearestFood()
    local Character = GetCharacter()
    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Root or not ItemsFolder then
        return nil
    end

    local Best
    local BestDistance = math.huge

    for _, Object in ipairs(ItemsFolder:GetChildren()) do
        if IsFood(Object) then
            local Part = GetFoodPart(Object)
            local Prompt = GetFoodPrompt(Object)

            if Part and (not Prompt or Prompt.Enabled) then
                local Distance = (Part.Position - Root.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    Best = Object
                end
            end
        end
    end

    if Best then
        return Best
    end

    for _, Object in ipairs(ItemsFolder:GetDescendants()) do
        if Object:IsA("Tool") and IsFood(Object) then
            local Part = GetFoodPart(Object)
            local Prompt = GetFoodPrompt(Object)

            if Part and (not Prompt or Prompt.Enabled) then
                local Distance = (Part.Position - Root.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    Best = Object
                end
            end
        end
    end

    return Best
end

local function PickupFood(Food)
    if not Food or not Food.Parent then
        return false
    end

    Unequip()

    local Character = GetCharacter()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Part = GetFoodPart(Food)

    if not Root or not Part then
        return false
    end

    local TargetCFrame = GetFoodTargetCFrame(Food, Part)
    if not TargetCFrame then
        return false
    end

    Character:PivotTo(TargetCFrame)
    task.wait(0.05)

    local Prompt = GetFoodPrompt(Food)
    if Prompt and Prompt.Enabled then
        pcall(function()
            Prompt:InputHoldBegin()
        end)
        task.wait(math.max(0.05, Prompt.HoldDuration + 0.05))
        pcall(function()
            Prompt:InputHoldEnd()
        end)
        task.wait(0.08)
    end

    pcall(function()
        PickupRemote:FireServer(Food)
    end)

    local Start = os.clock()
    while Enabled and os.clock() - Start < 1.25 do
        if not Food.Parent or Food:FindFirstAncestorOfClass("Backpack") then
            break
        end
        task.wait(0.05)
    end

    local Backpack = GetBackpack()
    if not Backpack then
        return false
    end

    local Stored = Backpack:FindFirstChild(Food.Name)
    if not Stored then
        return false
    end

    pcall(function()
        EquipRemote:FireServer(Stored)
    end)

    task.wait(0.05)
    return true
end

local function EquipFood(Food)
    if not Food then
        return false
    end

    local Character = GetCharacter()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return false
    end

    if Food.Parent == Character then
        return true
    end

    pcall(function()
        EquipRemote:FireServer(Food)
    end)

    task.wait()

    if Food.Parent == Character then
        return true
    end

    pcall(function()
        Humanoid:EquipTool(Food)
    end)

    task.wait()

    return Food.Parent == Character
end

local function EatFood(Food)
    if not EquipFood(Food) then
        return false
    end

    pcall(function()
        Food:Activate()
    end)

    task.wait(0.25)

    return true
end

local function EatUntilThreshold()
    local Safety = 0

    while Enabled and Safety < 20 do
        Safety += 1

        local Energy, MaxEnergy = GetEnergy()

        if not Energy or not MaxEnergy then
            return false
        end

        if Energy >= MaxEnergy or Energy >= FoodThreshold then
            return true
        end

        local Food = GetStoredFood()

        if not Food then
            return false
        end

        if not EatFood(Food) then
            return false
        end

        task.wait()
    end

    return false
end

local function Run()
    if Thread then
        return
    end

    Thread = task.spawn(function()
        while Enabled do
            local Energy = GetEnergy()

            if not Energy then
                task.wait(0.2)
                continue
            end

            if Energy >= FoodThreshold then
                TeleportHome()
                task.wait(0.5)
                continue
            end

            local StoredFood = GetStoredFood()

            if StoredFood then
                TeleportHome()
                EatUntilThreshold()
                task.wait(0.2)
                continue
            end

            if GetBackpackCount() >= MAX_SLOTS then
                TeleportHome()
                task.wait(0.5)
                continue
            end

            local Food = FindNearestFood()

            if Food then
                local Picked = PickupFood(Food)

                if Picked then
                    TeleportHome()
                    EatUntilThreshold()
                end
            else
                TeleportHome()
                task.wait(0.5)
            end

            task.wait(0.15)
        end

        Thread = nil
    end)
end

FarmTab:Slider({
    Title = "低于多少能量开始捡食物",
    Value = {
        Min = 0,
        Max = 100,
        Default = 60
    },
    Callback = function(Value)
        FoodThreshold = math.floor(Value)
    end
})

FarmTab:Toggle({
    Title = "自动食物补给",
    Desc = "能量低于设定值时自动拾取并进食",
    Value = false,
    Callback = function(Value)
        Enabled = Value

        if Value then
            Run()
        end
    end
})


local AutoItemDropEnabled = false
local AutoItemDropThread = nil

local TargetItems = {
    "Cola",
    "Burger",
    "AmmoARBasic",
    "AmmoShotgunBasic",
    "AmmoShotgun",
    "BasicAmmoShotgunBasic",
    "BasicFlashlight",
    "BigBasicFlashlight",
    "StandardBasicFlashlight",
    "Ham",
    "Hotdog",
    "Katana",
    "GreenCube",
    "PumpShotgun",
    "Plank",
    "RedCube",
    "BasicFlashlight_Standard",
    "Meshes/flashlights_Cylinder.001(1)",
    "AmmoPistolBasic"
}

local TargetLookup = {}
for _, Name in ipairs(TargetItems) do
    TargetLookup[Name] = true
end

local function IsDropTarget(Item)
    return Item and TargetLookup[Item.Name] == true
end

local function GetDropPosition(Object)
    local Part = Object and Object:FindFirstChildWhichIsA("BasePart", true)
    if Part then
        return Part.Position
    end
    local Success, Pivot = pcall(function()
        return Object:GetPivot()
    end)
    if Success and Pivot then
        return Pivot.Position
    end
    return nil
end

local function DropTargetItem(Item)
    local Position = GetDropPosition(Item)
    if Position then
        pcall(function()
            ReplicatedStorage.Remotes.RequestDropItem:FireServer(Item, Position)
        end)
    end
end

local function StartAutoItemDrop()
    if AutoItemDropThread then
        return
    end
    AutoItemDropThread = task.spawn(function()
        while AutoItemDropEnabled do
            local Character = Player.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local Folder = workspace.Map and workspace.Map:FindFirstChild("Util") and workspace.Map.Util:FindFirstChild("Items")

            if Root and Folder then
                for _, Item in ipairs(Folder:GetChildren()) do
                    if not AutoItemDropEnabled then
                        break
                    end
                    if IsDropTarget(Item) then
                        local Part = Item:FindFirstChildWhichIsA("BasePart", true)
                        local Prompt = Item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if Part and Prompt and Prompt.Enabled then
                            local Distance = (Root.Position - Part.Position).Magnitude
                            if Distance <= Prompt.MaxActivationDistance + 1 then
                                pcall(function()
                                    Prompt:InputHoldBegin()
                                end)
                                task.wait(math.max(0.05, Prompt.HoldDuration + 0.05))
                                pcall(function()
                                    Prompt:InputHoldEnd()
                                end)
                                task.wait(0.08)
                                DropTargetItem(Item)
                                task.wait(0.35)
                                break
                            end
                        end
                    end
                end
            end

            task.wait(0.1)
        end
        AutoItemDropThread = nil
    end)
end

FarmTab:Toggle({
    Title = "自动拾取后丢弃",
    Desc = "检测目标物品后自动交互并执行丢弃",
    Value = false,
    Callback = function(Value)
        AutoItemDropEnabled = Value
        if Value then
            StartAutoItemDrop()
        end
    end
})

Window:SelectTab(1)

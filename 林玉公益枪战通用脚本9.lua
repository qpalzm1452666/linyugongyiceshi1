local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local C_BLUE  = Color3.fromRGB(160, 216, 239)
local C_PINK  = Color3.fromRGB(248, 195, 205)
local C_BLUE2 = Color3.fromRGB(120, 186, 214)
local C_PINK2 = Color3.fromRGB(228, 165, 175)
local C_BG    = Color3.fromRGB(250, 250, 252)
local C_TEXT  = Color3.fromRGB(60, 60, 70)
local C_TEXT2 = Color3.fromRGB(120, 120, 130)
local C_WHITE = Color3.fromRGB(255, 255, 255)
local C_GRAY  = Color3.fromRGB(200, 200, 200)

local ESP2_Settings = {
    Enabled = false,
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowChams = true,
    ShowDistance = true,
    TeamCheck = false,
    MaxDistance = 5000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    ChamsFillColor = Color3.fromRGB(119, 120, 255),
    ChamsOutlineColor = Color3.fromRGB(119, 120, 255),
}

local ESP2 = {
    ScreenGui = nil,
    PlayerElements = {},
    RenderConnection = nil,
    FontSize = 11,
}

local AimConfig = {
    Enabled = false,
    FOV = 150,
    Distance = 500,
    Speed = 5,
    Priority = "FOV距离",
    CircleColor = Color3.fromRGB(255, 50, 50),
    VisCheck = true,
    TargetPart = "Head",
    TeamCheck = false,
    Smoothness = 5,
}

local BulletConfig = {
    Enabled = false,
    FOV = 60,
    Priority = "FOV优先",
    Prediction = false,
    PredictionFactor = 0.15,
}

local MiscConfig = {
    AutoFire = false,
    AutoFireRange = 200,
    AutoFireDelay = 0.1,
    FireRate = false,
    FireRateValue = 0.05,
    TeleportEnemies = false,
    TeleportDistance = 35,
}

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = false
FOV_Circle.Thickness = 2
FOV_Circle.Color = AimConfig.CircleColor
FOV_Circle.Transparency = 0.7
FOV_Circle.Filled = false
FOV_Circle.NumSides = 64

local BulletFOV_Circle = Drawing.new("Circle")
BulletFOV_Circle.Visible = false
BulletFOV_Circle.Radius = 60
BulletFOV_Circle.Color = Color3.fromRGB(255, 255, 255)
BulletFOV_Circle.Thickness = 1
BulletFOV_Circle.Transparency = 1
BulletFOV_Circle.Filled = false
BulletFOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    BulletFOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

local ui = Instance.new("ScreenGui")
ui.Name = "Ly枪战辅助"
ui.ResetOnSpawn = false
ui.Parent = playerGui

local orb = Instance.new("Frame")
orb.Name = "Orb"
orb.Size = UDim2.new(0, 52, 0, 52)
orb.Position = UDim2.new(1, -68, 1, -68)
orb.BackgroundColor3 = C_BLUE
orb.BorderSizePixel = 0
orb.ZIndex = 100
orb.Parent = ui

local orbCorner = Instance.new("UICorner")
orbCorner.CornerRadius = UDim.new(1, 0)
orbCorner.Parent = orb

local orbLabel = Instance.new("TextLabel")
orbLabel.Size = UDim2.new(1, 0, 1, 0)
orbLabel.BackgroundTransparency = 1
orbLabel.Text = "Ly"
orbLabel.TextColor3 = C_WHITE
orbLabel.TextSize = 18
orbLabel.Font = Enum.Font.GothamBold
orbLabel.ZIndex = 101
orbLabel.Parent = orb

local orbShadow = Instance.new("Frame")
orbShadow.Size = UDim2.new(1, 8, 1, 8)
orbShadow.Position = UDim2.new(0, -4, 0, -4)
orbShadow.BackgroundColor3 = C_PINK2
orbShadow.BorderSizePixel = 0
orbShadow.ZIndex = 99
orbShadow.Parent = orb

local orbShadowCorner = Instance.new("UICorner")
orbShadowCorner.CornerRadius = UDim.new(1, 0)
orbShadowCorner.Parent = orbShadow

spawn(function()
    while orb.Parent do
        if not orb.Visible then break end
        TweenService:Create(orb, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Size = UDim2.new(0, 58, 0, 58)}):Play()
        wait(1.2)
        if not orb.Parent then break end
        TweenService:Create(orb, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Size = UDim2.new(0, 52, 0, 52)}):Play()
        wait(1.2)
    end
end)

local PANEL_W = 0.70
local PANEL_H = PANEL_W * (400 / 300)
local PANEL_X = (1 - PANEL_W) / 2
local PANEL_Y = (1 - PANEL_H) / 2
local BOTTOM_SAFE = 24

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 0, 0, 0)
panel.Position = UDim2.new(1, -68, 1, -68)
panel.BackgroundColor3 = C_BG
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.ZIndex = 50
panel.Parent = ui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 24)
panelCorner.Parent = panel

local panelShadow = Instance.new("Frame")
panelShadow.Size = UDim2.new(1, 14, 1, 14)
panelShadow.Position = UDim2.new(0, -7, 0, -7)
panelShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
panelShadow.BackgroundTransparency = 0.88
panelShadow.BorderSizePixel = 0
panelShadow.ZIndex = 49
panelShadow.Parent = panel

local panelShadowCorner = Instance.new("UICorner")
panelShadowCorner.CornerRadius = UDim.new(0, 28)
panelShadowCorner.Parent = panelShadow

local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, 0, 1, 0)
inner.BackgroundColor3 = C_BG
inner.BackgroundTransparency = 0
inner.ClipsDescendants = true
inner.ZIndex = 51
inner.Parent = panel

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 24)
innerCorner.Parent = inner

local TOPBAR_H = 48
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
topBar.BackgroundColor3 = C_BLUE
topBar.BorderSizePixel = 0
topBar.ZIndex = 52

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 24)
topBarCorner.Parent = topBar

topBar.ClipsDescendants = true
local topBarMask = Instance.new("Frame")
topBarMask.Size = UDim2.new(1, 0, 0.5, 0)
topBarMask.Position = UDim2.new(0, 0, 0.5, 0)
topBarMask.BackgroundColor3 = C_BLUE
topBarMask.BorderSizePixel = 0
topBarMask.ZIndex = 53
topBarMask.Parent = topBar

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -60, 1, 0)
topTitle.Position = UDim2.new(0, 16, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Text = "Ly枪战辅助"
topTitle.TextColor3 = C_TEXT
topTitle.TextSize = 17
topTitle.Font = Enum.Font.GothamBold
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 54
topTitle.Parent = topBar

local shrinkBtn = Instance.new("TextButton")
shrinkBtn.Name = "ShrinkBtn"
shrinkBtn.Size = UDim2.new(0, 36, 0, 36)
shrinkBtn.Position = UDim2.new(1, -46, 0, 6)
shrinkBtn.BackgroundColor3 = C_PINK
shrinkBtn.Text = "−"
shrinkBtn.TextColor3 = C_TEXT
shrinkBtn.TextSize = 20
shrinkBtn.Font = Enum.Font.GothamBold
shrinkBtn.BorderSizePixel = 0
shrinkBtn.ZIndex = 55
shrinkBtn.Parent = topBar

local shrinkCorner = Instance.new("UICorner")
shrinkCorner.CornerRadius = UDim.new(1, 0)
shrinkCorner.Parent = shrinkBtn

topBar.Parent = inner

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
body.Position = UDim2.new(0, 0, 0, TOPBAR_H)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.ZIndex = 51
body.Parent = inner

local NAV_RATIO = 0.26
local GAP = 0.02
local nav = Instance.new("ScrollingFrame")
nav.Name = "Nav"
nav.Size = UDim2.new(NAV_RATIO, 0, 1, -BOTTOM_SAFE)
nav.BackgroundColor3 = Color3.fromRGB(245, 245, 247)
nav.BorderSizePixel = 0
nav.ScrollBarThickness = 4
nav.ScrollBarImageColor3 = C_BLUE2
nav.CanvasSize = UDim2.new(0, 0, 0, 0)
nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
nav.ZIndex = 52
nav.Parent = body

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 8)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = nav

local navPadding = Instance.new("UIPadding")
navPadding.PaddingLeft = UDim.new(0, 8)
navPadding.PaddingRight = UDim.new(0, 8)
navPadding.PaddingTop = UDim.new(0, 10)
navPadding.PaddingBottom = UDim.new(0, 10)
navPadding.Parent = nav

local navItems = {
    {name = "公告", icon = "📢"},
    {name = "绘制", icon = "🎨"},
    {name = "自瞄", icon = "🎯"},
    {name = "子追", icon = "🔫"},
    {name = "功能", icon = "⚡"},
}

local navBtns = {}
local pages = {}
local selectedIdx = 1

local function randomAccent()
    return math.random() > 0.5 and C_BLUE or C_PINK
end

for i, item in ipairs(navItems) do
    local btn = Instance.new("TextButton")
    btn.Name = item.name
    btn.Size = UDim2.new(1, 0, 0, 60)
    btn.BackgroundColor3 = (i == 1) and C_PINK or C_WHITE
    btn.BackgroundTransparency = 0
    btn.Text = item.icon
    btn.TextColor3 = C_TEXT
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.ZIndex = 53
    btn.Parent = nav

    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(0, 16)
    btnC.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 1, -16)
    lbl.BackgroundTransparency = 1
    lbl.Text = item.name
    lbl.TextColor3 = C_TEXT2
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Gotham
    lbl.ZIndex = 54
    lbl.Parent = btn

    navBtns[i] = btn
end

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1 - NAV_RATIO - GAP, 0, 1, -BOTTOM_SAFE)
content.Position = UDim2.new(NAV_RATIO + GAP, 0, 0, 0)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex = 52
content.Parent = body

local function createToggle(parent, labelText, accentColor, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = C_WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 12)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 46, 0, 26)
    toggleBg.Position = UDim2.new(1, -56, 0.5, -13)
    toggleBg.BackgroundColor3 = C_GRAY
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.AutoButtonColor = false
    toggleBg.ZIndex = 56
    toggleBg.Parent = row

    local toggleBgC = Instance.new("UICorner")
    toggleBgC.CornerRadius = UDim.new(1, 0)
    toggleBgC.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -11)
    toggleKnob.BackgroundColor3 = C_WHITE
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 57
    toggleKnob.Parent = toggleBg

    local toggleKnobC = Instance.new("UICorner")
    toggleKnobC.CornerRadius = UDim.new(1, 0)
    toggleKnobC.Parent = toggleKnob

    local enabled = false

    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 24, 0.5, -11)}):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C_GRAY}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
        end
        if onToggle then onToggle(enabled) end
    end)

    return row
end

local function createSlider(parent, labelText, accentColor, minVal, maxVal, defaultVal, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 60)
    row.BackgroundColor3 = C_WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 12)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 22)
    valLbl.Position = UDim2.new(1, -58, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = accentColor
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 56
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = C_GRAY
    track.BorderSizePixel = 0
    track.ZIndex = 56
    track.Parent = row

    local trackC = Instance.new("UICorner")
    trackC.CornerRadius = UDim.new(1, 0)
    trackC.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 57
    fill.Parent = track

    local fillC = Instance.new("UICorner")
    fillC.CornerRadius = UDim.new(1, 0)
    fillC.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    knob.BackgroundColor3 = C_WHITE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 58
    knob.Parent = track

    local knobC = Instance.new("UICorner")
    knobC.CornerRadius = UDim.new(1, 0)
    knobC.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = accentColor
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

    local dragging = false
    local currentVal = defaultVal

    local function updateFromPos(px)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local rel = math.clamp((px - trackAbs) / trackSize, 0, 1)
        currentVal = math.floor(minVal + rel * (maxVal - minVal))
        valLbl.Text = tostring(currentVal)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -8, 0.5, -8)
        if onChange then onChange(currentVal) end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateFromPos(input.Position.X)
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPos(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

local function createDropdown(parent, labelText, accentColor, options, defaultIdx, onSelect)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = C_WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 12)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -120, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 100, 0, 30)
    selBtn.Position = UDim2.new(1, -110, 0.5, -15)
    selBtn.BackgroundColor3 = accentColor
    selBtn.Text = options[defaultIdx] or options[1]
    selBtn.TextColor3 = C_WHITE
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamBold
    selBtn.BorderSizePixel = 0
    selBtn.ZIndex = 56
    selBtn.Parent = row

    local selC = Instance.new("UICorner")
    selC.CornerRadius = UDim.new(0, 8)
    selC.Parent = selBtn

    local dropdownOpen = false
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 100, 0, 0)
    dropdownFrame.Position = UDim2.new(1, -110, 0, 40)
    dropdownFrame.BackgroundColor3 = C_WHITE
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 60
    dropdownFrame.Visible = false
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = row

    local dropdownC = Instance.new("UICorner")
    dropdownC.CornerRadius = UDim.new(0, 8)
    dropdownC.Parent = dropdownFrame

    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = accentColor
    dropdownStroke.Thickness = 1
    dropdownStroke.Parent = dropdownFrame

    local ddLayout = Instance.new("UIListLayout")
    ddLayout.Padding = UDim.new(0, 2)
    ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ddLayout.Parent = dropdownFrame

    local ddPadding = Instance.new("UIPadding")
    ddPadding.PaddingTop = UDim.new(0, 4)
    ddPadding.PaddingBottom = UDim.new(0, 4)
    ddPadding.PaddingLeft = UDim.new(0, 4)
    ddPadding.PaddingRight = UDim.new(0, 4)
    ddPadding.Parent = dropdownFrame

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = C_BG
        optBtn.Text = opt
        optBtn.TextColor3 = C_TEXT
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.LayoutOrder = i
        optBtn.ZIndex = 61
        optBtn.Parent = dropdownFrame

        local optC = Instance.new("UICorner")
        optC.CornerRadius = UDim.new(0, 6)
        optC.Parent = optBtn

        optBtn.MouseButton1Click:Connect(function()
            selBtn.Text = opt
            dropdownOpen = false
            dropdownFrame.Visible = dropdownOpen
            if onSelect then onSelect(opt) end
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownFrame.Visible = dropdownOpen
        if dropdownOpen then
            dropdownFrame.Size = UDim2.new(0, 100, 0, #options * 30 + 4)
        end
    end)

    return row
end

local function createFeaturePage(name, title, desc, accent)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 53
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 40, 0, 3)
    line.BackgroundColor3 = accent
    line.BorderSizePixel = 0
    line.LayoutOrder = 1
    line.ZIndex = 54
    line.Parent = page

    local lineC = Instance.new("UICorner")
    lineC.CornerRadius = UDim.new(1, 0)
    lineC.Parent = line

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 26)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C_TEXT
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 2
    t.ZIndex = 54
    t.Parent = page

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 18)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = C_TEXT2
    d.TextSize = 12
    d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.LayoutOrder = 3
    d.ZIndex = 54
    d.Parent = page

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 4
    container.ZIndex = 54
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = page

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 6)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local function updateCanvas()
        task.wait()
        local totalH = layout.AbsoluteContentSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(totalH, 100))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.delay(0.2, updateCanvas)

    return page
end

local function createNoticePage()
    local page = Instance.new("ScrollingFrame")
    page.Name = "公告"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C_PINK
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Visible = false
    page.ZIndex = 53
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 40, 0, 3)
    line.BackgroundColor3 = C_PINK
    line.BorderSizePixel = 0
    line.LayoutOrder = 1
    line.ZIndex = 54
    line.Parent = page

    local lineC = Instance.new("UICorner")
    lineC.CornerRadius = UDim.new(1, 0)
    lineC.Parent = line

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 28)
    t.BackgroundTransparency = 1
    t.Text = "公告"
    t.TextColor3 = C_TEXT
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 2
    t.ZIndex = 54
    t.Parent = page

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 20)
    d.BackgroundTransparency = 1
    d.Text = "Ly枪战辅助 公告与更新日志"
    d.TextColor3 = C_TEXT2
    d.TextSize = 12
    d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.LayoutOrder = 3
    d.ZIndex = 54
    d.Parent = page

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 280)
    card.BackgroundColor3 = C_WHITE
    card.BorderSizePixel = 0
    card.LayoutOrder = 4
    card.ZIndex = 54
    card.Parent = page

    local cardC = Instance.new("UICorner")
    cardC.CornerRadius = UDim.new(0, 16)
    cardC.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = C_PINK
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.3
    cardStroke.Parent = card

    local noticeText = Instance.new("TextLabel")
    noticeText.Size = UDim2.new(1, -20, 1, -20)
    noticeText.Position = UDim2.new(0, 10, 0, 10)
    noticeText.BackgroundTransparency = 1
    noticeText.Text = "Ly枪战辅助\n\n欢迎使用本脚本！\n\n功能：\n• 高级绘制\n• 自瞄辅助\n• 子弹追踪\n\n作者：林玉"
    noticeText.TextColor3 = C_TEXT
    noticeText.TextSize = 13
    noticeText.Font = Enum.Font.Gotham
    noticeText.TextWrapped = true
    noticeText.TextXAlignment = Enum.TextXAlignment.Left
    noticeText.TextYAlignment = Enum.TextYAlignment.Top
    noticeText.ZIndex = 55
    noticeText.Parent = card

    local function updateCanvas()
        task.wait()
        local totalH = layout.AbsoluteContentSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(totalH, 100))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.delay(0.2, updateCanvas)

    return page
end

pages[1] = createNoticePage()
pages[1].Visible = true

local function switchPage(idx)
    if selectedIdx == idx then
        local color = randomAccent()
        navBtns[idx].BackgroundColor3 = color
        return
    end

    local oldBtn = navBtns[selectedIdx]
    if oldBtn then oldBtn.BackgroundColor3 = C_WHITE end

    local newBtn = navBtns[idx]
    if not newBtn then return end
    local color = randomAccent()
    newBtn.BackgroundColor3 = color

    if pages[selectedIdx] then
        pages[selectedIdx].Visible = false
    end

    if pages[idx] then
        local newPage = pages[idx]
        newPage.Visible = true
        newPage.Position = UDim2.new(0.04, 0, 0, 0)
        TweenService:Create(newPage, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 0, 0, 0),
        }):Play()
    end

    selectedIdx = idx
end

for i, btn in ipairs(navBtns) do
    btn.MouseButton1Click:Connect(function()
        switchPage(i)
    end)
end

local isOpen = false

local function openPanel()
    isOpen = true
    orb.Visible = false
    panel.Visible = true

    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Position = UDim2.new(1, -68, 1, -68)

    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(PANEL_W, 0, PANEL_H, 0),
        Position = UDim2.new(PANEL_X, 0, PANEL_Y, 0),
    }):Play()
end

local function closePanel()
    isOpen = false

    TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(1, -68, 1, -68),
    }):Play()

    wait(0.25)
    panel.Visible = false
    orb.Visible = true
end

shrinkBtn.MouseButton1Click:Connect(closePanel)

local dragTouchId = nil
local dragOffset = Vector2.new(0, 0)
local dragStartPos = Vector2.new(0, 0)
local isClick = true
local CLICK_THRESHOLD = 10

local function isOnOrb(pos)
    local orbPos = orb.AbsolutePosition
    local orbSize = orb.AbsoluteSize
    return pos.X >= orbPos.X - 15 and pos.X <= orbPos.X + orbSize.X + 15
       and pos.Y >= orbPos.Y - 15 and pos.Y <= orbPos.Y + orbSize.Y + 15
end

local function onInputBegan(input)
    if not orb.Visible then return end
    if input.UserInputType ~= Enum.UserInputType.Touch 
       and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    if not isOnOrb(input.Position) then return end

    dragTouchId = input.UserInputType == Enum.UserInputType.Touch and input or "mouse"
    dragStartPos = input.Position
    dragOffset = Vector2.new(
        input.Position.X - orb.AbsolutePosition.X,
        input.Position.Y - orb.AbsolutePosition.Y
    )
    isClick = true

    TweenService:Create(orb, TweenInfo.new(0.1), {Size = UDim2.new(0, 52, 0, 52)}):Play()
end

local function onInputChanged(input)
    if not dragTouchId then return end
    if input.UserInputType ~= Enum.UserInputType.Touch 
       and input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end
    if dragTouchId ~= "mouse" and dragTouchId ~= input then return end

    local pos = input.Position
    local dist = (pos - dragStartPos).Magnitude
    if dist > CLICK_THRESHOLD then isClick = false end

    local screenW = ui.AbsoluteSize.X
    local screenH = ui.AbsoluteSize.Y
    local orbW = 52
    local orbH = 52

    local newX = pos.X - dragOffset.X
    local newY = pos.Y - dragOffset.Y

    newX = math.clamp(newX, 0, screenW - orbW)
    newY = math.clamp(newY, 0, screenH - orbH)

    orb.Position = UDim2.new(0, newX, 0, newY)
end

local function onInputEnded(input)
    if not dragTouchId then return end
    if input.UserInputType ~= Enum.UserInputType.Touch 
       and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end
    if dragTouchId ~= "mouse" and dragTouchId ~= input then return end

    dragTouchId = nil

    if isClick then
        openPanel()
    else
        local screenW = ui.AbsoluteSize.X
        local orbX = orb.AbsolutePosition.X
        local orbW = 52
        local targetX = (orbX + orbW/2 < screenW / 2) and 12 or (screenW - orbW - 12)

        TweenService:Create(orb, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, targetX, 0, orb.AbsolutePosition.Y)
        }):Play()
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
end)

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then
        return true
    end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function ESP2_Create(Class, Properties)
    local inst = (type(Class) == "string") and Instance.new(Class) or Class
    for prop, val in pairs(Properties) do
        inst[prop] = val
    end
    return inst
end

local function ESP2_FadeOutOnDist(element, distance, maxDist)
    local maxD = maxDist or ESP2_Settings.MaxDistance
    local transparency = math.max(0.1, 1 - (distance / maxD))
    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("ImageLabel") then
        element.ImageTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    elseif element:IsA("Highlight") then
        element.FillTransparency = 1 - transparency
        element.OutlineTransparency = 1 - transparency
    end
end

local function CreateESP2ScreenGui()
    if ESP2.ScreenGui then return end
    ESP2.ScreenGui = ESP2_Create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        Name = "ESP2Holder",
        Enabled = true,
    })
end

local function CreateESP2ForPlayer(plr)
    if ESP2.PlayerElements[plr] then return end
    local sg = ESP2.ScreenGui
    if not sg then return end

    local elements = {}
    elements.Name = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = ESP2_Settings.NameColor, Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    elements.Distance = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    elements.Box = ESP2_Create("Frame", {Parent = sg, BackgroundColor3 = ESP2_Settings.BoxColor, BackgroundTransparency = 0.75, BorderSizePixel = 0})
    elements.Outline = ESP2_Create("UIStroke", {Parent = elements.Box, Enabled = true, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
    elements.Healthbar = ESP2_Create("Frame", {Parent = sg, BackgroundColor3 = ESP2_Settings.HealthBarColor, BackgroundTransparency = 0})
    elements.BehindHealthbar = ESP2_Create("Frame", {Parent = sg, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
    elements.HealthText = ESP2_Create("TextLabel", {Parent = sg, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP2.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
    elements.Chams = ESP2_Create("Highlight", {Parent = sg, FillTransparency = 1, OutlineTransparency = 0, OutlineColor = ESP2_Settings.ChamsOutlineColor, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop})
    for _, v in pairs(elements) do
        if v and v:IsA("GuiObject") then v.Visible = false end
    end
    if elements.Chams then elements.Chams.Enabled = false end
    ESP2.PlayerElements[plr] = elements
end

local function DestroyESP2ForPlayer(plr)
    local elements = ESP2.PlayerElements[plr]
    if elements then
        for _, v in pairs(elements) do
            if v then pcall(function() v:Destroy() end) end
        end
        ESP2.PlayerElements[plr] = nil
    end
end

local function UpdateESP2()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local lp = player
    local maxDist = ESP2_Settings.MaxDistance

    for plr, elements in pairs(ESP2.PlayerElements) do
        local shouldHide = true
        if plr and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local sameTeam = (ESP2_Settings.TeamCheck and lp.Team == plr.Team and lp.Team ~= nil)
                if not sameTeam then
                    local pos, onScreen = camera:WorldToScreenPoint(hrp.Position)
                    local dist = (camera.CFrame.Position - hrp.Position).Magnitude
                    if onScreen and dist <= maxDist then
                        shouldHide = false
                        local size = hrp.Size.Y
                        local scaleFactor = (size * camera.ViewportSize.Y) / (pos.Z * 2)
                        local w = 3 * scaleFactor
                        local h = 4.5 * scaleFactor

                        ESP2_FadeOutOnDist(elements.Box, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Outline, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Name, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Healthbar, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.BehindHealthbar, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.HealthText, dist, maxDist)
                        ESP2_FadeOutOnDist(elements.Chams, dist, maxDist)

                        if ESP2_Settings.ShowBox then
                            elements.Box.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                            elements.Box.Size = UDim2.new(0, w, 0, h)
                            elements.Box.Visible = true
                            elements.Box.BackgroundTransparency = 0.75
                            elements.Box.BorderSizePixel = 1
                            elements.Box.BackgroundColor3 = ESP2_Settings.BoxColor
                            elements.Outline.Enabled = true
                            elements.Outline.Transparency = 0
                        else
                            elements.Box.Visible = false
                            elements.Outline.Enabled = false
                        end

                        if ESP2_Settings.ShowChams then
                            elements.Chams.Adornee = char
                            elements.Chams.Enabled = true
                            elements.Chams.FillColor = ESP2_Settings.ChamsFillColor
                            elements.Chams.FillTransparency = 0.8
                            elements.Chams.OutlineColor = ESP2_Settings.ChamsOutlineColor
                            elements.Chams.OutlineTransparency = 0.5
                            elements.Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        else
                            elements.Chams.Enabled = false
                        end

                        if ESP2_Settings.ShowName then
                            local distText = ""
                            if ESP2_Settings.ShowDistance then
                                distText = string.format(" [%dm]", math.floor(dist))
                            end
                            elements.Name.Text = plr.Name .. distText
                            elements.Name.Position = UDim2.new(0, pos.X, 0, pos.Y - h/2 - 9)
                            elements.Name.TextColor3 = ESP2_Settings.NameColor
                            elements.Name.Visible = true
                        else
                            elements.Name.Visible = false
                        end

                        if ESP2_Settings.ShowHealth then
                            local health = hum.Health / hum.MaxHealth
                            health = math.clamp(health, 0, 1)
                            elements.Healthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - health))
                            elements.Healthbar.Size = UDim2.new(0, 2.5, 0, h * health)
                            elements.Healthbar.BackgroundColor3 = ESP2_Settings.HealthBarColor
                            elements.Healthbar.Visible = true
                            elements.BehindHealthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2)
                            elements.BehindHealthbar.Size = UDim2.new(0, 2.5, 0, h)
                            elements.BehindHealthbar.Visible = true
                            local healthPercent = math.floor(hum.Health / hum.MaxHealth * 100)
                            elements.HealthText.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - healthPercent/100) + 3)
                            elements.HealthText.Text = tostring(healthPercent)
                            elements.HealthText.Visible = (hum.Health < hum.MaxHealth)
                        else
                            elements.Healthbar.Visible = false
                            elements.BehindHealthbar.Visible = false
                            elements.HealthText.Visible = false
                        end

                        elements.Distance.Visible = false
                    end
                end
            end
        end
        if shouldHide then
            for _, v in pairs(elements) do
                if v and v:IsA("GuiObject") then v.Visible = false end
            end
            if elements.Chams then elements.Chams.Enabled = false end
        end
    end

    for plr, _ in pairs(ESP2.PlayerElements) do
        if not game.Players:FindFirstChild(plr.Name) then DestroyESP2ForPlayer(plr) end
    end
end

local function StartESP2()
    if ESP2.RenderConnection then return end
    ESP2.RenderConnection = RunService.RenderStepped:Connect(function()
        if ESP2_Settings.Enabled then
            UpdateESP2()
        else
            for plr, elements in pairs(ESP2.PlayerElements) do
                for _, v in pairs(elements) do
                    if v and v:IsA("GuiObject") then v.Visible = false end
                end
                if elements.Chams then elements.Chams.Enabled = false end
            end
        end
    end)
end

local function InitESP2Events()
    game.Players.PlayerAdded:Connect(function(plr)
        if plr == player then return end
        CreateESP2ForPlayer(plr)
    end)
    game.Players.PlayerRemoving:Connect(function(plr)
        DestroyESP2ForPlayer(plr)
    end)
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then CreateESP2ForPlayer(plr) end
    end
end

local function SetESP2Enabled(enabled)
    ESP2_Settings.Enabled = enabled
    if enabled then
        CreateESP2ScreenGui()
        InitESP2Events()
        StartESP2()
    else
        for plr, elements in pairs(ESP2.PlayerElements) do
            for _, v in pairs(elements) do
                if v and v:IsA("GuiObject") then v.Visible = false end
            end
            if elements.Chams then elements.Chams.Enabled = false end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Position = screenCenter
    FOV_Circle.Radius = AimConfig.FOV
    FOV_Circle.Color = AimConfig.CircleColor

    if not AimConfig.Enabled then return end

    local bestTarget = nil
    local bestScore = math.huge
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position or Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player or not plr.Character then continue end
        local char = plr.Character
        local targetPart = char:FindFirstChild(AimConfig.TargetPart)
        if not targetPart then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distToCenter > AimConfig.FOV then continue end

        local worldDist = (targetPart.Position - myPos).Magnitude
        if worldDist > AimConfig.Distance then continue end

        if AimConfig.TeamCheck and plr.Team == player.Team and player.Team ~= nil then continue end
        if AimConfig.VisCheck and not IsVisible(targetPart) then continue end

        local score
        if AimConfig.Priority == "FOV距离" then
            score = distToCenter
        elseif AimConfig.Priority == "世界距离" then
            score = worldDist
        elseif AimConfig.Priority == "综合评分" then
            score = distToCenter * 0.7 + worldDist * 0.3
        elseif AimConfig.Priority == "血量优先" then
            local hum = char:FindFirstChild("Humanoid")
            local hp = hum and hum.Health or 100
            score = distToCenter * 0.5 + hp * 0.5
        else
            score = distToCenter
        end

        if score < bestScore then
            bestScore = score
            bestTarget = targetPart
        end
    end

    if bestTarget then
        local targetCF = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
        local smoothFactor = math.clamp((21 - AimConfig.Smoothness) / 100, 0.01, 0.3)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothFactor)
    end
end)

local function getClosestHead()
    local bestHead = nil
    local bestScore = math.huge
    local cameraDirection = Camera.CFrame.LookVector
    local cameraPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local forcefield = char:FindFirstChild("ForceField")

            if head and humanoid and not forcefield and humanoid.Health > 0 then
                local targetPos = head.Position

                -- 预判：根据敌人速度预测未来位置
                if BulletConfig.Prediction then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local velocity = hrp.Velocity
                        targetPos = head.Position + velocity * BulletConfig.PredictionFactor
                    end
                end

                local directionToHead = (targetPos - cameraPos).Unit
                local angle = math.deg(math.acos(math.clamp(cameraDirection:Dot(directionToHead), -1, 1)))

                if angle <= BulletConfig.FOV then
                    local worldDist = (targetPos - cameraPos).Magnitude
                    local score
                    if BulletConfig.Priority == "FOV优先" then
                        score = angle
                    elseif BulletConfig.Priority == "距离优先" then
                        score = worldDist
                    elseif BulletConfig.Priority == "综合评分" then
                        score = angle * 0.7 + worldDist * 0.3
                    else
                        score = angle
                    end

                    if score < bestScore then
                        bestScore = score
                        bestHead = head
                    end
                end
            end
        end
    end

    return bestHead
end

local oldHook
local success, err = pcall(function()
    oldHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if BulletConfig.Enabled and (method == "Raycast" or method == "FindPartOnRay") and not checkcaller() and self == Workspace then
            local origin, direction
            if method == "Raycast" then
                origin = args[1]
                direction = args[2]
            else
                local ray = args[1]
                if typeof(ray) == "Ray" then
                    origin = ray.Origin
                    direction = ray.Direction
                end
            end

            if origin and direction then
                local closestHead = getClosestHead()
                if closestHead then
                    local targetPos = closestHead.Position
                    -- 应用预判到子弹命中位置
                    if BulletConfig.Prediction then
                        local char = closestHead.Parent
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            targetPos = closestHead.Position + hrp.Velocity * BulletConfig.PredictionFactor
                        end
                    end
                    return {
                        Instance = closestHead,
                        Position = targetPos,
                        Normal = (targetPos - origin).Unit,
                        Material = Enum.Material.Plastic
                    }
                end
            end
        end

        return oldHook(self, ...)
    end)
end)

RunService.RenderStepped:Connect(function()
    BulletFOV_Circle.Visible = BulletConfig.Enabled
    BulletFOV_Circle.Radius = BulletConfig.FOV
    BulletFOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

pages[2] = createFeaturePage("绘制", "绘制", "ESP 高级绘制设置", C_PINK)

createToggle(pages[2].Container, "ESP 总开关", C_PINK, function(v)
    SetESP2Enabled(v)
end).LayoutOrder = 1

createToggle(pages[2].Container, "显示方框", C_PINK, function(v)
    ESP2_Settings.ShowBox = v
end).LayoutOrder = 2

createToggle(pages[2].Container, "显示名字", C_PINK, function(v)
    ESP2_Settings.ShowName = v
end).LayoutOrder = 3

createToggle(pages[2].Container, "显示距离", C_PINK, function(v)
    ESP2_Settings.ShowDistance = v
end).LayoutOrder = 4

createToggle(pages[2].Container, "显示血量", C_PINK, function(v)
    ESP2_Settings.ShowHealth = v
end).LayoutOrder = 5

createToggle(pages[2].Container, "上色透视", C_PINK, function(v)
    ESP2_Settings.ShowChams = v
end).LayoutOrder = 6

createToggle(pages[2].Container, "队伍检测", C_PINK, function(v)
    ESP2_Settings.TeamCheck = v
end).LayoutOrder = 7

createSlider(pages[2].Container, "最大绘制距离", C_PINK, 50, 5000, 5000, function(v)
    ESP2_Settings.MaxDistance = v
end).LayoutOrder = 8

pages[3] = createFeaturePage("自瞄", "自瞄", "自瞄功能详细设置", C_BLUE)

createToggle(pages[3].Container, "启用自瞄", C_BLUE, function(v)
    AimConfig.Enabled = v
    FOV_Circle.Visible = v
end).LayoutOrder = 1

createToggle(pages[3].Container, "漏打检测", C_BLUE, function(v)
    AimConfig.VisCheck = v
end).LayoutOrder = 2

createToggle(pages[3].Container, "队伍检测", C_BLUE, function(v)
    AimConfig.TeamCheck = v
end).LayoutOrder = 3

createSlider(pages[3].Container, "自瞄范围", C_BLUE, 50, 400, 150, function(v)
    AimConfig.FOV = v
end).LayoutOrder = 4

createSlider(pages[3].Container, "自瞄距离", C_BLUE, 100, 2000, 500, function(v)
    AimConfig.Distance = v
end).LayoutOrder = 5

createSlider(pages[3].Container, "自瞄速度", C_BLUE, 1, 30, 5, function(v)
    AimConfig.Speed = v
end).LayoutOrder = 6

createSlider(pages[3].Container, "平滑度", C_BLUE, 1, 20, 5, function(v)
    AimConfig.Smoothness = v
end).LayoutOrder = 7

createDropdown(pages[3].Container, "优先条件", C_BLUE, {"FOV距离", "世界距离", "综合评分", "血量优先"}, 1, function(v)
    AimConfig.Priority = v
end).LayoutOrder = 8

createDropdown(pages[3].Container, "瞄准部位", C_BLUE, {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, 1, function(v)
    AimConfig.TargetPart = v
end).LayoutOrder = 9

pages[4] = createFeaturePage("子追", "子弹追踪", "子弹追踪功能设置", C_PINK)

createToggle(pages[4].Container, "启用子弹追踪", C_PINK, function(v)
    BulletConfig.Enabled = v
end).LayoutOrder = 1

createSlider(pages[4].Container, "追踪角度范围", C_PINK, 10, 180, 60, function(v)
    BulletConfig.FOV = v
end).LayoutOrder = 2

createDropdown(pages[4].Container, "优先条件", C_PINK, {"FOV优先", "距离优先", "综合评分"}, 1, function(v)
    BulletConfig.Priority = v
end).LayoutOrder = 3

createToggle(pages[4].Container, "启用预判", C_PINK, function(v)
    BulletConfig.Prediction = v
end).LayoutOrder = 4

createSlider(pages[4].Container, "预判系数", C_PINK, 5, 50, 15, function(v)
    BulletConfig.PredictionFactor = v / 100
end).LayoutOrder = 5

pages[5] = createFeaturePage("功能", "功能", "通用功能设置", C_BLUE)

createToggle(pages[5].Container, "自动开枪", C_BLUE, function(v)
    MiscConfig.AutoFire = v
end).LayoutOrder = 1

createSlider(pages[5].Container, "自动开枪范围", C_BLUE, 50, 500, 200, function(v)
    MiscConfig.AutoFireRange = v
end).LayoutOrder = 2

createSlider(pages[5].Container, "开枪间隔(秒)", C_BLUE, 1, 20, 10, function(v)
    MiscConfig.AutoFireDelay = v / 100
end).LayoutOrder = 3

createToggle(pages[5].Container, "修改射速", C_BLUE, function(v)
    MiscConfig.FireRate = v
end).LayoutOrder = 4

createSlider(pages[5].Container, "射速间隔(秒)", C_BLUE, 1, 20, 5, function(v)
    MiscConfig.FireRateValue = v / 100
end).LayoutOrder = 5

createToggle(pages[5].Container, "敌人传送面前", C_BLUE, function(v)
    MiscConfig.TeleportEnemies = v
end).LayoutOrder = 6

createSlider(pages[5].Container, "传送距离", C_BLUE, 15, 80, 35, function(v)
    MiscConfig.TeleportDistance = v
end).LayoutOrder = 7


-- ========== 本地传送（仅自己可见） ==========
-- 【原理】在自己的客户端上，每帧强制将其他玩家模型渲染到面前。
-- 服务端位置不变，敌人自己视角不变，只有你能看到敌人在面前。
-- 配合自瞄/子弹追踪可直接命中面前的敌人。

local teleportOffsets = {}

RunService.RenderStepped:Connect(function()
    if not MiscConfig.TeleportEnemies then
        teleportOffsets = {}
        return
    end

    local myChar = player.Character
    if not myChar then return end

    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local camera = Workspace.CurrentCamera
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local basePos = myHrp.Position + forward * MiscConfig.TeleportDistance + Vector3.new(0, 2, 0)

    local idx = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                idx = idx + 1

                -- 计算面前位置（扇形分布，避免重叠）
                local angle = (idx - 1) * 0.3
                local spread = right * math.sin(angle) * 5 + forward * math.cos(angle) * 0
                local targetPos = basePos + spread

                -- 记录偏移量（用于恢复）
                if not teleportOffsets[plr] then
                    teleportOffsets[plr] = hrp.CFrame
                end

                -- 强制设置到面前（仅本地渲染）
                hrp.CFrame = CFrame.new(targetPos, targetPos + forward)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

                -- 同时设置整个模型的 PrimaryPart
                if char.PrimaryPart and char.PrimaryPart ~= hrp then
                    char.PrimaryPart.CFrame = hrp.CFrame
                end
            end
        end
    end
end)

-- ========== 自动开枪 ==========
local VirtualUser = game:GetService("VirtualUser")
local lastAutoFire = 0

RunService.RenderStepped:Connect(function()
    if not MiscConfig.AutoFire then return end

    local now = tick()
    if now - lastAutoFire < MiscConfig.AutoFireDelay then return end

    local cameraPos = Camera.CFrame.Position
    local cameraDir = Camera.CFrame.LookVector
    local range = MiscConfig.AutoFireRange

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if head and humanoid and humanoid.Health > 0 then
                -- 漏打检测：只打可见目标
                if not IsVisible(head) then continue end

                local toTarget = head.Position - cameraPos
                local dist = toTarget.Magnitude
                if dist <= range then
                    local dir = toTarget.Unit
                    local angle = math.deg(math.acos(math.clamp(cameraDir:Dot(dir), -1, 1)))
                    if angle <= 15 then
                        -- 使用 VirtualUser 模拟点击，不干扰移动/跳跃输入
                        pcall(function()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                            task.wait(0.01)
                            VirtualUser:Button1Up(Vector2.new(0, 0))
                        end)
                        lastAutoFire = now
                        break
                    end
                end
            end
        end
    end
end)

-- ========== 射速修改 ==========
local function setupFireRate(tool)
    if not tool:IsA("Tool") then return end
    if not MiscConfig.FireRate then return end

    local config = tool:FindFirstChild("Configuration")
    if config then
        local fireRate = config:FindFirstChild("FireRate") or config:FindFirstChild("FireCooldown") or config:FindFirstChild("Cooldown")
        if fireRate then
            fireRate.Value = MiscConfig.FireRateValue
        end
    end
end

-- 监听当前装备的工具
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupFireRate(child)
        end
    end)

    -- 也扫描 Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                setupFireRate(tool)
            end
        end
        backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                setupFireRate(child)
            end
        end)
    end

    -- 持续保持射速
    if MiscConfig.FireRate then
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not char.Parent then
                conn:Disconnect()
                return
            end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    setupFireRate(tool)
                end
            end
        end)
    end
end)

-- 如果角色已存在，立即设置
if player.Character then
    for _, child in ipairs(player.Character:GetChildren()) do
        if child:IsA("Tool") then
            setupFireRate(child)
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                setupFireRate(tool)
            end
        end
    end
end

-- ========== 自动开枪 ==========
local VirtualUser = game:GetService("VirtualUser")
local lastAutoFire = 0

RunService.RenderStepped:Connect(function()
    if not MiscConfig.AutoFire then return end

    local now = tick()
    if now - lastAutoFire < MiscConfig.AutoFireDelay then return end

    local cameraPos = Camera.CFrame.Position
    local cameraDir = Camera.CFrame.LookVector
    local range = MiscConfig.AutoFireRange

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if head and humanoid and humanoid.Health > 0 then
                -- 漏打检测：只打可见目标
                if not IsVisible(head) then continue end

                local toTarget = head.Position - cameraPos
                local dist = toTarget.Magnitude
                if dist <= range then
                    local dir = toTarget.Unit
                    local angle = math.deg(math.acos(math.clamp(cameraDir:Dot(dir), -1, 1)))
                    if angle <= 15 then
                        -- 使用 VirtualUser 模拟点击，不干扰移动/跳跃输入
                        pcall(function()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                            task.wait(0.01)
                            VirtualUser:Button1Up(Vector2.new(0, 0))
                        end)
                        lastAutoFire = now
                        break
                    end
                end
            end
        end
    end
end)

-- ========== 敌人传送面前 ==========
-- 【说明】传送其他玩家/敌人需要服务端权限。
-- Roblox 引擎中其他玩家的位置由服务端权威控制，
-- 客户端修改后会被服务端立即覆盖。已尝试 CFrame、
-- PivotTo、MoveTo、持续强制保持、AlignPosition 约束等多种方法，
-- 均受服务端限制无法生效。
local lastTeleport = 0
local teleportCooldown = 0.5

-- 尝试通过远程事件发送移动数据（部分游戏有效）

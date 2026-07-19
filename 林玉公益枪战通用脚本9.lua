local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ========== 高级配色方案 ==========
local C_BG       = Color3.fromRGB(248, 250, 252)
local C_SURFACE  = Color3.fromRGB(255, 255, 255)
local C_SURFACE2 = Color3.fromRGB(241, 245, 249)
local C_ACCENT   = Color3.fromRGB(59, 130, 246)
local C_ACCENT2  = Color3.fromRGB(244, 63, 94)
local C_ACCENT3  = Color3.fromRGB(139, 92, 246)
local C_TEXT     = Color3.fromRGB(15, 23, 42)
local C_TEXT2    = Color3.fromRGB(100, 116, 139)
local C_TEXT3    = Color3.fromRGB(148, 163, 184)
local C_BORDER   = Color3.fromRGB(226, 232, 240)
local C_GREEN    = Color3.fromRGB(34, 197, 94)
local C_ORANGE   = Color3.fromRGB(249, 115, 22)

local ESP2_Settings = {
    Enabled = false,
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowChams = true,
    ShowDistance = true,
    TeamCheck = false,
    VisCheck = false,
    MaxDistance = 5000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(34, 197, 94),
    ChamsFillColor = Color3.fromRGB(99, 102, 241),
    ChamsOutlineColor = Color3.fromRGB(99, 102, 241),
    ShowRadar = false,
    RadarShape = "圆形",
    RadarSize = 120,
    RadarRange = 200,
    RadarPosX = 150,
    RadarPosY = 150,
    RadarVisibleColor = "绿色",
    RadarHiddenColor = "红色",
}

local ColorMap = {
    ["红色"] = Color3.fromRGB(239, 68, 68),
    ["绿色"] = Color3.fromRGB(34, 197, 94),
    ["蓝色"] = Color3.fromRGB(59, 130, 246),
    ["黄色"] = Color3.fromRGB(234, 179, 8),
    ["青色"] = Color3.fromRGB(6, 182, 212),
    ["紫色"] = Color3.fromRGB(139, 92, 246),
    ["橙色"] = Color3.fromRGB(249, 115, 22),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["粉色"] = Color3.fromRGB(236, 72, 153),
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
    CircleColor = Color3.fromRGB(244, 63, 94),
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
    TeleportDistance = 5,
    KillAura = false,
    KillAuraRange = 50,
    KillAuraPriority = "距离优先",
    KillAuraLock = false,
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

-- ========== 主UI ==========
local ui = Instance.new("ScreenGui")
ui.Name = "Ly枪战辅助"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ui.Parent = playerGui

-- 悬浮球
local orb = Instance.new("TextButton")
orb.Name = "Orb"
orb.Size = UDim2.new(0, 50, 0, 50)
orb.Position = UDim2.new(1, -70, 1, -70)
orb.BackgroundColor3 = C_ACCENT
orb.BorderSizePixel = 0
orb.Text = "Ly"
orb.TextColor3 = Color3.fromRGB(255,255,255)
orb.TextSize = 15
orb.Font = Enum.Font.GothamBold
orb.ZIndex = 100
orb.AutoButtonColor = false
orb.Parent = ui

local orbCorner = Instance.new("UICorner")
orbCorner.CornerRadius = UDim.new(1, 0)
orbCorner.Parent = orb

local orbStroke = Instance.new("UIStroke")
orbStroke.Color = Color3.fromRGB(147, 197, 253)
orbStroke.Thickness = 2.5
orbStroke.Transparency = 0.3
orbStroke.Parent = orb

local orbGlow = Instance.new("ImageLabel")
orbGlow.Name = "Glow"
orbGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
orbGlow.Position = UDim2.new(-0.3, 0, -0.3, 0)
orbGlow.BackgroundTransparency = 1
orbGlow.Image = "rbxassetid://5028857084"
orbGlow.ImageColor3 = C_ACCENT
orbGlow.ImageTransparency = 0.85
orbGlow.ZIndex = 99
orbGlow.Parent = orb

spawn(function()
    while orb.Parent do
        if not orb.Visible then break end
        TweenService:Create(orbStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Transparency = 0.1}):Play()
        wait(1.2)
        if not orb.Parent then break end
        TweenService:Create(orbStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Transparency = 0.5}):Play()
        wait(1.2)
    end
end)

-- 主面板
local PANEL_W = 0.72
local PANEL_H = PANEL_W * (420 / 320)
local PANEL_X = (1 - PANEL_W) / 2
local PANEL_Y = (1 - PANEL_H) / 2
local BOTTOM_SAFE = 20

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 0, 0, 0)
panel.Position = UDim2.new(1, -70, 1, -70)
panel.BackgroundColor3 = C_BG
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.ZIndex = 50
panel.Parent = ui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 20)
panelCorner.Parent = panel

local shadow1 = Instance.new("Frame")
shadow1.Size = UDim2.new(1, 24, 1, 24)
shadow1.Position = UDim2.new(0, -12, 0, -12)
shadow1.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow1.BackgroundTransparency = 0.92
shadow1.BorderSizePixel = 0
shadow1.ZIndex = 48
shadow1.Parent = panel
local sc1 = Instance.new("UICorner")
sc1.CornerRadius = UDim.new(0, 26)
sc1.Parent = shadow1

local shadow2 = Instance.new("Frame")
shadow2.Size = UDim2.new(1, 8, 1, 8)
shadow2.Position = UDim2.new(0, -4, 0, -4)
shadow2.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow2.BackgroundTransparency = 0.85
shadow2.BorderSizePixel = 0
shadow2.ZIndex = 49
shadow2.Parent = panel
local sc2 = Instance.new("UICorner")
sc2.CornerRadius = UDim.new(0, 22)
sc2.Parent = shadow2

local inner = Instance.new("Frame")
inner.Name = "Inner"
inner.Size = UDim2.new(1, 0, 1, 0)
inner.BackgroundColor3 = C_BG
inner.BorderSizePixel = 0
inner.ClipsDescendants = true
inner.ZIndex = 51
inner.Parent = panel

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 20)
innerCorner.Parent = inner

-- 顶部栏
local TOPBAR_H = 52
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
topBar.BackgroundColor3 = C_SURFACE
topBar.BorderSizePixel = 0
topBar.ZIndex = 52

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 20)
topBarCorner.Parent = topBar

topBar.ClipsDescendants = true
local topBarMask = Instance.new("Frame")
topBarMask.Size = UDim2.new(1, 0, 0.5, 0)
topBarMask.Position = UDim2.new(0, 0, 0.5, 0)
topBarMask.BackgroundColor3 = C_SURFACE
topBarMask.BorderSizePixel = 0
topBarMask.ZIndex = 53
topBarMask.Parent = topBar

local topGradient = Instance.new("Frame")
topGradient.Size = UDim2.new(1, 0, 0, 3)
topGradient.Position = UDim2.new(0, 0, 0, 0)
topGradient.BackgroundColor3 = C_ACCENT
local tgCorner = Instance.new("UICorner")
tgCorner.CornerRadius = UDim.new(0, 2)
tgCorner.Parent = topGradient

local topGradient2 = Instance.new("Frame")
topGradient2.Size = UDim2.new(0.5, 0, 0, 3)
topGradient2.Position = UDim2.new(0.5, 0, 0, 0)
topGradient2.BackgroundColor3 = C_ACCENT2
local tg2Corner = Instance.new("UICorner")
tg2Corner.CornerRadius = UDim.new(0, 2)
tg2Corner.Parent = topGradient2

topGradient.Parent = topBar
topGradient2.Parent = topBar
topGradient.ZIndex = 55
topGradient2.ZIndex = 55

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -100, 1, 0)
topTitle.Position = UDim2.new(0, 18, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Text = "Ly枪战辅助"
topTitle.TextColor3 = C_TEXT
topTitle.TextSize = 16
topTitle.Font = Enum.Font.GothamBold
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 54
topTitle.Parent = topBar

local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(0, 50, 0, 18)
verLabel.Position = UDim2.new(0, 110, 0.5, -9)
verLabel.BackgroundColor3 = C_ACCENT
verLabel.BackgroundTransparency = 0.85
verLabel.Text = "v2.6"
verLabel.TextColor3 = C_ACCENT
verLabel.TextSize = 10
verLabel.Font = Enum.Font.GothamBold
verLabel.ZIndex = 54
local verC = Instance.new("UICorner")
verC.CornerRadius = UDim.new(0, 4)
verC.Parent = verLabel
verLabel.Parent = topBar

local shrinkBtn = Instance.new("TextButton")
shrinkBtn.Name = "ShrinkBtn"
shrinkBtn.Size = UDim2.new(0, 32, 0, 32)
shrinkBtn.Position = UDim2.new(1, -42, 0, 10)
shrinkBtn.BackgroundColor3 = C_SURFACE2
shrinkBtn.Text = "✕"
shrinkBtn.TextColor3 = C_TEXT2
shrinkBtn.TextSize = 14
shrinkBtn.Font = Enum.Font.GothamBold
shrinkBtn.BorderSizePixel = 0
shrinkBtn.AutoButtonColor = false
shrinkBtn.ZIndex = 55
shrinkBtn.Parent = topBar

local shrinkCorner = Instance.new("UICorner")
shrinkCorner.CornerRadius = UDim.new(0, 10)
shrinkCorner.Parent = shrinkBtn

shrinkBtn.MouseEnter:Connect(function()
    TweenService:Create(shrinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(254, 202, 202)}):Play()
    shrinkBtn.TextColor3 = Color3.fromRGB(220, 38, 38)
end)
shrinkBtn.MouseLeave:Connect(function()
    TweenService:Create(shrinkBtn, TweenInfo.new(0.15), {BackgroundColor3 = C_SURFACE2}):Play()
    shrinkBtn.TextColor3 = C_TEXT2
end)

topBar.Parent = inner

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
body.Position = UDim2.new(0, 0, 0, TOPBAR_H)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.ZIndex = 51
body.Parent = inner

-- 导航栏
local NAV_RATIO = 0.24
local GAP = 0.015
local nav = Instance.new("ScrollingFrame")
nav.Name = "Nav"
nav.Size = UDim2.new(NAV_RATIO, 0, 1, -BOTTOM_SAFE)
nav.BackgroundTransparency = 1
nav.BorderSizePixel = 0
nav.ScrollBarThickness = 0
nav.CanvasSize = UDim2.new(0, 0, 0, 0)
nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
nav.ZIndex = 52
nav.Parent = body

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 6)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = nav

local navPadding = Instance.new("UIPadding")
navPadding.PaddingLeft = UDim.new(0, 10)
navPadding.PaddingRight = UDim.new(0, 6)
navPadding.PaddingTop = UDim.new(0, 12)
navPadding.PaddingBottom = UDim.new(0, 10)
navPadding.Parent = nav

local navItems = {
    {name = "公告", icon = "📢", accent = C_ACCENT2},
    {name = "绘制", icon = "🎨", accent = C_ACCENT},
    {name = "自瞄", icon = "🎯", accent = C_ACCENT3},
    {name = "子追", icon = "🔫", accent = C_ORANGE},
    {name = "功能", icon = "⚡", accent = C_GREEN},
}

local navBtns = {}
local pages = {}
local selectedIdx = 1

for i, item in ipairs(navItems) do
    local btn = Instance.new("TextButton")
    btn.Name = item.name
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundColor3 = (i == 1) and C_SURFACE or C_SURFACE2
    btn.BackgroundTransparency = (i == 1) and 0 or 0.6
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.ZIndex = 53
    btn.Parent = nav

    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(0, 12)
    btnC.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = item.accent
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 54
    indicator.Visible = (i == 1)
    local indC = Instance.new("UICorner")
    indC.CornerRadius = UDim.new(0, 2)
    indC.Parent = indicator
    indicator.Parent = btn

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 0, 28)
    iconLbl.Position = UDim2.new(0, 10, 0.5, -14)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = item.icon
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.ZIndex = 54
    iconLbl.Parent = btn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -44, 1, 0)
    nameLbl.Position = UDim2.new(0, 40, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = item.name
    nameLbl.TextColor3 = (i == 1) and C_TEXT or C_TEXT2
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 54
    nameLbl.Parent = btn

    btn.Indicator = indicator
    btn.NameLabel = nameLbl
    btn.Accent = item.accent
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

-- ========== 高级控件 ==========
local function createToggle(parent, labelText, accentColor, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C_SURFACE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C_BORDER
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.6
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 48, 0, 26)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBg.BackgroundColor3 = C_SURFACE2
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
    toggleKnob.BackgroundColor3 = C_SURFACE
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 57
    toggleKnob.Parent = toggleBg

    local toggleKnobC = Instance.new("UICorner")
    toggleKnobC.CornerRadius = UDim.new(1, 0)
    toggleKnobC.Parent = toggleKnob

    local knobShadow = Instance.new("UIStroke")
    knobShadow.Color = C_BORDER
    knobShadow.Thickness = 1
    knobShadow.Transparency = 0.5
    knobShadow.Parent = toggleKnob

    local enabled = false

    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 24, 0.5, -11)}):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C_SURFACE2}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
        end
        if onToggle then onToggle(enabled) end
    end)

    return row
end

local function createSlider(parent, labelText, accentColor, minVal, maxVal, defaultVal, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 64)
    row.BackgroundColor3 = C_SURFACE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C_BORDER
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.6
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 24)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 24)
    valLbl.Position = UDim2.new(1, -60, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = accentColor
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 56
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 5)
    track.Position = UDim2.new(0, 14, 0, 40)
    track.BackgroundColor3 = C_SURFACE2
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
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -9, 0.5, -9)
    knob.BackgroundColor3 = C_SURFACE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 58
    knob.Parent = track

    local knobC = Instance.new("UICorner")
    knobC.CornerRadius = UDim.new(1, 0)
    knobC.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = accentColor
    knobStroke.Thickness = 2.5
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
        knob.Position = UDim2.new(rel, -9, 0.5, -9)
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
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C_SURFACE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C_BORDER
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.6
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -130, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 110, 0, 32)
    selBtn.Position = UDim2.new(1, -122, 0.5, -16)
    selBtn.BackgroundColor3 = C_SURFACE2
    selBtn.Text = options[defaultIdx] or options[1]
    selBtn.TextColor3 = C_TEXT
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamBold
    selBtn.BorderSizePixel = 0
    selBtn.AutoButtonColor = false
    selBtn.ZIndex = 56
    selBtn.Parent = row

    local selC = Instance.new("UICorner")
    selC.CornerRadius = UDim.new(0, 10)
    selC.Parent = selBtn

    local selStroke = Instance.new("UIStroke")
    selStroke.Color = C_BORDER
    selStroke.Thickness = 1
    selStroke.Parent = selBtn

    local dropdownOpen = false
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 110, 0, 0)
    dropdownFrame.Position = UDim2.new(1, -122, 0, 42)
    dropdownFrame.BackgroundColor3 = C_SURFACE
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 60
    dropdownFrame.Visible = false
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = row

    local dropdownC = Instance.new("UICorner")
    dropdownC.CornerRadius = UDim.new(0, 12)
    dropdownC.Parent = dropdownFrame

    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = C_BORDER
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
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = C_SURFACE2
        optBtn.Text = opt
        optBtn.TextColor3 = C_TEXT
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.LayoutOrder = i
        optBtn.ZIndex = 61
        optBtn.Parent = dropdownFrame

        local optC = Instance.new("UICorner")
        optC.CornerRadius = UDim.new(0, 8)
        optC.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = accentColor
            optBtn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = C_SURFACE2
            optBtn.TextColor3 = C_TEXT
        end)

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
            dropdownFrame.Size = UDim2.new(0, 110, 0, #options * 32 + 6)
        end
    end)

    return row
end

local function createFeaturePage(name, title, desc, accent)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = accent
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.Visible = false
    page.ZIndex = 53
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 28, 0, 3)
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
    t.TextSize = 18
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 2
    t.ZIndex = 54
    t.Parent = page

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 16)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = C_TEXT2
    d.TextSize = 11
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
    container.Parent = page

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 8)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    local function updateCanvas()
        container.Size = UDim2.new(1, 0, 0, containerLayout.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.delay(0.1, updateCanvas)

    return page
end

-- ========== 高级公告页 ==========
local function createNoticePage()
    local page = Instance.new("ScrollingFrame")
    page.Name = "公告"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C_ACCENT2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Visible = false
    page.ZIndex = 53
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page

    -- 顶部横幅
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 0, 110)
    banner.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 1
    banner.ZIndex = 54
    banner.Parent = page

    local bannerC = Instance.new("UICorner")
    bannerC.CornerRadius = UDim.new(0, 16)
    bannerC.Parent = banner

    local bannerGrad = Instance.new("UIGradient")
    bannerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(30, 41, 59)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 130, 246)),
    })
    bannerGrad.Rotation = 45
    bannerGrad.Parent = banner

    local bannerTitle = Instance.new("TextLabel")
    bannerTitle.Size = UDim2.new(1, -20, 0, 32)
    bannerTitle.Position = UDim2.new(0, 14, 0, 14)
    bannerTitle.BackgroundTransparency = 1
    bannerTitle.Text = "Ly枪战辅助"
    bannerTitle.TextColor3 = Color3.fromRGB(255,255,255)
    bannerTitle.TextSize = 22
    bannerTitle.Font = Enum.Font.GothamBold
    bannerTitle.TextXAlignment = Enum.TextXAlignment.Left
    bannerTitle.ZIndex = 55
    bannerTitle.Parent = banner

    local bannerVer = Instance.new("TextLabel")
    bannerVer.Size = UDim2.new(0, 60, 0, 20)
    bannerVer.Position = UDim2.new(0, 14, 0, 46)
    bannerVer.BackgroundColor3 = C_ACCENT
    bannerVer.BackgroundTransparency = 0.2
    bannerVer.Text = "v2.6"
    bannerVer.TextColor3 = Color3.fromRGB(255,255,255)
    bannerVer.TextSize = 11
    bannerVer.Font = Enum.Font.GothamBold
    bannerVer.ZIndex = 55
    local bvC = Instance.new("UICorner")
    bvC.CornerRadius = UDim.new(0, 6)
    bvC.Parent = bannerVer
    bannerVer.Parent = banner

    local bannerSub = Instance.new("TextLabel")
    bannerSub.Size = UDim2.new(1, -20, 0, 20)
    bannerSub.Position = UDim2.new(0, 14, 0, 74)
    bannerSub.BackgroundTransparency = 1
    bannerSub.Text = "稳定运行 · 持续更新 · 公益免费"
    bannerSub.TextColor3 = Color3.fromRGB(148, 163, 184)
    bannerSub.TextSize = 11
    bannerSub.Font = Enum.Font.Gotham
    bannerSub.TextXAlignment = Enum.TextXAlignment.Left
    bannerSub.ZIndex = 55
    bannerSub.Parent = banner

    -- 功能特性卡片
    local featureCard = Instance.new("Frame")
    featureCard.Size = UDim2.new(1, 0, 0, 140)
    featureCard.BackgroundColor3 = C_SURFACE
    featureCard.BorderSizePixel = 0
    featureCard.LayoutOrder = 2
    featureCard.ZIndex = 54
    featureCard.Parent = page

    local fcC = Instance.new("UICorner")
    fcC.CornerRadius = UDim.new(0, 14)
    fcC.Parent = featureCard

    local fcStroke = Instance.new("UIStroke")
    fcStroke.Color = C_BORDER
    fcStroke.Thickness = 1
    fcStroke.Transparency = 0.5
    fcStroke.Parent = featureCard

    local fcTitle = Instance.new("TextLabel")
    fcTitle.Size = UDim2.new(1, -16, 0, 22)
    fcTitle.Position = UDim2.new(0, 12, 0, 10)
    fcTitle.BackgroundTransparency = 1
    fcTitle.Text = "核心功能"
    fcTitle.TextColor3 = C_TEXT
    fcTitle.TextSize = 13
    fcTitle.Font = Enum.Font.GothamBold
    fcTitle.TextXAlignment = Enum.TextXAlignment.Left
    fcTitle.ZIndex = 55
    fcTitle.Parent = featureCard

    local features = {
        {icon = "🎯", name = "智能自瞄", desc = "平滑锁定"},
        {icon = "👁️", name = "高级绘制", desc = "方框血量"},
        {icon = "🔫", name = "子弹追踪", desc = "预判射线"},
        {icon = "⚡", name = "杀戮光环", desc = "自动索敌"},
    }

    for i, feat in ipairs(features) do
        local fx = Instance.new("Frame")
        fx.Size = UDim2.new(0.48, -4, 0, 44)
        fx.Position = UDim2.new((i-1)%2 * 0.52, 0, 0, 40 + math.floor((i-1)/2) * 50)
        fx.BackgroundColor3 = C_SURFACE2
        fx.BorderSizePixel = 0
        fx.ZIndex = 55
        fx.Parent = featureCard

        local fxC = Instance.new("UICorner")
        fxC.CornerRadius = UDim.new(0, 10)
        fxC.Parent = fx

        local fxIcon = Instance.new("TextLabel")
        fxIcon.Size = UDim2.new(0, 28, 0, 28)
        fxIcon.Position = UDim2.new(0, 8, 0.5, -14)
        fxIcon.BackgroundTransparency = 1
        fxIcon.Text = feat.icon
        fxIcon.TextSize = 16
        fxIcon.ZIndex = 56
        fxIcon.Parent = fx

        local fxName = Instance.new("TextLabel")
        fxName.Size = UDim2.new(1, -40, 0, 16)
        fxName.Position = UDim2.new(0, 38, 0, 6)
        fxName.BackgroundTransparency = 1
        fxName.Text = feat.name
        fxName.TextColor3 = C_TEXT
        fxName.TextSize = 11
        fxName.Font = Enum.Font.GothamBold
        fxName.TextXAlignment = Enum.TextXAlignment.Left
        fxName.ZIndex = 56
        fxName.Parent = fx

        local fxDesc = Instance.new("TextLabel")
        fxDesc.Size = UDim2.new(1, -40, 0, 14)
        fxDesc.Position = UDim2.new(0, 38, 0, 22)
        fxDesc.BackgroundTransparency = 1
        fxDesc.Text = feat.desc
        fxDesc.TextColor3 = C_TEXT3
        fxDesc.TextSize = 10
        fxDesc.Font = Enum.Font.Gotham
        fxDesc.TextXAlignment = Enum.TextXAlignment.Left
        fxDesc.ZIndex = 56
        fxDesc.Parent = fx
    end

    -- 更新日志时间线
    local logCard = Instance.new("Frame")
    logCard.Size = UDim2.new(1, 0, 0, 180)
    logCard.BackgroundColor3 = C_SURFACE
    logCard.BorderSizePixel = 0
    logCard.LayoutOrder = 3
    logCard.ZIndex = 54
    logCard.Parent = page

    local lcC = Instance.new("UICorner")
    lcC.CornerRadius = UDim.new(0, 14)
    lcC.Parent = logCard

    local lcStroke = Instance.new("UIStroke")
    lcStroke.Color = C_BORDER
    lcStroke.Thickness = 1
    lcStroke.Transparency = 0.5
    lcStroke.Parent = logCard

    local lcTitle = Instance.new("TextLabel")
    lcTitle.Size = UDim2.new(1, -16, 0, 22)
    lcTitle.Position = UDim2.new(0, 12, 0, 10)
    lcTitle.BackgroundTransparency = 1
    lcTitle.Text = "更新日志"
    lcTitle.TextColor3 = C_TEXT
    lcTitle.TextSize = 13
    lcTitle.Font = Enum.Font.GothamBold
    lcTitle.TextXAlignment = Enum.TextXAlignment.Left
    lcTitle.ZIndex = 55
    lcTitle.Parent = logCard

    local logs = {
        {date = "2025.07.19", ver = "v2.6", text = "UI全面重构，新增漏打检测变色"},
        {date = "2025.07.16", ver = "v2.4", text = "修复ESP重生后绘制中断问题"},
        {date = "2025.07.14", ver = "v2.3", text = "新增雷达系统，支持自定义位置"},
    }

    for i, log in ipairs(logs) do
        local ly = 38 + (i-1) * 44

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 7, 0, 7)
        dot.Position = UDim2.new(0, 14, 0, ly + 6)
        dot.BackgroundColor3 = C_ACCENT
        dot.BorderSizePixel = 0
        dot.ZIndex = 55
        local dotC = Instance.new("UICorner")
        dotC.CornerRadius = UDim.new(1, 0)
        dotC.Parent = dot
        dot.Parent = logCard

        if i < #logs then
            local line2 = Instance.new("Frame")
            line2.Size = UDim2.new(0, 2, 0, 30)
            line2.Position = UDim2.new(0, 16, 0, ly + 14)
            line2.BackgroundColor3 = C_BORDER
            line2.BorderSizePixel = 0
            line2.ZIndex = 55
            line2.Parent = logCard
        end

        local logVer = Instance.new("TextLabel")
        logVer.Size = UDim2.new(0, 40, 0, 16)
        logVer.Position = UDim2.new(0, 28, 0, ly)
        logVer.BackgroundTransparency = 1
        logVer.Text = log.ver
        logVer.TextColor3 = C_ACCENT
        logVer.TextSize = 10
        logVer.Font = Enum.Font.GothamBold
        logVer.TextXAlignment = Enum.TextXAlignment.Left
        logVer.ZIndex = 55
        logVer.Parent = logCard

        local logDate = Instance.new("TextLabel")
        logDate.Size = UDim2.new(0, 80, 0, 16)
        logDate.Position = UDim2.new(0, 70, 0, ly)
        logDate.BackgroundTransparency = 1
        logDate.Text = log.date
        logDate.TextColor3 = C_TEXT3
        logDate.TextSize = 10
        logDate.Font = Enum.Font.Gotham
        logDate.TextXAlignment = Enum.TextXAlignment.Left
        logDate.ZIndex = 55
        logDate.Parent = logCard

        local logText = Instance.new("TextLabel")
        logText.Size = UDim2.new(1, -40, 0, 18)
        logText.Position = UDim2.new(0, 28, 0, ly + 16)
        logText.BackgroundTransparency = 1
        logText.Text = log.text
        logText.TextColor3 = C_TEXT2
        logText.TextSize = 11
        logText.Font = Enum.Font.Gotham
        logText.TextXAlignment = Enum.TextXAlignment.Left
        logText.ZIndex = 55
        logText.Parent = logCard
    end

    -- 底部信息
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 60)
    infoCard.BackgroundColor3 = C_SURFACE
    infoCard.BorderSizePixel = 0
    infoCard.LayoutOrder = 4
    infoCard.ZIndex = 54
    infoCard.Parent = page

    local icC = Instance.new("UICorner")
    icC.CornerRadius = UDim.new(0, 14)
    icC.Parent = infoCard

    local icStroke = Instance.new("UIStroke")
    icStroke.Color = C_BORDER
    icStroke.Thickness = 1
    icStroke.Transparency = 0.5
    icStroke.Parent = infoCard

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 1, -12)
    infoText.Position = UDim2.new(0, 10, 0, 6)
    infoText.BackgroundTransparency = 1
    infoText.Text = "脚本由林玉独立开发维护\n如遇问题请反馈，会持续优化"
    infoText.TextColor3 = C_TEXT2
    infoText.TextSize = 11
    infoText.Font = Enum.Font.Gotham
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.ZIndex = 55
    infoText.Parent = infoCard

    local function updateCanvas()
        local totalH = layout.AbsoluteContentSize.Y + 16
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(totalH, 1))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        task.defer(updateCanvas)
    end)
    task.defer(updateCanvas)

    return page
end

pages[1] = createNoticePage()
pages[1].Visible = true

local function switchPage(idx)
    if selectedIdx == idx then return end

    local oldBtn = navBtns[selectedIdx]
    if oldBtn then
        TweenService:Create(oldBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_SURFACE2, BackgroundTransparency = 0.6}):Play()
        oldBtn.NameLabel.TextColor3 = C_TEXT2
        oldBtn.Indicator.Visible = false
    end

    local newBtn = navBtns[idx]
    if newBtn then
        TweenService:Create(newBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_SURFACE, BackgroundTransparency = 0}):Play()
        newBtn.NameLabel.TextColor3 = C_TEXT
        newBtn.Indicator.Visible = true
    end

    if pages[selectedIdx] then pages[selectedIdx].Visible = false end
    if pages[idx] then
        pages[idx].Visible = true
        pages[idx].Position = UDim2.new(0.04, 0, 0, 0)
        TweenService:Create(pages[idx], TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
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

-- ========== 面板动画 ==========
local isOpen = false

local function openPanel()
    isOpen = true
    orb.Visible = false
    panel.Visible = true

    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(PANEL_W, 0, PANEL_H, 0),
        Position = UDim2.new(PANEL_X + PANEL_W/2, 0, PANEL_Y + PANEL_H/2, 0),
    }):Play()

    task.delay(0.5, function()
        if panel.Visible then
            panel.AnchorPoint = Vector2.new(0, 0)
            panel.Position = UDim2.new(PANEL_X, 0, PANEL_Y, 0)
        end
    end)
end

local function closePanel()
    isOpen = false

    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(PANEL_X + PANEL_W/2, 0, PANEL_Y + PANEL_H/2, 0)

    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }):Play()

    task.wait(0.35)
    panel.Visible = false
    panel.AnchorPoint = Vector2.new(0, 0)
    orb.Visible = true
end

shrinkBtn.MouseButton1Click:Connect(closePanel)

-- ========== 悬浮球拖拽 ==========
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
    TweenService:Create(orb, TweenInfo.new(0.1), {Size = UDim2.new(0, 54, 0, 54)}):Play()
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
    local orbW = 54
    local orbH = 54
    local newX = math.clamp(pos.X - dragOffset.X, 0, screenW - orbW)
    local newY = math.clamp(pos.Y - dragOffset.Y, 0, screenH - orbH)
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
        local orbW = 54
        local targetX = (orbX + orbW/2 < screenW / 2) and 14 or (screenW - orbW - 14)
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

-- ========== 工具函数 ==========
local function IsVisible(targetPart)
    if not targetPart then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
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

local function CreateESP2ScreenGui()
    if ESP2.ScreenGui then return end
    ESP2.ScreenGui = ESP2_Create("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        Name = "ESP2Holder",
        Enabled = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
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

-- ========== 核心修复：漏打检测逻辑 ==========
-- 可见(不漏) = 白色(初始色) | 被墙挡住(漏了) = 蓝色
local function UpdateESP2()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local lp = player
    local maxDist = ESP2_Settings.MaxDistance

    for plr, elements in pairs(ESP2.PlayerElements) do
        local success = pcall(function()
            local shouldHide = true
            if plr and plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")

                if hrp and hum and hum.Health > 0 then
                    local sameTeam = (ESP2_Settings.TeamCheck and lp.Team == plr.Team and lp.Team ~= nil)
                    if not sameTeam then
                        local pos, onScreen = camera:WorldToScreenPoint(hrp.Position)
                        local dist = (camera.CFrame.Position - hrp.Position).Magnitude

                        if onScreen and dist <= maxDist then
                            shouldHide = false

                            -- 漏打检测：被墙挡住=漏了=蓝色，没挡=白色
                            local isVisible = true
                            if ESP2_Settings.VisCheck and head then
                                isVisible = IsVisible(head)
                            end

                            -- 漏打检测：视野内可见=蓝色，视野内不可见=白色
                            local displayBoxColor = isVisible and Color3.fromRGB(0, 120, 255) or ESP2_Settings.BoxColor
                            local displayNameColor = isVisible and Color3.fromRGB(0, 120, 255) or ESP2_Settings.NameColor

                            local size = hrp.Size.Y
                            local scaleFactor = (size * camera.ViewportSize.Y) / (pos.Z * 2)
                            local w = 3 * scaleFactor
                            local h = 4.5 * scaleFactor
                            local fadeTrans = math.clamp(dist / maxDist, 0, 0.85)

                            if ESP2_Settings.ShowBox then
                                elements.Box.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                                elements.Box.Size = UDim2.new(0, w, 0, h)
                                elements.Box.Visible = true
                                elements.Box.BackgroundTransparency = 0.75 + fadeTrans * 0.15
                                elements.Box.BorderSizePixel = 1
                                elements.Box.BackgroundColor3 = displayBoxColor
                                elements.Outline.Enabled = true
                                elements.Outline.Transparency = fadeTrans
                                elements.Outline.Color = displayBoxColor
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
                                elements.Name.TextColor3 = displayNameColor
                                elements.Name.TextTransparency = fadeTrans
                                elements.Name.TextStrokeTransparency = fadeTrans
                                elements.Name.Visible = true
                            else
                                elements.Name.Visible = false
                            end

                            if ESP2_Settings.ShowHealth then
                                local healthRatio = hum.Health / hum.MaxHealth
                                healthRatio = math.clamp(healthRatio, 0, 1)
                                elements.Healthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - healthRatio))
                                elements.Healthbar.Size = UDim2.new(0, 2.5, 0, h * healthRatio)
                                elements.Healthbar.BackgroundColor3 = ESP2_Settings.HealthBarColor
                                elements.Healthbar.BackgroundTransparency = fadeTrans
                                elements.Healthbar.Visible = true

                                elements.BehindHealthbar.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2)
                                elements.BehindHealthbar.Size = UDim2.new(0, 2.5, 0, h)
                                elements.BehindHealthbar.BackgroundTransparency = fadeTrans
                                elements.BehindHealthbar.Visible = true

                                local healthPercent = math.floor(healthRatio * 100)
                                elements.HealthText.Position = UDim2.new(0, pos.X - w/2 - 6, 0, pos.Y - h/2 + h * (1 - healthPercent/100) + 3)
                                elements.HealthText.Text = tostring(healthPercent) .. "%"
                                elements.HealthText.TextTransparency = fadeTrans
                                elements.HealthText.TextStrokeTransparency = fadeTrans
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
        end)
    end

    for plr, _ in pairs(ESP2.PlayerElements) do
        if not game.Players:FindFirstChild(plr.Name) then
            DestroyESP2ForPlayer(plr)
        end
    end
end

-- ========== 雷达系统 ==========
local RadarElements = {
    Background = Drawing.new("Square"),
    BackgroundCircle = Drawing.new("Circle"),
    CenterDot = Drawing.new("Circle"),
    PlayerDots = {},
}

RadarElements.Background.Visible = false
RadarElements.Background.Color = Color3.fromRGB(30, 30, 30)
RadarElements.Background.Thickness = 1
RadarElements.Background.Transparency = 0.7
RadarElements.Background.Filled = true

RadarElements.BackgroundCircle.Visible = false
RadarElements.BackgroundCircle.Color = Color3.fromRGB(30, 30, 30)
RadarElements.BackgroundCircle.Thickness = 1
RadarElements.BackgroundCircle.Transparency = 0.7
RadarElements.BackgroundCircle.Filled = true
RadarElements.BackgroundCircle.NumSides = 64

RadarElements.CenterDot.Visible = false
RadarElements.CenterDot.Color = Color3.fromRGB(255, 255, 255)
RadarElements.CenterDot.Thickness = 1
RadarElements.CenterDot.Transparency = 1
RadarElements.CenterDot.Filled = true
RadarElements.CenterDot.NumSides = 16

local function getOrCreateRadarDot(plr)
    if not RadarElements.PlayerDots[plr] then
        local dot = Drawing.new("Circle")
        dot.Visible = false
        dot.Thickness = 1
        dot.Transparency = 1
        dot.Filled = true
        dot.NumSides = 12
        dot.Radius = 3
        RadarElements.PlayerDots[plr] = dot
    end
    return RadarElements.PlayerDots[plr]
end

local function destroyRadarDot(plr)
    local dot = RadarElements.PlayerDots[plr]
    if dot then
        pcall(function() dot:Destroy() end)
        RadarElements.PlayerDots[plr] = nil
    end
end

local function updateRadar()
    if not ESP2_Settings.ShowRadar then
        RadarElements.Background.Visible = false
        RadarElements.BackgroundCircle.Visible = false
        RadarElements.CenterDot.Visible = false
        for _, dot in pairs(RadarElements.PlayerDots) do
            dot.Visible = false
        end
        return
    end

    local myChar = player.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local radarSize = ESP2_Settings.RadarSize
    local radarRange = ESP2_Settings.RadarRange
    local posX = ESP2_Settings.RadarPosX
    local posY = ESP2_Settings.RadarPosY
    local centerX = posX + radarSize / 2
    local centerY = posY + radarSize / 2
    local isCircle = ESP2_Settings.RadarShape == "圆形"

    if isCircle then
        RadarElements.Background.Visible = false
        RadarElements.BackgroundCircle.Visible = true
        RadarElements.BackgroundCircle.Position = Vector2.new(centerX, centerY)
        RadarElements.BackgroundCircle.Radius = radarSize / 2
        RadarElements.BackgroundCircle.Color = Color3.fromRGB(30, 30, 30)
        RadarElements.BackgroundCircle.Transparency = 0.7
    else
        RadarElements.BackgroundCircle.Visible = false
        RadarElements.Background.Visible = true
        RadarElements.Background.Size = Vector2.new(radarSize, radarSize)
        RadarElements.Background.Position = Vector2.new(posX, posY)
        RadarElements.Background.Color = Color3.fromRGB(30, 30, 30)
        RadarElements.Background.Transparency = 0.7
    end

    RadarElements.CenterDot.Visible = true
    RadarElements.CenterDot.Position = Vector2.new(centerX, centerY)
    RadarElements.CenterDot.Radius = 3
    RadarElements.CenterDot.Color = Color3.fromRGB(255, 255, 255)

    local myPos = myHrp.Position
    local myLook = myHrp.CFrame.LookVector
    local myRight = myHrp.CFrame.RightVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")

            if hrp and humanoid and humanoid.Health > 0 then
                local dot = getOrCreateRadarDot(plr)
                local relPos = hrp.Position - myPos
                local forwardDist = myLook.X * relPos.X + myLook.Z * relPos.Z
                local rightDist = myRight.X * relPos.X + myRight.Z * relPos.Z
                local scale = (radarSize / 2) / radarRange
                local dotX = centerX + rightDist * scale
                local dotY = centerY - forwardDist * scale
                local dx = dotX - centerX
                local dy = dotY - centerY
                local distFromCenter = math.sqrt(dx * dx + dy * dy)

                if distFromCenter <= radarSize / 2 then
                    dot.Visible = true
                    dot.Position = Vector2.new(dotX, dotY)
                    dot.Radius = 3
                    if head and IsVisible(head) then
                        dot.Color = ColorMap[ESP2_Settings.RadarVisibleColor] or Color3.fromRGB(0, 255, 0)
                    else
                        dot.Color = ColorMap[ESP2_Settings.RadarHiddenColor] or Color3.fromRGB(255, 0, 0)
                    end
                else
                    dot.Visible = false
                end
            else
                local dot = RadarElements.PlayerDots[plr]
                if dot then dot.Visible = false end
            end
        else
            local dot = RadarElements.PlayerDots[plr]
            if dot then dot.Visible = false end
        end
    end

    for plr, _ in pairs(RadarElements.PlayerDots) do
        if not Players:FindFirstChild(plr.Name) then
            destroyRadarDot(plr)
        end
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
        updateRadar()
    end)
end

local function InitESP2Events()
    game.Players.PlayerAdded:Connect(function(plr)
        if plr == player then return end
        CreateESP2ForPlayer(plr)
        plr.CharacterAdded:Connect(function()
            task.wait(0.1)
            if not ESP2.PlayerElements[plr] then
                CreateESP2ForPlayer(plr)
            end
        end)
    end)
    game.Players.PlayerRemoving:Connect(function(plr)
        DestroyESP2ForPlayer(plr)
    end)
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            CreateESP2ForPlayer(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.1)
                if not ESP2.PlayerElements[plr] then
                    CreateESP2ForPlayer(plr)
                end
            end)
        end
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

-- ========== 自瞄 ==========
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

-- ========== 子弹追踪 ==========
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
                if BulletConfig.Prediction then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        targetPos = head.Position + hrp.Velocity * BulletConfig.PredictionFactor
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
pcall(function()
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

local BulletTargetText = Drawing.new("Text")
BulletTargetText.Visible = false
BulletTargetText.Size = 13
BulletTargetText.Color = Color3.fromRGB(255, 255, 255)
BulletTargetText.Outline = true
BulletTargetText.OutlineColor = Color3.fromRGB(0, 0, 0)
BulletTargetText.Center = false
BulletTargetText.Font = Drawing.Fonts.UI

RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    BulletFOV_Circle.Visible = BulletConfig.Enabled
    BulletFOV_Circle.Radius = BulletConfig.FOV
    BulletFOV_Circle.Position = screenCenter

    if BulletConfig.Enabled then
        local closestHead = getClosestHead()
        if closestHead and closestHead.Parent then
            local targetPlayer = Players:GetPlayerFromCharacter(closestHead.Parent)
            if targetPlayer then
                BulletTargetText.Text = "追踪: " .. targetPlayer.Name
                BulletTargetText.Visible = true
                BulletTargetText.Position = Vector2.new(
                    Camera.ViewportSize.X / 2 + BulletConfig.FOV + 10,
                    Camera.ViewportSize.Y / 2 - 6
                )
            else
                BulletTargetText.Visible = false
            end
        else
            BulletTargetText.Visible = false
        end
    else
        BulletTargetText.Visible = false
    end
end)

-- ========== UI页面绑定 ==========
pages[2] = createFeaturePage("绘制", "绘制", "ESP 高级绘制设置", C_ACCENT)

createToggle(pages[2].Container, "ESP 总开关", C_ACCENT, function(v)
    SetESP2Enabled(v)
end).LayoutOrder = 1

createToggle(pages[2].Container, "显示方框", C_ACCENT, function(v)
    ESP2_Settings.ShowBox = v
end).LayoutOrder = 2

createToggle(pages[2].Container, "显示名字", C_ACCENT, function(v)
    ESP2_Settings.ShowName = v
end).LayoutOrder = 3

createToggle(pages[2].Container, "显示距离", C_ACCENT, function(v)
    ESP2_Settings.ShowDistance = v
end).LayoutOrder = 4

createToggle(pages[2].Container, "显示血量", C_ACCENT, function(v)
    ESP2_Settings.ShowHealth = v
end).LayoutOrder = 5

createToggle(pages[2].Container, "上色透视", C_ACCENT, function(v)
    ESP2_Settings.ShowChams = v
end).LayoutOrder = 6

createToggle(pages[2].Container, "漏打检测", C_ACCENT, function(v)
    ESP2_Settings.VisCheck = v
end).LayoutOrder = 7

createToggle(pages[2].Container, "队伍检测", C_ACCENT, function(v)
    ESP2_Settings.TeamCheck = v
end).LayoutOrder = 8

createSlider(pages[2].Container, "最大绘制距离", C_ACCENT, 50, 5000, 5000, function(v)
    ESP2_Settings.MaxDistance = v
end).LayoutOrder = 9

createToggle(pages[2].Container, "显示雷达", C_ACCENT, function(v)
    ESP2_Settings.ShowRadar = v
end).LayoutOrder = 10

createDropdown(pages[2].Container, "雷达形状", C_ACCENT, {"圆形", "方形"}, 1, function(v)
    ESP2_Settings.RadarShape = v
end).LayoutOrder = 11

createSlider(pages[2].Container, "雷达大小", C_ACCENT, 60, 200, 120, function(v)
    ESP2_Settings.RadarSize = v
end).LayoutOrder = 12

createSlider(pages[2].Container, "雷达范围", C_ACCENT, 50, 500, 200, function(v)
    ESP2_Settings.RadarRange = v
end).LayoutOrder = 13

createSlider(pages[2].Container, "雷达X位置", C_ACCENT, 50, 800, 150, function(v)
    ESP2_Settings.RadarPosX = v
end).LayoutOrder = 14

createSlider(pages[2].Container, "雷达Y位置", C_ACCENT, 50, 600, 150, function(v)
    ESP2_Settings.RadarPosY = v
end).LayoutOrder = 15

createDropdown(pages[2].Container, "可见颜色", C_ACCENT, {"绿色", "红色", "蓝色", "黄色", "青色", "紫色", "橙色", "白色", "粉色"}, 1, function(v)
    ESP2_Settings.RadarVisibleColor = v
end).LayoutOrder = 16

createDropdown(pages[2].Container, "不可见颜色", C_ACCENT, {"红色", "绿色", "蓝色", "黄色", "青色", "紫色", "橙色", "白色", "粉色"}, 1, function(v)
    ESP2_Settings.RadarHiddenColor = v
end).LayoutOrder = 17

pages[3] = createFeaturePage("自瞄", "自瞄", "自瞄功能详细设置", C_ACCENT3)

createToggle(pages[3].Container, "启用自瞄", C_ACCENT3, function(v)
    AimConfig.Enabled = v
    FOV_Circle.Visible = v
end).LayoutOrder = 1

createToggle(pages[3].Container, "漏打检测", C_ACCENT3, function(v)
    AimConfig.VisCheck = v
end).LayoutOrder = 2

createToggle(pages[3].Container, "队伍检测", C_ACCENT3, function(v)
    AimConfig.TeamCheck = v
end).LayoutOrder = 3

createSlider(pages[3].Container, "自瞄范围", C_ACCENT3, 50, 400, 150, function(v)
    AimConfig.FOV = v
end).LayoutOrder = 4

createSlider(pages[3].Container, "自瞄距离", C_ACCENT3, 100, 2000, 500, function(v)
    AimConfig.Distance = v
end).LayoutOrder = 5

createSlider(pages[3].Container, "自瞄速度", C_ACCENT3, 1, 30, 5, function(v)
    AimConfig.Speed = v
end).LayoutOrder = 6

createSlider(pages[3].Container, "平滑度", C_ACCENT3, 1, 20, 5, function(v)
    AimConfig.Smoothness = v
end).LayoutOrder = 7

createDropdown(pages[3].Container, "优先条件", C_ACCENT3, {"FOV距离", "世界距离", "综合评分", "血量优先"}, 1, function(v)
    AimConfig.Priority = v
end).LayoutOrder = 8

createDropdown(pages[3].Container, "瞄准部位", C_ACCENT3, {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, 1, function(v)
    AimConfig.TargetPart = v
end).LayoutOrder = 9

pages[4] = createFeaturePage("子追", "子弹追踪", "子弹追踪功能设置", C_ORANGE)

createToggle(pages[4].Container, "启用子弹追踪", C_ORANGE, function(v)
    BulletConfig.Enabled = v
end).LayoutOrder = 1

createSlider(pages[4].Container, "追踪角度范围", C_ORANGE, 10, 180, 60, function(v)
    BulletConfig.FOV = v
end).LayoutOrder = 2

createDropdown(pages[4].Container, "优先条件", C_ORANGE, {"FOV优先", "距离优先", "综合评分"}, 1, function(v)
    BulletConfig.Priority = v
end).LayoutOrder = 3

createToggle(pages[4].Container, "启用预判", C_ORANGE, function(v)
    BulletConfig.Prediction = v
end).LayoutOrder = 4

createSlider(pages[4].Container, "预判系数", C_ORANGE, 5, 50, 15, function(v)
    BulletConfig.PredictionFactor = v / 100
end).LayoutOrder = 5

pages[5] = createFeaturePage("功能", "功能", "通用功能设置", C_GREEN)

createToggle(pages[5].Container, "自动开枪", C_GREEN, function(v)
    MiscConfig.AutoFire = v
end).LayoutOrder = 1

createSlider(pages[5].Container, "自动开枪范围", C_GREEN, 50, 500, 200, function(v)
    MiscConfig.AutoFireRange = v
end).LayoutOrder = 2

createSlider(pages[5].Container, "开枪间隔(秒)", C_GREEN, 1, 20, 10, function(v)
    MiscConfig.AutoFireDelay = v / 100
end).LayoutOrder = 3

createToggle(pages[5].Container, "修改射速", C_GREEN, function(v)
    MiscConfig.FireRate = v
end).LayoutOrder = 4

createSlider(pages[5].Container, "射速间隔(秒)", C_GREEN, 1, 20, 5, function(v)
    MiscConfig.FireRateValue = v / 100
end).LayoutOrder = 5

createToggle(pages[5].Container, "敌人传送面前", C_GREEN, function(v)
    MiscConfig.TeleportEnemies = v
end).LayoutOrder = 6

createSlider(pages[5].Container, "传送距离", C_GREEN, 1, 30, 5, function(v)
    MiscConfig.TeleportDistance = v
end).LayoutOrder = 7

createToggle(pages[5].Container, "杀戮光环", C_GREEN, function(v)
    MiscConfig.KillAura = v
end).LayoutOrder = 8

createSlider(pages[5].Container, "光环范围", C_GREEN, 1, 100, 50, function(v)
    MiscConfig.KillAuraRange = v
end).LayoutOrder = 9

createDropdown(pages[5].Container, "优先条件", C_GREEN, {"距离优先", "血量优先", "视角优先"}, 1, function(v)
    MiscConfig.KillAuraPriority = v
end).LayoutOrder = 10

createToggle(pages[5].Container, "持续锁定", C_GREEN, function(v)
    MiscConfig.KillAuraLock = v
end).LayoutOrder = 11

-- ========== 敌人传送面前 ==========
RunService.Heartbeat:Connect(function()
    if not MiscConfig.TeleportEnemies then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            pcall(function()
                local targetChar = plr.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        targetRoot.CFrame = root.CFrame * CFrame.new(0, 0, -MiscConfig.TeleportDistance)
                    end
                end
            end)
        end
    end
end)

-- ========== 自动开枪 ==========
local VirtualUser = game:GetService("VirtualUser")
local autoFireRunning = false

local function autoFireLoop()
    if autoFireRunning then return end
    autoFireRunning = true

    while MiscConfig.AutoFire do
        local shouldFire = false
        local cameraPos = Camera.CFrame.Position
        local cameraDir = Camera.CFrame.LookVector
        local range = MiscConfig.AutoFireRange

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local char = plr.Character
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if head and humanoid and humanoid.Health > 0 then
                    if not IsVisible(head) then continue end

                    local toTarget = head.Position - cameraPos
                    local dist = toTarget.Magnitude
                    if dist <= range then
                        local dir = toTarget.Unit
                        local angle = math.deg(math.acos(math.clamp(cameraDir:Dot(dir), -1, 1)))
                        if angle <= 15 then
                            shouldFire = true
                            break
                        end
                    end
                end
            end
        end

        if shouldFire then
            VirtualUser:Button1Down(Vector2.new(0, 0))
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end

        task.wait(MiscConfig.AutoFireDelay)
    end

    autoFireRunning = false
end

RunService.Heartbeat:Connect(function()
    if MiscConfig.AutoFire and not autoFireRunning then
        task.spawn(autoFireLoop)
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

player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setupFireRate(child)
        end
    end)

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

-- ========== 杀戮光环 ==========
local killAuraRunning = false
local lockedTarget = nil

local function killAuraLoop()
    if killAuraRunning then return end
    killAuraRunning = true
    lockedTarget = nil

    while MiscConfig.KillAura do
        local myChar = player.Character
        if not myChar then task.wait(0.1); continue end

        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then task.wait(0.1); continue end

        local myPos = myHrp.Position
        local range = MiscConfig.KillAuraRange
        local cameraPos = Camera.CFrame.Position
        local cameraDir = Camera.CFrame.LookVector
        local bestTarget = nil
        local bestScore = math.huge

        if MiscConfig.KillAuraLock and lockedTarget then
            local stillValid = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local char = plr.Character
                    local head = char:FindFirstChild("Head")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if head and humanoid and humanoid.Health > 0 then
                        if head == lockedTarget or (head.Position - lockedTarget.Position).Magnitude < 0.1 then
                            if (head.Position - myPos).Magnitude <= range and IsVisible(head) then
                                bestTarget = head
                                stillValid = true
                            end
                            break
                        end
                    end
                end
            end
            if not stillValid then lockedTarget = nil end
        end

        if not bestTarget then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local char = plr.Character
                    local head = char:FindFirstChild("Head")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")

                    if head and humanoid and humanoid.Health > 0 then
                        local dist = (head.Position - myPos).Magnitude
                        if dist <= range then
                            if IsVisible(head) then
                                local score
                                local priority = MiscConfig.KillAuraPriority

                                if priority == "距离优先" then
                                    score = dist
                                elseif priority == "血量优先" then
                                    score = humanoid.Health
                                elseif priority == "视角优先" then
                                    local toTarget = (head.Position - cameraPos).Unit
                                    local angle = math.deg(math.acos(math.clamp(cameraDir:Dot(toTarget), -1, 1)))
                                    score = angle
                                else
                                    score = dist
                                end

                                if score < bestScore then
                                    bestScore = score
                                    bestTarget = head
                                end
                            end
                        end
                    end
                end
            end
            if bestTarget and MiscConfig.KillAuraLock then
                lockedTarget = bestTarget
            end
        end

        if bestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
            VirtualUser:Button1Down(Vector2.new(0, 0))
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end

        task.wait(0.05)
    end

    killAuraRunning = false
    lockedTarget = nil
end

RunService.Heartbeat:Connect(function()
    if MiscConfig.KillAura and not killAuraRunning then
        task.spawn(killAuraLoop)
    end
end)

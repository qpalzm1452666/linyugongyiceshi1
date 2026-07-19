local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ============================================================
--  浅蓝浅粉拼凑配色 — 清新马卡龙主题
-- ============================================================
local C_SKY       = Color3.fromRGB(180, 230, 255)   -- 天空浅蓝
local C_SKY2      = Color3.fromRGB(140, 210, 245)   -- 中浅蓝
local C_SKY3      = Color3.fromRGB(100, 190, 235)   -- 深蓝强调
local C_PINK      = Color3.fromRGB(255, 200, 220)   -- 樱花浅粉
local C_PINK2     = Color3.fromRGB(255, 170, 200)   -- 中浅粉
local C_PINK3     = Color3.fromRGB(255, 140, 180)   -- 深粉强调
local C_BG        = Color3.fromRGB(245, 250, 255)   -- 极浅蓝白背景
local C_BG_PANEL  = Color3.fromRGB(255, 250, 252)   -- 极浅粉白面板
local C_CARD      = Color3.fromRGB(255, 255, 255)   -- 纯白卡片
local C_CARD_SKY  = Color3.fromRGB(235, 248, 255)   -- 浅蓝卡片
local C_CARD_PINK = Color3.fromRGB(255, 242, 248)   -- 浅粉卡片
local C_TEXT      = Color3.fromRGB(60, 65, 85)      -- 主文字
local C_TEXT2     = Color3.fromRGB(130, 135, 155)   -- 次要文字
local C_TEXT3     = Color3.fromRGB(160, 165, 185)   -- 辅助文字
local C_WHITE     = Color3.fromRGB(255, 255, 255)
local C_BLACK     = Color3.fromRGB(0, 0, 0)
local C_GRAY      = Color3.fromRGB(220, 225, 235)   -- 浅灰轨道
local C_GRAY2     = Color3.fromRGB(200, 205, 218)   -- 中浅灰
local C_GREEN     = Color3.fromRGB(120, 230, 160)
local C_RED       = Color3.fromRGB(255, 120, 140)
local C_INVIS     = Color3.fromRGB(255, 255, 255)   -- ESP初始色（白色）
local C_VISIBLE   = Color3.fromRGB(0, 150, 255)      -- ESP视野内蓝色

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
    BoxColor = C_INVIS,
    NameColor = C_WHITE,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    ChamsFillColor = Color3.fromRGB(119, 120, 255),
    ChamsOutlineColor = Color3.fromRGB(119, 120, 255),
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
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["绿色"] = Color3.fromRGB(0, 255, 0),
    ["蓝色"] = Color3.fromRGB(0, 120, 255),
    ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["紫色"] = Color3.fromRGB(180, 0, 255),
    ["橙色"] = Color3.fromRGB(255, 150, 0),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["粉色"] = Color3.fromRGB(255, 100, 180),
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

-- ============================================================
--  UI 根节点 — 悬浮球保持原样
-- ============================================================
local ui = Instance.new("ScreenGui")
ui.Name = "Ly枪战辅助"
ui.ResetOnSpawn = false
ui.Parent = playerGui

local orb = Instance.new("TextButton")
orb.Name = "Orb"
orb.Size = UDim2.new(0, 48, 0, 48)
orb.Position = UDim2.new(1, -64, 1, -64)
orb.BackgroundColor3 = C_SKY3
orb.BorderSizePixel = 0
orb.Text = "Ly"
orb.TextColor3 = C_WHITE
orb.TextSize = 16
orb.Font = Enum.Font.GothamBold
orb.ZIndex = 100
orb.AutoButtonColor = false
orb.Parent = ui

local orbCorner = Instance.new("UICorner")
orbCorner.CornerRadius = UDim.new(1, 0)
orbCorner.Parent = orb

local orbStroke = Instance.new("UIStroke")
orbStroke.Color = C_PINK3
orbStroke.Thickness = 2
orbStroke.Transparency = 0.5
orbStroke.Parent = orb

spawn(function()
    while orb.Parent do
        if not orb.Visible then break end
        TweenService:Create(orbStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Transparency = 0.2}):Play()
        wait(1.5)
        if not orb.Parent then break end
        TweenService:Create(orbStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), 
            {Transparency = 0.6}):Play()
        wait(1.5)
    end
end)

-- ============================================================
--  主面板 — 浅蓝浅粉拼凑风格
-- ============================================================
local PANEL_W = 0.72
local PANEL_H = PANEL_W * (420 / 320)
local PANEL_X = (1 - PANEL_W) / 2
local PANEL_Y = (1 - PANEL_H) / 2
local BOTTOM_SAFE = 28

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 0, 0, 0)
panel.Position = UDim2.new(1, -68, 1, -68)
panel.BackgroundColor3 = C_BG_PANEL
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.ZIndex = 50
panel.Parent = ui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 24)
panelCorner.Parent = panel

local panelShadow = Instance.new("Frame")
panelShadow.Size = UDim2.new(1, 16, 1, 16)
panelShadow.Position = UDim2.new(0, -8, 0, -8)
panelShadow.BackgroundColor3 = C_BLACK
panelShadow.BackgroundTransparency = 0.88
panelShadow.BorderSizePixel = 0
panelShadow.ZIndex = 49
panelShadow.Parent = panel

local panelShadowCorner = Instance.new("UICorner")
panelShadowCorner.CornerRadius = UDim.new(0, 28)
panelShadowCorner.Parent = panelShadow

-- 顶部粉蓝渐变装饰条
local topGradient = Instance.new("Frame")
topGradient.Name = "TopGradient"
topGradient.Size = UDim2.new(1, 0, 0, 4)
topGradient.Position = UDim2.new(0, 0, 0, 0)
topGradient.BorderSizePixel = 0
 topGradient.ZIndex = 51
 topGradient.Parent = panel

 local topGradColor = Instance.new("UIGradient")
 topGradColor.Color = ColorSequence.new({
     ColorSequenceKeypoint.new(0, C_SKY3),
     ColorSequenceKeypoint.new(0.5, C_PINK3),
     ColorSequenceKeypoint.new(1, C_SKY3)
 })
 topGradColor.Rotation = 90
 topGradColor.Parent = topGradient

 local inner = Instance.new("Frame")
 inner.Name = "Inner"
 inner.Size = UDim2.new(1, 0, 1, 0)
 inner.BackgroundColor3 = C_BG_PANEL
 inner.BackgroundTransparency = 0
 inner.ClipsDescendants = true
 inner.ZIndex = 52
 inner.Parent = panel

 local innerCorner = Instance.new("UICorner")
 innerCorner.CornerRadius = UDim.new(0, 24)
 innerCorner.Parent = inner

 -- ============================================================
 --  顶部栏 — 浅蓝背景 + 粉装饰
 -- ============================================================
 local TOPBAR_H = 52
 local topBar = Instance.new("Frame")
 topBar.Name = "TopBar"
 topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
 topBar.BackgroundColor3 = C_SKY
 topBar.BorderSizePixel = 0
 topBar.ZIndex = 53

 topBar.ClipsDescendants = true
 local topBarMask = Instance.new("Frame")
 topBarMask.Size = UDim2.new(1, 0, 0.5, 0)
 topBarMask.Position = UDim2.new(0, 0, 0.5, 0)
 topBarMask.BackgroundColor3 = C_SKY
 topBarMask.BorderSizePixel = 0
 topBarMask.ZIndex = 54
 topBarMask.Parent = topBar

 local topBarCorner = Instance.new("UICorner")
 topBarCorner.CornerRadius = UDim.new(0, 24)
 topBarCorner.Parent = topBar

 -- 右上角粉色装饰圆
 local topDecor = Instance.new("Frame")
 topDecor.Size = UDim2.new(0, 60, 0, 60)
 topDecor.Position = UDim2.new(1, -30, 0, -20)
 topDecor.BackgroundColor3 = C_PINK
 topDecor.BackgroundTransparency = 0.6
 topDecor.BorderSizePixel = 0
 topDecor.ZIndex = 53
 topDecor.Parent = topBar

 local topDecorC = Instance.new("UICorner")
 topDecorC.CornerRadius = UDim.new(1, 0)
 topDecorC.Parent = topDecor

 local topIcon = Instance.new("TextLabel")
 topIcon.Size = UDim2.new(0, 28, 0, 28)
 topIcon.Position = UDim2.new(0, 16, 0, 12)
 topIcon.BackgroundTransparency = 1
 topIcon.Text = "💠"
 topIcon.TextColor3 = C_SKY3
 topIcon.TextSize = 20
 topIcon.Font = Enum.Font.GothamBold
 topIcon.ZIndex = 55
 topIcon.Parent = topBar

 local topTitle = Instance.new("TextLabel")
 topTitle.Size = UDim2.new(1, -110, 1, 0)
 topTitle.Position = UDim2.new(0, 48, 0, 0)
 topTitle.BackgroundTransparency = 1
 topTitle.Text = "Ly枪战辅助"
 topTitle.TextColor3 = C_TEXT
 topTitle.TextSize = 18
 topTitle.Font = Enum.Font.GothamBold
 topTitle.TextXAlignment = Enum.TextXAlignment.Left
 topTitle.ZIndex = 55
 topTitle.Parent = topBar

 local topSub = Instance.new("TextLabel")
 topSub.Size = UDim2.new(0, 120, 0, 16)
 topSub.Position = UDim2.new(0, 48, 0, 30)
 topSub.BackgroundTransparency = 1
 topSub.Text = "v30.0 浅蓝浅粉版"
 topSub.TextColor3 = C_TEXT3
 topSub.TextSize = 10
 topSub.Font = Enum.Font.Gotham
 topSub.TextXAlignment = Enum.TextXAlignment.Left
 topSub.ZIndex = 55
 topSub.Parent = topBar

 local shrinkBtn = Instance.new("TextButton")
 shrinkBtn.Name = "ShrinkBtn"
 shrinkBtn.Size = UDim2.new(0, 32, 0, 32)
 shrinkBtn.Position = UDim2.new(1, -42, 0, 10)
 shrinkBtn.BackgroundColor3 = C_PINK2
 shrinkBtn.Text = "✕"
 shrinkBtn.TextColor3 = C_WHITE
 shrinkBtn.TextSize = 14
 shrinkBtn.Font = Enum.Font.GothamBold
 shrinkBtn.BorderSizePixel = 0
 shrinkBtn.AutoButtonColor = false
 shrinkBtn.ZIndex = 56
 shrinkBtn.Parent = topBar

 local shrinkCorner = Instance.new("UICorner")
 shrinkCorner.CornerRadius = UDim.new(1, 0)
 shrinkCorner.Parent = shrinkBtn

 shrinkBtn.MouseEnter:Connect(function()
     TweenService:Create(shrinkBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_PINK3}):Play()
 end)
 shrinkBtn.MouseLeave:Connect(function()
     TweenService:Create(shrinkBtn, TweenInfo.new(0.2), {BackgroundColor3 = C_PINK2}):Play()
 end)

 topBar.Parent = inner

 -- ============================================================
 --  主体区域
 -- ============================================================
 local body = Instance.new("Frame")
 body.Name = "Body"
 body.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
 body.Position = UDim2.new(0, 0, 0, TOPBAR_H)
 body.BackgroundTransparency = 1
 body.ClipsDescendants = true
 body.ZIndex = 52
 body.Parent = inner

 local NAV_RATIO = 0.24
 local GAP = 0.018
 local nav = Instance.new("ScrollingFrame")
 nav.Name = "Nav"
 nav.Size = UDim2.new(NAV_RATIO, 0, 1, -BOTTOM_SAFE)
 nav.BackgroundColor3 = C_BG
 nav.BorderSizePixel = 0
 nav.ScrollBarThickness = 3
 nav.ScrollBarImageColor3 = C_SKY3
 nav.CanvasSize = UDim2.new(0, 0, 0, 0)
 nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
 nav.ZIndex = 53
 nav.Parent = body

 local navCorner = Instance.new("UICorner")
 navCorner.CornerRadius = UDim.new(0, 16)
 navCorner.Parent = nav

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

 -- 浅蓝浅粉交替导航
 local navItems = {
     {name = "公告", icon = "📢", accent = C_PINK3, bg = C_PINK},
     {name = "绘制", icon = "🎨", accent = C_SKY3, bg = C_SKY},
     {name = "自瞄", icon = "🎯", accent = C_SKY3, bg = C_SKY},
     {name = "子追", icon = "🔫", accent = C_PINK3, bg = C_PINK},
     {name = "功能", icon = "⚡", accent = C_SKY3, bg = C_SKY},
 }

 local navBtns = {}
 local pages = {}
 local selectedIdx = 1

 for i, item in ipairs(navItems) do
     local btn = Instance.new("TextButton")
     btn.Name = item.name
     btn.Size = UDim2.new(1, 0, 0, 56)
     btn.BackgroundColor3 = (i == 1) and item.bg or C_CARD
     btn.BackgroundTransparency = (i == 1) and 0.4 or 0
     btn.Text = item.icon
     btn.TextColor3 = (i == 1) and C_TEXT or C_TEXT2
     btn.TextSize = 22
     btn.Font = Enum.Font.GothamBold
     btn.BorderSizePixel = 0
     btn.AutoButtonColor = false
     btn.LayoutOrder = i
     btn.ZIndex = 54
     btn.Parent = nav

     local btnC = Instance.new("UICorner")
     btnC.CornerRadius = UDim.new(0, 14)
     btnC.Parent = btn

     -- 左侧彩色指示条
     local indicator = Instance.new("Frame")
     indicator.Name = "Indicator"
     indicator.Size = UDim2.new(0, 4, 0, 24)
     indicator.Position = UDim2.new(0, 0, 0.5, -12)
     indicator.BackgroundColor3 = item.accent
     indicator.BorderSizePixel = 0
     indicator.ZIndex = 55
     indicator.Visible = (i == 1)
     indicator.Parent = btn

     local indC = Instance.new("UICorner")
     indC.CornerRadius = UDim.new(0, 2)
     indC.Parent = indicator

     local lbl = Instance.new("TextLabel")
     lbl.Size = UDim2.new(1, 0, 0, 14)
     lbl.Position = UDim2.new(0, 0, 1, -15)
     lbl.BackgroundTransparency = 1
     lbl.Text = item.name
     lbl.TextColor3 = (i == 1) and C_TEXT or C_TEXT2
     lbl.TextSize = 10
     lbl.Font = Enum.Font.Gotham
     lbl.ZIndex = 55
     lbl.Parent = btn

     btn.MouseEnter:Connect(function()
         if selectedIdx ~= i then
             TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = item.bg}):Play()
             TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
         end
     end)
     btn.MouseLeave:Connect(function()
         if selectedIdx ~= i then
             TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C_CARD}):Play()
             TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
         end
     end)

     navBtns[i] = btn
 end

 local content = Instance.new("Frame")
 content.Name = "Content"
 content.Size = UDim2.new(1 - NAV_RATIO - GAP, 0, 1, -BOTTOM_SAFE)
 content.Position = UDim2.new(NAV_RATIO + GAP, 0, 0, 0)
 content.BackgroundTransparency = 1
 content.ClipsDescendants = true
 content.ZIndex = 53
 content.Parent = body

-- ============================================================
--  浅蓝浅粉拼凑组件工厂
-- ============================================================
local function createToggle(parent, labelText, accentColor, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = C_CARD
    row.BorderSizePixel = 0
    row.ZIndex = 56
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    -- 彩色微边框
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.25
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
    lbl.ZIndex = 57
    lbl.Parent = row

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 48, 0, 26)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBg.BackgroundColor3 = C_GRAY
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.AutoButtonColor = false
    toggleBg.ZIndex = 57
    toggleBg.Parent = row

    local toggleBgC = Instance.new("UICorner")
    toggleBgC.CornerRadius = UDim.new(1, 0)
    toggleBgC.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -11)
    toggleKnob.BackgroundColor3 = C_WHITE
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 58
    toggleKnob.Parent = toggleBg

    local toggleKnobC = Instance.new("UICorner")
    toggleKnobC.CornerRadius = UDim.new(1, 0)
    toggleKnobC.Parent = toggleKnob

    local enabled = false

    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 24, 0.5, -11)}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.25), {Transparency = 0.55}):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = C_GRAY}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.25), {Transparency = 0.25}):Play()
        end
        if onToggle then onToggle(enabled) end
    end)

    return row
end

local function createSlider(parent, labelText, accentColor, minVal, maxVal, defaultVal, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 64)
    row.BackgroundColor3 = C_CARD
    row.BorderSizePixel = 0
    row.ZIndex = 56
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.25
    rowStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C_TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 57
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 22)
    valLbl.Position = UDim2.new(1, -58, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = accentColor
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 57
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = C_GRAY
    track.BorderSizePixel = 0
    track.ZIndex = 57
    track.Parent = row

    local trackC = Instance.new("UICorner")
    trackC.CornerRadius = UDim.new(1, 0)
    trackC.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 58
    fill.Parent = track

    local fillC = Instance.new("UICorner")
    fillC.CornerRadius = UDim.new(1, 0)
    fillC.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -9, 0.5, -9)
    knob.BackgroundColor3 = C_WHITE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 59
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
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = C_CARD
    row.BorderSizePixel = 0
    row.ZIndex = 56
    row.Parent = parent

    local rowC = Instance.new("UICorner")
    rowC.CornerRadius = UDim.new(0, 14)
    rowC.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = accentColor
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.25
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
    lbl.ZIndex = 57
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 110, 0, 32)
    selBtn.Position = UDim2.new(1, -122, 0.5, -16)
    selBtn.BackgroundColor3 = accentColor
    selBtn.Text = options[defaultIdx] or options[1]
    selBtn.TextColor3 = C_WHITE
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamBold
    selBtn.BorderSizePixel = 0
    selBtn.AutoButtonColor = false
    selBtn.ZIndex = 57
    selBtn.Parent = row

    local selC = Instance.new("UICorner")
    selC.CornerRadius = UDim.new(0, 8)
    selC.Parent = selBtn

    local dropdownOpen = false
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 110, 0, 0)
    dropdownFrame.Position = UDim2.new(1, -122, 0, 42)
    dropdownFrame.BackgroundColor3 = C_CARD
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 62
    dropdownFrame.Visible = false
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = row

    local dropdownC = Instance.new("UICorner")
    dropdownC.CornerRadius = UDim.new(0, 10)
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
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = C_BG
        optBtn.Text = opt
        optBtn.TextColor3 = C_TEXT
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.LayoutOrder = i
        optBtn.ZIndex = 63
        optBtn.Parent = dropdownFrame

        local optC = Instance.new("UICorner")
        optC.CornerRadius = UDim.new(0, 6)
        optC.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {BackgroundColor3 = accentColor}):Play()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {TextColor3 = C_WHITE}):Play()
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {BackgroundColor3 = C_BG}):Play()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {TextColor3 = C_TEXT}):Play()
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
            dropdownFrame.Size = UDim2.new(0, 110, 0, 0)
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 110, 0, #options * 32 + 8)
            }):Play()
        else
            dropdownFrame.Size = UDim2.new(0, 110, 0, #options * 32 + 8)
            TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 110, 0, 0)
            }):Play()
            task.delay(0.2, function()
                if not dropdownOpen then dropdownFrame.Visible = false end
            end)
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
    page.ZIndex = 54
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 14)
    padding.PaddingBottom = UDim.new(0, 14)
    padding.Parent = page

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 36)
    headerRow.BackgroundTransparency = 1
    headerRow.LayoutOrder = 1
    headerRow.ZIndex = 55
    headerRow.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 36, 0, 3)
    line.Position = UDim2.new(0, 0, 0, 6)
    line.BackgroundColor3 = accent
    line.BorderSizePixel = 0
    line.ZIndex = 56
    line.Parent = headerRow

    local lineC = Instance.new("UICorner")
    lineC.CornerRadius = UDim.new(1, 0)
    lineC.Parent = line

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 28)
    t.Position = UDim2.new(0, 0, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C_TEXT
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 56
    t.Parent = headerRow

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 18)
    d.Position = UDim2.new(0, 0, 0, 32)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = C_TEXT2
    d.TextSize = 11
    d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.ZIndex = 56
    d.Parent = headerRow

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 2
    container.ZIndex = 55
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

local function createNoticePage()
    local page = Instance.new("ScrollingFrame")
    page.Name = "公告"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C_PINK3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Visible = false
    page.ZIndex = 54
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = page

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 36)
    headerRow.BackgroundTransparency = 1
    headerRow.LayoutOrder = 1
    headerRow.ZIndex = 55
    headerRow.Parent = page

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 40, 0, 3)
    line.Position = UDim2.new(0, 0, 0, 6)
    line.BackgroundColor3 = C_PINK3
    line.BorderSizePixel = 0
    line.ZIndex = 56
    line.Parent = headerRow

    local lineC = Instance.new("UICorner")
    lineC.CornerRadius = UDim.new(1, 0)
    lineC.Parent = line

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 28)
    t.Position = UDim2.new(0, 0, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = "公告"
    t.TextColor3 = C_TEXT
    t.TextSize = 22
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 56
    t.Parent = headerRow

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, 0, 0, 18)
    d.Position = UDim2.new(0, 0, 0, 32)
    d.BackgroundTransparency = 1
    d.Text = "Ly枪战辅助 公告与更新日志"
    d.TextColor3 = C_TEXT2
    d.TextSize = 12
    d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.ZIndex = 56
    d.Parent = headerRow

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 300)
    card.BackgroundColor3 = C_CARD_PINK
    card.BorderSizePixel = 0
    card.LayoutOrder = 2
    card.ZIndex = 55
    card.Parent = page

    local cardC = Instance.new("UICorner")
    cardC.CornerRadius = UDim.new(0, 16)
    cardC.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = C_PINK2
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.35
    cardStroke.Parent = card

    local cardTop = Instance.new("Frame")
    cardTop.Size = UDim2.new(1, 0, 0, 4)
    cardTop.BackgroundColor3 = C_PINK3
    cardTop.BorderSizePixel = 0
    cardTop.ZIndex = 56
    cardTop.Parent = card

    local cardTopC = Instance.new("UICorner")
    cardTopC.CornerRadius = UDim.new(0, 16)
    cardTopC.Parent = cardTop

    local noticeText = Instance.new("TextLabel")
    noticeText.Size = UDim2.new(1, -24, 1, -24)
    noticeText.Position = UDim2.new(0, 12, 0, 12)
    noticeText.BackgroundTransparency = 1
    noticeText.Text = "Ly枪战辅助  v30.0 浅蓝浅粉版\n\n欢迎使用本脚本！\n\n本次更新：\n• UI全面升级为浅蓝浅粉清新风格\n• 顶部栏浅蓝背景配粉色装饰圆\n• 导航栏蓝粉交替卡片设计\n• 卡片彩色微边框 + 圆角\n• ESP视野内方框蓝色，视野外白色\n• 下拉框展开收起动画\n\n功能：\n• 高级绘制（方框/名字/血量/距离/透视）\n• 自瞄辅助（平滑/多条件优先）\n• 子弹追踪（预判/FOV）\n• 自动开枪 / 修改射速\n• 敌人传送 / 杀戮光环\n\n作者：林玉"
    noticeText.TextColor3 = C_TEXT
    noticeText.TextSize = 13
    noticeText.Font = Enum.Font.Gotham
    noticeText.TextWrapped = true
    noticeText.TextXAlignment = Enum.TextXAlignment.Left
    noticeText.TextYAlignment = Enum.TextYAlignment.Top
    noticeText.ZIndex = 56
    noticeText.Parent = card

    local function updateCanvas()
        local totalH = layout.AbsoluteContentSize.Y + 20
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

    if navBtns[selectedIdx] then
        TweenService:Create(navBtns[selectedIdx], TweenInfo.new(0.2), {BackgroundColor3 = C_CARD}):Play()
        TweenService:Create(navBtns[selectedIdx], TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        local oldLbl = navBtns[selectedIdx]:FindFirstChildOfClass("TextLabel")
        if oldLbl then
            TweenService:Create(oldLbl, TweenInfo.new(0.2), {TextColor3 = C_TEXT2}):Play()
        end
        local oldInd = navBtns[selectedIdx]:FindFirstChild("Indicator")
        if oldInd then oldInd.Visible = false end
    end

    if not navBtns[idx] then return end
    local newItem = navItems[idx]
    TweenService:Create(navBtns[idx], TweenInfo.new(0.2), {BackgroundColor3 = newItem.bg}):Play()
    TweenService:Create(navBtns[idx], TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
    local newLbl = navBtns[idx]:FindFirstChildOfClass("TextLabel")
    if newLbl then
        TweenService:Create(newLbl, TweenInfo.new(0.2), {TextColor3 = C_TEXT}):Play()
    end
    local newInd = navBtns[idx]:FindFirstChild("Indicator")
    if newInd then newInd.Visible = true end

    if pages[selectedIdx] then pages[selectedIdx].Visible = false end
    if pages[idx] then
        pages[idx].Visible = true
        pages[idx].Position = UDim2.new(0.04, 0, 0, 0)
        TweenService:Create(pages[idx], TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
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

-- ============================================================
--  悬浮球拖拽逻辑 — 保持原样
-- ============================================================
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

-- ============================================================
--  功能逻辑 — ESP颜色：视野内蓝色，视野外白色
-- ============================================================
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

local function UpdateESP2()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local lp = player
    local maxDist = ESP2_Settings.MaxDistance

    for plr, elements in pairs(ESP2.PlayerElements) do
        local success, err = pcall(function()
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

                            local isVisible = true
                            if ESP2_Settings.VisCheck then
                                local checkPart = head or hrp
                                isVisible = IsVisible(checkPart)
                            end

                            -- 视野内蓝色，视野外白色
                            local displayBoxColor = isVisible and C_VISIBLE or C_INVIS
                            local displayNameColor = isVisible and C_VISIBLE or C_TEXT

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

        if not success then
            -- 静默处理
        end
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
RadarElements.Background.Color = Color3.fromRGB(230, 240, 250)
RadarElements.Background.Thickness = 1
RadarElements.Background.Transparency = 0.5
RadarElements.Background.Filled = true

RadarElements.BackgroundCircle.Visible = false
RadarElements.BackgroundCircle.Color = Color3.fromRGB(230, 240, 250)
RadarElements.BackgroundCircle.Thickness = 1
RadarElements.BackgroundCircle.Transparency = 0.5
RadarElements.BackgroundCircle.Filled = true
RadarElements.BackgroundCircle.NumSides = 64

RadarElements.CenterDot.Visible = false
RadarElements.CenterDot.Color = Color3.fromRGB(100, 190, 235)
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
        RadarElements.BackgroundCircle.Color = Color3.fromRGB(230, 240, 250)
        RadarElements.BackgroundCircle.Transparency = 0.5
    else
        RadarElements.BackgroundCircle.Visible = false
        RadarElements.Background.Visible = true
        RadarElements.Background.Size = Vector2.new(radarSize, radarSize)
        RadarElements.Background.Position = Vector2.new(posX, posY)
        RadarElements.Background.Color = Color3.fromRGB(230, 240, 250)
        RadarElements.Background.Transparency = 0.5
    end

    RadarElements.CenterDot.Visible = true
    RadarElements.CenterDot.Position = Vector2.new(centerX, centerY)
    RadarElements.CenterDot.Radius = 3
    RadarElements.CenterDot.Color = Color3.fromRGB(100, 190, 235)

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

-- ============================================================
--  页面 UI 创建 — 浅蓝浅粉交替
-- ============================================================
pages[2] = createFeaturePage("绘制", "绘制", "ESP 高级绘制设置", C_SKY3)

createToggle(pages[2].Container, "ESP 总开关", C_SKY3, function(v)
    SetESP2Enabled(v)
end).LayoutOrder = 1

createToggle(pages[2].Container, "显示方框", C_SKY3, function(v)
    ESP2_Settings.ShowBox = v
end).LayoutOrder = 2

createToggle(pages[2].Container, "显示名字", C_SKY3, function(v)
    ESP2_Settings.ShowName = v
end).LayoutOrder = 3

createToggle(pages[2].Container, "显示距离", C_SKY3, function(v)
    ESP2_Settings.ShowDistance = v
end).LayoutOrder = 4

createToggle(pages[2].Container, "显示血量", C_SKY3, function(v)
    ESP2_Settings.ShowHealth = v
end).LayoutOrder = 5

createToggle(pages[2].Container, "上色透视", C_SKY3, function(v)
    ESP2_Settings.ShowChams = v
end).LayoutOrder = 6

createToggle(pages[2].Container, "漏打检测", C_SKY3, function(v)
    ESP2_Settings.VisCheck = v
end).LayoutOrder = 7

createToggle(pages[2].Container, "队伍检测", C_SKY3, function(v)
    ESP2_Settings.TeamCheck = v
end).LayoutOrder = 8

createSlider(pages[2].Container, "最大绘制距离", C_SKY3, 50, 5000, 5000, function(v)
    ESP2_Settings.MaxDistance = v
end).LayoutOrder = 9

createToggle(pages[2].Container, "显示雷达", C_SKY3, function(v)
    ESP2_Settings.ShowRadar = v
end).LayoutOrder = 10

createDropdown(pages[2].Container, "雷达形状", C_SKY3, {"圆形", "方形"}, 1, function(v)
    ESP2_Settings.RadarShape = v
end).LayoutOrder = 11

createSlider(pages[2].Container, "雷达大小", C_SKY3, 60, 200, 120, function(v)
    ESP2_Settings.RadarSize = v
end).LayoutOrder = 12

createSlider(pages[2].Container, "雷达范围", C_SKY3, 50, 500, 200, function(v)
    ESP2_Settings.RadarRange = v
end).LayoutOrder = 13

createSlider(pages[2].Container, "雷达X位置", C_SKY3, 50, 800, 150, function(v)
    ESP2_Settings.RadarPosX = v
end).LayoutOrder = 14

createSlider(pages[2].Container, "雷达Y位置", C_SKY3, 50, 600, 150, function(v)
    ESP2_Settings.RadarPosY = v
end).LayoutOrder = 15

createDropdown(pages[2].Container, "可见颜色", C_SKY3, {"绿色", "红色", "蓝色", "黄色", "青色", "紫色", "橙色", "白色", "粉色"}, 1, function(v)
    ESP2_Settings.RadarVisibleColor = v
end).LayoutOrder = 16

createDropdown(pages[2].Container, "不可见颜色", C_SKY3, {"红色", "绿色", "蓝色", "黄色", "青色", "紫色", "橙色", "白色", "粉色"}, 1, function(v)
    ESP2_Settings.RadarHiddenColor = v
end).LayoutOrder = 17

pages[3] = createFeaturePage("自瞄", "自瞄", "自瞄功能详细设置", C_PINK3)

createToggle(pages[3].Container, "启用自瞄", C_PINK3, function(v)
    AimConfig.Enabled = v
    FOV_Circle.Visible = v
end).LayoutOrder = 1

createToggle(pages[3].Container, "漏打检测", C_PINK3, function(v)
    AimConfig.VisCheck = v
end).LayoutOrder = 2

createToggle(pages[3].Container, "队伍检测", C_PINK3, function(v)
    AimConfig.TeamCheck = v
end).LayoutOrder = 3

createSlider(pages[3].Container, "自瞄范围", C_PINK3, 50, 400, 150, function(v)
    AimConfig.FOV = v
end).LayoutOrder = 4

createSlider(pages[3].Container, "自瞄距离", C_PINK3, 100, 2000, 500, function(v)
    AimConfig.Distance = v
end).LayoutOrder = 5

createSlider(pages[3].Container, "自瞄速度", C_PINK3, 1, 30, 5, function(v)
    AimConfig.Speed = v
end).LayoutOrder = 6

createSlider(pages[3].Container, "平滑度", C_PINK3, 1, 20, 5, function(v)
    AimConfig.Smoothness = v
end).LayoutOrder = 7

createDropdown(pages[3].Container, "优先条件", C_PINK3, {"FOV距离", "世界距离", "综合评分", "血量优先"}, 1, function(v)
    AimConfig.Priority = v
end).LayoutOrder = 8

createDropdown(pages[3].Container, "瞄准部位", C_PINK3, {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, 1, function(v)
    AimConfig.TargetPart = v
end).LayoutOrder = 9

pages[4] = createFeaturePage("子追", "子弹追踪", "子弹追踪功能设置", C_SKY3)

createToggle(pages[4].Container, "启用子弹追踪", C_SKY3, function(v)
    BulletConfig.Enabled = v
end).LayoutOrder = 1

createSlider(pages[4].Container, "追踪角度范围", C_SKY3, 10, 180, 60, function(v)
    BulletConfig.FOV = v
end).LayoutOrder = 2

createDropdown(pages[4].Container, "优先条件", C_SKY3, {"FOV优先", "距离优先", "综合评分"}, 1, function(v)
    BulletConfig.Priority = v
end).LayoutOrder = 3

createToggle(pages[4].Container, "启用预判", C_SKY3, function(v)
    BulletConfig.Prediction = v
end).LayoutOrder = 4

createSlider(pages[4].Container, "预判系数", C_SKY3, 5, 50, 15, function(v)
    BulletConfig.PredictionFactor = v / 100
end).LayoutOrder = 5

pages[5] = createFeaturePage("功能", "功能", "通用功能设置", C_PINK3)

createToggle(pages[5].Container, "自动开枪", C_PINK3, function(v)
    MiscConfig.AutoFire = v
end).LayoutOrder = 1

createSlider(pages[5].Container, "自动开枪范围", C_PINK3, 50, 500, 200, function(v)
    MiscConfig.AutoFireRange = v
end).LayoutOrder = 2

createSlider(pages[5].Container, "开枪间隔(秒)", C_PINK3, 1, 20, 10, function(v)
    MiscConfig.AutoFireDelay = v / 100
end).LayoutOrder = 3

createToggle(pages[5].Container, "修改射速", C_PINK3, function(v)
    MiscConfig.FireRate = v
end).LayoutOrder = 4

createSlider(pages[5].Container, "射速间隔(秒)", C_PINK3, 1, 20, 5, function(v)
    MiscConfig.FireRateValue = v / 100
end).LayoutOrder = 5

createToggle(pages[5].Container, "敌人传送面前", C_PINK3, function(v)
    MiscConfig.TeleportEnemies = v
end).LayoutOrder = 6

createSlider(pages[5].Container, "传送距离", C_PINK3, 1, 30, 5, function(v)
    MiscConfig.TeleportDistance = v
end).LayoutOrder = 7

createToggle(pages[5].Container, "杀戮光环", C_PINK3, function(v)
    MiscConfig.KillAura = v
end).LayoutOrder = 8

createSlider(pages[5].Container, "光环范围", C_PINK3, 1, 100, 50, function(v)
    MiscConfig.KillAuraRange = v
end).LayoutOrder = 9

createDropdown(pages[5].Container, "优先条件", C_PINK3, {"距离优先", "血量优先", "视角优先"}, 1, function(v)
    MiscConfig.KillAuraPriority = v
end).LayoutOrder = 10

createToggle(pages[5].Container, "持续锁定", C_PINK3, function(v)
    MiscConfig.KillAuraLock = v
end).LayoutOrder = 11

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

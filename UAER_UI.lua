--[[
    UAER_UI | Public Roblox UI Library
    Version: 0.2.0
    Author: uaer_179

    PUBLIC API
    UAER_UI is a UI framework. Requiring/loading this file returns the library;
    it does not create a window automatically. The caller creates windows,
    tabs, sections, and controls through the WindUI-style configuration API.

    This package provides interface components and callbacks only. It does not
    implement game-specific actions, remote calls, or automation.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = nil
local ActiveWindow = nil

local function SafeCallback(callback, ...)
    if type(callback) ~= "function" then return end
    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[UAER_UI] Callback error: " .. tostring(err))
    end
end

local IconAliases = {
    home = "⌂", house = "⌂", star = "★", settings = "⚙", gear = "⚙",
    swords = "⚔", sword = "⚔", shield = "⛨", user = "●", users = "♟",
    eye = "◉", gamepad = "▣", box = "▦", flame = "♨", zap = "ϟ",
    sparkles = "✦", activity = "⌁", info = "ⓘ", search = "⌕",
    palette = "◈", code = "</>", menu = "☰", bell = "♢", crown = "♛",
}
local function ResolveIcon(value, fallback)
    if value == nil then return fallback or "◈" end
    local text = tostring(value)
    return IconAliases[string.lower(text)] or text
end

local Library = {}
Library.Name = "UAER_UI"
Library.Version = "0.2.0"
Library.Author = "uaer_179"
Library.Description = "A customizable, responsive Roblox UI library."
Library.Release = "Public beta"
Library.APIStyle = "WindUI-compatible config tables"

local Themes = {
    Midnight = {
        Background = Color3.fromRGB(12, 10, 23), Panel = Color3.fromRGB(19, 16, 35),
        Card = Color3.fromRGB(26, 21, 47), Card2 = Color3.fromRGB(32, 25, 57),
        Accent = Color3.fromRGB(158, 93, 255), Accent2 = Color3.fromRGB(91, 65, 214),
        Text = Color3.fromRGB(245, 241, 255), Muted = Color3.fromRGB(157, 147, 181),
        Line = Color3.fromRGB(83, 65, 122), Green = Color3.fromRGB(91, 224, 165), Red = Color3.fromRGB(255, 104, 130),
    },
    Obsidian = {
        Background = Color3.fromRGB(9, 12, 18), Panel = Color3.fromRGB(15, 20, 29),
        Card = Color3.fromRGB(22, 29, 41), Card2 = Color3.fromRGB(29, 38, 53),
        Accent = Color3.fromRGB(79, 166, 255), Accent2 = Color3.fromRGB(42, 111, 201),
        Text = Color3.fromRGB(240, 247, 255), Muted = Color3.fromRGB(143, 159, 181),
        Line = Color3.fromRGB(66, 84, 109), Green = Color3.fromRGB(91, 220, 166), Red = Color3.fromRGB(255, 105, 130),
    },
    Aurora = {
        Background = Color3.fromRGB(7, 17, 23), Panel = Color3.fromRGB(12, 29, 38),
        Card = Color3.fromRGB(18, 40, 50), Card2 = Color3.fromRGB(25, 53, 63),
        Accent = Color3.fromRGB(71, 224, 205), Accent2 = Color3.fromRGB(48, 151, 175),
        Text = Color3.fromRGB(231, 250, 247), Muted = Color3.fromRGB(137, 181, 182),
        Line = Color3.fromRGB(56, 112, 119), Green = Color3.fromRGB(104, 235, 169), Red = Color3.fromRGB(255, 118, 139),
    },
    Crimson = {
        Background = Color3.fromRGB(19, 8, 16), Panel = Color3.fromRGB(31, 13, 25),
        Card = Color3.fromRGB(46, 19, 35), Card2 = Color3.fromRGB(61, 25, 44),
        Accent = Color3.fromRGB(255, 83, 125), Accent2 = Color3.fromRGB(177, 43, 92),
        Text = Color3.fromRGB(255, 241, 246), Muted = Color3.fromRGB(190, 145, 162),
        Line = Color3.fromRGB(119, 57, 80), Green = Color3.fromRGB(103, 225, 164), Red = Color3.fromRGB(255, 110, 137),
    },
    Cloud = {
        Background = Color3.fromRGB(235, 239, 248), Panel = Color3.fromRGB(247, 249, 253),
        Card = Color3.fromRGB(255, 255, 255), Card2 = Color3.fromRGB(235, 239, 248),
        Accent = Color3.fromRGB(111, 85, 240), Accent2 = Color3.fromRGB(83, 67, 193),
        Text = Color3.fromRGB(34, 37, 55), Muted = Color3.fromRGB(111, 117, 139),
        Line = Color3.fromRGB(204, 210, 227), Green = Color3.fromRGB(26, 165, 113), Red = Color3.fromRGB(220, 70, 94),
    },
    Sakura = {
        Background = Color3.fromRGB(25, 12, 24), Panel = Color3.fromRGB(39, 19, 37),
        Card = Color3.fromRGB(55, 27, 50), Card2 = Color3.fromRGB(70, 35, 62),
        Accent = Color3.fromRGB(255, 132, 185), Accent2 = Color3.fromRGB(194, 82, 145),
        Text = Color3.fromRGB(255, 241, 249), Muted = Color3.fromRGB(193, 151, 177),
        Line = Color3.fromRGB(120, 69, 103), Green = Color3.fromRGB(112, 225, 167), Red = Color3.fromRGB(255, 105, 140),
    },
    Emerald = {
        Background = Color3.fromRGB(7, 20, 17), Panel = Color3.fromRGB(12, 32, 26),
        Card = Color3.fromRGB(18, 47, 37), Card2 = Color3.fromRGB(25, 62, 48),
        Accent = Color3.fromRGB(63, 220, 154), Accent2 = Color3.fromRGB(30, 145, 105),
        Text = Color3.fromRGB(232, 255, 245), Muted = Color3.fromRGB(137, 185, 164),
        Line = Color3.fromRGB(55, 111, 87), Green = Color3.fromRGB(91, 235, 157), Red = Color3.fromRGB(255, 111, 132),
    },
    Ocean = {
        Background = Color3.fromRGB(7, 16, 31), Panel = Color3.fromRGB(12, 27, 48),
        Card = Color3.fromRGB(18, 39, 67), Card2 = Color3.fromRGB(25, 52, 84),
        Accent = Color3.fromRGB(75, 171, 255), Accent2 = Color3.fromRGB(42, 105, 196),
        Text = Color3.fromRGB(235, 246, 255), Muted = Color3.fromRGB(143, 171, 201),
        Line = Color3.fromRGB(61, 97, 139), Green = Color3.fromRGB(88, 224, 173), Red = Color3.fromRGB(255, 110, 135),
    },
    Sunset = {
        Background = Color3.fromRGB(29, 14, 14), Panel = Color3.fromRGB(45, 22, 19),
        Card = Color3.fromRGB(62, 31, 25), Card2 = Color3.fromRGB(79, 41, 29),
        Accent = Color3.fromRGB(255, 145, 75), Accent2 = Color3.fromRGB(211, 76, 72),
        Text = Color3.fromRGB(255, 244, 232), Muted = Color3.fromRGB(199, 157, 135),
        Line = Color3.fromRGB(130, 77, 57), Green = Color3.fromRGB(116, 224, 157), Red = Color3.fromRGB(255, 105, 120),
    },
    RoseGold = {
        Background = Color3.fromRGB(28, 20, 23), Panel = Color3.fromRGB(43, 30, 35),
        Card = Color3.fromRGB(59, 41, 46), Card2 = Color3.fromRGB(76, 52, 57),
        Accent = Color3.fromRGB(226, 158, 151), Accent2 = Color3.fromRGB(165, 105, 112),
        Text = Color3.fromRGB(255, 244, 241), Muted = Color3.fromRGB(191, 157, 157),
        Line = Color3.fromRGB(119, 83, 91), Green = Color3.fromRGB(117, 217, 164), Red = Color3.fromRGB(255, 113, 132),
    },
    Cyberpunk = {
        Background = Color3.fromRGB(12, 8, 26), Panel = Color3.fromRGB(21, 13, 42),
        Card = Color3.fromRGB(31, 19, 59), Card2 = Color3.fromRGB(43, 24, 74),
        Accent = Color3.fromRGB(255, 66, 190), Accent2 = Color3.fromRGB(70, 210, 255),
        Text = Color3.fromRGB(250, 241, 255), Muted = Color3.fromRGB(171, 151, 198),
        Line = Color3.fromRGB(94, 61, 132), Green = Color3.fromRGB(86, 239, 190), Red = Color3.fromRGB(255, 88, 130),
    },
    Lavender = {
        Background = Color3.fromRGB(20, 17, 31), Panel = Color3.fromRGB(32, 27, 48),
        Card = Color3.fromRGB(45, 38, 65), Card2 = Color3.fromRGB(58, 49, 81),
        Accent = Color3.fromRGB(187, 159, 255), Accent2 = Color3.fromRGB(127, 105, 208),
        Text = Color3.fromRGB(247, 242, 255), Muted = Color3.fromRGB(177, 164, 202),
        Line = Color3.fromRGB(103, 87, 139), Green = Color3.fromRGB(112, 224, 169), Red = Color3.fromRGB(255, 113, 143),
    },
    Forest = {
        Background = Color3.fromRGB(13, 19, 15), Panel = Color3.fromRGB(21, 31, 23),
        Card = Color3.fromRGB(30, 44, 32), Card2 = Color3.fromRGB(39, 57, 40),
        Accent = Color3.fromRGB(151, 197, 112), Accent2 = Color3.fromRGB(78, 139, 83),
        Text = Color3.fromRGB(241, 249, 235), Muted = Color3.fromRGB(166, 184, 151),
        Line = Color3.fromRGB(83, 112, 79), Green = Color3.fromRGB(108, 222, 139), Red = Color3.fromRGB(245, 112, 119),
    },
    Ember = {
        Background = Color3.fromRGB(24, 12, 10), Panel = Color3.fromRGB(39, 19, 15),
        Card = Color3.fromRGB(55, 27, 20), Card2 = Color3.fromRGB(72, 36, 24),
        Accent = Color3.fromRGB(255, 111, 48), Accent2 = Color3.fromRGB(188, 54, 31),
        Text = Color3.fromRGB(255, 242, 231), Muted = Color3.fromRGB(194, 151, 129),
        Line = Color3.fromRGB(124, 72, 51), Green = Color3.fromRGB(115, 221, 148), Red = Color3.fromRGB(255, 92, 91),
    },
    Arctic = {
        Background = Color3.fromRGB(12, 21, 31), Panel = Color3.fromRGB(19, 33, 47),
        Card = Color3.fromRGB(27, 47, 64), Card2 = Color3.fromRGB(37, 61, 80),
        Accent = Color3.fromRGB(133, 220, 255), Accent2 = Color3.fromRGB(75, 149, 207),
        Text = Color3.fromRGB(240, 251, 255), Muted = Color3.fromRGB(158, 190, 207),
        Line = Color3.fromRGB(79, 121, 149), Green = Color3.fromRGB(109, 225, 178), Red = Color3.fromRGB(255, 116, 142),
    },
}
local ThemeNames = {
    "Midnight", "Obsidian", "Aurora", "Crimson", "Cloud",
    "Sakura", "Emerald", "Ocean", "Sunset", "RoseGold",
    "Cyberpunk", "Lavender", "Forest", "Ember", "Arctic",
}
local ThemeAliases = {
    Dark = "Midnight",
    Light = "Cloud",
    Default = "Midnight",
}
local function ResolveThemeName(name)
    name = tostring(name or "Midnight")
    return ThemeAliases[name] or name
end

-- Designs change the layout, geometry, borders, and component finish.
-- Themes remain separate and only change the color palette.
local Designs = {
    -- Every design keeps rounded geometry; the design differences come from
    -- spacing, borders, gradients, and surface finish rather than square edges.
    Glass = { MainRadius = 22, SurfaceRadius = 16, ControlRadius = 12, StrokeThickness = 1.1, StrokeTransparency = 0.34, Gradients = true, WindowX = 0.92, WindowY = 0.82 },
    Minimal = { MainRadius = 18, SurfaceRadius = 14, ControlRadius = 11, StrokeThickness = 0.7, StrokeTransparency = 0.68, Gradients = false, WindowX = 0.92, WindowY = 0.82 },
    Soft = { MainRadius = 26, SurfaceRadius = 20, ControlRadius = 15, StrokeThickness = 0.8, StrokeTransparency = 0.58, Gradients = true, WindowX = 0.92, WindowY = 0.82 },
    Sharp = { MainRadius = 18, SurfaceRadius = 14, ControlRadius = 10, StrokeThickness = 1.0, StrokeTransparency = 0.2, Gradients = false, WindowX = 0.92, WindowY = 0.82 },
    Neon = { MainRadius = 22, SurfaceRadius = 16, ControlRadius = 12, StrokeThickness = 1.8, StrokeTransparency = 0.08, Gradients = true, WindowX = 0.92, WindowY = 0.82 },
    Compact = { MainRadius = 18, SurfaceRadius = 14, ControlRadius = 10, StrokeThickness = 0.9, StrokeTransparency = 0.42, Gradients = true, WindowX = 0.86, WindowY = 0.76 },
}
Library.ThemePresets = Themes
Library.ThemeNames = ThemeNames
Library.ThemeAliases = ThemeAliases
Library.DesignPresets = Designs
Library.DefaultTheme = "Midnight"
Library.DefaultDesign = "Glass"
local Theme = table.clone(Themes.Midnight)
Theme.Name = "Midnight"
local CurrentDesign = "Glass"

-- Seven selectable Roblox audio presets. Audio availability can vary by experience permissions.
local NotificationSoundPresets = {
    ["Windows 8/10"] = "rbxassetid://478544929",
    ["Steam Message"] = "rbxassetid://195868961",
    ["Classic Notify"] = "rbxassetid://199077102",
    ["Windows Balloon"] = "rbxassetid://225320558",
    ["Notification Ding"] = "rbxassetid://1421653565",
    ["Roblox Plus"] = "rbxassetid://3023237993",
    ["Android Notification"] = "rbxassetid://6205430632",
}
local NotificationSoundNames = {
    "Windows 8/10", "Steam Message", "Classic Notify", "Windows Balloon",
    "Notification Ding", "Roblox Plus", "Android Notification",
}
local NotificationSoundPresetName = "Windows 8/10"
local NotificationSoundId = NotificationSoundPresets[NotificationSoundPresetName]
local NotificationVolume = 0.55
local NotificationSoundEnabled = true
Library.NotificationSoundPresets = NotificationSoundPresets
Library.NotificationSoundNames = NotificationSoundNames

local function ThemeRole(color)
    if typeof(color) ~= "Color3" then return nil end
    for key, value in pairs(Theme) do
        if typeof(value) == "Color3" and value == color then return key end
    end
end

local function New(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    local bindings = {
        BackgroundColor3 = "UAER_BG", TextColor3 = "UAER_TEXT",
        PlaceholderColor3 = "UAER_PLACEHOLDER",
        ImageColor3 = "UAER_IMAGE", ScrollBarImageColor3 = "UAER_SCROLL",
        Color = "UAER_STROKE",
    }
    for property, attribute in pairs(bindings) do
        local role = ThemeRole((props or {})[property])
        if role then object:SetAttribute(attribute, role) end
    end
    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    local base = radius or 10
    local kind = "Surface"
    if parent.Name == "MainWindow" or parent.Name == "Topbar" then
        kind = "Main"
    elseif parent:IsA("TextButton") or parent:IsA("TextBox") then
        kind = base >= 18 and "Pill" or "Control"
    elseif base >= 18 then
        kind = "Pill"
    end
    local style = Designs[CurrentDesign] or Designs.Glass
    local applied = kind == "Main" and math.max(18, style.MainRadius)
        or (kind == "Control" and math.max(10, style.ControlRadius)
        or (kind == "Surface" and math.max(12, style.SurfaceRadius) or base))
    local corner = New("UICorner", { CornerRadius = UDim.new(0, applied) }, parent)
    corner:SetAttribute("UAER_CORNER_KIND", kind)
    corner:SetAttribute("UAER_CORNER_BASE", base)
    return corner
end

local function Stroke(parent, color, transparency, thickness)
    local style = Designs[CurrentDesign] or Designs.Glass
    local stroke = New("UIStroke", {
        Color = color or Theme.Line,
        Transparency = style.StrokeTransparency,
        Thickness = style.StrokeThickness,
    }, parent)
    stroke:SetAttribute("UAER_STROKE_BASE_TRANSPARENCY", transparency or 0.35)
    stroke:SetAttribute("UAER_STROKE_BASE_THICKNESS", thickness or 1)
    return stroke
end

local function Gradient(parent, first, second, rotation)
    first, second = first or Theme.Accent, second or Theme.Accent2
    local style = Designs[CurrentDesign] or Designs.Glass
    local gradient = New("UIGradient", {
        Color = ColorSequence.new(first, second),
        Rotation = rotation or 0,
        Enabled = style.Gradients,
    }, parent)
    gradient:SetAttribute("UAER_GRADIENT_A", ThemeRole(first) or "")
    gradient:SetAttribute("UAER_GRADIENT_B", ThemeRole(second) or "")
    return gradient
end

local function MakeLabel(parent, text, size, color, font, xAlign)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 13,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = xAlign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 22),
        BorderSizePixel = 0,
    }, parent)
end

local function Tween(object, duration, properties)
    local animation = TweenService:Create(object, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    animation:Play()
    return animation
end

local function AddPadding(parent, left, right, top, bottom)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
end

local function MakeButton(parent, text, size, primary)
    local button = New("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = primary and Theme.Accent2 or Theme.Card2,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Size = size or UDim2.new(1, 0, 0, 34),
    }, parent)
    Corner(button, 9)
    Stroke(button, primary and Theme.Accent or Theme.Line, 0.45, 1)
    if primary then Gradient(button, Theme.Accent, Theme.Accent2, 0) end
    button.MouseEnter:Connect(function()
        button:SetAttribute("UAER_BG", primary and "Accent" or "Card")
        Tween(button, 0.12, { BackgroundColor3 = primary and Theme.Accent or Theme.Card })
    end)
    button.MouseLeave:Connect(function()
        button:SetAttribute("UAER_BG", primary and "Accent2" or "Card2")
        Tween(button, 0.12, { BackgroundColor3 = primary and Theme.Accent2 or Theme.Card2 })
    end)
    return button
end

--// Notification system -------------------------------------------------------
local NoticeHolder
local function PlayNotificationSound()
    if not NotificationSoundEnabled or not NotificationSoundId or NotificationSoundId == "" then return end
    local sound = Instance.new("Sound")
    sound.Name = "UAER_NotificationSound"
    sound.SoundId = NotificationSoundId
    sound.Volume = math.clamp(NotificationVolume, 0, 1)
    sound.Parent = SoundService
    local ok = pcall(function() SoundService:PlayLocalSound(sound) end)
    if not ok then sound:Destroy() return end
    Debris:AddItem(sound, 6)
end

local function Notify(title, message, kind, duration)
    if not NoticeHolder then return end
    PlayNotificationSound()
    local tint = kind == "success" and Theme.Green or (kind == "error" and Theme.Red or Theme.Accent)
    local item = New("Frame", {
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 68),
        ClipsDescendants = true,
    }, NoticeHolder)
    Corner(item, 11)
    Stroke(item, tint, 0.28, 1)
    local bar = New("Frame", { BackgroundColor3 = tint, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0) }, item)
    Corner(bar, 3)
    local titleLabel = MakeLabel(item, title or "Notification", 12, Theme.Text, Enum.Font.GothamBold)
    titleLabel.Position = UDim2.fromOffset(14, 8)
    titleLabel.Size = UDim2.new(1, -24, 0, 18)
    local body = MakeLabel(item, message or "This is a preview notification.", 11, Theme.Muted)
    body.Position = UDim2.fromOffset(14, 29)
    body.Size = UDim2.new(1, -24, 0, 28)
    body.TextWrapped = true
    item.BackgroundTransparency = 1
    Tween(item, 0.18, { BackgroundTransparency = 0 })
    task.delay(math.clamp(tonumber(duration) or 3.2, 0.5, 30), function()
        if item and item.Parent then
            Tween(item, 0.18, { BackgroundTransparency = 1 })
            task.wait(0.2)
            if item then item:Destroy() end
        end
    end)
end
--// Window --------------------------------------------------------------------
function Library:CreateWindow(config)
    config = type(config) == "table" and config or {}
    local userConfig = type(config.User) == "table" and config.User or {}
    local showSearchBar = config.HideSearchBar ~= true and config.ShowSearch ~= false
    local showUserProfile = userConfig.Enabled ~= false and config.ShowProfile ~= false
    local scrollbarsEnabled = config.ScrollBarEnabled ~= false
    local isTransparent = config.Transparent == true
    local configuredSidebarWidth = math.clamp(tonumber(config.SideBarWidth) or 145, 96, 250)
    if not RunService:IsClient() then
        error("UAER_UI must be required from a LocalScript or client ModuleScript.", 2)
    end
    Player = Players.LocalPlayer
    if not Player then
        error("UAER_UI could not find Players.LocalPlayer. Require it on the client.", 2)
    end
    PlayerGui = Player:WaitForChild("PlayerGui")
    if ActiveWindow and not ActiveWindow.Destroyed then
        warn("[UAER_UI] A window is already active. Destroy it before creating another.")
        return ActiveWindow
    end

    local window = {}
    window.Library = Library
    window.Title = tostring(config.Title or "UAER_UI")
    window.Author = tostring(config.Author or config.Credit or "uaer_179")
    window.Folder = tostring(config.Folder or "UAER_UI")
    window.Config = table.clone(config)
    local GlobalConnections = {}
    local function TrackConnection(connection)
        table.insert(GlobalConnections, connection)
        return connection
    end
    window.Tabs = {}
    window.ActiveTab = nil
    window.CurrentDesign = config.Design and Designs[config.Design] and config.Design or CurrentDesign
    window.CurrentTheme = Theme.Name or requestedTheme
    CurrentDesign = window.CurrentDesign
    local requestedTheme = ResolveThemeName(config.Theme)
    if Themes[requestedTheme] then
        for key, value in pairs(Themes[requestedTheme]) do Theme[key] = value end
        Theme.Name = requestedTheme
    end
    if config.KeySystem ~= nil then
        warn("[UAER_UI] KeySystem is not implemented in this beta. Do not rely on client-side keys for security.")
    end
    local toggleKeyInput = config.ToggleKey or config.ToggleKeybind or "RightShift"
    local ToggleKey
    if typeof(toggleKeyInput) == "EnumItem" and toggleKeyInput.EnumType == Enum.KeyCode then
        ToggleKey = toggleKeyInput
    else
        local toggleKeyName = tostring(toggleKeyInput):match("([^%.]+)$") or tostring(toggleKeyInput)
        ToggleKey = Enum.KeyCode[toggleKeyName] or Enum.KeyCode.RightShift
    end
    local ToggleKeyName = ToggleKey.Name
    if config.NotificationSoundPreset ~= nil and NotificationSoundPresets[tostring(config.NotificationSoundPreset)] then
        NotificationSoundPresetName = tostring(config.NotificationSoundPreset)
        NotificationSoundId = NotificationSoundPresets[NotificationSoundPresetName]
    end
    if config.NotificationSoundId ~= nil then
        NotificationSoundId = tostring(config.NotificationSoundId)
        NotificationSoundPresetName = "Custom"
    end
    if config.NotificationVolume ~= nil then NotificationVolume = math.clamp(tonumber(config.NotificationVolume) or 0.55, 0, 1) end
    if config.NotificationSounds ~= nil then NotificationSoundEnabled = config.NotificationSounds == true end

    local Main
    local updateResponsive
    local screenName = tostring(config.GuiName or config.Name or "UAER_UI")
    local guiParent = config.Parent or PlayerGui
    local old = guiParent:FindFirstChild(screenName)
    if old then old:Destroy() end

    local Screen = New("ScreenGui", {
        Name = screenName,
        ResetOnSpawn = config.ResetOnSpawn == true,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(config.DisplayOrder) or 80,
    }, guiParent)
    window.Screen = Screen

    function window:SetDesign(designName)
        local preset = Designs[designName]
        if not preset then
            warn("[UAER_UI] Unknown design: " .. tostring(designName))
            return false
        end
        CurrentDesign = designName
        window.CurrentDesign = designName
        for _, object in ipairs(Screen:GetDescendants()) do
            if object:IsA("UICorner") then
                local kind = object:GetAttribute("UAER_CORNER_KIND")
                if kind == "Main" then object.CornerRadius = UDim.new(0, math.max(18, preset.MainRadius))
                elseif kind == "Surface" then object.CornerRadius = UDim.new(0, math.max(12, preset.SurfaceRadius))
                elseif kind == "Control" then object.CornerRadius = UDim.new(0, math.max(10, preset.ControlRadius))
                elseif kind == "Circle" or kind == "Pill" then object.CornerRadius = UDim.new(1, 0) end
            elseif object:IsA("UIStroke") and not object:GetAttribute("UAER_KEEP_STROKE") then
                object.Thickness = preset.StrokeThickness
                object.Transparency = preset.StrokeTransparency
            elseif object:IsA("UIGradient") and not object:GetAttribute("UAER_KEEP_GRADIENT") then
                object.Enabled = preset.Gradients
            end
        end
        return true
    end

    function window:SetNotificationSound(soundId, volume)
        NotificationSoundId = soundId == nil and "" or tostring(soundId)
        NotificationSoundPresetName = "Custom"
        if volume ~= nil then NotificationVolume = math.clamp(tonumber(volume) or NotificationVolume, 0, 1) end
    end

    function window:SetNotificationSoundPreset(presetName)
        presetName = tostring(presetName or "")
        local soundId = NotificationSoundPresets[presetName]
        if not soundId then
            warn("[UAER_UI] Unknown notification sound: " .. presetName)
            return false
        end
        NotificationSoundPresetName = presetName
        NotificationSoundId = soundId
        if NotificationSoundEnabled then PlayNotificationSound() end
        return true
    end

    function window:SetNotificationSoundEnabled(enabled)
        NotificationSoundEnabled = enabled == true
    end

    function window:SetTheme(themeName)
        themeName = ResolveThemeName(themeName)
        local preset = Themes[themeName]
        if not preset then
            warn("[UAER_UI] Unknown theme: " .. tostring(themeName))
            return false
        end
        for key, value in pairs(preset) do Theme[key] = value end
        Theme.Name = themeName
        window.CurrentTheme = themeName

        for _, object in ipairs(Screen:GetDescendants()) do
            local bg = object:GetAttribute("UAER_BG")
            local txt = object:GetAttribute("UAER_TEXT")
            local placeholder = object:GetAttribute("UAER_PLACEHOLDER")
            local img = object:GetAttribute("UAER_IMAGE")
            local scroll = object:GetAttribute("UAER_SCROLL")
            local stroke = object:GetAttribute("UAER_STROKE")
            if bg and Theme[bg] then object.BackgroundColor3 = Theme[bg] end
            if txt and Theme[txt] then object.TextColor3 = Theme[txt] end
            if placeholder and Theme[placeholder] and object:IsA("TextBox") then object.PlaceholderColor3 = Theme[placeholder] end
            if img and Theme[img] then object.ImageColor3 = Theme[img] end
            if scroll and Theme[scroll] then object.ScrollBarImageColor3 = Theme[scroll] end
            if stroke and Theme[stroke] then object.Color = Theme[stroke] end
            if object:IsA("UIGradient") then
                local a, b = object:GetAttribute("UAER_GRADIENT_A"), object:GetAttribute("UAER_GRADIENT_B")
                if a and b and Theme[a] and Theme[b] then
                    object.Color = ColorSequence.new(Theme[a], Theme[b])
                end
            end
        end

        for _, tab in ipairs(self.Tabs) do
            local selected = tab == self.ActiveTab
            tab.NavText.TextColor3 = selected and Theme.Text or Theme.Muted
            tab.NavIcon.TextColor3 = selected and Theme.Accent or Theme.Muted
        end
        return true
    end

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local initialWidth = math.clamp(math.floor(viewport.X * 0.88), 320, 780)
    local initialHeight = math.clamp(math.floor(viewport.Y * 0.78), 360, 600)
    local requestedSize = UDim2.fromOffset(initialWidth, initialHeight)
    if typeof(config.Size) == "UDim2" then
        requestedSize = config.Size
    elseif type(config.Size) == "table" then
        requestedSize = UDim2.fromOffset(
            math.clamp(tonumber(config.Size.Width or config.Size.X) or initialWidth, 300, 920),
            math.clamp(tonumber(config.Size.Height or config.Size.Y) or initialHeight, 340, 680)
        )
    end
    Main = New("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = typeof(config.Position) == "UDim2" and config.Position or UDim2.fromScale(0.5, 0.5),
        Size = requestedSize,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = isTransparent and 0.16 or 0,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Visible = config.StartVisible ~= false,
    }, Screen)
    local MainCorner = Corner(Main, 16)
    Stroke(Main, Theme.Accent, 0.18, 1.2)
    Gradient(Main, Theme.Panel, Theme.Background, 35)
    local backgroundAsset = config.Background or config.BackgroundImage
    if backgroundAsset ~= nil and tostring(backgroundAsset) ~= "" then
        local imageId = tostring(backgroundAsset)
        if imageId:match("^%d+$") then imageId = "rbxassetid://" .. imageId end
        if imageId ~= "rbxassetid://YOUR_IMAGE_ID_HERE" then
            local backgroundImage = New("ImageLabel", {
                Name = "WindowBackgroundImage",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Image = imageId,
                ImageTransparency = math.clamp(tonumber(config.BackgroundTransparency) or (isTransparent and 0.45 or 0.68), 0, 1),
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = Main.ZIndex,
            }, Main)
            Corner(backgroundImage, 16)
            window.BackgroundImage = backgroundImage
        end
    end
    local minSize = config.MinSize or {}
    local maxSize = config.MaxSize or {}
    local WindowSizeConstraint = New("UISizeConstraint", {
        MinSize = Vector2.new(tonumber(minSize.Width or minSize.X) or 300, tonumber(minSize.Height or minSize.Y) or 340),
        MaxSize = Vector2.new(tonumber(maxSize.Width or maxSize.X) or 920, tonumber(maxSize.Height or maxSize.Y) or 680),
    }, Main)
    local MainScale = New("UIScale", { Scale = 1 }, Main)
    window.Main = Main
    window.MainScale = MainScale

    local Top = New("Frame", {
        Name = "Topbar",
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = isTransparent and 0.22 or 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
    }, Main)
    Corner(Top, 16)
    Gradient(Top, Theme.Card2, Theme.Panel, 0)
    -- Fill only the lower half of the rounded topbar. This keeps the upper
    -- corners visibly rounded while the bottom edge stays clean and straight.
    local TopbarBottomFill = New("Frame", {
        Name = "TopbarBottomFill",
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = isTransparent and 0.22 or 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 1, -22),
        ZIndex = Top.ZIndex,
    }, Top)
    Gradient(TopbarBottomFill, Theme.Card2, Theme.Panel, 0)
    local BrandMark = New("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(15, 13),
        Size = UDim2.fromOffset(28, 28),
    }, Top)
    Corner(BrandMark, 9)
    Gradient(BrandMark, Theme.Accent, Theme.Accent2, 45)
    local MarkText = MakeLabel(BrandMark, ResolveIcon(config.Icon, "U"), 16, Color3.new(1, 1, 1), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    MarkText.Size = UDim2.fromScale(1, 1)

    local Brand = MakeLabel(Top, config.Title or "UAER_UI", 15, Theme.Text, Enum.Font.GothamBold)
    Brand.Position = UDim2.fromOffset(53, 7)
    Brand.Size = UDim2.new(0, 150, 0, 22)
    local subtitleText = config.Subtitle or config.Author or (config.Credit and ("BY " .. string.upper(tostring(config.Credit)))) or "CUSTOM INTERFACE LIBRARY"
    local Subtitle = MakeLabel(Top, subtitleText, 8, Theme.Muted, Enum.Font.GothamBold)
    Subtitle.Position = UDim2.fromOffset(54, 29)
    Subtitle.Size = UDim2.new(0, 190, 0, 13)
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

    local Version = MakeLabel(Top, "v" .. Library.Version .. "  •  " .. string.upper(tostring(config.Badge or "PUBLIC BETA")), 9, Theme.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    Version.AnchorPoint = Vector2.new(1, 0.5)
    Version.Position = UDim2.new(1, -76, 0.5, 0)
    Version.Size = UDim2.new(0, 150, 0, 20)

    local Minimize = MakeButton(Top, "—", UDim2.fromOffset(27, 25), false)
    Minimize.AnchorPoint = Vector2.new(1, 0.5)
    Minimize.Position = UDim2.new(1, -39, 0.5, 0)
    Minimize.TextSize = 14
    local Close = MakeButton(Top, "×", UDim2.fromOffset(27, 25), false)
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.TextSize = 17

    local Body = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(1, 0, 1, -54),
    }, Main)

    -- The resize corner and the bottom move bar are CHILDREN of Main (Main has
    -- ClipsDescendants = false), so they sit OUTSIDE the window while being
    -- locked to its edges with UDim2 scale. They follow dragging, resizing and
    -- UIScale automatically, so no manual position syncing is needed.

    -- Resize corner: a thin quarter-circle arc that hugs the window's rounded
    -- bottom-right corner from the outside. ArcClip shows only the bottom-right
    -- quarter of a ring whose center is the center of Main's corner curve.
    local ArcClip = New("Frame", {
        Name = "ResizeArcClip",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = false,
        ZIndex = 149,
    }, Main)
    local ArcRing = New("Frame", {
        Name = "ResizeArcRing",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 149,
    }, ArcClip)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, ArcRing)
    local ArcStroke = New("UIStroke", {
        Color = Theme.Muted,
        Thickness = 3,
        Transparency = 0.1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, ArcRing)
    ArcStroke:SetAttribute("UAER_KEEP_STROKE", true) -- SetDesign must not thin this stroke
    -- Fade both ends of the arc so it blends away along the window edges.
    local ArcFade = New("UIGradient", {
        Rotation = 135,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0.9),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(0.75, 0.9),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, ArcStroke)
    ArcFade:SetAttribute("UAER_KEEP_GRADIENT", true)

    -- Invisible touch target for the arc, placed just outside the corner.
    local ResizeGrip = New("TextButton", {
        Name = "ResizeCornerHandle",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 8, 1, 8),
        Size = UDim2.fromOffset(44, 44),
        Text = "",
        ZIndex = 150,
    }, Main)

    -- Keep the arc concentric with the window's corner, even when SetDesign
    -- changes the corner radius.
    local ARC_GAP = 7
    local function updateArc()
        local radius = MainCorner.CornerRadius.Offset
        local inner = radius + ARC_GAP
        ArcClip.Position = UDim2.new(1, -radius, 1, -radius)
        ArcClip.Size = UDim2.fromOffset(inner + 6, inner + 6)
        ArcRing.Position = UDim2.fromOffset(-inner, -inner)
        ArcRing.Size = UDim2.fromOffset(inner * 2, inner * 2)
    end
    updateArc()
    MainCorner:GetPropertyChangedSignal("CornerRadius"):Connect(updateArc)

    local function setGripActive(active)
        Tween(ArcStroke, 0.12, { Color = active and Theme.Accent or Theme.Muted })
    end

    -- Move bar: exactly 50% of the window width, just below the bottom edge.
    local BottomDragHandle = New("TextButton", {
        Name = "BottomDragHandle",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 1, 11), -- centered, 11 below the bottom edge
        Size = UDim2.fromOffset(200, 22),
        Text = "",
        ZIndex = 150,
    }, Main)
    local BottomDragLine = New("Frame", {
        Name = "BottomDragLine",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(160, 4),
        BackgroundColor3 = Theme.Muted,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 151,
    }, BottomDragHandle)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, BottomDragLine)
    BottomDragLine:SetAttribute("UAER_BG", "Muted")

    -- Kept as a harmless stub: older code paths still call it, but the handles
    -- are parented to Main now, so there is nothing to sync.
    local function syncAuxiliaryHandles() end

    window.ResizeGrip = ResizeGrip
    window.ResizeArc = ArcRing
    window.BottomDragHandle = BottomDragHandle
    window.BottomDragLine = BottomDragLine
    if config.Resizable == false then
        ResizeGrip.Visible = false
        ArcClip.Visible = false
    end
    if config.BottomDragHandle == false then
        BottomDragHandle.Visible = false
    end

    local Sidebar = New("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = isTransparent and 0.25 or 0.12,
        BorderSizePixel = 0,
        Size = UDim2.new(0, configuredSidebarWidth, 1, 0),
    }, Body)
    Corner(Sidebar, 14)
    local SidebarPadding = AddPadding(Sidebar, 10, 10, 14, 12)
    -- Persistent search field sits above Home and the rest of the tab list.
    local SearchContainer = New("Frame", {
        Name = "SearchContainer",
        BackgroundColor3 = Theme.Card2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 20,
    }, Sidebar)
    SearchContainer.Visible = showSearchBar
    Corner(SearchContainer, 12)
    local SearchStroke = Stroke(SearchContainer, Theme.Line, 0.48, 1)
    SearchContainer:SetAttribute("UAER_BG", "Card2")

    local SearchIcon = MakeLabel(SearchContainer, "🔎", 13, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    SearchIcon.Position = UDim2.fromOffset(4, 0)
    SearchIcon.Size = UDim2.fromOffset(23, 36)
    SearchIcon.ZIndex = 21

    local SearchBox = New("TextBox", {
        Name = "LibrarySearch",
        ClearTextOnFocus = false,
        PlaceholderText = tostring(config.SearchPlaceholder or "Search..."),
        Text = "",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -54, 1, 0),
        ZIndex = 21,
    }, SearchContainer)

    local SearchClear = New("TextButton", {
        Name = "SearchClear",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.Muted,
        TextSize = 17,
        Font = Enum.Font.GothamMedium,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(20, 24),
        Visible = false,
        ZIndex = 22,
    }, SearchContainer)
    SearchClear.Activated:Connect(function()
        SearchBox.Text = ""
        SearchBox:CaptureFocus()
    end)

    SearchBox.Focused:Connect(function()
        Tween(SearchStroke, 0.14, { Color = Theme.Accent, Transparency = 0.12, Thickness = 1.35 })
        Tween(SearchContainer, 0.14, { BackgroundColor3 = Theme.Card })
    end)
    SearchBox.FocusLost:Connect(function()
        Tween(SearchStroke, 0.14, { Color = Theme.Line, Transparency = 0.48, Thickness = 1 })
        Tween(SearchContainer, 0.14, { BackgroundColor3 = Theme.Card2 })
    end)

    local navTop = not showSearchBar and 8 or 44
    local NavList = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, navTop),
        Size = UDim2.new(1, 0, 1, -(navTop + 52)),
    }, Sidebar)
    local NavLayout = New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, NavList)

    local Profile = New("TextButton", {
        Name = "PlayerProfileButton",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 40),
    }, Sidebar)
    Profile.Visible = showUserProfile
    if not showUserProfile then
        NavList.Size = UDim2.new(1, 0, 1, -(navTop + 16))
    end
    Corner(Profile, 9)
    Stroke(Profile, Theme.Line, 0.62, 1)
    local Avatar = New("Frame", { BackgroundColor3 = Theme.Accent2, Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(26, 26), BorderSizePixel = 0 }, Profile)
    Corner(Avatar, 8)
    local AvatarImage = New("ImageLabel", {
        Name = "RobloxHeadshot", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        Image = "", ScaleType = Enum.ScaleType.Crop,
    }, Avatar)
    Corner(AvatarImage, 8)
    local AvatarText = MakeLabel(Avatar, "...", 10, Theme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    AvatarText.Size = UDim2.fromScale(1, 1)
    local isAnonymousUser = userConfig.Anonymous == true
    local UserLabel = MakeLabel(Profile, isAnonymousUser and "Anonymous" or Player.Name, 10, Theme.Text, Enum.Font.GothamBold)
    UserLabel.Position = UDim2.fromOffset(40, 4)
    UserLabel.Size = UDim2.new(1, -46, 0, 16)
    UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
    local UserSub = MakeLabel(Profile, isAnonymousUser and "Profile hidden" or Player.DisplayName, 8, Theme.Muted, Enum.Font.GothamMedium)
    UserSub.Position = UDim2.fromOffset(40, 20)
    UserSub.Size = UDim2.new(1, -46, 0, 12)
    UserSub.TextTruncate = Enum.TextTruncate.AtEnd

    -- Fetch the local player's official Roblox headshot for the sidebar profile.
    task.spawn(function()
        local ok, imageUrl = pcall(function()
            return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and AvatarImage and AvatarImage.Parent then
            AvatarImage.Image = imageUrl
            AvatarText.Visible = false
        else
            AvatarText.Text = string.sub(Player.Name, 1, 1):upper()
        end
    end)

    -- The profile card opens a details panel. All fields are read from Roblox's
    -- normal client APIs; executor identity is not exposed to a standard LocalScript.
    local ProfileModal
    local function getPlatformLabel()
        local tenFoot = false
        pcall(function() tenFoot = GuiService:IsTenFootInterface() end)
        if tenFoot then return "Console" end
        local preferred = UIS.PreferredInput
        if preferred == Enum.PreferredInput.Touch or (UIS.TouchEnabled and not UIS.KeyboardEnabled) then
            return "Mobile / Touch"
        elseif preferred == Enum.PreferredInput.Gamepad then
            return "Controller / Console"
        elseif preferred == Enum.PreferredInput.KeyboardAndMouse or UIS.KeyboardEnabled then
            return "PC / Keyboard & Mouse"
        elseif UIS.GamepadEnabled then
            return "Controller"
        end
        return "Unknown"
    end

    local function countRobloxFriends()
        local pages = Players:GetFriendsAsync(Player.UserId)
        local total = 0
        while true do
            total += #pages:GetCurrentPage()
            if pages.IsFinished then break end
            pages:AdvanceToNextPageAsync()
        end
        return total
    end

    local function openPlayerProfile()
        if ProfileModal and ProfileModal.Parent then ProfileModal:Destroy() end
        local overlay = New("Frame", {
            Name = "PlayerProfileOverlay", BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.42, BorderSizePixel = 0, Active = true,
            Size = UDim2.fromScale(1, 1), ZIndex = 120,
        }, Screen)
        ProfileModal = overlay
        local modal = New("Frame", {
            Name = "PlayerProfileDialog", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(340, 332),
            BackgroundColor3 = Theme.Card, BorderSizePixel = 0, ZIndex = 121,
        }, overlay)
        New("UISizeConstraint", { MinSize = Vector2.new(278, 332), MaxSize = Vector2.new(390, 332) }, modal)
        Corner(modal, 17)
        Stroke(modal, Theme.Accent, 0.18, 1.4)
        Gradient(modal, Theme.Card, Theme.Panel, 18)

        local heading = MakeLabel(modal, "ROBLOX PLAYER PROFILE", 13, Theme.Text, Enum.Font.GothamBold)
        heading.Position = UDim2.fromOffset(16, 11)
        heading.Size = UDim2.new(1, -62, 0, 23)
        heading.ZIndex = 123
        local close = MakeButton(modal, "×", UDim2.fromOffset(28, 27), false)
        close.Position = UDim2.new(1, -40, 0, 9)
        close.ZIndex = 124
        close.TextSize = 17
        close.Activated:Connect(function()
            if overlay and overlay.Parent then overlay:Destroy() end
            if ProfileModal == overlay then ProfileModal = nil end
        end)

        local headshot = New("ImageLabel", {
            Name = "ProfileHeadshot", BackgroundColor3 = Theme.Card2, BorderSizePixel = 0,
            Position = UDim2.fromOffset(17, 44), Size = UDim2.fromOffset(58, 58),
            Image = AvatarImage.Image, ScaleType = Enum.ScaleType.Crop, ZIndex = 123,
        }, modal)
        Corner(headshot, 11)
        local display = MakeLabel(modal, Player.DisplayName, 13, Theme.Text, Enum.Font.GothamBold)
        display.Position = UDim2.fromOffset(87, 49)
        display.Size = UDim2.new(1, -104, 0, 22)
        display.TextTruncate = Enum.TextTruncate.AtEnd
        display.ZIndex = 123
        local username = MakeLabel(modal, "@" .. Player.Name, 10, Theme.Muted, Enum.Font.GothamMedium)
        username.Position = UDim2.fromOffset(87, 73)
        username.Size = UDim2.new(1, -104, 0, 18)
        username.TextTruncate = Enum.TextTruncate.AtEnd
        username.ZIndex = 123

        local separator = New("Frame", {
            BackgroundColor3 = Theme.Line, BackgroundTransparency = 0.35, BorderSizePixel = 0,
            Position = UDim2.fromOffset(16, 112), Size = UDim2.new(1, -32, 0, 1), ZIndex = 123,
        }, modal)

        local function infoRow(labelText, valueText, y)
            local row = New("Frame", {
                BackgroundTransparency = 1, Position = UDim2.fromOffset(16, y),
                Size = UDim2.new(1, -32, 0, 25), ZIndex = 123,
            }, modal)
            local label = MakeLabel(row, labelText, 10, Theme.Muted, Enum.Font.GothamMedium)
            label.Size = UDim2.new(0.43, 0, 1, 0)
            label.ZIndex = 124
            local value = MakeLabel(row, tostring(valueText), 10, Theme.Text, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right)
            value.Position = UDim2.new(0.43, 0, 0, 0)
            value.Size = UDim2.new(0.57, 0, 1, 0)
            value.TextTruncate = Enum.TextTruncate.AtEnd
            value.ZIndex = 124
            return value
        end

        infoRow("Username", Player.Name, 120)
        infoRow("Display name", Player.DisplayName, 148)
        infoRow("Account age", tostring(Player.AccountAge) .. " days", 176)
        infoRow("Platform", getPlatformLabel(), 204)
        infoRow("Executor", RunService:IsStudio() and "Roblox Studio" or "Not exposed to LocalScripts", 232)
        local friendsValue = infoRow("Total friends", "Loading...", 260)
        local note = MakeLabel(modal, "Executor names are not available to standard Roblox LocalScripts.", 8, Theme.Muted, Enum.Font.Gotham)
        note.Position = UDim2.fromOffset(16, 299)
        note.Size = UDim2.new(1, -32, 0, 18)
        note.TextWrapped = true
        note.ZIndex = 123

        task.spawn(function()
            local ok, result = pcall(countRobloxFriends)
            if friendsValue and friendsValue.Parent then
                friendsValue.Text = ok and tostring(result) or "Unavailable"
            end
        end)
    end
    Profile.Activated:Connect(function()
        if type(userConfig.Callback) == "function" then
            SafeCallback(userConfig.Callback, Player)
        elseif not isAnonymousUser then
            openPlayerProfile()
        end
    end)

    local Content = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, configuredSidebarWidth, 0, 0),
        Size = UDim2.new(1, -configuredSidebarWidth, 1, 0),
    }, Body)
    window.Content = Content

    local SearchEmpty = New("Frame", {
        Name = "SearchEmptyState",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 20,
    }, Content)
    local SearchEmptyIcon = MakeLabel(SearchEmpty, "🔎", 34, Theme.Muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    SearchEmptyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchEmptyIcon.Position = UDim2.new(0.5, 0, 0.5, -24)
    SearchEmptyIcon.Size = UDim2.fromOffset(80, 52)
    SearchEmptyIcon.ZIndex = 21
    local SearchEmptyTitle = MakeLabel(SearchEmpty, "No results found", 15, Theme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    SearchEmptyTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchEmptyTitle.Position = UDim2.new(0.5, 0, 0.5, 18)
    SearchEmptyTitle.Size = UDim2.new(1, -30, 0, 24)
    SearchEmptyTitle.ZIndex = 21
    local SearchEmptyHint = MakeLabel(SearchEmpty, "Try a different search term", 10, Theme.Muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    SearchEmptyHint.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchEmptyHint.Position = UDim2.new(0.5, 0, 0.5, 42)
    SearchEmptyHint.Size = UDim2.new(1, -30, 0, 20)
    SearchEmptyHint.ZIndex = 21

    local Floating = MakeButton(Screen, tostring(config.OpenButtonText or "U"), UDim2.fromOffset(48, 48), true)
    Floating.Name = "OpenButton"
    Floating.AnchorPoint = Vector2.new(1, 1)
    Floating.Position = UDim2.new(1, -18, 1, -18)
    Floating.Visible = config.StartVisible == false and config.ShowOpenButton ~= false
    Floating.TextSize = 18
    Floating.ZIndex = 20
    local floatingCorner = Floating:FindFirstChildOfClass("UICorner")
    if floatingCorner then
        floatingCorner.CornerRadius = UDim.new(1, 0)
        floatingCorner:SetAttribute("UAER_CORNER_KIND", "Circle")
    end
    Stroke(Floating, Theme.Accent, 0.12, 1.5)

    NoticeHolder = New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(250, 220),
        ZIndex = 50,
    }, Screen)
    New("UIListLayout", { Padding = UDim.new(0, 7), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom, SortOrder = Enum.SortOrder.LayoutOrder }, NoticeHolder)
    local WindowNoticeHolder = NoticeHolder
    ActiveWindow = window
    window.Screen = Screen
    window.Main = Main
    window.MainScale = MainScale
    window.Destroyed = false

    local function setVisible(value)
        value = value == true
        if value == Main.Visible then return end
        if value then
            Floating.Visible = false
            Main.Visible = true
            MainScale.Scale = 0.94
            local veil = New("Frame", {
                Name = "OpenTransition",
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.20,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 70,
            }, Main)
            local stamp = MakeLabel(veil, "✦  UAER_UI", 13, Theme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            stamp.Size = UDim2.fromScale(1, 1)
            stamp.ZIndex = 71
            Tween(MainScale, 0.25, { Scale = 1 })
            local fade = Tween(veil, 0.22, { BackgroundTransparency = 1 })
            fade.Completed:Connect(function()
                if veil and veil.Parent then veil:Destroy() end
            end)
        else
            local veil = New("Frame", {
                Name = "CloseTransition",
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 70,
            }, Main)
            Tween(veil, 0.16, { BackgroundTransparency = 0.16 })
            local shrink = Tween(MainScale, 0.20, { Scale = 0.95 })
            shrink.Completed:Connect(function()
                if Main and Main.Parent then
                    Main.Visible = false
                    MainScale.Scale = 1
                    Floating.Visible = config.ShowOpenButton ~= false
                    if veil and veil.Parent then veil:Destroy() end
                end
            end)
        end
    end

    -- Live resize handle: mouse and touch. The window is center-anchored, so the
    -- position is shifted by half the size change to keep the top-left corner
    -- fixed and make the bottom-right corner follow the finger exactly.
    local resizing, resizeInputStart, resizeStartSize, resizeStartPos = false, nil, nil, nil
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeInputStart = input.Position
            resizeStartSize = Main.AbsoluteSize / MainScale.Scale
            resizeStartPos = Main.Position
            setGripActive(true)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    setGripActive(false)
                end
            end)
        end
    end)
    TrackConnection(UIS.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeInputStart
            local currentCamera = workspace.CurrentCamera
            local currentViewport = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
            local maxWidth = math.max(300, math.min(920, currentViewport.X - 16))
            -- leave room below the window for the outside move bar
            local maxHeight = math.max(340, math.min(680, currentViewport.Y - 96))
            local minWidth = WindowSizeConstraint.MinSize.X
            local minHeight = WindowSizeConstraint.MinSize.Y
            local maxWidth = math.min(WindowSizeConstraint.MaxSize.X, maxWidth)
            local maxHeight = math.min(WindowSizeConstraint.MaxSize.Y, maxHeight)
            local width = math.clamp(resizeStartSize.X + delta.X, minWidth, math.max(minWidth, maxWidth))
            local height = math.clamp(resizeStartSize.Y + delta.Y, minHeight, math.max(minHeight, maxHeight))
            Main.Size = UDim2.fromOffset(width, height)
            Main.Position = UDim2.new(
                resizeStartPos.X.Scale,
                resizeStartPos.X.Offset + (width - resizeStartSize.X) / 2,
                resizeStartPos.Y.Scale,
                resizeStartPos.Y.Offset + (height - resizeStartSize.Y) / 2
            )
            updateResponsive()
        end
    end))
    TrackConnection(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if resizing then setGripActive(false) end
            resizing = false
        end
    end))
    function window:SetSize(width, height)
        local currentCamera = workspace.CurrentCamera
        local currentViewport = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
        local minWidth = WindowSizeConstraint.MinSize.X
        local minHeight = WindowSizeConstraint.MinSize.Y
        local maxWidth = math.min(WindowSizeConstraint.MaxSize.X, math.max(minWidth, currentViewport.X - 16))
        local maxHeight = math.min(WindowSizeConstraint.MaxSize.Y, math.max(minHeight, currentViewport.Y - 96))
        Main.Size = UDim2.fromOffset(
            math.clamp(tonumber(width) or Main.AbsoluteSize.X, minWidth, math.max(minWidth, maxWidth)),
            math.clamp(tonumber(height) or Main.AbsoluteSize.Y, minHeight, math.max(minHeight, maxHeight))
        )
        updateResponsive()
        syncAuxiliaryHandles()
    end

    -- Live search filters the real controls in-place across every tab.
    -- Matching controls remain fully interactive; non-matches are hidden.
    local SearchEntries = {}
    local SearchQuery = ""

    local function NormalizeSearch(value)
        local normalized = string.lower(tostring(value or ""))
        normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")
        return normalized:gsub("%s+", " ")
    end

    local function EntryMatches(entry, query)
        if query == "" then return true end
        local tabName = NormalizeSearch(entry.Tab and entry.Tab.Name)
        local sectionName = NormalizeSearch(entry.SectionTitle)
        local sectionDescription = NormalizeSearch(entry.SectionDescription)
        if string.find(tabName, query, 1, true)
            or string.find(sectionName, query, 1, true)
            or string.find(sectionDescription, query, 1, true) then
            return true
        end

        local searchable = { entry.Name or "" }
        local row = entry.Row
        if row then
            if row:IsA("TextLabel") or row:IsA("TextButton") or row:IsA("TextBox") then
                table.insert(searchable, row.Text or "")
            end
            for _, descendant in ipairs(row:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                    table.insert(searchable, descendant.Text or "")
                    if descendant:IsA("TextBox") then
                        table.insert(searchable, descendant.PlaceholderText or "")
                    end
                end
            end
        end
        local haystack = NormalizeSearch(table.concat(searchable, " "))
        return string.find(haystack, query, 1, true) ~= nil
    end

    local function ApplySearch(rawQuery)
        local query = NormalizeSearch(rawQuery)
        SearchQuery = query
        SearchClear.Visible = query ~= ""
        local tabCounts = {}
        local cardCounts = {}
        local totalMatches = 0

        for _, entry in ipairs(SearchEntries) do
            local matches = EntryMatches(entry, query)
            if entry.Row and entry.Row.Parent then
                if query == "" then
                    entry.Row.Visible = entry.OriginalVisible
                else
                    entry.Row.Visible = matches
                end
            end
            if matches then
                tabCounts[entry.Tab] = (tabCounts[entry.Tab] or 0) + 1
                if entry.Card then cardCounts[entry.Card] = (cardCounts[entry.Card] or 0) + 1 end
                totalMatches += 1
            end
        end

        for _, tab in ipairs(window.Tabs) do
            local count = tabCounts[tab] or 0
            tab.Nav.Visible = query == "" or count > 0
            for _, sectionCard in ipairs(tab.SearchSections or {}) do
                if sectionCard.Card and sectionCard.Card.Parent then
                    sectionCard.Card.Visible = query == "" or (cardCounts[sectionCard.Card] or 0) > 0
                end
            end
            tab.SearchMatchCount = count
        end

        if query == "" then
            SearchEmpty.Visible = false
            local active = window.ActiveTab
            if not active or not active.Page or not active.Page.Parent then active = window.Tabs[1] end
            if active then active:Show() end
            return
        end

        if totalMatches == 0 then
            for _, tab in ipairs(window.Tabs) do tab.Page.Visible = false end
            SearchEmpty.Visible = true
            SearchEmptyTitle.Text = "No results found"
            SearchEmptyHint.Text = "No matches for  “" .. tostring(rawQuery or "") .. "”"
            return
        end

        SearchEmpty.Visible = false
        local active = window.ActiveTab
        if not active or (tabCounts[active] or 0) == 0 then
            for _, tab in ipairs(window.Tabs) do
                if (tabCounts[tab] or 0) > 0 then active = tab break end
            end
        end
        if active then active:Show() end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        ApplySearch(SearchBox.Text)
    end)

    Minimize.Activated:Connect(function() setVisible(false) end)
    Floating.Activated:Connect(function()
        if Floating:GetAttribute("UAER_WasDragged") then
            Floating:SetAttribute("UAER_WasDragged", false)
            return
        end
        setVisible(true)
    end)
    Close.Activated:Connect(function() window:Destroy() end)

    -- Main window drag (mouse + touch).
    if config.Draggable ~= false then
    local dragging, dragStart, startPosition
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TrackConnection(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            syncAuxiliaryHandles()
        end
    end))

    -- The bottom-center underline is a second move handle (mouse + touch).
    local bottomDragging, bottomDragStart, bottomStartPosition = false, nil, nil
    BottomDragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bottomDragging = true
            bottomDragStart = input.Position
            bottomStartPosition = Main.Position
        end
    end)
    TrackConnection(UIS.InputChanged:Connect(function(input)
        if bottomDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - bottomDragStart
            Main.Position = UDim2.new(
                bottomStartPosition.X.Scale,
                bottomStartPosition.X.Offset + delta.X,
                bottomStartPosition.Y.Scale,
                bottomStartPosition.Y.Offset + delta.Y
            )
            syncAuxiliaryHandles()
        end
    end))
    TrackConnection(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bottomDragging = false
        end
    end))
    else
        BottomDragHandle.Visible = false
    end

    -- The hidden-state launcher is a draggable circle; drag it on desktop or mobile.
    local floatingDragging, floatingMoved = false, false
    local floatingStart, floatingOrigin
    Floating.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatingDragging = true
            floatingMoved = false
            floatingStart = input.Position
            floatingOrigin = Floating.Position
        end
    end)
    TrackConnection(UIS.InputChanged:Connect(function(input)
        if floatingDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatingStart
            if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then floatingMoved = true end
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
            local size = Floating.AbsoluteSize
            local x = math.clamp(floatingOrigin.X.Offset + delta.X, size.X + 8 - viewport.X, -8)
            local y = math.clamp(floatingOrigin.Y.Offset + delta.Y, size.Y + 8 - viewport.Y, -8)
            Floating.Position = UDim2.new(1, x, 1, y)
        end
    end))
    TrackConnection(UIS.InputEnded:Connect(function(input)
        if floatingDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            floatingDragging = false
            if floatingMoved then
                Floating:SetAttribute("UAER_WasDragged", true)
                task.delay(0.18, function()
                    if Floating and Floating.Parent then Floating:SetAttribute("UAER_WasDragged", false) end
                end)
            end
        end
    end))
    TrackConnection(UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            setVisible(not Main.Visible)
        end
    end))

    updateResponsive = function()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local width = Main.AbsoluteSize.X
        local viewportWidth = camera.ViewportSize.X
        local sidebarWidth = math.clamp(tonumber(config.SideBarWidth) or (width < 560 and 112 or 145), 96, 250)
        Sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
        Content.Position = UDim2.new(0, sidebarWidth, 0, 0)
        Content.Size = UDim2.new(1, -sidebarWidth, 1, 0)
        SearchContainer.Size = UDim2.new(1, 0, 0, 36)
        SearchBox.Size = UDim2.new(1, -54, 1, 0)
        SearchIcon.Size = UDim2.fromOffset(23, 36)
        SearchClear.Position = UDim2.new(1, -5, 0.5, 0)
        syncAuxiliaryHandles()
        if viewportWidth < 560 or width < 500 then
            Version.Visible = false
            Subtitle.Visible = false
            Brand.Position = UDim2.fromOffset(53, 15)
            Brand.Size = UDim2.new(0, 105, 0, 22)
        else
            Version.Visible = true
            Subtitle.Visible = true
            Brand.Position = UDim2.fromOffset(53, 7)
            Brand.Size = UDim2.new(0, 190, 0, 22)
        end
    end
    updateResponsive()
    if workspace.CurrentCamera then
        TrackConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive))
    end

    --// Tab + component API ---------------------------------------------------
    function window:Tab(name, icon)
        if type(name) == "table" then
            local tabConfig = name
            name = tabConfig.Title or tabConfig.Name or "Tab"
            icon = tabConfig.Icon or tabConfig.IconId or icon
        end
        name = tostring(name or "Tab")
        local tab = { Name = name, Sections = {}, SearchSections = {} }
        local nav = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Accent2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 34),
            Text = "",
        }, NavList)
        Corner(nav, 8)
        local navIcon = MakeLabel(nav, ResolveIcon(icon, "◈"), 13, Theme.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        navIcon.Position = UDim2.fromOffset(3, 0)
        navIcon.Size = UDim2.fromOffset(27, 34)
        local navText = MakeLabel(nav, name, 11, Theme.Muted, Enum.Font.GothamSemibold)
        navText.Position = UDim2.fromOffset(34, 0)
        navText.Size = UDim2.new(1, -38, 1, 0)

        local Page = New("ScrollingFrame", {
            Name = name .. "Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = scrollbarsEnabled and 3 or 0,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
        }, Content)
        AddPadding(Page, 14, 14, 15, 16)
        local PageLayout = New("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, Page)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 32)
        end)
        local function RegisterSearch(row, controlName)
            if row and controlName and tostring(controlName) ~= "" then
                local card = row:FindFirstAncestor("SectionCard")
                local sectionTitle = card and card:GetAttribute("SearchSectionTitle") or ""
                local sectionDescription = card and card:GetAttribute("SearchSectionDescription") or ""
                table.insert(SearchEntries, {
                    Name = tostring(controlName),
                    Row = row,
                    Tab = tab,
                    Card = card,
                    SectionTitle = sectionTitle,
                    SectionDescription = sectionDescription,
                    OriginalVisible = row.Visible,
                })
                if SearchQuery ~= "" then ApplySearch(SearchQuery) end
            end
        end

        function tab:Show()
            if SearchQuery ~= "" and (tab.SearchMatchCount or 0) <= 0 then return end
            SearchEmpty.Visible = false
            for _, other in ipairs(window.Tabs) do
                other.Page.Visible = false
                Tween(other.Nav, 0.12, { BackgroundTransparency = 1 })
                other.NavText.TextColor3 = Theme.Muted
                other.NavIcon.TextColor3 = Theme.Muted
            end
            Page.Visible = true
            Tween(nav, 0.12, { BackgroundTransparency = 0.12 })
            navText.TextColor3 = Theme.Text
            navIcon.TextColor3 = Theme.Accent
            window.ActiveTab = tab
        end

        function tab:Section(title, description)
            if type(title) == "table" then
                local sectionConfig = title
                title = sectionConfig.Title or sectionConfig.Name or "Section"
                description = sectionConfig.Description or sectionConfig.Desc or description
            end
            local section = {}
            local Card = New("Frame", {
                Name = "SectionCard",
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, Page)
            Card:SetAttribute("SearchSectionTitle", tostring(title or "Section"))
            Card:SetAttribute("SearchSectionDescription", tostring(description or ""))
            table.insert(tab.SearchSections, { Card = Card })
            Corner(Card, 12)
            Stroke(Card, Theme.Line, 0.55, 1)
            AddPadding(Card, 12, 12, 10, 12)
            local Header = MakeLabel(Card, title or "Section", 12, Theme.Text, Enum.Font.GothamBold)
            Header.Size = UDim2.new(1, 0, 0, 22)
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 28),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, Card)
            local HolderLayout = New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, Holder)
            HolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Holder.Size = UDim2.new(1, 0, 0, HolderLayout.AbsoluteContentSize.Y)
            end)
            if description then
                local desc = MakeLabel(Card, description, 10, Theme.Muted)
                desc.Position = UDim2.fromOffset(0, 27)
                desc.Size = UDim2.new(1, 0, 0, 20)
                Holder.Position = UDim2.fromOffset(0, 51)
            end

            function section:Label(text)
                if type(text) == "table" then text = text.Title or text.Text or text.Name end
                local label = MakeLabel(Holder, text, 11, Theme.Muted)
                label.Size = UDim2.new(1, 0, 0, 23)
                RegisterSearch(label, text or "Label")
                return label
            end

            function section:Paragraph(titleText, bodyText)
                if type(titleText) == "table" then
                    local paragraphConfig = titleText
                    titleText = paragraphConfig.Title or paragraphConfig.Name or "Information"
                    bodyText = paragraphConfig.Content or paragraphConfig.Description or paragraphConfig.Text or bodyText
                end
                local frame = New("Frame", { BackgroundColor3 = Theme.Card2, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, Holder)
                Corner(frame, 9)
                AddPadding(frame, 10, 10, 7, 8)
                local head = MakeLabel(frame, titleText or "Paragraph", 11, Theme.Text, Enum.Font.GothamBold)
                head.Size = UDim2.new(1, 0, 0, 18)
                local body = MakeLabel(frame, bodyText or "Add information here.", 10, Theme.Muted)
                body.Position = UDim2.fromOffset(0, 19)
                body.Size = UDim2.new(1, 0, 0, 0)
                body.AutomaticSize = Enum.AutomaticSize.Y
                body.TextWrapped = true
                body.TextYAlignment = Enum.TextYAlignment.Top
                RegisterSearch(frame, titleText or "Paragraph")
                return frame
            end

            function section:Divider(text)
                if type(text) == "table" then text = text.Title or text.Text end
                local wrap = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) }, Holder)
                local line = New("Frame", { BackgroundColor3 = Theme.Line, BackgroundTransparency = 0.35, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1) }, wrap)
                if text then
                    local chip = MakeLabel(wrap, text, 8, Theme.Muted, Enum.Font.GothamBold)
                    chip.BackgroundColor3 = Theme.Card
                    chip:SetAttribute("UAER_BG", "Card")
                    chip.Size = UDim2.fromOffset(70, 16)
                    chip.Position = UDim2.fromOffset(8, 2)
                    chip.TextXAlignment = Enum.TextXAlignment.Center
                end
                RegisterSearch(wrap, text or "Divider")
                return wrap
            end

            function section:Button(text, callback)
                if type(text) == "table" then
                    local buttonConfig = text
                    text = buttonConfig.Title or buttonConfig.Name or "Button"
                    callback = buttonConfig.Callback or buttonConfig.Function or callback
                end
                local button = MakeButton(Holder, text or "Button", UDim2.new(1, 0, 0, 34), true)
                button.Activated:Connect(function()
                    if callback then SafeCallback(callback) else Notify("Button pressed", text or "Button", "success") end
                end)
                function button:SetText(value) button.Text = tostring(value or "") end
                RegisterSearch(button, text or "Button")
                return button
            end

            function section:Toggle(text, default, callback)
                if type(text) == "table" then
                    local toggleConfig = text
                    text = toggleConfig.Title or toggleConfig.Name or "Toggle"
                    default = toggleConfig.Default
                    if default == nil then default = toggleConfig.Value end
                    callback = toggleConfig.Callback or toggleConfig.Function or callback
                end
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32) }, Holder)
                local label = MakeLabel(row, text or "Toggle", 11, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(1, -60, 1, 0)
                local pill = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = default and Theme.Accent or Theme.Line, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 22) }, row)
                Corner(pill, 20)
                local knob = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromOffset(16, 16), Position = default and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3) }, pill)
                Corner(knob, 20)
                local state = default == true
                local control = { Value = state }
                local function set(value)
                    state = value == true
                    control.Value = state
                    pill:SetAttribute("UAER_BG", state and "Accent" or "Line")
                    Tween(pill, 0.14, { BackgroundColor3 = state and Theme.Accent or Theme.Line })
                    Tween(knob, 0.14, { Position = state and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3) })
                    SafeCallback(callback, state)
                end
                pill.Activated:Connect(function() set(not state) end)
                function control:Set(value, silent) 
                    if silent then
                        local oldCallback = callback
                        callback = nil
                        set(value)
                        callback = oldCallback
                    else
                        set(value)
                    end
                end
                function control:Get() return state end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(row, text or "Toggle")
                return control
            end

            function section:Slider(text, minimum, maximum, default, callback)
                local step = 1
                if type(text) == "table" then
                    local sliderConfig = text
                    text = sliderConfig.Title or sliderConfig.Name or "Slider"
                    minimum = sliderConfig.Min or sliderConfig.Minimum or 0
                    maximum = sliderConfig.Max or sliderConfig.Maximum or 100
                    default = sliderConfig.Default or sliderConfig.Value or minimum
                    local decimals = tonumber(sliderConfig.Decimals)
                    step = tonumber(sliderConfig.Step) or (decimals and (10 ^ -math.clamp(decimals, 0, 6))) or 1
                    callback = sliderConfig.Callback or sliderConfig.Function or callback
                end
                minimum, maximum = tonumber(minimum) or 0, tonumber(maximum) or 100
                if maximum < minimum then minimum, maximum = maximum, minimum end
                step = math.max(0.000001, math.abs(step))
                local function quantize(raw)
                    local stepped = minimum + math.floor(((raw - minimum) / step) + 0.5) * step
                    local rounded = math.floor(stepped * 10000 + 0.5) / 10000
                    return math.clamp(rounded, minimum, maximum)
                end
                local value = quantize(tonumber(default) or minimum)
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 49) }, Holder)
                local label = MakeLabel(row, text or "Slider", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Position = UDim2.fromOffset(0, 0)
                label.Size = UDim2.new(1, -55, 0, 18)
                local valueLabel = MakeLabel(row, tostring(value), 10, Theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
                valueLabel.Position = UDim2.new(1, -48, 0, 0)
                valueLabel.Size = UDim2.fromOffset(48, 18)
                local track = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = Theme.Line, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 7) }, row)
                Corner(track, 8)
                local fill = New("Frame", { BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new((value - minimum) / math.max(1, maximum - minimum), 0, 1, 0) }, track)
                Corner(fill, 8)
                local dot = New("Frame", { Name = "SliderKnob", Active = true, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((value - minimum) / math.max(1, maximum - minimum), 0, 0.5, 0), Size = UDim2.fromOffset(15, 15), ZIndex = 4 }, track)
                Corner(dot, 20)
                Stroke(dot, Theme.Accent, 0, 2)
                local draggingSlider = false
                local control = { Value = value }
                local function setFromX(x)
                    local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
                    value = quantize(minimum + (maximum - minimum) * alpha)
                    control.Value = value
                    valueLabel.Text = tostring(value)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    dot.Position = UDim2.new(alpha, 0, 0.5, 0)
                    SafeCallback(callback, value)
                end
                local function beginSliderDrag(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        setFromX(input.Position.X)
                    end
                end
                track.InputBegan:Connect(beginSliderDrag)
                dot.InputBegan:Connect(beginSliderDrag)
                TrackConnection(UIS.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X) end
                end))
                TrackConnection(UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
                end))
                function control:Set(newValue, silent)
                    value = quantize(tonumber(newValue) or minimum)
                    local oldCallback = callback
                    if silent then callback = nil end
                    setFromX(track.AbsolutePosition.X + ((value - minimum) / math.max(1, maximum - minimum)) * track.AbsoluteSize.X)
                    callback = oldCallback
                end
                function control:Get() return value end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(row, text or "Slider")
                return control
            end

            function section:Dropdown(text, options, default, callback)
                if type(text) == "table" then
                    local dropdownConfig = text
                    text = dropdownConfig.Title or dropdownConfig.Name or "Dropdown"
                    options = dropdownConfig.Options or options
                    default = dropdownConfig.Default or dropdownConfig.Value or default
                    callback = dropdownConfig.Callback or dropdownConfig.Function or callback
                end
                options = options or { "Option 1", "Option 2", "Option 3" }
                if #options == 0 then options = { "No options" } end
                local index = table.find(options, default) or 1
                local wrapper = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), AutomaticSize = Enum.AutomaticSize.Y }, Holder)
                local layout = New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, wrapper)
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 1 }, wrapper)
                local label = MakeLabel(row, text or "Dropdown", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(0.42, 0, 1, 0)
                local button = MakeButton(row, tostring(options[index]) .. "  ▾", UDim2.new(0.56, 0, 0, 32), false)
                button.AnchorPoint = Vector2.new(1, 0.5)
                button.Position = UDim2.new(1, 0, 0.5, 0)
                button.TextSize = 10
                local popup = New("Frame", { BackgroundColor3 = Theme.Card2, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, LayoutOrder = 2 }, wrapper)
                Corner(popup, 8)
                Stroke(popup, Theme.Line, 0.45, 1)
                local list = New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = scrollbarsEnabled and 2 or 0, ScrollBarImageColor3 = Theme.Accent }, popup)
                local listLayout = New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
                local control = { Value = options[index], Open = false }
                local function setOpen(open)
                    control.Open = open
                    button.Text = tostring(control.Value) .. (open and "  ▴" or "  ▾")
                    local height = open and (math.min(#options, 5) * 29 + 8) or 0
                    Tween(popup, 0.14, { Size = UDim2.new(1, 0, 0, height) })
                end
                for optionIndex, option in ipairs(options) do
                    local optionButton = New("TextButton", { AutoButtonColor = false, BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Size = UDim2.new(1, -2, 0, 26), Text = tostring(option), TextColor3 = Theme.Text, TextSize = 10, Font = Enum.Font.Gotham, LayoutOrder = optionIndex }, list)
                    Corner(optionButton, 6)
                    optionButton.Activated:Connect(function()
                        index = optionIndex
                        control.Value = option
                        button.Text = tostring(option) .. "  ▾"
                        setOpen(false)
                        SafeCallback(callback, control.Value)
                    end)
                end
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
                end)
                button.Activated:Connect(function() setOpen(not control.Open) end)
                function control:Set(newValue)
                    local found = table.find(options, newValue)
                    if found then
                        index = found
                        control.Value = options[index]
                        button.Text = tostring(control.Value) .. (control.Open and "  ▴" or "  ▾")
                        SafeCallback(callback, control.Value)
                    end
                end
                function control:Refresh(newOptions)
                    options = newOptions or options
                    if #options == 0 then options = { "No options" } end
                    index = table.find(options, control.Value) or 1
                    control.Value = options[index]
                    for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for optionIndex, option in ipairs(options) do
                        local optionButton = New("TextButton", { AutoButtonColor = false, BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Size = UDim2.new(1, -2, 0, 26), Text = tostring(option), TextColor3 = Theme.Text, TextSize = 10, Font = Enum.Font.Gotham, LayoutOrder = optionIndex }, list)
                        Corner(optionButton, 6)
                        optionButton.Activated:Connect(function() control:Set(option); setOpen(false) end)
                    end
                    button.Text = tostring(control.Value) .. "  ▾"
                end
                function control:Get() return options[index] end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(wrapper, text or "Dropdown")
                return control
            end

            function section:MultiDropdown(text, options, defaults, callback)
                if type(text) == "table" then
                    local multiConfig = text
                    text = multiConfig.Title or multiConfig.Name or "Multi dropdown"
                    options = multiConfig.Options or options
                    defaults = multiConfig.Default or multiConfig.Values or defaults
                    callback = multiConfig.Callback or multiConfig.Function or callback
                end
                options = options or { "Option 1", "Option 2", "Option 3" }
                local selected = {}
                if type(defaults) == "table" then
                    for _, value in ipairs(defaults) do selected[value] = true end
                elseif defaults ~= nil then
                    selected[defaults] = true
                end
                local wrapper = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), AutomaticSize = Enum.AutomaticSize.Y }, Holder)
                New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, wrapper)
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 1 }, wrapper)
                local label = MakeLabel(row, text or "Multi dropdown", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(0.42, 0, 1, 0)
                local button = MakeButton(row, "Select options  ▾", UDim2.new(0.56, 0, 0, 32), false)
                button.AnchorPoint = Vector2.new(1, 0.5)
                button.Position = UDim2.new(1, 0, 0.5, 0)
                button.TextSize = 10
                local popup = New("Frame", { BackgroundColor3 = Theme.Card2, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, LayoutOrder = 2 }, wrapper)
                Corner(popup, 8)
                Stroke(popup, Theme.Line, 0.45, 1)
                local list = New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -38), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = scrollbarsEnabled and 2 or 0, ScrollBarImageColor3 = Theme.Accent }, popup)
                local listLayout = New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
                local done = MakeButton(popup, "Done", UDim2.new(1, -8, 0, 27), true)
                done.Position = UDim2.new(0, 4, 1, -31)
                done.TextSize = 9
                done.ZIndex = 4
                local control = { Value = {} , Open = false }
                local function getValues()
                    local values = {}
                    for _, option in ipairs(options) do if selected[option] then table.insert(values, option) end end
                    return values
                end
                local function updateText()
                    control.Value = getValues()
                    if #control.Value == 0 then
                        button.Text = "Select options" .. (control.Open and "  ▴" or "  ▾")
                    elseif #control.Value <= 2 then
                        button.Text = table.concat(control.Value, ", ") .. (control.Open and "  ▴" or "  ▾")
                    else
                        button.Text = tostring(#control.Value) .. " selected" .. (control.Open and "  ▴" or "  ▾")
                    end
                end
                local function refreshOptionButtons()
                    for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    for optionIndex, option in ipairs(options) do
                        local optionButton = New("TextButton", { AutoButtonColor = false, BackgroundColor3 = selected[option] and Theme.Accent2 or Theme.Card, BorderSizePixel = 0, Size = UDim2.new(1, -2, 0, 26), Text = (selected[option] and "✓  " or "＋  ") .. tostring(option), TextColor3 = Theme.Text, TextSize = 10, Font = Enum.Font.Gotham, LayoutOrder = optionIndex }, list)
                        Corner(optionButton, 6)
                        optionButton.Activated:Connect(function()
                            selected[option] = not selected[option] or nil
                            refreshOptionButtons()
                            updateText()
                            SafeCallback(callback, table.clone(control.Value))
                        end)
                    end
                end
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4) end)
                local function setOpen(open)
                    control.Open = open
                    updateText()
                    local height = open and (math.min(#options, 4) * 29 + 42) or 0
                    Tween(popup, 0.14, { Size = UDim2.new(1, 0, 0, height) })
                end
                refreshOptionButtons()
                updateText()
                button.Activated:Connect(function() setOpen(not control.Open) end)
                done.Activated:Connect(function() setOpen(false) end)
                function control:Set(values)
                    selected = {}
                    if type(values) == "table" then
                        for _, value in ipairs(values) do selected[value] = true end
                    elseif values ~= nil then
                        selected[values] = true
                    end
                    refreshOptionButtons()
                    updateText()
                    SafeCallback(callback, table.clone(control.Value))
                end
                function control:Clear()
                    control:Set({})
                end
                function control:Refresh(newOptions)
                    options = newOptions or options
                    if #options == 0 then options = { "No options" } end
                    for selectedValue in pairs(selected) do
                        if not table.find(options, selectedValue) then selected[selectedValue] = nil end
                    end
                    refreshOptionButtons()
                    updateText()
                end
                function control:Get() return table.clone(control.Value) end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(wrapper, text or "Multi dropdown")
                return control
            end
            section.MultiSelectDropdown = section.MultiDropdown

            function section:Input(text, placeholder, callback)
                local defaultText = ""
                if type(text) == "table" then
                    local inputConfig = text
                    text = inputConfig.Title or inputConfig.Name or "Input"
                    placeholder = inputConfig.Placeholder or placeholder
                    defaultText = tostring(inputConfig.Default or inputConfig.Value or "")
                    callback = inputConfig.Callback or inputConfig.Function or callback
                end
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 39) }, Holder)
                local label = MakeLabel(row, text or "Input", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(0.38, 0, 1, 0)
                local box = New("TextBox", { BackgroundColor3 = Theme.Card2, BorderSizePixel = 0, ClearTextOnFocus = false, PlaceholderText = placeholder or "Type something...", PlaceholderColor3 = Theme.Muted, Text = defaultText, TextColor3 = Theme.Text, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.60, 0, 0, 32), Position = UDim2.new(0.40, 0, 0.5, -16) }, row)
                Corner(box, 8)
                Stroke(box, Theme.Line, 0.5, 1)
                AddPadding(box, 9, 8, 0, 0)
                box.FocusLost:Connect(function(enterPressed) SafeCallback(callback, box.Text, enterPressed) end)
                local control = { Instance = box }
                function control:Set(value) box.Text = tostring(value or "") end
                function control:Get() return box.Text end
                function control:Focus() box:CaptureFocus() end
                RegisterSearch(row, text or "Input")
                return control
            end

            function section:Keybind(text, default, callback)
                if type(text) == "table" then
                    local keyConfig = text
                    text = keyConfig.Title or keyConfig.Name or "Keybind"
                    default = keyConfig.Default or keyConfig.Value or keyConfig.Key or default
                    callback = keyConfig.Callback or keyConfig.Function or callback
                end
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36) }, Holder)
                local label = MakeLabel(row, text or "Keybind", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(1, -92, 1, 0)
                local keyName = tostring(default or "K"):match("([^%.]+)$") or tostring(default or "K")
                local keyCode = (typeof(default) == "EnumItem" and default.EnumType == Enum.KeyCode)
                    and default or Enum.KeyCode[keyName] or Enum.KeyCode.K
                local button = MakeButton(row, keyCode.Name, UDim2.fromOffset(88, 29), false)
                button.AnchorPoint = Vector2.new(1, 0.5)
                button.Position = UDim2.new(1, 0, 0.5, 0)
                button.TextSize = 9
                local listening = false
                local control = { Value = keyCode.Name, Listening = false, Instance = button }
                local function setKey(value, silent)
                    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
                        keyCode = value
                    else
                        keyCode = Enum.KeyCode[tostring(value)] or keyCode
                    end
                    control.Value = keyCode.Name
                    button.Text = keyCode.Name
                    if callback and not silent then SafeCallback(callback, keyCode) end
                end
                button.Activated:Connect(function()
                    listening = true
                    control.Listening = true
                    button.Text = "Press key..."
                    Tween(button, 0.12, { BackgroundColor3 = Theme.Accent2 })
                end)
                TrackConnection(UIS.InputBegan:Connect(function(input, processed)
                    if not listening then
                        if not processed and input.KeyCode == keyCode then SafeCallback(callback, keyCode) end
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        control.Listening = false
                        setKey(input.KeyCode)
                        Tween(button, 0.12, { BackgroundColor3 = Theme.Card2 })
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        listening = false
                        control.Listening = false
                        button.Text = keyCode.Name
                    end
                end))
                function control:Set(value, silent) setKey(value, silent) end
                function control:Get() return keyCode end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(row, text or "Keybind")
                return control
            end

            function section:Colorpicker(text, defaultColor, callback)
                if type(text) == "table" then
                    local colorConfig = text
                    text = colorConfig.Title or colorConfig.Name or "Colorpicker"
                    defaultColor = colorConfig.Default or colorConfig.Color or colorConfig.Value or defaultColor
                    callback = colorConfig.Callback or colorConfig.Function or callback
                end
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36) }, Holder)
                local label = MakeLabel(row, text or "Accent color", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(1, -60, 1, 0)
                local swatch = MakeButton(row, "", UDim2.fromOffset(42, 26), false)
                swatch.AnchorPoint = Vector2.new(1, 0.5)
                swatch.Position = UDim2.new(1, 0, 0.5, 0)
                local currentColor = typeof(defaultColor) == "Color3" and defaultColor or Theme.Accent
                swatch.BackgroundColor3 = currentColor
                swatch:SetAttribute("UAER_BG", nil)
                local palette = {
                    Color3.fromRGB(158, 93, 255), Color3.fromRGB(83, 187, 255),
                    Color3.fromRGB(85, 222, 158), Color3.fromRGB(255, 178, 91),
                    Color3.fromRGB(255, 105, 154), Color3.fromRGB(244, 244, 248),
                    Color3.fromRGB(45, 48, 62), Color3.fromRGB(255, 80, 80),
                }
                local popup = New("Frame", {
                    BackgroundColor3 = Theme.Card2, BorderSizePixel = 0,
                    Position = UDim2.new(1, -186, 0, 34), Size = UDim2.fromOffset(180, 0),
                    ClipsDescendants = true, ZIndex = 15, Visible = false,
                }, row)
                Corner(popup, 9)
                Stroke(popup, Theme.Line, 0.35, 1)
                local grid = New("UIGridLayout", {
                    CellSize = UDim2.fromOffset(28, 25), CellPadding = UDim2.fromOffset(7, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, popup)
                AddPadding(popup, 8, 8, 8, 8)
                local control = { Value = currentColor, Instance = swatch, Open = false }
                local function setColor(color, silent)
                    if typeof(color) ~= "Color3" then return end
                    currentColor = color
                    control.Value = color
                    swatch.BackgroundColor3 = color
                    if callback and not silent then SafeCallback(callback, color) end
                end
                for index, color in ipairs(palette) do
                    local option = New("TextButton", {
                        AutoButtonColor = false, Text = "", BackgroundColor3 = color,
                        BorderSizePixel = 0, LayoutOrder = index, ZIndex = 16,
                    }, popup)
                    Corner(option, 7)
                    Stroke(option, Theme.Text, 0.82, 1)
                    option.Activated:Connect(function()
                        setColor(color)
                        control.Open = false
                        popup.Visible = false
                        popup.Size = UDim2.fromOffset(180, 0)
                    end)
                end
                swatch.Activated:Connect(function()
                    control.Open = not control.Open
                    popup.Visible = control.Open
                    Tween(popup, 0.14, { Size = UDim2.fromOffset(180, control.Open and 76 or 0) })
                end)
                function control:Set(color, silent) setColor(color, silent) end
                function control:Get() return currentColor end
                function control:OnChanged(fn) callback = fn end
                RegisterSearch(row, text or "Colorpicker")
                return control
            end

            function section:Progress(text, percent)
                local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38) }, Holder)
                local label = MakeLabel(row, text or "Progress", 10, Theme.Text, Enum.Font.GothamMedium)
                label.Size = UDim2.new(1, -45, 0, 17)
                local value = math.clamp(percent or 65, 0, 100)
                local number = MakeLabel(row, tostring(value) .. "%", 9, Theme.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
                number.Position = UDim2.new(1, -42, 0, 0)
                number.Size = UDim2.fromOffset(42, 17)
                local track = New("Frame", { BackgroundColor3 = Theme.Line, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 23), Size = UDim2.new(1, 0, 0, 7) }, row)
                Corner(track, 8)
                local fill = New("Frame", { BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(value / 100, 0, 1, 0) }, track)
                Corner(fill, 8)
                RegisterSearch(row, text or "Progress")
                local control = { Value = value, Instance = row }
                function control:Set(newValue)
                    value = math.clamp(tonumber(newValue) or 0, 0, 100)
                    control.Value = value
                    number.Text = tostring(value) .. "%"
                    Tween(fill, 0.18, { Size = UDim2.new(value / 100, 0, 1, 0) })
                end
                function control:Get() return value end
                return control
            end

            function section:Chip(text, color)
                local chip = New("TextLabel", { BackgroundColor3 = color or Theme.Accent2, BackgroundTransparency = 0.68, BorderSizePixel = 0, Size = UDim2.fromOffset(100, 25), Text = text or "UAER_UI", TextColor3 = Theme.Text, TextSize = 9, Font = Enum.Font.GothamBold }, Holder)
                Corner(chip, 8)
                Stroke(chip, color or Theme.Accent, 0.5, 1)
                RegisterSearch(chip, text or "Chip")
                return chip
            end

            section.AddButton = section.Button
            section.AddLabel = section.Label
            section.AddParagraph = section.Paragraph
            section.AddDivider = section.Divider
            section.AddToggle = section.Toggle
            section.AddSlider = section.Slider
            section.AddDropdown = section.Dropdown
            section.AddInput = section.Input
            section.AddKeybind = section.Keybind
            section.AddColorpicker = section.Colorpicker
            section.AddProgress = section.Progress
            section.AddChip = section.Chip
            table.insert(tab.Sections, section)
            return section
        end

        tab.Select = tab.Show
        tab.CreateSection = tab.Section
        nav.Activated:Connect(function() tab:Show() end)
        tab.Page = Page
        tab.Nav = nav
        tab.NavText = navText
        tab.NavIcon = navIcon
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then tab:Show() end
        return tab
    end

    function window:Notify(title, message, kind)
        if type(title) == "table" then
            local notice = title
            Notify(notice.Title or notice.title or "Notification", notice.Content or notice.Message or notice.message or "", notice.Type or notice.Kind or notice.kind, notice.Duration)
        else
            Notify(title, message, kind)
        end
    end

    function window:SetVisible(value)
        if window.Destroyed then return false end
        setVisible(value == true)
        return true
    end

    function window:Toggle()
        if window.Destroyed then return false end
        setVisible(not Main.Visible)
        return Main.Visible
    end

    function window:IsVisible()
        return not window.Destroyed and Main.Visible
    end

    function window:SetToggleKey(value)
        local keyName = tostring(value or ""):match("([^%.]+)$") or tostring(value or "")
        local parsed = (typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode) and value or Enum.KeyCode[keyName]
        if not parsed or parsed.EnumType ~= Enum.KeyCode then return false end
        ToggleKey = parsed
        ToggleKeyName = parsed.Name
        return true
    end

    function window:GetToggleKey()
        return ToggleKey.Name
    end

    function window:SetTitle(value)
        if window.Destroyed then return false end
        window.Title = tostring(value or "UAER_UI")
        Brand.Text = window.Title
        return true
    end

    function window:SetAuthor(value)
        if window.Destroyed then return false end
        window.Author = tostring(value or "")
        Subtitle.Text = window.Author
        Subtitle.Visible = window.Author ~= ""
        return true
    end

    function window:SetBackgroundImage(value, transparency)
        if window.Destroyed then return false end
        local imageId = tostring(value or "")
        if imageId == "" then
            if window.BackgroundImage then window.BackgroundImage:Destroy(); window.BackgroundImage = nil end
            return true
        end
        if imageId:match("^%d+$") then imageId = "rbxassetid://" .. imageId end
        if not window.BackgroundImage or not window.BackgroundImage.Parent then
            window.BackgroundImage = New("ImageLabel", {
                Name = "WindowBackgroundImage", BackgroundTransparency = 1, BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
                ScaleType = Enum.ScaleType.Crop, ZIndex = Main.ZIndex,
            }, Main)
            Corner(window.BackgroundImage, 16)
        end
        window.BackgroundImage.Image = imageId
        window.BackgroundImage.ImageTransparency = math.clamp(tonumber(transparency) or 0.68, 0, 1)
        return true
    end

    function window:OnDestroy(callback)
        if type(callback) ~= "function" then return false end
        if window.Destroyed then SafeCallback(callback); return true end
        window._OnDestroy = callback
        return true
    end

    function window:Destroy()
        if window.Destroyed then return end
        SafeCallback(window._OnDestroy)
        window.Destroyed = true
        for index = #GlobalConnections, 1, -1 do
            local connection = GlobalConnections[index]
            if connection and connection.Connected then connection:Disconnect() end
        end
        table.clear(GlobalConnections)
        if Screen and Screen.Parent then Screen:Destroy() end
        if NoticeHolder == WindowNoticeHolder then NoticeHolder = nil end
        if ActiveWindow == window then ActiveWindow = nil end
    end

    function window:Close()
        if window.Destroyed then return end
        setVisible(false)
    end

    function window:Show()
        if window.Destroyed then return end
        setVisible(true)
    end

    window.CreateTab = window.Tab
    window.SetPosition = function(_, position)
        if typeof(position) == "UDim2" then Main.Position = position end
    end

    return window
end

function Library.Notify(first, second, third, fourth)
    if first == Library then
        first, second, third = second, third, fourth
    end
    if type(first) == "table" then
        local notice = first
        Notify(notice.Title or notice.title or "Notification", notice.Content or notice.Message or notice.message or "", notice.Type or notice.Kind or notice.kind, notice.Duration)
    else
        Notify(first, second, third)
    end
end

function Library:GetThemes()
    return table.clone(Themes)
end

function Library:GetThemeNames()
    return table.clone(ThemeNames)
end

function Library:GetDesigns()
    return table.clone(Designs)
end

function Library:GetVersion()
    return self.Version
end

function Library:GetName()
    return self.Name
end

function Library:GetWindow()
    return ActiveWindow
end

function Library:Destroy()
    if ActiveWindow then ActiveWindow:Destroy() end
end

function Library:AddTheme(theme)
    if type(theme) ~= "table" or type(theme.Name) ~= "string" or theme.Name == "" then
        return false, "Theme must be a table with a Name."
    end
    local required = { "Background", "Panel", "Card", "Card2", "Accent", "Accent2", "Text", "Muted", "Line", "Green", "Red" }
    for _, key in ipairs(required) do
        if typeof(theme[key]) ~= "Color3" then
            return false, "Theme is missing a Color3 value for " .. key
        end
    end
    Themes[theme.Name] = table.clone(theme)
    if not table.find(ThemeNames, theme.Name) then table.insert(ThemeNames, theme.Name) end
    Library.ThemePresets = Themes
    Library.ThemeNames = ThemeNames
    return true
end

Library.Create = function(first, second)
    local config = first == Library and second or first
    return Library:CreateWindow(config)
end

return Library


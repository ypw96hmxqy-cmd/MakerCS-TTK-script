--!native

local BlankCFunc = newcclosure(function() return end)
local TARGET_AMMO = 1000000000000

-- ======================
--   SETTINGS (Toggles)
-- ======================
local Settings = {
	ESP = true,
	GunMods = true,
	InfiniteAmmo = true,
}

-- ======================
--   SIMPLE TOGGLE UI
-- ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TTKScriptUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.5, -110, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "TTK Shotty Mods"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local function CreateToggle(name, yOffset, default)
	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1, -20, 0, 30)
	Toggle.Position = UDim2.new(0, 10, 0, yOffset)
	Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
	Toggle.Text = name .. ": " .. (default and "ON" or "OFF")
	Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	Toggle.Font = Enum.Font.Gotham
	Toggle.TextSize = 14
	Toggle.Parent = Frame
	
	Toggle.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		local isOn = Settings[name]
		Toggle.BackgroundColor3 = isOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
		Toggle.Text = name .. ": " .. (isOn and "ON" or "OFF")
	end)
	
	return Toggle
end

CreateToggle("ESP", 40, true)
CreateToggle("GunMods", 75, true)
CreateToggle("InfiniteAmmo", 110, true)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 60, 0, 25)
CloseBtn.Position = UDim2.new(1, -70, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "Close"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Parent = Frame
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui.Enabled = false
end)

print("UI Loaded - Drag the window")

-- ======================
--   ENHANCED ESP
-- ======================
local ESP = {}
ESP.Players = {}

local function CreateESP(plr)
	if ESP.Players[plr] or plr == game.Players.LocalPlayer then return end
	-- ... (same as previous ESP code)
	local Box = Drawing.new("Square")
	Box.Thickness = 2
	Box.Filled = false
	Box.Transparency = 1
	Box.Color = Color3.fromRGB(255, 0, 0)
	
	local Name = Drawing.new("Text")
	Name.Size = 14
	Name.Center = true
	Name.Outline = true
	Name.Color = Color3.fromRGB(255, 255, 255)
	
	local HealthBar = Drawing.new("Square")
	HealthBar.Thickness = 1
	HealthBar.Filled = true
	HealthBar.Color = Color3.fromRGB(0, 255, 0)
	
	ESP.Players[plr] = {Box = Box, Name = Name, HealthBar = HealthBar}
end

local function UpdateESP()
	if not Settings.ESP then 
		for _, data in pairs(ESP.Players) do
			data.Box.Visible = false
			data.Name.Visible = false
			data.HealthBar.Visible = false
		end
		return 
	end
	
	for plr, data in pairs(ESP.Players) do
		local Character = plr.Character
		if not Character or not Character:FindFirstChild("HumanoidRootPart") or not Character:FindFirstChildOfClass("Humanoid") then
			data.Box.Visible = false
			data.Name.Visible = false
			data.HealthBar.Visible = false
			continue
		end
		
		local Root = Character.HumanoidRootPart
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local Camera = workspace.CurrentCamera
		local LocalRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		
		local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
		if not OnScreen then
			data.Box.Visible = false
			data.Name.Visible = false
			data.HealthBar.Visible = false
			continue
		end
		
		local Top = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3.5, 0))
		local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
		local Height = (Bottom - Top).Y
		local Width = Height * 0.6
		
		data.Box.Size = Vector2.new(Width, Height)
		data.Box.Position = Vector2.new(ScreenPos.X - Width/2, ScreenPos.Y - Height/2)
		data.Box.Visible = true
		
		local distance = LocalRoot and math.floor((Root.Position - LocalRoot.Position).Magnitude) or 0
		local hp = math.floor(Humanoid.Health)
		data.Name.Text = string.format("%s\nHP: %d\n%d studs", plr.Name, hp, distance)
		data.Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Height/2 - 25)
		data.Name.Visible = true
		
		local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
		data.HealthBar.Size = Vector2.new(4, Height * HealthPercent)
		data.HealthBar.Position = Vector2.new(data.Box.Position.X - 6, data.Box.Position.Y + Height * (1 - HealthPercent))
		data.HealthBar.Visible = true
	end
end

local function SetupESP()
	for _, plr in ipairs(game.Players:GetPlayers()) do
		CreateESP(plr)
	end
	game.Players.PlayerAdded:Connect(CreateESP)
	game:GetService("RunService").RenderStepped:Connect(UpdateESP)
end

SetupESP()

-- ======================
--   GUN MODS + INFINITE AMMO
-- ======================
local function HookInitFromDef(Function)
	local Previous
	Previous = hookfunction(Function, newcclosure(function(p2, ...)
		Previous(p2, ...)
		if not Settings.GunMods then return end
		
		p2.FireRate = 0
		p2.Cooldown = 0
		p2.FireDelay = 0
		p2.BurstDelay = 0
		p2.ReloadTime = 0.001
		
		p2.FireMode = "auto"
		p2.RecoilRecovery = 0
		p2.SpreadAngle = 25
		
		p2.BulletsPerShot = 50
		p2.NumProjectiles = 50
		p2.ProjectileCount = 50
		p2.Pellets = 50
		
		p2.MagAmmo = TARGET_AMMO
		p2.Ammo = TARGET_AMMO
		p2.CurrentAmmo = TARGET_AMMO
		p2.ReserveAmmo = TARGET_AMMO
		
		if p2.RecoilSpring then p2.RecoilSpring.s = 0 end
		if p2.FireConfig then
			p2.FireConfig.Rate = 0
			p2.FireConfig.Delay = 0
			p2.FireConfig.BulletsPerShot = 50
		end
	end))
end

local function HookWeaponHandler(Handler)
	if not Settings.GunMods then return end
	
	hookfunction(rawget(Handler, "ApplyRecoil"), BlankCFunc)
	hookfunction(rawget(Handler, "_FireScriptedRecoil"), BlankCFunc)
	hookfunction(rawget(Handler, "_FireAdsShoulderImpact"), BlankCFunc)
	hookfunction(rawget(Handler, "_ApplyFireDriftImpulse"), BlankCFunc)
	
	if rawget(Handler, "Fire") then
		hookfunction(rawget(Handler, "Fire"), newcclosure(function(self, ...)
			local result = rawget(Handler, "Fire")(self, ...)
			if self and Settings.InfiniteAmmo then
				self.LastFireTime = 0
				self.NextFireTime = 0
				self.CurrentAmmo = TARGET_AMMO
				self.Ammo = TARGET_AMMO
				self.MagAmmo = TARGET_AMMO
				self.ReserveAmmo = TARGET_AMMO
			end
			return result
		end))
	end
end

-- Ultra ammo enforcer
game:GetService("RunService").Heartbeat:Connect(function()
	if not Settings.InfiniteAmmo then return end
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			for _, obj in ipairs(tool:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("IntValue") then
					local n = obj.Name:lower()
					if n:find("ammo") or n:find("mag") or n:find("clip") or n:find("bullet") or n:find("reserve") then
						obj.Value = TARGET_AMMO
					end
				end
			end
		end
	end
end)

-- Main GC Scan
for _, Thing in next, getgc(true) do
	if typeof(Thing) ~= "table" then continue end

	if rawget(Thing, "ApplyRecoil") then
		HookWeaponHandler(Thing)
	elseif rawget(Thing, "InitFromDef") then
		HookInitFromDef(rawget(Thing, "InitFromDef"))
	end
end

print("Full script with UI loaded!")
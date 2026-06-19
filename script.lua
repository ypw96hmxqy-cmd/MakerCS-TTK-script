--!native

local BlankCFunc = newcclosure(function() return end)
local TARGET_AMMO = 1000000000000

-- ======================
--   SETTINGS
-- ======================
local Settings = {
	ESP = true,
	GunMods = true,
	InfiniteAmmo = true,
}

-- ======================
--   TOGGLE UI
-- ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TTKModsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 190)
Frame.Position = UDim2.new(0.5, -120, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "MakerCS TTK Mods"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local function CreateToggle(name, yOffset, default)
	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1, -20, 0, 35)
	Toggle.Position = UDim2.new(0, 10, 0, yOffset)
	Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
	Toggle.Text = name .. ": " .. (default and "ON" or "OFF")
	Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	Toggle.Font = Enum.Font.GothamSemibold
	Toggle.TextSize = 15
	Toggle.Parent = Frame
	
	Toggle.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		local on = Settings[name]
		Toggle.BackgroundColor3 = on and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
		Toggle.Text = name .. ": " .. (on and "ON" or "OFF")
	end)
end

CreateToggle("ESP", 45, true)
CreateToggle("GunMods", 85, true)
CreateToggle("InfiniteAmmo", 125, true)

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 70, 0, 28)
Close.Position = UDim2.new(1, -80, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
Close.Text = "Close"
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.Font = Enum.Font.Gotham
Close.Parent = Frame
Close.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

print("✅ MakerCS TTK UI Loaded - Drag window")

-- ======================
--   ESP
-- ======================
local ESP = {Players = {}}

local function CreateESP(plr)
	if ESP.Players[plr] or plr == game.Players.LocalPlayer then return end
	local Box = Drawing.new("Square")
	Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Color = Color3.fromRGB(255,0,0)
	
	local Name = Drawing.new("Text")
	Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Color = Color3.fromRGB(255,255,255)
	
	local HealthBar = Drawing.new("Square")
	HealthBar.Thickness = 1; HealthBar.Filled = true; HealthBar.Color = Color3.fromRGB(0,255,0)
	
	ESP.Players[plr] = {Box=Box, Name=Name, HealthBar=HealthBar}
end

local function UpdateESP()
	if not Settings.ESP then
		for _,v in pairs(ESP.Players) do v.Box.Visible = false; v.Name.Visible = false; v.HealthBar.Visible = false end
		return
	end
	for plr, data in pairs(ESP.Players) do
		local char = plr.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then
			data.Box.Visible = false; data.Name.Visible = false; data.HealthBar.Visible = false
			continue
		end
		local root = char.HumanoidRootPart
		local hum = char:FindFirstChildOfClass("Humanoid")
		local cam = workspace.CurrentCamera
		local lroot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		
		local pos, onscreen = cam:WorldToViewportPoint(root.Position)
		if not onscreen then
			data.Box.Visible = false; data.Name.Visible = false; data.HealthBar.Visible = false
			continue
		end
		
		local top = cam:WorldToViewportPoint(root.Position + Vector3.new(0,3.5,0))
		local bot = cam:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
		local h = (bot - top).Y
		local w = h * 0.6
		
		data.Box.Size = Vector2.new(w, h)
		data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
		data.Box.Visible = true
		
		local dist = lroot and math.floor((root.Position - lroot.Position).Magnitude) or 0
		data.Name.Text = string.format("%s\nHP: %d\n%d studs", plr.Name, math.floor(hum.Health), dist)
		data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 28)
		data.Name.Visible = true
		
		local hpPct = hum.Health / hum.MaxHealth
		data.HealthBar.Size = Vector2.new(4, h * hpPct)
		data.HealthBar.Position = Vector2.new(data.Box.Position.X - 7, data.Box.Position.Y + h * (1 - hpPct))
		data.HealthBar.Visible = true
	end
end

for _, plr in ipairs(game.Players:GetPlayers()) do CreateESP(plr) end
game.Players.PlayerAdded:Connect(CreateESP)
game:GetService("RunService").RenderStepped:Connect(UpdateESP)

-- ======================
--   GUN MODS + INFINITE AMMO
-- ======================
local function HookInitFromDef(fn)
	local prev = hookfunction(fn, newcclosure(function(p2, ...)
		prev(p2, ...)
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

local function HookWeaponHandler(h)
	if not Settings.GunMods then return end
	hookfunction(rawget(h, "ApplyRecoil"), BlankCFunc)
	hookfunction(rawget(h, "_FireScriptedRecoil"), BlankCFunc)
	hookfunction(rawget(h, "_FireAdsShoulderImpact"), BlankCFunc)
	hookfunction(rawget(h, "_ApplyFireDriftImpulse"), BlankCFunc)
	
	if rawget(h, "Fire") then
		hookfunction(rawget(h, "Fire"), newcclosure(function(self, ...)
			local res = rawget(h, "Fire")(self, ...)
			if self and Settings.InfiniteAmmo then
				self.LastFireTime = 0
				self.NextFireTime = 0
				self.CurrentAmmo = TARGET_AMMO
				self.Ammo = TARGET_AMMO
				self.MagAmmo = TARGET_AMMO
				self.ReserveAmmo = TARGET_AMMO
			end
			return res
		end))
	end
end

-- Ammo enforcer
game:GetService("RunService").Heartbeat:Connect(function()
	if not Settings.InfiniteAmmo then return end
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			for _, v in ipairs(tool:GetDescendants()) do
				if (v:IsA("NumberValue") or v:IsA("IntValue")) then
					local n = v.Name:lower()
					if n:find("ammo") or n:find("mag") or n:find("clip") or n:find("bullet") or n:find("reserve") then
						v.Value = TARGET_AMMO
					end
				end
			end
		end
	end
end)

-- Hook scan
for _, v in next, getgc(true) do
	if typeof(v) == "table" then
		if rawget(v, "ApplyRecoil") then
			HookWeaponHandler(v)
		elseif rawget(v, "InitFromDef") then
			HookInitFromDef(rawget(v, "InitFromDef"))
		end
	end
end

print("🎯 MakerCS TTK Script Fully Loaded!")
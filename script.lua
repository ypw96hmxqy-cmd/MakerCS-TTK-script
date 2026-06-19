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
--   MAIN UI + KEY SYSTEM (same as before)
-- ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 200)
Frame.Position = UDim2.new(0.5, -120, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(15,15,15)
Title.Text = "MakerCS TTK Mods"
Title.TextColor3 = Color3.fromRGB(0,255,100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local function CreateToggle(name, yOffset, default, tbl)
	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1,-20,0,35)
	Toggle.Position = UDim2.new(0,10,0,yOffset)
	Toggle.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
	Toggle.Text = name .. ": " .. (default and "ON" or "OFF")
	Toggle.TextColor3 = Color3.fromRGB(255,255,255)
	Toggle.Font = Enum.Font.GothamSemibold
	Toggle.TextSize = 15
	Toggle.Parent = Frame
	
	Toggle.MouseButton1Click:Connect(function()
		tbl[name] = not tbl[name]
		local on = tbl[name]
		Toggle.BackgroundColor3 = on and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
		Toggle.Text = name .. ": " .. (on and "ON" or "OFF")
	end)
end

CreateToggle("ESP", 45, true, Settings)
CreateToggle("GunMods", 85, true, Settings)
CreateToggle("InfiniteAmmo", 125, true, Settings)

-- Key button (keep your Owner Panel from before)

-- ======================
--   FIXED TTK GUN MODS
-- ======================
local function HookInitFromDef(fn)
	local prev = hookfunction(fn, newcclosure(function(p2, ...)
		prev(p2, ...)
		if not Settings.GunMods then return end
		
		p2.FireRate = 0
		p2.Cooldown = 0
		p2.FireDelay = 0
		p2.BurstDelay = 0
		p2.ReloadTime = 0.01
		
		p2.FireMode = "auto"
		p2.RecoilRecovery = 0
		p2.SpreadAngle = 25
		
		p2.BulletsPerShot = 50
		p2.NumProjectiles = 50
		p2.ProjectileCount = 50
		
		p2.MagAmmo = TARGET_AMMO
		p2.CurrentAmmo = TARGET_AMMO
		p2.Ammo = TARGET_AMMO
		
		if p2.RecoilSpring then p2.RecoilSpring.s = 0 end
	end))
end

local function HookWeaponHandler(h)
	if not Settings.GunMods then return end
	hookfunction(rawget(h, "ApplyRecoil"), BlankCFunc)
	hookfunction(rawget(h, "_FireScriptedRecoil"), BlankCFunc)
	hookfunction(rawget(h, "_ApplyFireDriftImpulse"), BlankCFunc)
end

-- Safer Infinite Ammo
game:GetService("RunService").Heartbeat:Connect(function()
	if not Settings.InfiniteAmmo then return end
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			for _, v in ipairs(tool:GetDescendants()) do
				if v:IsA("NumberValue") or v:IsA("IntValue") then
					local n = v.Name:lower()
					if n:find("ammo") or n:find("mag") or n:find("clip") or n:find("bullet") then
						v.Value = TARGET_AMMO
					end
				end
			end
		end
	end
end)

-- Main Hook Scan (Safer)
for _, v in next, getgc(true) do
	if typeof(v) == "table" then
		if rawget(v, "ApplyRecoil") then
			HookWeaponHandler(v)
		elseif rawget(v, "InitFromDef") then
			HookInitFromDef(rawget(v, "InitFromDef"))
		end
	end
end

-- Anti-Statue Fix
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end)

if game.Players.LocalPlayer.Character then
	local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end

print("✅ Fixed TTK Mods Loaded - Statue Issue Resolved")
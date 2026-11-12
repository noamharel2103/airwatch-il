--!strict
-- Real Roblox avatars sitting at the desks. Friends you hired show up with their own avatar,
-- everyone else gets a random look. The block workers built in the room stay as a fallback.
local Players = game:GetService("Players")

local Avatars = {}
local descCache: { [number]: HumanoidDescription } = {}
local building = false

local SKINS = { Color3.fromRGB(255, 220, 180), Color3.fromRGB(234, 184, 146), Color3.fromRGB(198, 140, 100), Color3.fromRGB(140, 95, 65) }
local SHIRTS = { Color3.fromRGB(230, 70, 80), Color3.fromRGB(40, 140, 240), Color3.fromRGB(255, 190, 40), Color3.fromRGB(40, 190, 110), Color3.fromRGB(160, 100, 240), Color3.fromRGB(255, 120, 40), Color3.fromRGB(40, 42, 50) }
local PANTS = { Color3.fromRGB(40, 55, 100), Color3.fromRGB(30, 32, 38), Color3.fromRGB(90, 70, 50), Color3.fromRGB(60, 70, 80) }

local function randomDesc(seed: number): HumanoidDescription
	local r = Random.new(seed)
	local d = Instance.new("HumanoidDescription")
	local skin = SKINS[r:NextInteger(1, #SKINS)]
	local shirt = SHIRTS[r:NextInteger(1, #SHIRTS)]
	local pants = PANTS[r:NextInteger(1, #PANTS)]
	d.HeadColor = skin
	d.LeftArmColor = shirt
	d.RightArmColor = shirt
	d.TorsoColor = shirt
	d.LeftLegColor = pants
	d.RightLegColor = pants
	return d
end

local function descFor(person, slot: number): HumanoidDescription
	if person and person.userId then
		local id = person.userId
		if descCache[id] then
			return descCache[id]
		end
		local ok, d = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		if ok and d then
			descCache[id] = d
			return d
		end
	end
	-- random people wear the look of a random Roblox player (tries a few ids, then plain colours)
	local seed = (person and person.id or 0) * 31 + slot
	local r = Random.new(seed)
	for _ = 1, 4 do
		local id = r:NextInteger(20000000, 3500000000)
		if descCache[id] then
			return descCache[id]
		end
		local ok, d = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		if ok and d then
			descCache[id] = d
			return d
		end
	end
	return randomDesc(seed)
end

-- Sitting and typing pose. New avatars use physics joints, so we anchor every body part
-- and turn the limbs around their joint points ourselves.
local function att(model: Model, part: string, name: string): Vector3?
	local p = model:FindFirstChild(part)
	local a = p and p:FindFirstChild(name)
	return a and (a :: Attachment).WorldPosition or nil
end

local function turn(model: Model, parts: { string }, pivot: Vector3?, axisRot: CFrame)
	if not pivot then
		return
	end
	local m = CFrame.new(pivot) * axisRot * CFrame.new(-pivot)
	for _, n in ipairs(parts) do
		local p = model:FindFirstChild(n) :: BasePart?
		if p then
			p.CFrame = m * p.CFrame
		end
	end
end

local function sit(model: Model, facing: CFrame)
	local R = facing - facing.Position
	local function about(deg)
		return R * CFrame.Angles(math.rad(deg), 0, 0) * R:Inverse()
	end
	for _, side in ipairs({ "Left", "Right" }) do
		turn(model, { side .. "UpperLeg", side .. "LowerLeg", side .. "Foot" }, att(model, side .. "UpperLeg", side .. "HipRigAttachment"), about(90))
		turn(model, { side .. "LowerLeg", side .. "Foot" }, att(model, side .. "LowerLeg", side .. "KneeRigAttachment"), about(-90))
		turn(model, { side .. "UpperArm", side .. "LowerArm", side .. "Hand" }, att(model, side .. "UpperArm", side .. "ShoulderRigAttachment"), about(55))
		turn(model, { side .. "LowerArm", side .. "Hand" }, att(model, side .. "LowerArm", side .. "ElbowRigAttachment"), about(25))
	end
end

local function make(person, slot: number, anchor: BasePart): Model?
	local desc = descFor(person, slot)
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, desc, Enum.HumanoidRigType.R15)
	if not ok or not model then
		return nil
	end
	local m = model :: Model
	local animate = m:FindFirstChild("Animate")
	if animate then
		animate:Destroy()
	end
	local hum = m:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.PlatformStand = true
	end
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CanCollide = false
			d.CanQuery = false
			d.Massless = true
			-- body parts are anchored; accessories stay welded to them
			d.Anchored = d.Parent == m
		end
	end
	local root = m:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		m:Destroy()
		return nil
	end
	root.Transparency = 1
	-- stand at the desk, then sit down: thighs rest on the seat (1.4 below the block torso)
	local facing = anchor.CFrame
	m:PivotTo(facing)
	sit(m, facing)
	local thigh = m:FindFirstChild("LeftUpperLeg") :: BasePart?
	if thigh then
		local seatTop = anchor.Position.Y - 1.4
		local dy = seatTop + thigh.Size.Z * 0 + 0.45 - thigh.Position.Y
		m:PivotTo(CFrame.new(0, dy, 0) * m:GetPivot())
	end
	m.Name = person and person.name or ("Worker " .. slot)
	m:SetAttribute("Slot", slot)
	return m
end

-- state: the company; keeps workspace.Avatars in sync with the people at visible desks
function Avatars.sync(state)
	if building then
		return
	end
	building = true
	local rooms = workspace:FindFirstChild("Rooms")
	local room = rooms and rooms:FindFirstChild("Stage" .. tostring(state.office))
	local folder = workspace:FindFirstChild("Avatars")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Avatars"
		folder.Parent = workspace
	end
	local want: { [number]: { key: string, person: any, anchor: BasePart } } = {}
	if room then
		local head = 0
		for _, n in pairs(state.staff or {}) do
			head += n
		end
		for _, w in ipairs(room:GetDescendants()) do
			if w:IsA("BasePart") and w.Name == "Torso" then
				local slot = w:GetAttribute("WorkerSlot")
				if typeof(slot) == "number" and slot <= head and slot <= 40 then
					local person = state.people and state.people[slot]
					local key = (person and person.userId and ("u" .. person.userId)) or (person and ("p" .. tostring(person.id))) or ("x" .. slot)
					want[slot] = { key = state.office .. key, person = person, anchor = w }
				end
			end
		end
	end
	for _, m in ipairs(folder:GetChildren()) do
		local slot = m:GetAttribute("Slot")
		local w = typeof(slot) == "number" and want[slot]
		if not w or m:GetAttribute("Key") ~= w.key then
			m:Destroy()
		else
			want[slot] = nil
		end
	end
	for slot, w in pairs(want) do
		local m = make(w.person, slot, w.anchor)
		if m then
			m:SetAttribute("Key", w.key)
			m.Parent = folder
		end
		task.wait()
	end
	building = false
end

return Avatars

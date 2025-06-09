--[[
Created by: mqt464
Last update: June 9th, 2025
]]

local runService = game:GetService("RunService")
local Players = game:GetService("Players")

local export type valueType = string | number | boolean

local supportedValues = {
	number = "NumberValue",
	string = "StringValue",
	boolean = "BoolValue"
}

local settings = {}
local changedEvent = Instance.new("BindableEvent")

local function getSettingsFolder(): Folder?
	if not runService:IsClient() then return nil end

	local player = Players.LocalPlayer
	if not player then return nil end

	local folder = player:FindFirstChild("settings")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "settings"
		folder.Parent = player
	end

	return folder
end

local function resolveKeyPath(key: string): (Folder?, string)
	local segments = key:split(".")
	local settingName = table.remove(segments, #segments)
	local root = getSettingsFolder()
	if not root then return nil, "" end

	local current = root
	for _, segment in ipairs(segments) do
		local child = current:FindFirstChild(segment)
		if not child then
			child = Instance.new("Folder")
			child.Name = segment
			child.Parent = current
		end
		if child:IsA("Folder") then
			current = child
		else
			warn(`Invalid namespace structure for key "{key}"`)
			return nil, ""
		end
	end

	return current, settingName
end

local function createOrGetValueBase(parent: Folder, key: string, value: valueType): ValueBase
	local existing = parent:FindFirstChild(key)
	if existing and existing:IsA("ValueBase") then
		return existing
	end

	local valueTypeName = typeof(value)
	local className = supportedValues[valueTypeName]
	assert(className, `Unsupported type '{valueTypeName}' for key '{key}'`)

	local valueBase = Instance.new(className)
	valueBase.Name = key
	valueBase.Value = value
	valueBase.Parent = parent

	return valueBase
end

function settings.set(key: string, value: valueType)
	if not runService:IsClient() then return end

	local parent, name = resolveKeyPath(key)
	if not parent then return end

	local valueObj = createOrGetValueBase(parent, name, value)
	valueObj.Value = value

	local signal = valueObj:FindFirstChildOfClass("BindableEvent") or Instance.new("BindableEvent", valueObj)

	valueObj:GetPropertyChangedSignal("Value"):Connect(function()
		signal:Fire(valueObj.Value)
		changedEvent:Fire(key, valueObj.Value)
	end)

	local self = {}
	self.Name = key

	function self:Connect(callback: (newValue: valueType) -> ())
		return signal.Event:Connect(callback)
	end

	function self:Disconnect()
		signal:Destroy()
	end

	function self:set(newValue: valueType)
		valueObj.Value = newValue
	end

	return self
end

function settings.get(key: string): { Name: string, Value: valueType }?
	if not runService:IsClient() then return end

	local parent, name = resolveKeyPath(key)
	if not parent then return end

	local obj = parent:FindFirstChild(name)
	if obj and obj:IsA("ValueBase") then
		return { Name = obj.Name, Value = obj.Value }
	end
end

function settings.getOrDefault(key: string, defaultValue: valueType): valueType
	local result = settings.get(key)
	if result then
		return result.Value
	end
	return defaultValue
end

function settings.delete(key: string)
	local parent, name = resolveKeyPath(key)
	if parent then
		local child = parent:FindFirstChild(name)
		if child then
			child:Destroy()
		end
	end
end

function settings:export(): { [string]: valueType }
	local folder = getSettingsFolder()
	if not folder then return {} end

	local results = {}

	local function collectValues(obj: Instance, path: string)
		for _, child in obj:GetChildren() do
			local newPath = path ~= "" and path .. "." .. child.Name or child.Name
			if child:IsA("ValueBase") then
				results[newPath] = child.Value
			elseif child:IsA("Folder") then
				collectValues(child, newPath)
			end
		end
	end

	collectValues(folder, "")
	return results
end

function settings:import(data: { [string]: valueType })
	for key, value in data do
		settings.set(key, value)
	end
end

function settings.onChanged(callback: (key: string, value: valueType) -> ())
	return changedEvent.Event:Connect(callback)
end

return settings

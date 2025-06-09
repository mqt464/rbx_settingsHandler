# Documentation created by ChatGPT, because I am lazy

---

## 📘 `settings` Module Documentation

A client-only module for managing per-player settings using `ValueBase` objects, supporting namespaced keys, change signals, export/import, and value safety.

---

### 🔧 Module Overview

* Stores and organises local player settings in a `Folder` under `Players.LocalPlayer`
* Supports primitive types: `string`, `number`, and `boolean`
* Automatically handles change signals for each setting
* Supports dot-notation for nested organisation (e.g. `"audio.volume"`)
* Includes global `.onChanged` event
* Includes utility functions for export/import and safe deletion

---

### 🧩 Types

```lua
type valueType = string | number | boolean
```

---

### 📂 Structure

```
Players.LocalPlayer
└── settings (Folder)
    └── audio (Folder)
        └── volume (NumberValue)
    └── video (Folder)
        └── quality (StringValue)
```

---

## #📘 API Reference

---

#### 🔹 `settings.set(key: string, value: valueType) → SettingHandle`

Creates or updates a setting. Automatically creates folders for namespaced keys (e.g. `"audio.volume"`).

**Returns:**
A `SettingHandle` that allows `.Connect(callback)`, `.Disconnect()`, and `.set(value)`.

**Example:**

```lua
local volume = settings.set("audio.volume", 0.8)

volume:Connect(function(newVal)
	print("Volume changed to:", newVal)
end)

volume:set(0.5)
```

---

#### 🔹 `settings.get(key: string) → { Name: string, Value: valueType }?`

Retrieves the value and name of a setting. Returns `nil` if the key doesn't exist.

**Example:**

```lua
local result = settings.get("video.quality")
if result then
	print(result.Name, result.Value)
end
```

---

#### 🔹 `settings.getOrDefault(key: string, defaultValue: valueType) → valueType`

Returns the setting's value if it exists, or the provided fallback value otherwise.

**Example:**

```lua
local language = settings.getOrDefault("user.language", "en")
```

---

#### 🔹 `settings.delete(key: string) → nil`

Removes a setting (including its `ValueBase` object). Does nothing if the key doesn’t exist.

**Example:**

```lua
settings.delete("audio.volume")
```

---

#### 🔹 `settings:export() → { [string]: valueType }`

Exports all settings as a flat dictionary with dot-separated keys. Useful for saving settings between sessions.

**Example:**

```lua
local data = settings:export()
-- { ["audio.volume"] = 0.5, ["video.quality"] = "high" }
```

---

#### 🔹 `settings:import(data: { [string]: valueType }) → nil`

Loads settings from a previously exported table.

**Example:**

```lua
settings:import({
	["audio.volume"] = 0.7,
	["video.quality"] = "medium"
})
```

---

#### 🔹 `settings.onChanged(callback: (key: string, value: valueType) → ()) → RBXScriptConnection`

Connects a listener to changes of **any** setting.

**Example:**

```lua
settings.onChanged(function(key, value)
	print(`Setting changed: {key} = {value}`)
end)
```

---

### 🧪 SettingHandle Methods

Returned from `settings.set(...)`

```lua
local handle = settings.set("game.difficulty", "hard")
```

#### 🔸 `handle:Connect(callback: (value: valueType) → RBXScriptConnection)`

Connects to changes for that specific setting.

---

#### 🔸 `handle:set(newValue: valueType) → nil`

Manually updates the setting's value.

---

#### 🔸 `handle:Disconnect() → nil`

Disconnects internal signals for the setting and resets the event.

---

### 🛡️ Limitations

* **Client-only**: Must be used in **LocalScripts**, not on the server
* **No replication**: Settings are not synced across devices unless you manually export/import

---

### ✅ Example Usage

```lua
local settings = require(path.to.settings)

local music = settings.set("audio.music", true)

music:Connect(function(enabled)
	print("Music toggled:", enabled)
end)

music:set(false)

local all = settings:export()
settings:import(all)
```

---

Let me know if you'd like a Markdown or HTML version of this doc for a DevForum post, GitHub README, or in-game UI integration.

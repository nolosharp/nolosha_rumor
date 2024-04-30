---@class Rumor
---@field rumor stringlib
---@field createdAt integer

---@class RumorArea
---@field id integer
---@field rumors table<integer, Rumor>

---@alias RumorList table<integer, RumorArea>

---@type RumorList
Rumors = {}

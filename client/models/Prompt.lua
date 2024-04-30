---@class Prompt
Prompt = {}
Prompt.handle = 0
Prompt.visible = true
Prompt.label = ''
Prompt.group = 0
Prompt.eventTriggered = false


function Prompt:Delete()
    --Citizen.InvokeNative(0x00EDE88D4D13CF59, self.handle) -- UiPromptDelete
    PromptDelete(self.handle)
end

function Prompt:IsPressed()
    --return Citizen.InvokeNative(0xE0F65F0640EF0617, self.handle) -- UiPromptHasHoldModeCompleted
    return Citizen.InvokeNative(0xC92AC953F0A982AE, self.handle) -- UiPromptHasStandardModeCompleted
end

function Prompt:GetEnabled()
    --return Citizen.InvokeNative(0x0D00EDDFB58B7F28, self.handle) == 1
end

function Prompt:SetEnabled(enabled)
    --Citizen.InvokeNative(0x8A0FB4D03A630D21, self.handle, enabled) -- UiPromptSetEnabled
end

function Prompt:GetVisible()
    --return self.visible
end

function Prompt:SetVisible(visible)
    if visible == self.visible then
        return
    end
    self.visible = visible
    self:SetEnabled(visible)
    --Citizen.InvokeNative(0x71215ACCFDE075EE, self.handle, visible) -- UiPromptSetVisible
end

function Prompt:SetActiveGroupThisFrame()
    PromptSetActiveGroupThisFrame(self.group, self.label)
end

---@return Prompt
function Prompt:new(control, label, group)
    local priority = 1
    local transportMode = 0

    --local promptHandle = Citizen.InvokeNative(0x04F97DE45A519419) -- UiPromptRegisterBegin
    local promptHandle = PromptRegisterBegin()-- UiPromptRegisterBegin

    --Citizen.InvokeNative(0xB5352B7494A08258, promptHandle, control) -- UiPromptSetControlAction
    PromptSetControlAction(promptHandle, control)

    local strLabel = CreateVarString(10, "LITERAL_STRING", label)
    --Citizen.InvokeNative(0x5DD02A8318420DD7, promptHandle, strLabel) -- UiPromptSetText
    PromptSetText(promptHandle, strLabel)

    PromptSetEnabled(promptHandle, 1)
    PromptSetVisible(promptHandle, 1)
    PromptSetStandardMode(promptHandle, 1)
    -- Citizen.InvokeNative(0xCA24F528D0D16289, promptHandle, priority) -- UiPromptSetPriority
    -- Citizen.InvokeNative(0x876E4A35C73A6655, promptHandle, transportMode) -- UiPromptSetTransportMode
    -- Citizen.InvokeNative(0x560E76D5E2E1803F, promptHandle,  18, true) -- UiPromptSetAttribute

    --Citizen.InvokeNative(0xCC6656799977741B, promptHandle, true)

    if group <= 0 then
        group = GetRandomIntInRange(0, 0xffffff)
    end

    --Citizen.InvokeNative(0x2F11D3A254169EA4, promptHandle, group, 0) -- UiPromptSetGroup
    PromptSetGroup(promptHandle, group)

    Citizen.InvokeNative(0xC5F428EE08FA7F2C, promptHandle, true)
   
    -- Citizen.InvokeNative(0x71215ACCFDE075EE, promptHandle, false) -- UiPromptSetVisible
    -- Citizen.InvokeNative(0x8A0FB4D03A630D21, promptHandle, false) -- UiPromptSetEnabled

    --Citizen.InvokeNative(0xF7AA2696A22AD8B9, promptHandle) -- UiPromptRegisterEnd
    PromptRegisterEnd(promptHandle)

    local t = {handle = promptHandle, label = label, group = group}
	setmetatable(t, self)
	self.__index = self
	return t
end
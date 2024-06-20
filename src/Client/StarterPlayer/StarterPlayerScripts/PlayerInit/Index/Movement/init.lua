--! strict
--! optimize 2
--! native

local configuration = {
    ["SPRINT_KEY"] = Enum.KeyCode.LeftShift,
        ["SPRINT_COOLDOWN"] = 2,
        ["SPRINT_SPEED"] = 24,
    ["DASH_KEY"] = Enum.KeyCode.Q,
        ["DASH_COOLDOWN"] = 4
};

local Movement = {};
Movement.__index = Movement;

-- [[ Variables ]]:

local Players = game:GetService("Players");
local StarterPlayer = game:GetService("StarterPlayer");
local UserInputService = game:GetService("UserInputService");

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait();

local Janitor = require(script.Utils.Janitor);

local SprintDebounce = false;
local DashDebounce = false;

-- [[ Functions ]]:

-- Initalizes Movement (Should be run ``Once`` on Client).
function Movement:Init()
    if LocalPlayer.Character then
        coroutine.wrap(function()
            self:CharacterAdded();
        end)();
    end;

    LocalPlayer.CharacterAdded:Connect(function()
        coroutine.wrap(function()
            self:CharacterAdded();
        end)();
    end);
end

function Movement:CharacterAdded()
    local self = setmetatable({}, Movement);

    self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() :: Model;
    self.Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid;
    self.RootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart;

    self._connectionsJanitor = Janitor.new();

    self._connectionsJanitor:Add(UserInputService.InputBegan:Connect(function(Input: InputObject, gameProcessedEvent: boolean)
        if Input.KeyCode == configuration.SPRINT_KEY then
            self:SprintInit();
        elseif Input.KeyCode == configuration.DASH_KEY then
            self:DashInit();
        end;
    end));

    self._connectionsJanitor:Add(UserInputService.InputEnded:Connect(function(Input: InputObject)
        if Input.KeyCode == configuration.SPRINT_KEY then
            self:SprintTerm();
        end;
    end));
end

local DEFAULT_WALKSPEED = StarterPlayer.CharacterWalkSpeed;

function Movement:SprintInit()
    assert(self.Humanoid, "(ERROR) This is a read-only function");
    if SprintDebounce then return end;
    SprintDebounce = true;

    self.Humanoid.WalkSpeed = configuration.SPRINT_SPEED;
end

function Movement:SprintTerm()
    assert(self.Humanoid, "(ERROR) This is a read-only function");
    if not SprintDebounce then return end;

    self.Humanoid.WalkSpeed = DEFAULT_WALKSPEED;

    task.wait(configuration.SPRINT_COOLDOWN);
    SprintDebounce = false;
end
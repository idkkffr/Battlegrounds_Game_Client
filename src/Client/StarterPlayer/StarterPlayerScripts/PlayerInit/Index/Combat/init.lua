--! strict
--! optimize 2
--! native

local type = require(script.type)

local Combat: type.Combat = {};
Combat.__index = Combat;

-- [[ Variables ]]:

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer");
local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait();

local Utils = script.Utils
    local Janitor = require(Utils.Janitor);
    
local Knockback = require(script.Knockback);

--  Configuration
local CombatDebounce = false;
local HoldingM1 = false; -- (READ-ONLY) Returns if the player is holding Left Mouse Button.

local DebounceTime = .5; -- How Long the player has to wait between debounces.
local MaxTime = 2; -- How long the player has to wait after hitting a max combo.

local MaxCombo = 4; -- The combo limit.

local LastM1 = os.clock(); -- (READ-ONLY) Returns the last time the player M1ed.
local TimeWindow = 1.5; -- How long the player can wait between m1s to continue

-- [[ Functions ]]:

-- Initalizes Combat (Should be run ``Once`` on Client).
function Combat:Init()
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

function Combat:CharacterAdded()
    local self: type.selfobj = setmetatable({}, Combat);

    self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() :: Model;
    self.Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid;
    self.RootPart = self.Character:WaitForChild("HumanoidRootPart") :: BasePart;
    self.Combo = 0

    self._connectionsJanitor = Janitor.new();

    self._connectionsJanitor:Add(function()
        ContextActionService:UnbindAction("M1")
    end);

    ContextActionService:BindAction("M1", function(_, UserInputState)
        HoldingM1 = (UserInputState == Enum.UserInputState.Begin)
    end, true, Enum.UserInputType.MouseButton1)

    self._connectionsJanitor:Add(RunService.RenderStepped:Connect(function(DeltaTime: number) -- Time Between Frame
        if not (HoldingM1) then self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) return end;
        self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
        if (CombatDebounce) then return end;
        CombatDebounce = true;

        if (self.Combo >= MaxCombo) and (os.clock() - LastM1) - DeltaTime < MaxTime then
            self.Combo = 0;

            task.wait(MaxTime - (os.clock() - LastM1))
            LastM1 = os.clock();
            CombatDebounce = false;
            return;
        end;

        if ((os.clock() - LastM1) - DeltaTime >= TimeWindow) then
            self.Combo = 0;
        end;

        LastM1 = os.clock();

        self.Combo += 1;

        self:BeginCombat();

        task.wait(DebounceTime);
        CombatDebounce = false;
    end));
end

function Combat.BeginCombat(self: type.selfobj)
    assert(self.Combo, "(ERROR) This is a read-only function");

    self.Target = Workspace:FindFirstChild("Dummy");

    if self.Combo < MaxCombo then
        Knockback:Impulse(self.Character, self.Target, 2.5, 0)
        Knockback:Impulse(self.Character, self.Character, 2, 0)
    elseif self.Combo >= MaxCombo then
        local Special = if self.Humanoid.FloorMaterial == Enum.Material.Air then 1 elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) then 2 else 3

        if Special == 1 then
            -- Downslam
            print("Downslam!")
            Knockback:Impulse(self.Character, self.Target, 0.5, -10)

        elseif Special == 2 then
            -- Uppercut
            print("Uppercut!")
            Knockback:Impulse(self.Character, self.Target, 0.5, 4)
        elseif Special == 3 then
            -- Forward
            print("Finisher!")
            Knockback:Impulse(self.Character, self.Target, 10, 1.5)
        end
    end
end

return Combat
local Stun = {}

function Stun:Init(Character: Model)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then return end
end

return Stun
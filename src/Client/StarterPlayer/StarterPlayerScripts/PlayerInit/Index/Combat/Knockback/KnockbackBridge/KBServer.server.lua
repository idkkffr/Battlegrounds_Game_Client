local KnockbackBridge = script.Parent;

KnockbackBridge.OnServerEvent:Connect(function(Player, Target: Model, Force)
    for Index, Part: Part in pairs(Target:GetChildren()) do
        if Part:IsA("Part") then Part:SetNetworkOwner(Player); end
    end;

    Target.PrimaryPart:ApplyImpulse(Force)
end);
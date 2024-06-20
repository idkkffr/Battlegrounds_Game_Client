--! strict
export type Janitor = {
    Add: (self: Janitor) -> (),
    Destroy: (self: Janitor) -> (),
    Cleanup: (self: Janitor) -> ()
}

export type Combat = {
    Init: (self: Combat) -> (selfobj),
}

export type selfobj = {
    Combo: number,

    _connectionsJanitor: Janitor,

    Character: Model,
    Humanoid: Humanoid,
    RootPart: BasePart,

    BeginCombat: (self: selfobj) -> (),
    CharacterAdded: (self: selfobj) -> (),
}

return nil
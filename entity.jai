Entity :: struct {
    type: enum {
        HERO;
        CREEP;
    }
    union {
        hero: Hero;
        creep: Creep;
    }
    stats: Stat_Block;
    using position: Vector3;
    battle_position: Vector3;
    representation_color: Vector4;
    representation_size: Vector2;
    hp: float;
    mana: float;
    unit_name: string;
}

Hero :: struct {
    id: Hero_ID;
    spells: [4] Spell;
}

Creep :: struct {
    id: Creep_ID;
}

Stat_Block :: struct {
    base_health: float;
    base_mana: float;
    base_attack: Attack;
    base_move_speed: float;
    strength: float;
    agility: float;
    intelligence: float;
}

Spell :: struct {
    target: enum {
        PASSIVE;
        POINT;
        UNIT;
        AREA;
    }
    name: string;
    cooldown: int;
    cooldown_remaining: int = 0;
}

Attack :: struct {
    type: enum {
        MELEE;
        RANGED;
    }
    damage: float;
    base_attack_speed: float;
    base_attack_time: float;
}

Hero_ID :: enum {
    EARTHSHAKER;
    JUGGERNAUT;
}
Creep_ID :: enum {
    SKELETON;
    SKELETON_ARCHER;
}

// Hero Templates
HERO_TEMPLATE_EARTHSHAKER :: Entity.{
    type = .HERO,
    hero = .{
        .EARTHSHAKER,
        .[.{.POINT, "Fissure", 3, 0}, .{.POINT, "Enchant Totem", 2, 0}, .{.PASSIVE, "Aftershock", 0, 0}, .{.POINT, "Echo Slam", 12, 0}],
    },
    stats = .{
        base_health = 500,
        base_mana = 200,
        base_attack = .{.MELEE, 50.0, 100.0, 1.7},
        base_move_speed = 5.0,
        strength = 12,
        agility = 10,
        intelligence = 10,
    },
    representation_color = .{1, 0, 0, 1},
    representation_size = .{50, 50},
    unit_name = "Earthshaker",
};
HERO_TEMPLATE_JUGGERNAUT :: Entity.{
    type = .HERO,
    hero = .{
        .JUGGERNAUT,
        .[.{.POINT, "Battlefury", 3, 0}, .{.POINT, "Healing Ward", 6, 0}, .{.PASSIVE, "Blade Dance", 0, 0}, .{.POINT, "Omnislash", 12, 0}],
    },
    stats = .{
        base_health = 500,
        base_mana = 200,
        base_attack = .{.MELEE, 60.0, 100.0, 1.5},
        base_move_speed = 6.0,
        strength = 10,
        agility = 12,
        intelligence = 10,
    },
    representation_color = .{0, 1, 0, 1},
    representation_size = .{50, 50},
    unit_name = "Juggernaut",
};
CREEP_TEMPLATE_SKELETON :: Entity.{
    type = .CREEP,
    creep = .{.SKELETON},
    stats = .{
        base_health = 200,
        base_mana = 0,
        base_attack = .{.MELEE, 16.0, 100.0, 1.85},
        base_move_speed = 5.0,
        strength = 0,
        agility = 0,
        intelligence = 0,
    },
    representation_color = .{0.8, 0.8, 0.8, 1},
    representation_size = .{20, 20},
    unit_name = "Skeleton",
};
CREEP_TEMPLATE_SKELETON_ARCHER :: Entity.{
    type = .CREEP,
    creep = .{.SKELETON_ARCHER},
    stats = .{
        base_health = 200,
        base_mana = 0,
        base_attack = .{.RANGED, 16.0, 100.0, 1.85},
        base_move_speed = 5.0,
        strength = 0,
        agility = 0,
        intelligence = 0,
    },
    representation_color = .{1, 1, 1, 1},
    representation_size = .{20, 20},
    unit_name = "Skeleton Archer",
};
game: struct {
    quit := false;
    resetting := false;
    current_time: float64;
    last_time: float64;
    dt: float;

    player_in_combat := false;
    battle_start_time: float64;

    player: struct {
        using #as entity: Entity;
        overworld_speed: float : 5.0;
    }

    grid: struct {
        height :: 1000;
        width  :: 1000;
        cell_size :: 25.0;
    }

    battle_arena: struct {
        bottom_left: Vector2;
        top_right:   Vector2;
    }

    camera: struct {
        position: Vector3;
    }

    entities: [..] Entity;

    battle: struct {
        opponent: struct {
            using entity: *Entity;
        }
        is_player_turn: bool;
        ply: enum {
            PLAYER_PLY_1;
            PLAYER_PLY_2;
            OPPONENT_PLY_1;
            OPPONENT_PLY_2;
            PLAYER_PLY_3;
            OPPONENT_PLY_3;
        }
    }
}

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
        POINT;
        UNIT;
        AREA;
    }
    name: string;
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
        .[.{.POINT, "Fissure"}, .{.POINT, "Enchat Totem"}, .{.POINT, "Aftershock"}, .{.POINT, "Echo Slam"}],
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
};
HERO_TEMPLATE_JUGGERNAUT :: Entity.{
    type = .HERO,
    hero = .{
        .JUGGERNAUT,
        .[.{.POINT, "Battlefury"}, .{.POINT, "Healing Ward"}, .{.POINT, "Blade Dance"}, .{.POINT, "Omnislash"}],
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
};

game_loop :: () {
    using game;

    current_time = get_time();
    dt = xx (current_time - last_time);
    defer last_time = current_time;

    simulate();

    reset_temporary_storage();
}

game_reset :: () {
    log("RESETTING GAME");
    game = .{};

    game.battle_arena.bottom_left = .{300, hud_height};
    game.battle_arena.top_right   = .{xx window.width - 600.0, xx window.height - 300.0};

    {
        e := HERO_TEMPLATE_EARTHSHAKER;
        e.position = .{500, 500, 0};
        e.battle_position = .{500, 300, 0};
        game.player.entity = e;
    }
    {
        e := HERO_TEMPLATE_JUGGERNAUT;
        e.position = .{600, 600, 0};
        e.battle_position = .{600, 600, 0};
        array_add(*game.entities, e);
    }
}

simulate :: () {
    using game;
    using Input_Controller;

    // Simulate player --------------------------------------------
    x_direction : s64 = key_left ^ key_right;
    if key_left && !key_right then x_direction *= -1;
    y_direction : s64 = key_down ^ key_up;
    if key_down && !key_up then y_direction *= -1;

    player.position += normalize(Vector3.{xx x_direction, xx y_direction, 0}) * player.overworld_speed;

    // Simulate camera -------------------------------------------
    camera.position = player.position;

    // Battle logic ----------------------------------------------
    
}

can_cast_spell :: (spell: Spell) -> bool {
    return true;
}
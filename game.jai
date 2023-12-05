game: struct {
    quit := false;
    resetting := false;
    current_time: float64;
    last_time: float64;
    dt: float;

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
        start_time: float64;

        opponent: struct {
            using entity: *Entity;
        }
        
        ply: Ply;
        Ply :: enum {
            PLAYER_PLY_1;
            PLAYER_PLY_2;
            OPPONENT_PLY_1;
            OPPONENT_PLY_2;
            PLAYER_PLY_3;
            OPPONENT_PLY_3;
        }

        highlighted_spell := -1;
        ai_message_start_time: float64;
        ai_ply_duration: float : 2.0;
    }
}

player_in_battle :: () -> bool {
    return game.battle.opponent.entity != null;
}

is_player_turn :: () -> bool {
    return game.battle.ply == .PLAYER_PLY_1 || game.battle.ply == .PLAYER_PLY_2 || game.battle.ply == .PLAYER_PLY_3;
}

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
    if is_player_turn() {
        if spell_1 {
            battle.highlighted_spell = 0;
            spell_1 = false;
        }
        if spell_2 {
            battle.highlighted_spell = 1;
            spell_2 = false;
        }
        if spell_3 {
            battle.highlighted_spell = 2;
            spell_3 = false;
        }
        if spell_4 {
            battle.highlighted_spell = 3;
            spell_4 = false;
        }
    } else {
        if get_time() - battle.ai_message_start_time > battle.ai_ply_duration {
            chosen_spell := cast(int) random_get_within_range(0, battle.opponent.hero.spells.count);
            print("AI casts %\n", battle.opponent.hero.spells[chosen_spell]);
            advance_battle();
        }
    }

    player_used_ply := false;
    if battle.highlighted_spell >= 0 {
        if mouse_button_right {
            battle.highlighted_spell = -1;
            mouse_button_right = 0;
        } else if mouse_button_left {
            print("Player casts %\n", player.hero.spells[battle.highlighted_spell]);
            player_used_ply = true;
            battle.highlighted_spell = -1;
            mouse_button_left = 0;
        }
    }

    if player_used_ply {
        advance_battle();
    }
}

advance_battle :: () {
    game.battle.ply = cast(game.battle.Ply) ((cast(int) game.battle.ply + 1) % (enum_highest_value(game.battle.Ply) + 1));
    print("Advancing to %\n", game.battle.ply);
    if !is_player_turn() {
        game.battle.ai_message_start_time = get_time();
    }
}

can_cast_spell :: (spell: Spell) -> bool {
    return true;
}
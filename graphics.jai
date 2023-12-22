cursor: Vector2 = .{503, 660};
intro_duration :: 0.5;
hud_height :: 200.0;

render :: () {
    using game;
    Simp.clear_render_target(0, 0, 0, 1);
    Simp.set_shader_for_color();

    // Simp.prepare_text(fonts.OpenSans, "test");
    // Simp.draw_prepared_text(fonts.OpenSans, xx cursor.x, xx cursor.y, Vector4.{1, 1, 1, 1});

    time_since_start := current_time - battle.start_time;
    should_play_battle_intro := player_in_battle() && time_since_start < intro_duration;
    should_draw_overworld := !player_in_battle() || (player_in_battle() && time_since_start < intro_duration/2.0);
    if should_draw_overworld {
        draw_grid();
        draw_overworld_entity(player);
        for e: entities {
            draw_overworld_entity(e);
        }
    } else if player_in_battle() {
        draw_battle();
    }
    if should_play_battle_intro {
        should_play_battle_intro = draw_battle_curtain(time_since_start);
    }

    Simp.swap_buffers(window.handle);
}

draw_grid :: () {
    using game;

    left_bound   := camera.position.x - window.width/2.0;
    right_bound  := camera.position.x + window.width/2.0;
    bottom_bound := camera.position.y - window.width/2.0;
    top_bound    := camera.position.y + window.width/2.0;

    left_column  := cast(int) (left_bound / grid.cell_size);
    right_column := cast(int) (right_bound / grid.cell_size);
    bottom_row   := cast(int) (bottom_bound / grid.cell_size);
    top_row      := cast(int) (top_bound / grid.cell_size);

    for row: bottom_row..top_row {
        for col: left_column-1..right_column {
            draw_rectangle(ss(.{col * grid.cell_size, row * grid.cell_size}), 
                .{grid.cell_size, grid.cell_size}, 
                .{0.1, 0.1, 0.1, 1});
        }
    }
}

draw_overworld_entity :: (e: Entity) {
    draw_rectangle(ss(e.position.xy), e.representation_size, e.representation_color); 
}
draw_battle_entity :: (e: Entity) {
    draw_rectangle(e.battle_position.xy, e.representation_size, e.representation_color); 
}

draw_battle_curtain :: (time_since_start: float64) -> bool {
    half_duration := intro_duration/2.0;
    if time_since_start < intro_duration/2.0 {
        progress := cast(float) (time_since_start / half_duration);
        draw_rectangle(.{0, 0}, .{xx window.width, progress * xx window.height}, .{1,1,1,1});
        return true;
    } else if time_since_start < intro_duration {
        progress := cast(float) (time_since_start - half_duration) / half_duration;
        draw_rectangle(.{0, 0}, .{xx window.width, (1.0 - progress) * xx window.height}, .{1,1,1,1});
        return true;
    } else return false;
}

draw_battle :: () {
    using game;
    draw_rectangle_outline(battle_arena.bottom_left, battle_arena.top_right, 4.0, .{1, 1, 1, 1});
    draw_battle_entity(player);
    draw_battle_entity(entities[0]);

    // UI ------------------------------------------------------------------------
    draw_rectangle(.{}, .{xx window.width, hud_height}, .{0.4, 0.4, 0.4, 1});
    
    cursor := Vector2.{300, 50};
    for spell: player.hero.spells {
        color := Vector4.{0.8, 0.8, 0.8, 1};
        if !can_cast_spell(it_index) color = Vector4.{0.6, 0.6, 0.6, 1};
        if battle.highlighted_spell == it_index then color = Vector4.{1,1,1,1};
        draw_rectangle(cursor, .{75, 75}, color);
        if spell.cooldown_remaining {
            Simp.set_shader_for_text();
            cd := sprint("%", spell.cooldown_remaining);
            offset := ifx spell.cooldown_remaining <= 9 then Vector2.{25, 20} else Vector2.{12, 20};
            position := cursor + offset;
            Simp.draw_text(fonts.OpenSans, xx position.x, xx position.y, cd, Vector4.{1,1,1,1});
        }
        Simp.set_shader_for_color();
        cursor.x += 100;
    }

    if battle.highlighted_spell >= 0 {
        draw_rectangle(.{Input_Controller.mouse_x, Input_Controller.mouse_y} - .{5,5}, .{10,10}, Vector4.{1,0,0,1});
    }

    if !is_player_turn() {
        Simp.set_shader_for_text();
        Simp.draw_text(fonts.OpenSans, xx window.width/2, xx window.height/2, "ENEMY TURN", Vector4.{1,1,1,1});
        Simp.set_shader_for_color();
    }

    Simp.set_shader_for_text();
    Simp.draw_text(fonts.OpenSans, xx window.width/2, 130, sprint("%", player.unit_name), Vector4.{1,1,1,1});
    Simp.draw_text(fonts.OpenSans, xx window.width/2, 70, sprint("HP: %", player.hp), Vector4.{1,1,1,1});
    Simp.draw_text(fonts.OpenSans, xx window.width/2, 30, sprint("Mana: %", player.mana), Vector4.{1,1,1,1});
    Simp.set_shader_for_color();
}

// Helpers -----------------------------------------------------------------------
draw_rectangle :: (position: Vector2, size: Vector2, color: Vector4) {
    Simp.immediate_quad(position.x, position.y, position.x + size.x, position.y + size.y, color);
}

draw_rectangle_outline :: (position: Vector2, size: Vector2, thickness: float, color: Vector4) {
    // left edge
    Simp.immediate_quad(position.x, position.y, position.x + thickness, position.y + size.y, color);
    // right edge
    Simp.immediate_quad(position.x + size.x - thickness, position.y, position.x + size.x, position.y + size.y, color);
    // bottom edge
    Simp.immediate_quad(position.x + thickness, position.y, position.x + size.x - thickness, position.y + thickness, color);
    // top edge
    Simp.immediate_quad(position.x + thickness, position.y + size.y - thickness, position.x + size.x - thickness, position.y + size.y, color);
}

ss :: world_to_screen;
world_to_screen :: (world: Vector2) -> screen: Vector2 {
    to_ss_vector := Vector2.{xx window.width/2.0, xx window.height/2.0} - game.camera.position.xy;
    return world + to_ss_vector;
}
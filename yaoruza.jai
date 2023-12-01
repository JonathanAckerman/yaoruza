window: struct {
    width := 1920;
    height := 1080;
    handle: Window_Type;
    saved_info: Saved_Window_Info;
}

Input_Controller: struct {
    key_left:  u32;
    key_right: u32;
    key_up:    u32;
    key_down:  u32;

    mouse_x: float;
    mouse_y: float;
}

main :: () {
    #run {
        #if OS == .WINDOWS {
            WR :: #import "Windows_Resources";
            //WR.disable_runtime_console();
        }
    }

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window.handle = create_window(window.width, window.height, "yaoruza", 2560);
    toggle_fullscreen(window.handle, true, *window.saved_info);
    Simp.set_render_target(window.handle);
    init_fonts();

    game.resetting = true;
    while game.resetting {
        game_reset();
        while !game.quit {
            handle_input();
            game_loop();
            render();
        }
    }
}

handle_input :: () {
    using Input_Controller;

    Input.update_window_events();
    for Input.get_window_resizes() {
        Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.            
        if it.window == window.handle {
            should_reinit := (it.width != window.width) || (it.height != window.height);
            window.width  = it.width;
            window.height = it.height;
            if should_reinit init_fonts();  // Resize the font for the new window size.
        }
    }
    for event : Input.events_this_frame {
        if event.type == .QUIT then game.quit = true;

        if event.type == .KEYBOARD {
            key := event.key_code;

            if key == .ESCAPE then game.quit = true;
            if key == .F5     then game.resetting = true;

            if !game.player_in_combat {
                if key == .ARROW_LEFT  || key == #char "A" then key_left = event.key_pressed;
                if key == .ARROW_RIGHT || key == #char "D" then key_right = event.key_pressed;
                if key == .ARROW_UP    || key == #char "W" then key_up = event.key_pressed;
                if key == .ARROW_DOWN  || key == #char "S" then key_down = event.key_pressed;
            } else {
                if game.battle.is_player_turn {
                    if key == {
                        case #char "Q";
                            if event.key_pressed && Input.input_button_states[key] & .START && !event.repeat {
                                print("%\n", game.player.hero.spells[0]);
                            }
                        case #char "W";
                            if event.key_pressed && Input.input_button_states[key] & .START && !event.repeat {
                                print("%\n", game.player.hero.spells[1]);
                            }
                        case #char "E";
                            if event.key_pressed && Input.input_button_states[key] & .START && !event.repeat {
                                print("%\n", game.player.hero.spells[2]);
                            }
                        case #char "R";
                            if event.key_pressed && Input.input_button_states[key] & .START && !event.repeat {
                                print("%\n", game.player.hero.spells[3]);
                            }
                        case #char "A";
                    }
                }
            }

            // @Debug
            if game.player_in_combat {
                if key == #char "2" then game.player_in_combat = false;
            } else if key == #char "1"{
                game.player_in_combat = true;
                game.battle.is_player_turn = true;
                game.battle_start_time = get_time();
            }
        }
    }

    per_frame_update_mouse_position :: () {
        current_mouse_x, current_mouse_y, success := get_mouse_pointer_position(true);
        if success {
            Input_Controller.mouse_x = xx max(current_mouse_x, 0);
            Input_Controller.mouse_y = xx max(current_mouse_y, 0);
        }
    }
    per_frame_update_mouse_position();
}

init_fonts :: () {
    if !working_directory_set {
        path := path_strip_filename(get_path_of_running_executable());
        set_working_directory(path);
        working_directory_set = true;
    }
    fonts.OpenSans = Simp.get_font_at_size("assets/fonts", "OpenSans-Regular.ttf", window.height/24);
    assert(fonts.OpenSans != null);
}

fonts: struct {
    OpenSans: *Simp.Dynamic_Font;
}

working_directory_set := false;

#load "game.jai";
#load "graphics.jai";

Compiler :: #import "Compiler";
Simp  :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";
#import "Basic";
#import "Math";
#import "Random";
#import "System";  // For get_path_of_running_executable. @Cleanup.
#import "String";  // For path_strip_filename. @Cleanup.
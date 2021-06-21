function Molecule() constructor {
    static MoleculeNode = function(element) constructor {
        static atom_id = 0;
        self.element = element;
        self.id = string(atom_id++);
        self.bonds = { };
        self.valence = element.valence;
        
        Game.player.molecule.set(self);
        
        function Add(node, seen, bonds) {
            if (seen[$ self.id]) return BondStatusCodes.INVALID;
            seen[$ self.id] = true;
            
            // i don't know if this is an actual rule but i've never seen atoms
            // that both have an electronegativity lower than Hydrogen bond so
            // we'll just go with it for now
            if (self.element.electro < 2.3 && node.element.electro < 2.3) {
                return BondStatusCodes.INVALID;
            }
            
            if (!self.Complete()) {
                var diff = node.element.electro - self.element.electro;
                if (abs(diff) < 1.7) {      // covalent
                    var shared = min(node.element.shell_size - node.valence, self.element.shell_size - self.valence, 3);
                    if (shared == 1) bonds = 1;
                    if (bonds != undefined) {
                        shared = min(shared, bonds);
                        self.valence += shared;
                        node.valence += shared;
                        repeat (shared) {
                            self.Bond(node);
                        }
                        show_debug_message("Bonded " + string(self) + " to " + string(node) + " (covalent)");
                        return BondStatusCodes.SUCCESS;
                    } else {
                        #region ask
                        var responses = [
                            {
                                message: "Single",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 1);
                                },
                            },
                        ];
                        if (shared >= 2) {
                            array_push(responses,  {
                                message: "Double",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 2);
                                },
                            });
                        }
                        if (shared >= 3) {
                            array_push(responses,  {
                                message: "Triple",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 3);
                                },
                            });
                        }
                        ui_create_message("How many bonds would you like to create?", responses);
                        return BondStatusCodes.DEFERRED;
                        #endregion
                    }
                } else {                    // ionic
                    var donated;
                    if (self.element.electro < node.element.electro) {
                        donated = min(node.element.shell_size - node.valence, self.valence, 3);
                        if (donated = 1) bonds = 1;
                        if (bonds != undefined) {
                            donated = min(bonds, donated);
                            self.valence -= donated;
                            node.valence += donated;
                        }
                    } else {
                        donated = min(self.element.shell_size - self.valence, node.valence, 3);
                        if (donated = 1) bonds = 1;
                        if (bonds != undefined) {
                            donated = min(bonds, donated);
                            self.valence += donated;
                            node.valence -= donated;
                        }
                    }
                    if (bonds != undefined) {
                        donated = min(bonds, donated);
                        repeat (donated) {
                            self.Bond(node);
                        }
                        show_debug_message("Bonded " + string(self) + " to " + string(node) + " (ionic)");
                        return BondStatusCodes.SUCCESS;
                    } else {
                        #region ask
                        var responses = [
                            {
                                message: "Single",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 1);
                                },
                            },
                        ];
                        if (shared >= 2) {
                            array_push(responses,  {
                                message: "Double",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 2);
                                },
                            });
                        }
                        if (shared >= 3) {
                            array_push(responses,  {
                                message: "Triple",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Add(undefined, 3);
                                },
                            });
                        }
                        ui_create_message("How many bonds would you like to create?", responses);
                        return BondStatusCodes.DEFERRED;
                        #endregion
                    }
                }
                return BondStatusCodes.SUCCESS;
            }
            
            var keys = variable_struct_get_names(self.bonds);
            for (var i = 0; i < array_length(keys); i++) {
                if (Game.player.molecule.get(keys[i]).Add(node, seen, bonds) == BondStatusCodes.SUCCESS) return BondStatusCodes.SUCCESS;
            }
            
            return BondStatusCodes.INVALID;
        }
        
        function Bond(node) {
            if (!variable_struct_exists(self.bonds, node.id)) self.bonds[$ node.id] = 0;
            if (!variable_struct_exists(node.bonds, self.id)) node.bonds[$ self.id] = 0;
            self.bonds[$ node.id]++;
            node.bonds[$ self.id]++;
        }
        
        function Complete() {
            return (self.valence == 0 || self.valence == self.element.shell_size);
        }
        
        function RawScore(seen) {
            if (seen[$ self.id]) return 0;
            seen[$ self.id] = true;
            
            var value = self.element.number;
            var keys = variable_struct_get_names(self.bonds);
            for (var i = 0; i < array_length(keys); i++) {
                value += Game.player.molecule.get(keys[i]).RawScore(seen);
            }
            
            return value;
        }
        
        function Size(seen) {
            if (seen[$ self.id]) return 0;
            seen[$ self.id] = true;
            
            var value = 1;
            var keys = variable_struct_get_names(self.bonds);
            for (var i = 0; i < array_length(keys); i++) {
                value += Game.player.molecule.get(keys[i]).Size(seen);
            }
            
            return value;
        }
        
        function toString() {
            return self.element.name + " (" + string(self.valence) + "/" + string(self.element.shell_size) + ")";
        }
        
        function draw(x, y, seen, symbols = false, starting_angle = undefined, from = undefined) {
            if (seen[$ self.id]) return;
            seen[$ self.id] = true;
            static uniform_color = shader_get_uniform(shd_atom, "color");
            
            var xx = x - Game.player.molecule.draw_center.x;
            var yy = y - Game.player.molecule.draw_center.y;
            
            if (symbols) {
                draw_text_colour(xx, yy, self.element.symbol, c_black, c_black, c_black, c_black, 1);
            } else {
                matrix_set(matrix_world, matrix_build(xx, yy, 0, 0, 0, 0, self.element.radius, self.element.radius, -self.element.radius));
                shader_set_uniform_f(uniform_color, ((self.element.class.color >> 0) & 0xff) / 0xff, ((self.element.class.color >> 8) & 0xff) / 0xff, ((self.element.class.color >> 16) & 0xff) / 0xff);
                vertex_submit(Game.vbuff_atom, pr_trianglelist, -1);
                Game.player.molecule.AdjustDrawBounds(x, y);
            }
            
            var keys = variable_struct_get_names(self.bonds);
            if (array_length(keys) > 0) {
                var spacing = 360 / array_length(keys);
                
                var angles_used = { };
                if (starting_angle != undefined) {
                    angles_used[$ (starting_angle + 180) % 360] = true;
                } else {
                    starting_angle = 0;
                }
                
                var slot = 0;
                for (var i = 0, n = array_length(keys); i < n; i++) {
                    var next = Game.player.molecule.get(keys[i]);
                    if (next == from) continue;
                    var angle;
                    do {
                        angle = (slot++ * spacing + starting_angle + 180) % 360;
                    } until (!angles_used[$ angle]);
                    angles_used[$ angle] = true;
                    var radius = max(self.element.radius, next.element.radius);
                    next.draw(x + radius * dcos(angle), y - radius * dsin(angle), seen, symbols, angle, self);
                }
            }
        };
    };
    
    function Clear() {
        self.root = undefined;
        self.score = 0;
        self.log = [];
        self.cached_node = undefined;
        
        self.all_nodes = { };
        
        self.draw_min = { x: 0, y: 0 };
        self.draw_max = { x: 0, y: 0 };
        self.draw_center = { x: 0, y: 0 };
        
        Game.player.ResetAfterRound();
    }
    
    function Add(element, bonds = undefined) {
        var node;
        if (element == undefined) {
            node = self.cached_node;
            element = node.element;
        } else {
            node = new self.MoleculeNode(element);
        }
        self.cached_node = node;
        if (element.electro == undefined) {
            self.score *= element.number;
            array_push(self.log, node);
            return BondStatusCodes.SUCCESS;
        }
        if (!self.root) {
            self.root = node;
            self.score = element.number;
            array_push(self.log, node);
            return BondStatusCodes.SUCCESS;
        }
        if (Game.player.AtomsRemaining() == 0) {
            self.Shake();
            return BondStatusCodes.INVALID;
        }
        var addition = self.root.Add(node, { }, bonds);
        switch (addition) {
            case BondStatusCodes.SUCCESS:
                self.score += element.number;
                array_push(self.log, node);
                if (self.IsComplete()) {
                    if (!Game.player.tutorial.running) {
                        Game.player.score += self.score;
                        ui_create_message("Completed a molecule!\nScore: " + string(self.score), [
                            {
                                message: "Continue",
                                click: function() {
                                    ui_clear_dynamic_messages();
                                    Game.player.molecule.Clear();
                                }
                            },
                        ]);
                    }
                }
                return BondStatusCodes.SUCCESS;
            case BondStatusCodes.DEFERRED:
                return BondStatusCodes.DEFERRED;
            case BondStatusCodes.INVALID:
                self.Shake();
                return BondStatusCodes.INVALID;
        }
        return BondStatusCodes.INVALID;
    }
    
    function IsComplete() {
        if (!self.root) return false;
        for (var i = 0; i < array_length(self.log); i++) {
            if (!self.log[i].Complete()) return false;
        }
        return true;
    }
    
    function RawScore() {
        if (!self.root) return 0;
        return self.root.RawScore({ });
    }
    
    function Size() {
        if (!self.root) return 0;
        return self.root.Size({ });
    }
    
    function Score() {
        return self.score;
    }
    
    function draw() {
        if (!self.root) return;
        shader_set(shd_atom);
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        gpu_set_cullmode(cull_counterclockwise);
        self.root.draw(self.x + self.shake.x, self.y + self.shake.y, { });
        shader_reset();
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        gpu_set_cullmode(cull_noculling);
        matrix_set(matrix_world, matrix_build_identity());
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_neon_medium);
        self.root.draw(self.x, self.y, { }, true);
        self.shake.x = choose(-1, 1) * abs(lerp(self.shake.x, 0, SHAKE_DECAY));
        self.shake.y = choose(-1, 1) * abs(lerp(self.shake.y, 0, SHAKE_DECAY));
    }
    
    function AdjustDrawBounds(x, y) {
        self.draw_min.x = min(self.draw_min.x, x - self.x);
        self.draw_min.y = min(self.draw_min.y, y - self.y);
        self.draw_max.x = max(self.draw_max.x, x - self.x);
        self.draw_max.y = max(self.draw_max.y, y - self.y);
        self.draw_center.x = lerp(self.draw_center.x, mean(self.draw_min.x, self.draw_max.x), 0.1);
        self.draw_center.y = lerp(self.draw_center.y, mean(self.draw_min.y, self.draw_max.y), 0.1);
    }
    
    function GetFormula() {
        var elements = array_create(array_length(Game.periodic_table), 0);
        for (var i = 0, n = array_length(self.log); i < n; i++) {
            if (self.log[i].element.valence > 0) {
                elements[self.log[i].element.number]++;
            }
        }
        return elements;
    }
    
    function DrawFormula(x, y) {
        var formula = self.GetFormula();
        var formula_width = 0;
        draw_set_font(fnt_neon_large);
        for (var i = 0, n = array_length(formula); i < n; i++) {
            if (formula[i] > 0) {
                formula_width += string_width(Game.periodic_table[i - 1].symbol);
                if (formula[i] > 1) {
                    formula_width += string_width(" ");
                }
            }
        }
        if (formula_width > 0) {
            draw_set_halign(fa_left);
            draw_set_valign(fa_center);
            var formula_surface = surface_create(formula_width, 80);
            surface_set_target(formula_surface);
            draw_clear_alpha(c_black, 0);
            var xx = 0;
            var yy = 40;
            for (var i = 0, n = array_length(formula); i < n; i++) {
                if (formula[i] > 0) {
                    draw_set_font(fnt_neon_large);
                    draw_text_colour(xx, yy, Game.periodic_table[i - 1].symbol, c_white, c_white, c_white, c_white, 1);
                    xx += string_width(Game.periodic_table[i - 1].symbol);
                    if (formula[i] > 1) {
                        draw_set_font(fnt_neon);
                        draw_text_colour(xx - 4, yy + 12, formula[i], c_yellow, c_yellow, c_yellow, c_yellow, 1);
                        xx += string_width(" ");
                    }
                }
            }
            surface_reset_target();
            draw_surface_ext(formula_surface, x - formula_width / 2 - 1, y - 40 + 0, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 + 1, y - 40 + 0, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 + 0, y - 40 - 1, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 + 0, y - 40 + 1, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 - 1, y - 40 - 1, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 - 1, y - 40 + 1, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 + 1, y - 40 - 1, 1, 1, 0, c_black, 1);
            draw_surface_ext(formula_surface, x - formula_width / 2 + 1, y - 40 + 1, 1, 1, 0, c_black, 1);
            draw_surface(formula_surface, x - formula_width / 2, y - 40);
            surface_free(formula_surface);
        }
    }
    
    function Shake() {
        self.shake.x = random_range(-SHAKE_DISTANCE, SHAKE_DISTANCE);
        self.shake.y = random_range(-SHAKE_DISTANCE, SHAKE_DISTANCE);
    }
    
    self.root = undefined;
    self.score = 0;
    self.log = [];
    self.cached_node = undefined;
    
    static all_nodes = { };
    function get(id) {
        return self.all_nodes[$ id];
    }
    function set(node) {
        self.all_nodes[$ node.id] = node;
    }
    
    self.x = room_width * 3 / 4;
    self.y = room_height / 2;
    self.draw_min = { x: 0, y: 0 };
    self.draw_max = { x: 0, y: 0 };
    self.draw_center = { x: 0, y: 0 };
    self.shake = { x: 0, y: 0 };
}

enum BondStatusCodes {
    INVALID     = 0,
    DEFERRED    = 1,
    SUCCESS     = 2,
}
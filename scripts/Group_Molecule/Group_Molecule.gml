function Molecule() constructor {
    static MoleculeNode = function(element) constructor {
        static atom_id = 0;
        self.element = element;
        self.id = atom_id++;
        self.bonds = [];
        self.valence = element.valence;
        
        function Add(node, seen) {
            if (seen[$ self.id]) return;
            seen[$ self.id] = true;
            
            // i don't know if this is an actual rule but i've never seen atoms
            // that both have an electronegativity lower than Hydrogen bond so
            // we'll just go with it for now
            if (self.element.electro < 2.3 && node.element.electro < 2.3) {
                return false;
            }
            
            if (!self.Complete()) {
                var diff = node.element.electro - self.element.electro;
                if (abs(diff) < 1.7) {      // covalent
                    var shared = min(node.element.shell_size - node.valence, self.element.shell_size - self.valence);
                    self.valence += shared;
                    node.valence += shared;
                    repeat (shared) {
                        self.Bond(node);
                    }
                    show_debug_message("Bonded " + string(self) + " to " + string(node) + " (covalent)");
                } else {                    // ionic
                    var donated;
                    if (self.element.electro < node.element.electro) {
                        donated = min(node.element.shell_size - node.valence, self.valence);
                        self.valence -= donated;
                        node.valence += donated;
                    } else {
                        donated = min(self.element.shell_size - self.valence, node.valence);
                        self.valence += donated;
                        node.valence -= donated;
                    }
                    repeat (donated) {
                        self.Bond(node);
                    }
                    show_debug_message("Bonded " + string(self) + " to " + string(node) + " (ionic)");
                }
                self.Bond(node);
                return true;
            }
            
            for (var i = 0; i < array_length(self.bonds); i++) {
                if (self.bonds[i].Add(node, seen)) return true;
            }
            
            return false;
        }
        
        function Bond(node) {
            array_push(self.bonds, node);
            array_push(node.bonds, self);
        }
        
        function Complete() {
            return (self.valence == 0 || self.valence == self.element.shell_size);
        }
        
        function RawScore(seen) {
            if (seen[$ self.id]) return 0;
            seen[$ self.id] = true;
            
            var value = self.element.number;
            for (var i = 0; i < array_length(self.bonds); i++) {
                value += self.bonds[i].RawScore(seen);
            }
            
            return value;
        }
            
        function toString() {
            return self.element.name + " (" + string(self.valence) + "/" + string(self.element.shell_size) + ")";
        }
        
        function draw(x, y, seen) {
            if (seen[$ self.id]) return false;
            seen[$ self.id] = true;
            static uniform_color = shader_get_uniform(shd_atom, "color");
            matrix_set(matrix_world, matrix_build(x - Game.player.molecule.draw_center.x, y - Game.player.molecule.draw_center.y, 0, 0, 0, 0, self.element.radius, self.element.radius, -self.element.radius));
            shader_set_uniform_f(uniform_color, ((self.element.class.color >> 0) & 0xff) / 0xff, ((self.element.class.color >> 8) & 0xff) / 0xff, ((self.element.class.color >> 16) & 0xff) / 0xff);
            vertex_submit(Game.vbuff_atom, pr_trianglelist, -1);
            
            Game.player.molecule.AdjustDrawBounds(x, y);
            
            var unique_atoms = { };
            for (var i = 0, n = array_length(self.bonds); i < n; i++) {
                unique_atoms[$ self.bonds[i].id] = self.bonds[i];
            }
            var keys = variable_struct_get_names(unique_atoms);
            if (array_length(keys) > 0) {
                var spacing = 2 * pi / array_length(keys);
                var slot = 0;
                for (var i = 0, n = array_length(keys); i < n; i++) {
                    var next = unique_atoms[$ keys[i]];
                    var radius = max(self.element.radius, next.element.radius);
                    if (next.draw(x + radius * cos(slot * spacing), y - radius * sin(slot * spacing), seen)) {
                        slot++;
                    }
                }
            }
            return true;
        };
    };
    
    function Clear() {
        self.root = undefined;
        self.score = 0;
        self.log = [];
        
        self.draw_min = { x: 0, y: 0 };
        self.draw_max = { x: 0, y: 0 };
        self.draw_center = { x: 0, y: 0 };
        
        Game.player.EnableAll();
    }
    
    function Add(element) {
        var node = new self.MoleculeNode(element);
        array_push(self.log, node);
        if (element.electro == undefined) {
            self.score *= element.number;
            return true;
        }
        if (!self.root) {
            self.root = node;
            self.score = element.number;
            return true;
        }
        if (self.root.Add(node, { })) {
            self.score += element.number;
            return true;
        }
        return false;
    }
    
    function IsComplete() {
        for (var i = 0; i < array_length(self.log); i++) {
            if (!self.log[i].Complete()) return false;
        }
        return true;
    }
    
    function RawScore() {
        if (!self.root) return 0;
        return self.root.RawScore({ });
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
        self.root.draw(self.x, self.y, { });
        shader_reset();
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        gpu_set_cullmode(cull_noculling);
        matrix_set(matrix_world, matrix_build_identity());
    }
    
    function AdjustDrawBounds(x, y) {
        self.draw_min.x = min(self.draw_min.x, x - self.x);
        self.draw_min.y = min(self.draw_min.y, y - self.y);
        self.draw_max.x = max(self.draw_max.x, x - self.x);
        self.draw_max.y = max(self.draw_max.y, y - self.y);
        self.draw_center.x = mean(self.draw_min.x, self.draw_max.x);
        self.draw_center.y = mean(self.draw_min.y, self.draw_max.y);
    }
    
    self.root = undefined;
    self.score = 0;
    self.log = [];
    
    self.x = room_width * 3 / 4;
    self.y = room_height / 2;
    self.draw_min = { x: 0, y: 0 };
    self.draw_max = { x: 0, y: 0 };
    self.draw_center = { x: 0, y: 0 };
}
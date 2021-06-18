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
            if (seen[$ self.id]) return;
            seen[$ self.id] = true;
            static uniform_color = shader_get_uniform(shd_atom, "color");
            matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, 0, self.element.radius, self.element.radius, self.element.radius));
            shader_set_uniform_f(uniform_color, ((self.element.class.color >> 0) & 0xff) / 0xff, ((self.element.class.color >> 8) & 0xff) / 0xff, ((self.element.class.color >> 16) & 0xff) / 0xff);
            vertex_submit(Game.vbuff_atom, pr_trianglelist, -1);
        };
    };
    
    function Clear() {
        self.root = undefined;
        self.score = 0;
        self.log = [];
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
    
    function draw(x, y) {
        if (!self.root) return;
        shader_set(shd_atom);
        self.root.draw(x, y, { });
        shader_reset();
        matrix_set(matrix_world, matrix_build_identity());
    }
    
    self.root = undefined;
    self.score = 0;
    self.log = [];
}
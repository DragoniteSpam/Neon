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
            
            //if (!self.Complete()) {
            if (self.valence > 0 && self.valence < self.element.shell_size) {
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
            //show_debug_message([self.element.name, self.valence, self.element.shell_size])
            return (self.valence == 0 || self.valence == self.element.shell_size);
        }
        
        function toString() {
            return self.element.name + " (" + string(self.valence) + "/" + string(self.element.shell_size) + ")";
        }
    };
    
    function Add(element) {
        var node = new self.MoleculeNode(element);
        if (!self.root) {
            self.root = node;
            return;
        }
        if (!self.IsValid(element)) {
            //return;
        }
        self.root.Add(node, { });
    }
    
    function IsValid(element) {
        return false;
    }
    
    function IsComplete() {
        return false;
    }
    
    function Score() {
        
    }
    
    self.root = undefined;
}
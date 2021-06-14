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
            
            if (self.valence > 0 && self.valence < self.element.shell_size) {
                if (node.element.electro > self.element.electro) {
                    var will_give = min(node.element.shell_size - node.element.valence, self.element.shell_size - self.valence);
                    node.valence += will_give;
                    self.valence += will_give;
                } else {
                    var will_accept = min(self.element.shell_size - self.element.valence, node.element.shell_size - node.valence);
                    node.valence += will_accept;
                    self.valence += will_accept;
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
            
        }
    };
    
    function Add(element) {
        var node = new self.MoleculeNode(element);
        if (!self.root) {
            self.root = node;
            return;
        }
        if (!self.IsValid(element)) {
            return;
        }
        var seen = { };
        self.root.Add(node, seen);
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
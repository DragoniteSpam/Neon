function Molecule() constructor {
    static MoleculeNode = function(element) constructor {
        static atom_id = 0;
        self.element = element;
        self.id = atom_id++;
        self.bonds = [];
        
        function Add(node, seen) {
            if (seen[$ self.id]) return;
            seen[$ self.id] = true;
            
            if (/* can be added to this atom */false) {
                
            }
            
            for (var i = 0; i < array_length(self.bonds); i++) {
                self.bonds[i].Add(node, seen);
            }
        }
        
        function Bond(node) {
            array_push(self.bonds, node);
            array_push(node.bonds, self);
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
        seen[$ self.root.id] = true;
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
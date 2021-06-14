function Molecule() constructor {
    static MoleculeNode = function(element) constructor {
        self.element = element;
        self.bonds = [];
        
        function Bond(node) {
            array_push(self.bonds, node);
            array_push(node.bonds, self);
        }
    };
    
    function Add(element) {
        
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
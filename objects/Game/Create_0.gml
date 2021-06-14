#macro c_hydrogen       0xffcc00
#macro c_alkali         0x00ccff
#macro c_earth          0x0099cc
#macro c_nonmetal       0x66cc00
#macro c_semiconductor  0x669999
#macro c_metal          0xbfbfbf
#macro c_halogen        0x0033ff
#macro c_noble          0xcc66ff

class_hydrogen          = new Class("Hydrogen", c_hydrogen);
class_alkali            = new Class("Alkali Metals", c_alkali);
class_earth             = new Class("Rare Earth Metals", c_earth);
class_nonmetal          = new Class("Non-Metals", c_nonmetal);
class_semiconductor     = new Class("Semiconductors", c_semiconductor);
class_metal             = new Class("Metals", c_metal);
class_halogen           = new Class("Halogens", c_halogen);
class_noble             = new Class("Noble Gasses", c_noble);

hydrogen                = new Element("Hydrogen",   "H",    01,     1,      2.30,       class_hydrogen);
helium                  = new Element("Helium",     "He",   02,     0,      undefined,  class_noble);

lithium                 = new Element("Lithium",    "Li",   03,     1,      0.91,       class_alkali);
beryllium               = new Element("Beryllium",  "Be",   04,     2,      1.58,       class_earth);
boron                   = new Element("Boron",      "B",    05,     3,      2.05,       class_semiconductor);
carbon                  = new Element("Carbon",     "C",    06,     4,      2.54,       class_nonmetal);
nitrogen                = new Element("Nitrogen",   "N",    07,     5,      3.07,       class_nonmetal);
oxygen                  = new Element("Oxygen",     "O",    08,     6,      3.61,       class_nonmetal);
fluorine                = new Element("Fluorine",   "F",    09,     7,      4.19,       class_halogen);
neon                    = new Element("Neon",       "Ne",   10,     0,      undefined,  class_noble);

sodium                  = new Element("Sodium",     "Na",   11,     1,      0.87,       class_alkali);
magnesium               = new Element("Magnesium",  "Mg",   12,     2,      1.29,       class_earth);
aluminum                = new Element("Aluminum",   "Al",   13,     3,      1.61,       class_metal);
silicon                 = new Element("Silicon",    "Si",   14,     4,      1.92,       class_semiconductor);
phosphorus              = new Element("Phosphorus", "P",    15,     5,      2.25,       class_nonmetal);
sulfur                  = new Element("Sulfur",     "S",    16,     6,      2.59,       class_nonmetal);
chlorine                = new Element("Chlorine",   "Cl",   17,     7,      2.87,       class_halogen);
argon                   = new Element("Argon",      "Ar",   18,     8,      undefined,  class_noble);

elements = [
    [
        { element: hydrogen,        weight: 2.5 },
        { element: helium,          weight: 0.8 },
        { element: lithium,         weight: 0.0 },
        { element: beryllium,       weight: 0.0 },
        { element: boron,           weight: 0.0 },
        { element: carbon,          weight: 0.0 },  // i really don't want to do organic chemistry, thanks
        { element: nitrogen,        weight: 1.5 },
        { element: oxygen,          weight: 2.5 },
    ],
    [
        { element: fluorine,        weight: 1.0 },
        { element: neon,            weight: 0.5 },
        { element: sodium,          weight: 0.8 },
    ],
    [
        { element: magnesium,       weight: 0.7 },
        { element: aluminum,        weight: 0.5 },
        { element: silicon,         weight: 0.0 },
        { element: phosphorus,      weight: 0.5 },
        { element: sulfur,          weight: 0.7 },
        { element: chlorine,        weight: 0.8 },
        { element: argon,           weight: 0.1 },
    ],
];

function GenerateElement(rank) {
    var max_weight = 0;
    for (var i = 0; i < min(rank + 1, array_length(self.elements)); i++) {
        for (var j = 0; j < array_length(self.elements[i]); j++) {
            max_weight += self.elements[i][j].weight;
        }
    }
    var rng = random(max_weight - 1);
    var allotted_weight = 0;
    for (var i = 0; i < min(rank + 1, array_length(self.elements)); i++) {
        for (var j = 0; j < array_length(self.elements[i]); j++) {
            allotted_weight += self.elements[i][j].weight;
            if (allotted_weight >= rng) {
                return self.elements[i][j].element;
            }
        }
    }
    
    return self.hydrogen;
};

#macro BOARD_SIZE 5

board_start_x = 32;
board_start_y = 32;
board_spacing = 130;

board = array_create(BOARD_SIZE);
for (var i = 0; i < BOARD_SIZE; i++) {
    board[i] = array_create(BOARD_SIZE);
    for (var j = 0; j < BOARD_SIZE; j++) {
        board[i][j] = new ElementCard(board_start_x + i * board_spacing, board_start_y + j * board_spacing, GenerateElement(0));
    }
}

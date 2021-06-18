#region chemistry setup
#macro c_hydrogen       0xffcc00
#macro c_alkali         0x00ccff
#macro c_earth          0x0099cc
#macro c_nonmetal       0x66cc00
#macro c_semiconductor  0x669999
#macro c_metal          0xbfbfbf
#macro c_carbon         0x0099cc
#macro c_halogen        0x0033ff
#macro c_noble          0xcc66ff

class_hydrogen          = new Class("Hydrogen", c_hydrogen);
class_alkali            = new Class("Alkali Metals", c_alkali);
class_earth             = new Class("Rare Earth Metals", c_earth);
class_nonmetal          = new Class("Non-Metals", c_nonmetal);
class_semiconductor     = new Class("Semiconductors", c_semiconductor);
class_metal             = new Class("Metals", c_metal);
class_carbon            = new Class("Halogens", c_carbon);              // yes i know, shut up
class_halogen           = new Class("Halogens", c_halogen);
class_noble             = new Class("Noble Gasses", c_noble);

hydrogen                = new Element("Hydrogen",   "H",    01,     1,      2,      2.30,       class_hydrogen);
helium                  = new Element("Helium",     "He",   02,     0,      2,      undefined,  class_noble);

lithium                 = new Element("Lithium",    "Li",   03,     1,      8,      0.91,       class_alkali);
beryllium               = new Element("Beryllium",  "Be",   04,     2,      8,      1.58,       class_earth);
boron                   = new Element("Boron",      "B",    05,     3,      8,      2.05,       class_semiconductor);
carbon                  = new Element("Carbon",     "C",    06,     4,      8,      2.54,       class_carbon);
nitrogen                = new Element("Nitrogen",   "N",    07,     5,      8,      3.07,       class_nonmetal);
oxygen                  = new Element("Oxygen",     "O",    08,     6,      8,      3.61,       class_nonmetal);
fluorine                = new Element("Fluorine",   "F",    09,     7,      8,      4.19,       class_halogen);
neon                    = new Element("Neon",       "Ne",   10,     0,      8,      undefined,  class_noble);

sodium                  = new Element("Sodium",     "Na",   11,     1,      8,      0.87,       class_alkali);
magnesium               = new Element("Magnesium",  "Mg",   12,     2,      8,      1.29,       class_earth);
aluminum                = new Element("Aluminum",   "Al",   13,     3,      8,      1.61,       class_metal);
silicon                 = new Element("Silicon",    "Si",   14,     4,      8,      1.92,       class_semiconductor);
phosphorus              = new Element("Phosphorus", "P",    15,     5,      8,      2.25,       class_nonmetal);
sulfur                  = new Element("Sulfur",     "S",    16,     6,      8,      2.59,       class_nonmetal);
chlorine                = new Element("Chlorine",   "Cl",   17,     7,      8,      2.87,       class_halogen);
argon                   = new Element("Argon",      "Ar",   18,     8,      8,      undefined,  class_noble);

periodic_table = [
    hydrogen, helium,
    lithium, beryllium, boron, carbon, nitrogen, oxygen, fluorine, neon,
    sodium, magnesium, aluminum, silicon, phosphorus, sulfur, chlorine, argon
];

elements = [
    [
        { element: hydrogen,        weight: 2.5 },
        { element: helium,          weight: 0.8 },
        { element: lithium,         weight: 0.0 },
        { element: beryllium,       weight: 0.0 },
        { element: boron,           weight: 0.0 },
        { element: carbon,          weight: 1.0 },
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
#endregion

#region game setup
#macro c_hover                  0xbfbfbf
#macro c_used                   0x3f3f3f
#macro BOARD_SIZE               5
#macro STARTING_TIME            60
#macro WRONGNESS_PENALTY        0.75
#macro CARBON_LIMIT             2                           // organic chemistry makes this really bad, let's not do it

board_start_x = 32;
board_start_y = 32;
board_spacing = 130;

vertex_format_begin();
vertex_format_add_position_3d();
format_atom = vertex_format_end();
var data = buffer_load("sphere20.atom");
vbuff_atom = vertex_create_buffer_from_buffer(data, format_atom);
buffer_delete(data);
#endregion

#region player stuff
player = {
    board: array_create(BOARD_SIZE * BOARD_SIZE, undefined),
    molecule: new Molecule(),
    time: 0,
    running: false,
    
    fill: function() {
        var carbons = 0;
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            if (self.board[i] && self.board[i].element == Game.carbon) carbons++;
        }
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            var col = i div BOARD_SIZE;
            var row = i mod BOARD_SIZE;
            do {
                if (self.board[i] && self.board[i].element == Game.carbon) carbons--;
                self.board[i] = new ElementCard(Game.board_start_x + col * Game.board_spacing, Game.board_start_y + row * Game.board_spacing, self.generate(0));
                if (self.board[i].element == Game.carbon) carbons++;
            } until (carbons <= CARBON_LIMIT);
        }
    },
    
    generate: function(rank) {
        var max_weight = 0;
        for (var i = 0; i < min(rank + 1, array_length(Game.elements)); i++) {
            for (var j = 0; j < array_length(Game.elements[i]); j++) {
                max_weight += Game.elements[i][j].weight;
            }
        }
        var rng = random(max_weight - 1);
        var allotted_weight = 0;
        for (var i = 0; i < min(rank + 1, array_length(Game.elements)); i++) {
            for (var j = 0; j < array_length(Game.elements[i]); j++) {
                allotted_weight += Game.elements[i][j].weight;
                if (allotted_weight >= rng) {
                    return Game.elements[i][j].element;
                }
            }
        }
    
        return Game.hydrogen;
    },
    
    start: function() {
        self.fill();
        self.time = STARTING_TIME;
        self.running = true;
    },
    
    tick: function() {
        if (!self.running) return;
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            self.board[i].step(window_mouse_get_x(), window_mouse_get_y());
        }
        self.time -= delta_time / 1000000;
        if (self.time <= 0) {
            self.time = 0;
            self.running = false;
        }
    },
    
    EnableAll: function() {
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            self.board[i].used = false;
        }
    },
};
#endregion

player.start();
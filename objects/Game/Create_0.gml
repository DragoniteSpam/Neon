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

#macro c_invalid        0x999999

class_hydrogen          = new Class("Hydrogen", c_hydrogen);
class_alkali            = new Class("Alkali Metals", c_alkali);
class_earth             = new Class("Rare Earth Metals", c_earth);
class_nonmetal          = new Class("Non-Metals", c_nonmetal);
class_semiconductor     = new Class("Semiconductors", c_semiconductor);
class_metal             = new Class("Metals", c_metal);
class_carbon            = new Class("Halogens", c_carbon);              // yes i know, shut up
class_halogen           = new Class("Halogens", c_halogen);
class_noble             = new Class("Noble Gasses", c_noble);

class_invalid           = new Class("Invalid", c_invalid);

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

element_invalid         = new Element("Invalid", "", undefined, undefined, undefined, undefined, class_invalid);
element_invalid.valid = false;

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
#macro BASE_ATOM_LIMIT          4
#macro SHAKE_DISTANCE           20
#macro SHAKE_DECAY              0.5
#macro UI_LAYER                 layer_get_depth("UI_Game")
#macro SAVE_DATA_FILE           "adam_sounds_like_atom_get_it.json"

save_data = {
    exists: false,
    high_scores: [ ],
};

try {
    var buffer = buffer_load(SAVE_DATA_FILE);
    var json = json_parse(buffer_read(buffer, buffer_text));
    save_data.exists = true;
    save_data.high_scores = json.high_scores;
    buffer_delete(buffer);
    if (!is_array(save_data.high_scores)) {
        throw "bad high score table";
    }
    for (var i = 0, n = array_length(save_data.high_scores); i < n; i++) {
        if (!is_numeric(save_data.high_scores[i])) throw "bad high score value(s)";
    }
} catch (e) {
    show_debug_message("no valid save data found, let's create some instead");
    self.save_data = {
        exists: false,
        high_scores: [ ],
    };
}

save = function() {
    var buffer = buffer_create(100, buffer_grow, 1);
    buffer_write(buffer, buffer_text, json_stringify(self.save_data));
    buffer_save_ext(buffer, SAVE_DATA_FILE, 0, buffer_tell(buffer));
    buffer_delete(buffer);
};

AddHighScore = function(value) {
    array_push(self.save_data.high_scores, value);
    array_sort(self.save_data.high_scores, false);
};

GameOver = function() {
    ui_clear_dynamic_messages();
    self.player.running = false;
    if (array_length(self.save_data.high_scores) > 0) {
        var is_high_score = (self.player.score > self.save_data.high_scores[0]);
        ui_create_message("Time's up!\nNew high score: " + string(self.player.score), [
            {
                message: "Cool!",
                click: function() {
                },
            },
        ]);
    } else {
        var is_high_score = (self.player.score > self.save_data.high_scores[0]);
        ui_create_message("Time's up!", [
            {
                message: "Return!",
                click: function() {
                },
            },
        ]);
    }
    Game.AddHighScore(self.player.score);
    // Game.save();
};

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
    atom_limit: BASE_ATOM_LIMIT,
    rank: 0,
    score: 0,
    molecules: 0,
    
    Fill: function() {
        var carbons = 0;
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            if (self.board[i] && self.board[i].element == Game.carbon) carbons++;
        }
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            var col = i div BOARD_SIZE;
            var row = i mod BOARD_SIZE;
            do {
                if (self.board[i] && self.board[i].element == Game.carbon) carbons--;
                self.board[i] = new ElementCard(Game.board_start_x + col * Game.board_spacing, Game.board_start_y + row * Game.board_spacing, self.Generate(0));
                if (self.board[i].element == Game.carbon) carbons++;
            } until (carbons <= CARBON_LIMIT);
        }
    },
    
    EraseBoard: function() {
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            var col = i div BOARD_SIZE;
            var row = i mod BOARD_SIZE;
            self.board[i] = new ElementCard(Game.board_start_x + col * Game.board_spacing, Game.board_start_y + row * Game.board_spacing, Game.element_invalid);
        }
    },
    
    Generate: function(rank) {
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
    
    Start: function() {
        self.running = true;
        self.atom_limit = BASE_ATOM_LIMIT + 2 * self.rank;
        if (Game.save_data.exists) {
            self.Fill();
            self.time = STARTING_TIME;
        } else {
            inst_score.enabled = false;
            inst_time.enabled = false;
            inst_atom_count.enabled = false;
            inst_atom_name.enabled = false;
            inst_reset.enabled = false;
            inst_total_score.enabled = false;
            self.EraseBoard();
            self.time = 1000000000;
            self.tutorial.Next();
        }
    },
    
    StartTutorial: function() {
        self.running = true;
        self.atom_limit = 3;
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            var col = i div BOARD_SIZE;
            var row = i mod BOARD_SIZE;
            if (i == 12) {
                self.board[i] = new ElementCard(Game.board_start_x + col * Game.board_spacing, Game.board_start_y + row * Game.board_spacing, self.Generate(0));
            } else {
                self.board[i] = undefined;
            }
        }
    },
    
    tick: function() {
        if (!self.running) return;
        if (self.tutorial.running) self.tutorial.tick();
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            if (self.board[i]) self.board[i].step(window_mouse_get_x(), window_mouse_get_y());
        }
        self.time -= delta_time / 1000000;
        if (self.time <= 0) {
            self.time = 0;
            self.running = false;
            Game.GameOver();
        }
    },
    
    draw: function() {
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            if (self.board[i]) {
                self.board[i].draw();
            }
        }
        self.molecule.draw();
    },
    
    EnableAll: function() {
        for (var i = 0, n = array_length(self.board); i < n; i++) {
            if (!self.board[i].special_disable) self.board[i].used = false;
        }
    },
    
    AtomsRemaining: function() {
        return (self.atom_limit - self.molecule.Size());
    },
    
    ResetAfterRound: function() {
        if (self.tutorial.running) return;
    },
    
    tutorial: {
        running: false,
        
        sequence: [
            { type: TutorialSequenceTypes.WAIT, duration: 1, },
            { type: TutorialSequenceTypes.TEXT, text: "Hey there!", },
            { type: TutorialSequenceTypes.TEXT, text: "My name is Adam!", },
            { type: TutorialSequenceTypes.CHOICES, text: "You remember chemistry, right?", choices: ["Yeah!", "Nope!", "Oh no..."], },
            { type: TutorialSequenceTypes.CHOICE_BRANCH, branches: ["Really? We're going to get along just great, I can tell!", "Well, there's no time like the present to brush up on your skills!", "Cool! Wait, you sound worried. Why are you worried?"], },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[12] = new ElementCard(Game.board_start_x + 2 * Game.board_spacing, Game.board_start_y + 2 * Game.board_spacing, Game.nitrogen);
                Game.player.board[12].OnClick = method(Game.player.board[12], function() {
                    Game.player.tutorial.flags.first_atom = true;
                });
                Game.player.board[12].interactive = false;
                Game.player.board[12].special_disable = true;
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "Anyway, you see this here? That's a atom of the element Nitrogen.", },
            { type: TutorialSequenceTypes.TEXT, text: "Elements are the basis of allmost everything in the Universe!" },
            { type: TutorialSequenceTypes.TEXT, text: "Except for the stuff they make in particle accelerators.", },
            { type: TutorialSequenceTypes.TEXT, text: "And maybe the weird pasta stuff in neutron stars.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[12].interactive = true;
            }, },
            { type: TutorialSequenceTypes.CONDITIONAL_PASS, text: "You can use atoms to build molecules. Click on it!", condition: function() {
                return Game.player.tutorial.flags.first_atom;
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "Now, molecules are made of multiple elements chemically bonded to each other.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[7] = new ElementCard(Game.board_start_x + 1 * Game.board_spacing, Game.board_start_y + 2 * Game.board_spacing, Game.hydrogen);
                Game.player.board[7].interactive = false;
                Game.player.board[7].OnClick = method(Game.player.board[7], function() {
                    Game.player.tutorial.flags.first_bond = true;
                });
                Game.player.board[7].special_disable = true;
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "Here's another element. It can bond with your Nitrogen atom.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[7].interactive = true;
            }, },
            { type: TutorialSequenceTypes.CONDITIONAL_PASS, text: "Click on it to create a chemical bond!", condition: function() {
                return Game.player.tutorial.flags.first_bond;
            } },
            { type: TutorialSequenceTypes.TEXT, text: "Got that? Good!", },
            { type: TutorialSequenceTypes.TEXT, text: "So, different elements can bond with other elements in different ways.", },
            { type: TutorialSequenceTypes.TEXT, text: "Atomic bonds are powered by the number of valence electrons an element has.", },
            { type: TutorialSequenceTypes.TEXT, text: "When an atom bonds with another atom, they share electrons with one another.", },
            { type: TutorialSequenceTypes.TEXT, text: "(I swear to Dmitri Mendeleev, that is NOT supposed to be an innuendo for anything.)", },
            { type: TutorialSequenceTypes.TEXT, text: "The number of valence electrons that an element has is show in the top left of its tile." },
            { type: TutorialSequenceTypes.TEXT, text: "The second number is the maximum number of electrons it can acquire through bonding with something.", },
            { type: TutorialSequenceTypes.TEXT, text: "When every atom in a molecule has reached that maximum number of electrons, it's considered a stable molecule.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[8] = new ElementCard(Game.board_start_x + 1 * Game.board_spacing, Game.board_start_y + 3 * Game.board_spacing, Game.hydrogen);
                Game.player.board[9] = new ElementCard(Game.board_start_x + 1 * Game.board_spacing, Game.board_start_y + 4 * Game.board_spacing, Game.hydrogen);
                Game.player.board[8].special_disable = true;
                Game.player.board[9].special_disable = true;
            }, },
            { type: TutorialSequenceTypes.CONDITIONAL_PASS, text: "Here's everything else you need to finish a molecule. Have at it!", condition: function() {
                return Game.player.molecule.IsComplete();
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "You did it! You created a complete molecule of Ammonia!", },
            { type: TutorialSequenceTypes.TEXT, text: "There's more to chemistry than that, though.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.molecule.Clear();
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "A Hydrogen atom and a Nitrogen atom can only share a single electron through an atomic bond.", },
            { type: TutorialSequenceTypes.TEXT, text: "Hydrogen can only share up to one additional electron with another element.", },
            { type: TutorialSequenceTypes.ACTION, action: function() {
                Game.player.board[19] = new ElementCard(Game.board_start_x + 3 * Game.board_spacing, Game.board_start_y + 4 * Game.board_spacing, Game.oxygen);
                Game.player.board[24] = new ElementCard(Game.board_start_x + 4 * Game.board_spacing, Game.board_start_y + 4 * Game.board_spacing, Game.oxygen);
                inst_reset.enabled = true;
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "Here are two Oxygen atoms. By the way, if you ever want to reset the molecule, you can click the \"Reset\" button in the corner.", },
            { type: TutorialSequenceTypes.CONDITIONAL_PASS, text: "", condition: function() {
                return Game.player.molecule.IsComplete();
            }, },
            { type: TutorialSequenceTypes.TEXT, text: "Oxygen, as you can see, requires two more electrons to be shared until it reaches its limit.", },
            { type: TutorialSequenceTypes.TEXT, text: "And since oxygen atoms have more than two valence electrons available, it can share both of them!", },
            { type: TutorialSequenceTypes.TEXT, text: "This creates a double bond with the other atom.", },
            { type: TutorialSequenceTypes.TEXT, text: "Atomic bonds can form either single, double, or triple bonds with each other.", },
            { type: TutorialSequenceTypes.TEXT, text: "If two atoms in a molecule are capable of forming multiple bonds, you get to choose which type you want.", },
            { type: TutorialSequenceTypes.TEXT, text: "This adds a bit of variety to the types of molecules you're able to create.", },
            { type: TutorialSequenceTypes.TEXT, text: "Now that we've covered the basics, let's talk about how to play the game.", },
            { type: TutorialSequenceTypes.TEXT, text: "Your score is dependent on the combined atomic numbers of all of the elements in your molecule.", },
            { type: TutorialSequenceTypes.TEXT, text: "The atomic number is what you see at the bottom of every card.", },
            { type: TutorialSequenceTypes.TEXT, text: "The atomic number is what your score is based on in this game.", },
            { type: TutorialSequenceTypes.TEXT, text: "Creating bigger molecules out of heavier elements will give you a higher score!", },
            { type: TutorialSequenceTypes.TEXT, text: "You get " + string(STARTING_TIME) + " seconds to rack up as much score as you can.", },
            { type: TutorialSequenceTypes.TEXT, text: "Completing molecules gives you a small time bonus, and also allows you to create bigger molecules.", },
            { type: TutorialSequenceTypes.TEXT, text: "One last thing.", },
            ///
            { type: TutorialSequenceTypes.TEXT, text: "There's much more to chemistry than this, of course.", },
            { type: TutorialSequenceTypes.TEXT, text: "You'll find distinctions between ionic, covalent, and polar covalent bonds, and heavier elements being able to bond with more elements...", },
            { type: TutorialSequenceTypes.TEXT, text: "...but this game was made in the span of just a few days, so for now we'll just be playing with small, light elements.", },
            { type: TutorialSequenceTypes.TEXT, text: "In some cases you'll find that the world geometry of molecules looks a little different from what you see on the right in the real world...", },
            { type: TutorialSequenceTypes.TEXT, text: "...but again, this was made for a game jam. Give me a break.", },
            { type: TutorialSequenceTypes.TEXT, text: "Now, is that everything? Have fun!", },
            
            { type: TutorialSequenceTypes.ACTION, action: function() {
                inst_score.enabled = true;
                inst_time.enabled = true;
                inst_atom_count.enabled = true;
                inst_atom_name.enabled = true
                inst_total_score.enabled = true;
                Game.save_data.exists = true;
                Game.player.molecule.Clear();
                Game.player.Start();
            }, },
        ],
        
        choice: 0,
        index: -1,
        wait_time: -1,
        conditional_function: undefined,
        flags: {
            first_atom: false,
            first_bond: false,
        },
        
        tick: function() {
            if (self.wait_time > 0) {
                self.wait_time -= (delta_time / 1000000);
                if (self.wait_time <= 0) {
                    self.Next();
                }
                return;
            }
            if (self.conditional_function) {
                if (self.conditional_function()) {
                    self.conditional_function = undefined;
                    self.Next();
                    return;
                }
            }
        },
        
        Next: function() {
            ui_clear_tutorial_messages();
            self.running = true;
            if (++self.index >= array_length(self.sequence)) {
                self.running = false;
                return;
            }
            var data = self.sequence[self.index];
            switch (data.type) {
                case TutorialSequenceTypes.TEXT:
                    ui_create_message(data.text, [{
                        message: "Next",
                        click: function() {
                            Game.player.tutorial.Next();
                        },
                    }], Game.ui_tutorial);
                    break;
                case TutorialSequenceTypes.CONDITIONAL_PASS:
                    if (data.text != "") {
                        ui_create_message(data.text, [], Game.ui_tutorial).shade = false;
                    }
                    self.conditional_function = data.condition;
                    break;
                case TutorialSequenceTypes.CHOICES:
                    var choices = [];
                    for (var i = 0, n = array_length(data.choices); i < n; i++) {
                        array_push(choices, {
                            message: data.choices[i],
                            click: function() {
                                Game.player.tutorial.choice = self.index;
                                Game.player.tutorial.Next();
                            },
                        });
                    }
                    ui_create_message(data.text, choices, Game.ui_tutorial);
                    break;
                case TutorialSequenceTypes.CHOICE_BRANCH:
                    ui_create_message(data.branches[self.choice], [{
                        message: "Next",
                        click: function() {
                            Game.player.tutorial.Next();
                        },
                    }], Game.ui_tutorial);
                    break;
                case TutorialSequenceTypes.WAIT:
                    self.wait_time = data.duration;
                    break;
                case TutorialSequenceTypes.ACTION:
                    data.action();
                    self.Next();
                    break;
            }
        },
    },
};
#endregion

ui_dynamic = ds_list_create();
ui_tutorial = ds_list_create();

blocked = function() {
    return !ds_list_empty(Game.ui_dynamic);
};

active = false;

enum TutorialSequenceTypes {
    TEXT, CHOICES, CHOICE_BRANCH, CONDITIONAL_PASS, ACTION, WAIT,
}
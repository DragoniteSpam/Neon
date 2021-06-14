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
phosohorus              = new Element("Phosphorus", "P",    15,     5,      2.25,       class_nonmetal);
sulfur                  = new Element("Sulfur",     "S",    16,     6,      2.59,       class_nonmetal);
chlorine                = new Element("Chlorine",   "Cl",   17,     7,      2.87,       class_halogen);
argon                   = new Element("Argon",      "Ar",   18,     8,      undefined,  class_noble);
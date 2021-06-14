#macro c_hydrogen       0xffcc00
#macro c_alkali         0x00ccff
#macro c_earth          0x0099cc
#macro c_nonmetal       0x66cc00
#macro c_metal          0x669999
#macro c_halogen        0x0033ff
#macro c_noble          0xcc66ff

class_hydrogen          = new Class("Hydrogen", c_hydrogen);
class_alkali            = new Class("Alkali Metals", c_alkali);
class_earth             = new Class("Rare Earth Metals", c_earth);
class_nonmetal          = new Class("Non-Metals", c_nonmetal);
class_metal             = new Class("Metals", c_metal);
class_halogen           = new Class("Halogens", c_halogen);
class_noble             = new Class("Noble Gasses", c_noble);

hydrogen                = new Element("Hydrogen", "H", 1, 1, 0, class_hydrogen);
helium                  = new Element("Helium", "He", 2, 0, 0, class_noble);
lithium                 = new Element("Lithium", "Li", 3, 1, 0, class_alkali);
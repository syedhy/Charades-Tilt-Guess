import Foundation
import Cocoa

let mapping: [String: String] = [
    "kids_animals_dolphin": "🐬",
    "kids_animals_whale": "🐳",
    "kids_animals_shark": "🦈",
    "kids_animals_octopus": "🐙",
    "kids_animals_turtle": "🐢",
    "kids_animals_frog": "🐸",
    "kids_animals_snake": "🐍",
    "kids_animals_crocodile": "🐊",
    "kids_animals_alligator": "🐊",
    "kids_animals_kangaroo": "🦘",
    "kids_animals_koala": "🐨",
    "kids_animals_panda": "🐼",
    "kids_animals_rabbit": "🐰",
    "kids_animals_mouse": "🐭",
    "kids_animals_rat": "🐀",
    "kids_animals_squirrel": "🐿️",
    "kids_animals_bat": "🦇",
    "kids_animals_owl": "🦉",
    "kids_animals_eagle": "🦅",
    "kids_animals_hawk": "🦅",
    "kids_animals_parrot": "🦜",
    "kids_animals_peacock": "🦚",
    "kids_animals_flamingo": "🦩",
    "kids_animals_ostrich": "🦤",
    "kids_animals_chicken": "🐔",
    "kids_animals_duck": "🦆",
    "kids_animals_goose": "🪿",
    "kids_animals_swan": "🦢",
    "kids_animals_pig": "🐷",
    "kids_animals_cow": "🐮",
    "kids_animals_horse": "🐴",
    "kids_animals_sheep": "🐑",
    "kids_animals_goat": "🐐",
    "kids_animals_deer": "🦌",
    "kids_animals_moose": "🫎",
    "kids_animals_camel": "🐪",
    "kids_animals_rhino": "🦏",
    "kids_animals_hippo": "🦛",
    
    "kids_tools_hammer": "🔨",
    "kids_tools_screwdriver": "🪛",
    "kids_tools_wrench": "🔧",
    "kids_tools_pliers": "🗜️",
    "kids_tools_saw": "🪚",
    "kids_tools_drill": "🪛",
    "kids_tools_tape_measure": "📏",
    "kids_tools_level": "📏",
    "kids_tools_utility_knife": "🔪",
    "kids_tools_chisel": "🗡️",
    "kids_tools_files": "🗂️",
    "kids_tools_mallet": "🔨",
    "kids_tools_axe": "🪓",
    "kids_tools_shovel": "⛏️",
    "kids_tools_rake": "🌿",
    "kids_tools_hoe": "⛏️",
    "kids_tools_trowel": "⛏️",
    "kids_tools_pitchfork": "🔱",
    "kids_tools_wheelbarrow": "🛒",
    "kids_tools_ladder": "🪜",
    "kids_tools_flashlight": "🔦",
    "kids_tools_extension_cord": "🔌",
    "kids_tools_toolbox": "🧰",
    "kids_tools_nails": "📍",
    "kids_tools_screws": "🔩",
    "kids_tools_bolts": "🔩",
    "kids_tools_nuts": "🔩",
    "kids_tools_washers": "⭕",
    "kids_tools_sandpaper": "📜",
    "kids_tools_paintbrush": "🖌️",
    "kids_tools_paint_roller": "🖌️",
    "kids_tools_paint_tray": "🎨",
    "kids_tools_drop_cloth": "⬜",
    "kids_tools_bucket": "🪣",
    "kids_tools_sponge": "🧽",
    "kids_tools_broom": "🧹",
    "kids_tools_dustpan": "🧹",
    "kids_tools_mop": "🧹",
    "kids_tools_vacuum": "🌪️",
    "kids_tools_iron": "💨",
    "kids_tools_ironing_board": "💨",
    "kids_tools_scissors": "✂️",
    "kids_tools_needle": "🪡",
    "kids_tools_thread": "🧵",
    "kids_tools_thimble": "🪡",
    "kids_tools_pins": "📍",
    "kids_tools_measuring_tape": "📏",
    "kids_tools_sewing_machine": "🧵",
    "kids_tools_plunger": "🪠",
    "kids_tools_extra_item_0": "🧰",
    
    "kids_food_apple": "🍎",
    "kids_food_banana": "🍌",
    "kids_food_orange": "🍊",
    "kids_food_grape": "🍇",
    "kids_food_strawberry": "🍓",
    "kids_food_watermelon": "🍉",
    "kids_food_pineapple": "🍍",
    "kids_food_mango": "🥭",
    "kids_food_peach": "🍑",
    "kids_food_cherry": "🍒",
    "kids_food_pear": "🍐",
    "kids_food_plum": "🍑",
    "kids_food_kiwi": "🥝",
    "kids_food_lemon": "🍋",
    "kids_food_lime": "🍋",
    "kids_food_coconut": "🥥",
    "kids_food_tomato": "🍅",
    "kids_food_carrot": "🥕",
    "kids_food_potato": "🥔",
    "kids_food_onion": "🧅",
    "kids_food_garlic": "🧄",
    "kids_food_broccoli": "🥦",
    "kids_food_cauliflower": "🥦",
    "kids_food_corn": "🌽",
    "kids_food_peas": "🫛",
    "kids_food_green_beans": "🫘",
    "kids_food_spinach": "🥬",
    "kids_food_lettuce": "🥬",
    "kids_food_cucumber": "🥒",
    "kids_food_bell_pepper": "🫑",
    "kids_food_mushroom": "🍄",
    "kids_food_pizza": "🍕",
    "kids_food_burger": "🍔",
    "kids_food_hot_dog": "🌭",
    "kids_food_sandwich": "🥪",
    "kids_food_taco": "🌮",
    "kids_food_burrito": "🌯",
    "kids_food_sushi": "🍣",
    "kids_food_pasta": "🍝",
    "kids_food_noodles": "🍜",
    "kids_food_rice": "🍚",
    "kids_food_bread": "🍞",
    "kids_food_cheese": "🧀",
    "kids_food_egg": "🥚",
    "kids_food_bacon": "🥓",
    "kids_food_sausage": "🌭",
    "kids_food_chicken": "🍗",
    "kids_food_steak": "🥩",
    "kids_food_fish": "🐟",
    "kids_food_shrimp": "🍤"
]

let outputDir = URL(fileURLWithPath: "/Users/hyder/Documents/Projects/Charades/CharadesTiltGuess/Assets.xcassets/KidsMode")
try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

let size = CGSize(width: 256, height: 256)
let rect = CGRect(origin: .zero, size: size)

for (name, emoji) in mapping {
    let imagesetDir = outputDir.appendingPathComponent("\(name).imageset")
    try? FileManager.default.createDirectory(at: imagesetDir, withIntermediateDirectories: true)
    
    let font = NSFont.systemFont(ofSize: 200)
    let string = NSAttributedString(
        string: emoji,
        attributes: [.font: font]
    )
    
    let image = NSImage(size: size)
    image.lockFocus()
    let textSize = string.size()
    let textRect = NSRect(
        x: (size.width - textSize.width) / 2.0,
        y: (size.height - textSize.height) / 2.0,
        width: textSize.width,
        height: textSize.height
    )
    string.draw(in: textRect)
    image.unlockFocus()
    
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let pngData = bitmapRep.representation(using: .png, properties: [:])!
    
    let imageURL = imagesetDir.appendingPathComponent("\(name).png")
    try? pngData.write(to: imageURL)
    
    let contents = """
    {
      "images" : [
        {
          "filename" : "\(name).png",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    let contentsURL = imagesetDir.appendingPathComponent("Contents.json")
    try? contents.write(to: contentsURL, atomically: true, encoding: .utf8)
}

print("Generated \(mapping.count) emoji images.")

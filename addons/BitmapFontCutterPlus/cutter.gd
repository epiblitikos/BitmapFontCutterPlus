tool
extends BitmapFont


var index = 0
export(Vector2) var glyph_size = Vector2(8,8) setget change_glyph_size
export(Texture) var texture_to_cut = null setget change_texture
export(String, MULTILINE) var character_map setget change_character_map
export(float) var spacing = 1 setget change_spacing
export(bool) var monospaced = true setget change_monospaced


func change_character_map(value):
    character_map = value
    update()


func change_glyph_size(value):
    glyph_size = value
    height = glyph_size.y
    update()
    

func change_texture(value):
    texture_to_cut = value
    index = 0
    if texture_to_cut:
        update()
    

func change_spacing(value):
    spacing = value
    update()


func change_monospaced(value):
    monospaced = value
    update()


func _get_char_region(col, row):
    var left_margin = 0
    var character_width = glyph_size.x
    
    if not monospaced:
        var data = texture_to_cut.get_data()
        data.lock()
        
        var found = false
        for px in range(glyph_size.x):
            if found:
                break
            for py in range(glyph_size.y):
                var pixel = data.get_pixel(
                    col * glyph_size.x + px,
                    row * glyph_size.y + py
                )
                if pixel.a != 0:
                    left_margin = px
                    character_width -= px
                    found = true
                    break
        
        found = false
        for px in range(glyph_size.x):
            if found:
                break
            for py in range(glyph_size.y):
                var pixel = data.get_pixel(
                    col * glyph_size.x + glyph_size.x - px - 1,
                    row * glyph_size.y + py
                )
                if pixel.a != 0:
                    character_width -= px
                    found = true
                    break
                    
        data.unlock()
    
    return Rect2(
        col * glyph_size.x + left_margin,
        row * glyph_size.y,
        character_width,
        glyph_size.y
    )
    
    
func update():
    print("CutBitmapFont: Cut texture to font")
    if texture_to_cut != null and glyph_size.x > 0 and glyph_size.y > 0:
        var chars_wide = texture_to_cut.get_width() / glyph_size.x
        var chars_high = texture_to_cut.get_height() / glyph_size.y
        var char_offset = 0
        
        # Take the line breaks out. Allowing them is easy on the end user.
        #  This obviously means no custom char for it.
        var compact_char_map = character_map.replace("\n", "").replace("\r", "")

        clear()
        add_texture(texture_to_cut)
        height = glyph_size.y
        
        for row in range(chars_high):
            for col in range(chars_wide):
                var region = _get_char_region(col, row)
                add_char(
                    compact_char_map.ord_at(char_offset),
                    0,
                    region,
                    Vector2.ZERO,
                    region.size[0] + spacing
                )
                char_offset += 1
        update_changes()

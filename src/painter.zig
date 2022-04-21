
// 'w' counts only the interior, excluding left & right ends.
// prints total w + 2 characters
pub fn draw_line(win: anytype, x: u16, y: u16, w: u16,
    horiz: []const u8, left: []const u8, right: []const u8,
) !void {
    try win.puts_at(x+0, y, left);

    var i: u16 = 1;
    while (i <= w) : (i += 1) {
        try win.puts_at(x+i, y, horiz);
    }

    try win.puts_at(x+i, y, right);
}

// 'w', 'h' counts only the interior, excluding left & right, top & bottom ends.
// interior of the square drawn gets w*h sized area.
// (w+2) * (h+2) area is occupied by the drawing.
// does not clear the interior area.
pub fn draw_box(win: anytype, x: u16, y: u16, w: u16, h: u16,
    horiz:   []const u8, vert:     []const u8,
    topleft: []const u8, topright: []const u8,
    botleft: []const u8, botright: []const u8,
) !void {

    try draw_line(win, x, y, w, horiz, topleft, topright);

    var j: u16 = 1;
    while (j <= h) : (j += 1) {
        try win.puts_at(x,     y+j, vert);
        try win.puts_at(x+w+1, y+j, vert);
    }

    try draw_line(win, x, y+j, w, horiz, botleft, botright);
}

pub const UnicodeGlyphs = struct {
    pub const hori_line:       []const u8 = "\xe2\x94\x80"; // BOX DRAWINGS LIGHT HORIZONTAL
    pub const vert_line:       []const u8 = "\xe2\x94\x82"; // BOX DRAWINGS LIGHT VERTICAL
    pub const crossing_up:     []const u8 = "\xe2\x94\xb4"; // BOX DRAWINGS LIGHT UP AND HORIZONTAL
    pub const crossing_down:   []const u8 = "\xe2\x94\xac"; // BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
    pub const crossing_left:   []const u8 = "\xe2\x94\xa4"; // BOX DRAWINGS LIGHT VERTICAL AND LEFT
    pub const crossing_right:  []const u8 = "\xe2\x94\x9c"; // BOX DRAWINGS LIGHT VERTICAL AND RIGHT
    pub const crossing_plus:   []const u8 = "\xe2\x94\xbc"; // BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
    pub const corner_topleft:  []const u8 = "\xe2\x95\xad"; // BOX DRAWINGS LIGHT ARC DOWN AND RIGHT
    pub const corner_topright: []const u8 = "\xe2\x95\xae"; // BOX DRAWINGS LIGHT ARC DOWN AND LEFT
    pub const corner_botleft:  []const u8 = "\xe2\x95\xb0"; // BOX DRAWINGS LIGHT ARC UP AND RIGHT
    pub const corner_botright: []const u8 = "\xe2\x95\xaf"; // BOX DRAWINGS LIGHT ARC UP AND LEFT
};

pub fn unicode_draw_box(win: anytype, x: u16, y: u16, w: u16, h: u16) !void {
    try draw_box(win, x, y, w, h,
        UnicodeGlyphs.hori_line, UnicodeGlyphs.vert_line,
        UnicodeGlyphs.corner_topleft, UnicodeGlyphs.corner_topright,
        UnicodeGlyphs.corner_botleft, UnicodeGlyphs.corner_botright);
}

pub fn unicode_draw_hori_bar(win: anytype, x: u16, y: u16, width8: u32) !void {
    var col8: u32 = 8;
    var i: u16 = x;

    while (col8 < width8) : (col8 += 8) {
        try win.puts_at(i,y,"\u{2588}");
        i+=1;
    }

    if (col8 - width8 != 8) {
        try win.print_at(i,y,"{u}", .{
            @intCast(u21, 0x2588 + (col8 - width8))
        });
    }
}

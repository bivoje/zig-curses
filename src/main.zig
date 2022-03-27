const std = @import("std");
const curses = @import("curses.zig");
const Window = curses.Window;
const Screen = curses.Screen;

const print = std.debug.print;

const ColorPairs = enum(u8) {
    NormalMessage, Highlighted,
    WarningKeyword, WarningMessage,
    ErrorKeyword, ErrorMessage
};

pub fn main() !void {
    var alloc = std.testing.allocator;

    //var screen = try Screen(void).init(alloc, "screen", "/dev/pts/11", "/dev/pts/11");
    //var screen = try Screen(ColorPairs).init(alloc, "screen", "/dev/pts/5", "/dev/pts/5");
    //var screen = try Screen(ColorPairs).init(alloc, "screen-256color", "/dev/pts/5", "/dev/pts/5");
    var screen = try Screen(ColorPairs).init(alloc, "screen-256color", null, null);
    defer screen._deinit();
    var window = screen.std_window();
    defer window._deinit();

    try screen.echo(false);
    try screen.cbreak(true);
    try screen._curs_set(.Invisible);
    //try window.standout();
    try window.keypad(true);

    try screen.start_color();
    //try screen.register_colorpair(.NormalMessage, curses.COLOR_WHITE, curses.COLOR_BLACK);
    try screen.register_colorpair(.Highlighted,   curses.COLOR_BLACK, curses.COLOR_WHITE);
    try screen.register_colorpair(.WarningKeyword, .Turquoise4,  .Black);
    try screen.register_colorpair(.WarningMessage, .DeepSkyBlue1,.Black);
    try screen.register_colorpair(.ErrorKeyword,   .DeepPink,    .Yellow1);
    try screen.register_colorpair(.ErrorMessage,   .White,       .Cornsilk1);

    try window.color_set(.NormalMessage);
    try window.printw("hello! %d", .{@intCast(c_int, 3)});

    try window.color_set(.Highlighted);
    try window.mvprintw(4, 3, "zig-curses Demo! %d", .{@intCast(c_int, 3)});

    try window.color_set(.WarningKeyword);
    try window.mvprintw(5, 3, "zig-curses Demo! %d", .{@intCast(c_int, 3)});

    try window.color_set(.WarningMessage);
    try window.mvprintw(6, 3, "zig-curses Demo! %d", .{@intCast(c_int, 3)});

    try window.color_set(.ErrorKeyword);
    try window.mvprintw(7, 3, "zig-curses Demo! %d", .{@intCast(c_int, 3)});

    try window.color_set(.ErrorMessage);
    try window.mvprintw(8, 3, "zig-curses Demo! %d", .{@intCast(c_int, 3)});

    try window.color_set(.NormalMessage);
    try window.visual_on(.Blink);
    try window.print_at(3, 9, "zig-curses Demo! {d}", .{3});

    const a = screen.gen_attrs(.{
        ColorPairs.NormalMessage,
        curses.VisualAttr.Standout,
        curses.VisualAttr.Blink
    });
    try window.attr_on(a);
    try window.print_at(3, 10, "zig-curses Demo! {d}", .{3});

    try window.refresh();

    _ = try window.getch();
}

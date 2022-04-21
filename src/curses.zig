
const std = @import("std");

pub const painter = @import("painter.zig");


const c = @cImport({
    @cInclude("cursesflags.h");
    @cInclude("curses.h");
    @cInclude("stdio.h");
});

pub const CursesError = error {
    CursesInternal,
    FileOpenFail,
    VoidColor,
    ColorNotStarted,
    ImmutableDefault,
};

fn checkError(res: c_int) !c_int {
    if (res == c.ERR) {
        return error.CursesInternal;
    }
    return res;
}

fn check(res: c_int) !void{
    if (res == c.ERR) {
        return error.CursesInternal;
    }
}

fn cfileopen(alloc: std.mem.Allocator,
    path: []const u8, comptime mode: [:0]const u8
) ?*c.FILE {
    const cpath = alloc.dupeZ(u8, path) catch return null;
    defer alloc.free(cpath);
    const res = c.fopen(cpath.ptr, mode);
    return @ptrCast(?*c.FILE, res);
}

fn cfileclose(file: *c.FILE) !void {
    if (c.fclose(file) != 0) return error.FileOpenFail;
}

fn map(
    ox: anytype,
    comptime T: type,
    comptime f: fn (
        y: @typeInfo(@TypeOf(ox)).Optional.child
    //) @typeInfo(@TypeOf(f)).Fn.return_type.?
    ) T,
) @typeInfo(@TypeOf(f)).Fn.return_type {
    return if (ox) |x| f(x) else ox;
}

pub const KEY = struct {
    pub const BREAK       = c.KEY_BREAK;      //Break key
    pub const DOWN        = c.KEY_DOWN;       //The four arrow keys ...
    pub const UP          = c.KEY_UP;
    pub const LEFT        = c.KEY_LEFT;
    pub const RIGHT       = c.KEY_RIGHT;
    pub const HOME        = c.KEY_HOME;       //Home key (upward+left arrow)
    pub const BACKSPACE   = c.KEY_BACKSPACE;  //Backspace
    pub const F0          = c.KEY_F0;         //Function keys; space for 64 keys is reserved.
    pub const F1          = c.KEY_F1;         //For 0 <= n <= 63
    pub const F2          = c.KEY_F2;
    pub const F3          = c.KEY_F3;
    pub const F4          = c.KEY_F4;
    pub const F5          = c.KEY_F5;
    pub const F6          = c.KEY_F6;
    pub const F7          = c.KEY_F7;
    pub const F8          = c.KEY_F8;
    pub const F9          = c.KEY_F9;
    pub const F10         = c.KEY_F10;
    pub const F11         = c.KEY_F11;
    pub const F12         = c.KEY_F12;
    pub const F13         = c.KEY_F13;
    pub const F14         = c.KEY_F14;
    pub const F15         = c.KEY_F15;
    pub const F16         = c.KEY_F16;
    pub const F17         = c.KEY_F17;
    pub const F18         = c.KEY_F18;
    pub const F19         = c.KEY_F19;
    pub const F20         = c.KEY_F20;
    pub const F21         = c.KEY_F21;
    pub const F22         = c.KEY_F22;
    pub const F23         = c.KEY_F23;
    pub const F24         = c.KEY_F24;
    pub const F25         = c.KEY_F25;
    pub const F26         = c.KEY_F26;
    pub const F27         = c.KEY_F27;
    pub const F28         = c.KEY_F28;
    pub const F29         = c.KEY_F29;
    pub const F30         = c.KEY_F30;
    pub const F31         = c.KEY_F31;
    pub const F32         = c.KEY_F32;
    pub const F33         = c.KEY_F33;
    pub const F34         = c.KEY_F34;
    pub const F35         = c.KEY_F35;
    pub const F36         = c.KEY_F36;
    pub const F37         = c.KEY_F37;
    pub const F38         = c.KEY_F38;
    pub const F39         = c.KEY_F39;
    pub const F40         = c.KEY_F40;
    pub const F41         = c.KEY_F41;
    pub const F42         = c.KEY_F42;
    pub const F43         = c.KEY_F43;
    pub const F44         = c.KEY_F44;
    pub const F45         = c.KEY_F45;
    pub const F46         = c.KEY_F46;
    pub const F47         = c.KEY_F47;
    pub const F48         = c.KEY_F48;
    pub const F49         = c.KEY_F49;
    pub const F50         = c.KEY_F50;
    pub const F51         = c.KEY_F51;
    pub const F52         = c.KEY_F52;
    pub const F53         = c.KEY_F53;
    pub const F54         = c.KEY_F54;
    pub const F55         = c.KEY_F55;
    pub const F56         = c.KEY_F56;
    pub const F57         = c.KEY_F57;
    pub const F58         = c.KEY_F58;
    pub const F59         = c.KEY_F59;
    pub const F60         = c.KEY_F60;
    pub const F61         = c.KEY_F61;
    pub const F62         = c.KEY_F62;
    pub const F63         = c.KEY_F63;
    pub const DL          = c.KEY_DL;         //Delete line
    pub const IL          = c.KEY_IL;         //Insert line
    pub const DC          = c.KEY_DC;         //Delete character
    pub const IC          = c.KEY_IC;         //Insert char or enter insert mode
    pub const EIC         = c.KEY_EIC;        //Exit insert char mode
    pub const CLEAR       = c.KEY_CLEAR;      //Clear screen
    pub const EOS         = c.KEY_EOS;        //Clear to end of screen
    pub const EOL         = c.KEY_EOL;        //Clear to end of line
    pub const SF          = c.KEY_SF;         //Scroll 1 line forward
    pub const SR          = c.KEY_SR;         //Scroll 1 line backward (reverse)
    pub const NPAGE       = c.KEY_NPAGE;      //Next page
    pub const PPAGE       = c.KEY_PPAGE;      //Previous page
    pub const STAB        = c.KEY_STAB;       //Set tab
    pub const CTAB        = c.KEY_CTAB;       //Clear tab
    pub const CATAB       = c.KEY_CATAB;      //Clear all tabs
    pub const ENTER       = c.KEY_ENTER;      //Enter or send
    pub const SRESET      = c.KEY_SRESET;     //Soft (partial) reset
    pub const RESET       = c.KEY_RESET;      //Reset or hard reset

    pub const PRINT       = c.KEY_PRINT;      //Print or copy
    pub const LL          = c.KEY_LL;         //Home down or bottom (lower left)
    pub const A1          = c.KEY_A1;         //Upper left of keypad
    pub const A3          = c.KEY_A3;         //Upper right of keypad
    pub const B2          = c.KEY_B2;         //Center of keypad
    pub const C1          = c.KEY_C1;         //Lower left of keypad
    pub const C3          = c.KEY_C3;         //Lower right of keypad
    pub const BTAB        = c.KEY_BTAB;       //Back tab key
    pub const BEG         = c.KEY_BEG;        //Beg(inning) key
    pub const CANCEL      = c.KEY_CANCEL;     //Cancel key
    pub const CLOSE       = c.KEY_CLOSE;      //Close key
    pub const COMMAND     = c.KEY_COMMAND;    //Cmd (command) key
    pub const COPY        = c.KEY_COPY;       //Copy key
    pub const CREATE      = c.KEY_CREATE;     //Create key
    pub const END         = c.KEY_END;        //End key
    pub const EXIT        = c.KEY_EXIT;       //Exit key
    pub const FIND        = c.KEY_FIND;       //Find key
    pub const HELP        = c.KEY_HELP;       //Help key
    pub const MARK        = c.KEY_MARK;       //Mark key
    pub const MESSAGE     = c.KEY_MESSAGE;    //Message key
    pub const MOUSE       = c.KEY_MOUSE;      //Mouse event occurred
    pub const MOVE        = c.KEY_MOVE;       //Move key
    pub const NEXT        = c.KEY_NEXT;       //Next object key
    pub const OPEN        = c.KEY_OPEN;       //Open key
    pub const OPTIONS     = c.KEY_OPTIONS;    //Options key
    pub const PREVIOUS    = c.KEY_PREVIOUS;   //Previous object key
    pub const REDO        = c.KEY_REDO;       //Redo key
    pub const REFERENCE   = c.KEY_REFERENCE;  //Ref(erence) key
    pub const REFRESH     = c.KEY_REFRESH;    //Refresh key
    pub const REPLACE     = c.KEY_REPLACE;    //Replace key
    pub const RESIZE      = c.KEY_RESIZE;     //Screen resized
    pub const RESTART     = c.KEY_RESTART;    //Restart key
    pub const RESUME      = c.KEY_RESUME;     //Resume key
    pub const SAVE        = c.KEY_SAVE;       //Save key
    pub const SBEG        = c.KEY_SBEG;       //Shifted beginning key
    pub const SCANCEL     = c.KEY_SCANCEL;    //Shifted cancel key
    pub const SCOMMAND    = c.KEY_SCOMMAND;   //Shifted command key
    pub const SCOPY       = c.KEY_SCOPY;      //Shifted copy key
    pub const SCREATE     = c.KEY_SCREATE;    //Shifted create key
    pub const SDC         = c.KEY_SDC;        //Shifted delete char key
    pub const SDL         = c.KEY_SDL;        //Shifted delete line key
    pub const SELECT      = c.KEY_SELECT;     //Select key
    pub const SEND        = c.KEY_SEND;       //Shifted end key
    pub const SEOL        = c.KEY_SEOL;       //Shifted clear line key
    pub const SEXIT       = c.KEY_SEXIT;      //Shifted exit key
    pub const SFIND       = c.KEY_SFIND;      //Shifted find key
    pub const SHELP       = c.KEY_SHELP;      //Shifted help key
    pub const SHOME       = c.KEY_SHOME;      //Shifted home key
    pub const SIC         = c.KEY_SIC;        //Shifted insert key
    pub const SLEFT       = c.KEY_SLEFT;      //Shifted left arrow key
    pub const SMESSAGE    = c.KEY_SMESSAGE;   //Shifted message key
    pub const SMOVE       = c.KEY_SMOVE;      //Shifted move key
    pub const SNEXT       = c.KEY_SNEXT;      //Shifted next key
    pub const SOPTIONS    = c.KEY_SOPTIONS;   //Shifted options key
    pub const SPREVIOUS   = c.KEY_SPREVIOUS;  //Shifted prev key
    pub const SPRINT      = c.KEY_SPRINT;     //Shifted print key
    pub const SREDO       = c.KEY_SREDO;      //Shifted redo key
    pub const SREPLACE    = c.KEY_SREPLACE;   //Shifted replace key
    pub const SRIGHT      = c.KEY_SRIGHT;     //Shifted right arrow key
    pub const SRSUME      = c.KEY_SRSUME;     //Shifted resume key
    pub const SSAVE       = c.KEY_SSAVE;      //Shifted save key
    pub const SSUSPEND    = c.KEY_SSUSPEND;   //Shifted suspend key
    pub const SUNDO       = c.KEY_SUNDO;      //Shifted undo key
    pub const SUSPEND     = c.KEY_SUSPEND;    //Suspend key
    pub const UNDO        = c.KEY_UNDO;       //Undo key
};

const CursorVisibility = enum(c_int) {
    Invisible   = 0,
    Normal      = 1,
    VeryVisible = 2,
};

pub const VisualAttr = enum(c_uint) {
    Normal      = c.A_NORMAL,
    Standout    = c.A_STANDOUT,
    Underline   = c.A_UNDERLINE,
    Reverse     = c.A_REVERSE,
    Blink       = c.A_BLINK,
    Dim         = c.A_DIM,
    Bold        = c.A_BOLD,
    Protect     = c.A_PROTECT,
    Invis       = c.A_INVIS,
    Altcharset  = c.A_ALTCHARSET,
    Italic      = c.A_ITALIC,
    Chartext    = c.A_CHARTEXT,
    Color       = c.A_COLOR,
};

pub const Attr = struct {
    const Self = @This();

    attr: c_uint,

    pub fn normal() Self {
        return .{ .attr = @enumToInt(VisualAttr.Normal) };
    }

    pub fn color(self: *Self, colorpair: anytype) void {
        const x =
            if (@typeInfo(@TypeOf(colorpair)) == .Enum)
                @enumToInt(colorpair)
            else if (@TypeOf(colorpair) == c_short)
                colorpair
            else
                @compileError("Expected enum or c_short argument, found "
                              ++ @typeName(@TypeOf(colorpair)))
            ;
        self.attr |= @intCast(c_uint, c.COLOR_PAIR(@intCast(c_int, x)));
    }

    pub fn visual(self: *Self, attr: VisualAttr) void {
        self.attr |= @enumToInt(attr);
    }
};


pub fn Screen(comptime PAIR_ENUM: type) type {
    return struct {
        const Self = @This();

        scr: *c.SCREEN,
        ofd: ?*c.FILE,
        ifd: ?*c.FILE,
        alloc: std.mem.Allocator,

        // FIXME refactor
        pub fn init(alloc: std.mem.Allocator,
            term_type: ?[]const u8,
            outfile: ?[]const u8,
            infile: ?[]const u8,
        ) !Self {

            var term = if (term_type) |term_string|
                try alloc.dupeZ(u8, term_string)
            else null;
            defer if (term) |t| alloc.free(t);

            const ofd = if (outfile) |path|
                cfileopen(alloc, path, "wb")
            else null;
            errdefer if (ofd) |f| { _=c.fclose(f); };

            const ifd = if (infile) |path|
                cfileopen(alloc, path, "rb")
            else null;
            errdefer if (ifd) |f| { _=c.fclose(f); };

            const cscreen = c.newterm(
                @ptrCast(
                    [*c]const u8,
                    if (term) |t| t.ptr else null
                ),
                @ptrCast(*allowzero c.FILE, ofd),
                @ptrCast(*allowzero c.FILE, ifd),
            );

            const screen = @ptrCast(?*c.SCREEN, cscreen)
                orelse return error.CursesInteral;

            return Self {
                .scr = screen, .alloc = alloc,
                .ofd = ofd, .ifd = ifd,
            };
        }

        pub fn deinit(self: *Self) !void {
            try self.putback();
            c.delscreen(self.scr);
            if (self.ofd) |f| try cfileclose(f);
            if (self.ifd) |f| try cfileclose(f);
            // TODO set to null?
        }

        // silenced version to be used with defer
        pub fn _deinit(self: *Self) void {
            self.deinit() catch return;
        }

        pub fn use(self: Self) !void {
            return check(c.set_term(self.src));
        }

        pub fn putback(_: Self) !void {
            return check(c.endwin());
        }

        pub fn is_putback(_: Self) bool {
            return c.isendwin();
        }

        pub fn std_window(self: Self) Window(PAIR_ENUM) {
            const window = @ptrCast(?*c.WINDOW, c.stdscr) orelse unreachable;
            return Window(PAIR_ENUM) { .win = window, .alloc = self.alloc };
        }

        pub fn new_window(self: Self, x: u16, y: u16, w: u16, h: u16) !Window {
            return Window.init(self.alloc, x, y, w, h);
        }

        // returns the previous cursor visibility
        pub fn curs_set(_: Self, visibility: CursorVisibility) !CursorVisibility{
            return @intToEnum(CursorVisibility,
                try checkError(c.curs_set(@enumToInt(visibility)))
            );
        }

        // silenced version
        pub fn _curs_set(_: Self, visibility: CursorVisibility) !void{
            return check(c.curs_set(@enumToInt(visibility)));
        }

        // toggle char-buffering
        pub fn cbreak(_: Self, b: bool) !void {
            return check(if (b) c.cbreak() else c.nocbreak());
        }

        // toggle blind typing
        pub fn echo(_: Self, b: bool) !void {
            return check(if (b) c.echo() else c.noecho());
        }

        pub fn has_colors(_: Self) bool {
            return c.has_colors();
        }

        pub fn can_change_color(_: Self) bool {
            return c.can_change_color();
        }

        pub fn start_color(_: Self) !void {
            if (PAIR_ENUM == void) return error.VoidColor;
            try check(c.start_color());
        }

        // TODO not tested yet
        pub fn register_color(_: Self, id: PalleteCell, r: c_short, g: c_short, b: c_short) !void {
            if (PAIR_ENUM == void) return error.VoidColor;
            if (c.COLORS == 0) return error.ColorNotStarted;

            const color_id = @intCast(c_int, @enumToInt(id));
            if (c.COLORS <= color_id) return error.OutOfColorRange;
            try check(c.init_color(color_id, r, g, b));
        }

        pub fn register_colorpair(_: Self, id: PAIR_ENUM, fg: PalleteCell, bg: PalleteCell) !void {
            if (PAIR_ENUM == void) return error.VoidColor;
            if (c.COLORS == 0) return error.ColorNotStarted;
            const pair_id =
                if (PAIR_ENUM == c_short) id
                else @intCast(c_short, @enumToInt(id)) ;
            if (pair_id == 0) return error.ImmutableDefault;
            if (c.COLOR_PAIRS <= pair_id) return error.OutOfColorPairRange;

            const fg_color = @enumToInt(fg);
            const bg_color = @enumToInt(bg);
            if (c.COLORS <= fg_color) return error.OutOfColorRange;
            if (c.COLORS <= bg_color) return error.OutOfColorRange;

            return check(c.init_pair(pair_id, fg_color, bg_color));
        }

        // this character will be read by next getch called from
        // any of the windows in this screen
        pub fn ungetch(_: Self, ch: u8) !void {
            try check(c.ungetch(ch));
        }

        pub fn gen_attrs(_: Self, comptime args: anytype) Attr {
            const ArgsType = @TypeOf(args);
            const args_type_info = @typeInfo(ArgsType);
            if (args_type_info != .Struct) {
                @compileError("Expected tuple or struct argument, found " ++ @typeName(ArgsType));
            }

            var attr = Attr.normal();

            const fields_info = args_type_info.Struct.fields;
            inline for (fields_info) |field| {
                const a = @field(args, field.name);
                if (@TypeOf(a) == VisualAttr) {
                    attr.visual(a);
                } else if (@TypeOf(a) == PAIR_ENUM) {
                    attr.color(a);
                } else {
                    @compileError("Expected VisualAttr or enum, found " ++ @typeName(@TypeOf(a)));
                }
            }

            return attr;
        }
    };
}


pub fn Window(comptime PAIR_ENUM: type) type {

    if (PAIR_ENUM != void and PAIR_ENUM != c_short and @typeInfo(PAIR_ENUM) != .Enum) {
        @compileError("Expected void, c_short or enum type, found " ++ @typeName(PAIR_ENUM));
    }

    return struct {
        const Self = @This();

        win: *c.WINDOW,
        alloc: std.mem.Allocator,

        pub fn init(alloc: std.mem.Allocator, x: u16, y: u16, w: u16, h: u16) !Self {
            const cwindow = c.newwin(h, w, y, x);
            const window = @ptrCast(?*c.SCREEN, cwindow)
                orelse return error.CursesInternal;
            return Self{ .win = window, .alloc = alloc };
        }

        pub fn deinit(self: Self) !void {
            return check(c.delwin(self.win));
        }

        pub fn _deinit(self: Self) void {
            self.deinit() catch return;
        }

        // ncurses extension
        // pub fn resize(lines: u16, columns: u16) !void {}

        // uses format string of zig
        pub fn print_at(self: Self, x: u16, y: u16, comptime fmt: []const u8, args: anytype) !void {
            const cstr = try std.fmt.allocPrintZ(self.alloc, fmt, args);
            defer self.alloc.free(cstr);
            const res = @call(.{}, c.mvwaddstr, .{self.win, y, x, cstr.ptr});
            return check(res);
        }

        // uses format string of zig
        pub fn print(self: Self, comptime fmt: []const u8, args: anytype) !void {
            const cstr = try std.fmt.allocPrintZ(self.alloc, fmt, args);
            defer self.alloc.free(cstr);
            const res = @call(.{}, c.waddstr, .{self.win, cstr.ptr});
            return check(res);
        }

        // uses format string of zig
        pub fn puts_at(self: Self, x: u16, y: u16, str: []const u8) !void {
            return self.print_at(x, y, "{s}", .{str});
        }

        pub fn puts(self: Self, str: []const u8) !void {
            return self.print_at("{s}", .{str});
        }

        pub fn refresh(self: Self) !void {
            return check(c.wrefresh(self.win));
        }

        pub fn erase(self: Self) !void {
            try check(c.werase(self.win));
        }


        pub fn keypad(self: Self, bf: bool) !void {
            return check(c.keypad(self.win, bf));
        }

        pub fn visual_on(self: Self, attr: VisualAttr) !void {
            return check(c.wattr_on(self.win, @enumToInt(attr), null));
        }

        pub fn visual_off(self: Self, attr: VisualAttr) !void {
            return check(c.wattr_off(self.win, @enumToInt(attr), null));
        }

        pub fn color_set(self: Self, cp: PAIR_ENUM) !void {
            if (PAIR_ENUM == void) return error.VoidColor;
            if (c.COLORS == 0) return error.ColorNotStarted;

            const pair_id =
                if (PAIR_ENUM == c_short) cp
                else @intCast(c_short, @enumToInt(cp)) ;
            if (c.COLOR_PAIRS <= pair_id) return error.OutOfColorPairRange;
            const x = c.COLOR_PAIR(@intCast(c_int, pair_id));
            return check(c.wattr_on(self.win, @intCast(c_uint, x), null));
        }

        // getch returns null if timeout (wait is positive)
        // non blocking input (wait is 0)
        // blocking input (wait is negative)
        pub fn timeout(self: Self, wait: i32) void {
            c.wtimeout(self.win, @intCast(c_int, wait));
        }

        pub fn getch(self: Self) ?c_int {
            // FIXME ref states wgetch returns Err when interrupted
            // or timeout, (the former) in turn, sets errno to EINTR.
            // but i coundn't let it return Err on interrupt,
            // for some reason. so leaving the case unhandled.
            // a bugreport in future may address this problem and
            // let me know how to produce such cases.
            const ret = c.wgetch(self.win);
            return if (ret == c.ERR) null else ret;
        }

        pub fn botRight(self: Self) struct { x: u16, y: u16 } {
            var x: c_int = undefined;
            var y: c_int = undefined;
            c.get_maxyx(self.win, &y, &x);
            return .{ .x = @intCast(u16, x), .y = @intCast(u16, y) };
        }

        pub fn topLeft(self: Self) struct { x: u16, y: u16 } {
            var x: c_int = undefined;
            var y: c_int = undefined;
            c.get_begyx(self.win, &y, &x);
            return .{ .x = @intCast(u16, x), .y = @intCast(u16, y) };
        }

        //pub fn getmaxy(self: Self) u16 { return @intCast(u16, c.getmaxy(self.win)); }
        //pub fn getmaxx(self: Self) u16 { return @intCast(u16, c.getmaxx(self.win)); }

        // these methods are provided as is.
        // no abstraction, protection is provided.
        // for those who want to access curses API as it were in C.

        pub fn mvaddstr(self: Self, y: u16, x: u16, str: []const u8) !void {
            const cstr = try self.alloc.dupeZ(u8, str);
            defer self.alloc.free(cstr);
            return check(c.mvwaddstr(self.win, y, x, cstr.ptr));
        }

        // uses format string of C
        pub fn mvprintw(self: Self, y: u16, x: u16, fmt: []const u8, args: anytype) !void {
            const cstr = try self.alloc.dupeZ(u8, fmt);
            defer self.alloc.free(cstr);
            const res = @call(.{}, c.mvwprintw, .{self.win, y, x, cstr.ptr} ++ args);
            return check(res);
        }

        // uses format string of C
        pub fn printw(self: Self, fmt: []const u8, args: anytype) !void {
            const cstr = try self.alloc.dupeZ(u8, fmt);
            defer self.alloc.free(cstr);
            const res = @call(.{}, c.wprintw, .{self.win, cstr.ptr} ++ args);
            return check(res);
        }

        pub fn attr_on(self: Self, attr: Attr) !void {
            return check(c.wattr_on(self.win, attr.attr, null));
        }

        pub fn attr_off(self: Self, attr: Attr) !void {
            return check(c.wattr_off(self.win, attr.attr, null));
        }

    };
}

pub const PalleteCell = enum(c_short) {
    Black                =   0, // rgb: #000000
    Red4                 =   1, // rgb: #800000 <= #8b0000
    Green                =   2, // rgb: #008000 <= #00ff00
    Olive                =   3, // rgb: #808000
    Navy                 =   4, // rgb: #000080 <= #000080
    Magenta4             =   5, // rgb: #800080 <= #8b008b
    Teal                 =   6, // rgb: #008080
    Silver               =   7, // rgb: #c0c0c0
    Grey                 =   8, // rgb: #808080 <= #bebebe
    Red                  =   9, // rgb: #ff0000 <= #ff0000
    Lime                 =  10, // rgb: #00ff00
    Yellow               =  11, // rgb: #ffff00 <= #ffff00
    Blue                 =  12, // rgb: #0000ff <= #0000ff
    Fuchsia              =  13, // rgb: #ff00ff
    Aqua                 =  14, // rgb: #00ffff
    White                =  15, // rgb: #ffffff <= #ffffff
    Grey0                =  16, // rgb: #000000
    NavyBlue             =  17, // rgb: #00005f <= #000080
    DarkBlue             =  18, // rgb: #000087 <= #00008b
    Blue3                =  19, // rgb: #0000af <= #0000cd
    MediumBlue           =  20, // rgb: #0000d7 <= #0000cd
    Blue1                =  21, // rgb: #0000ff <= #0000ff
    DarkGreen            =  22, // rgb: #005f00 <= #006400
    DodgerBlue4          =  23, // rgb: #005f5f <= #104e8b
    DeepSkyBlue4         =  24, // rgb: #005f87 <= #00688b
    RoyalBlue4           =  25, // rgb: #005faf <= #27408b
    DodgerBlue3          =  26, // rgb: #005fd7 <= #1874cd
    DodgerBlue2          =  27, // rgb: #005fff <= #1c86ee
    Green4               =  28, // rgb: #008700 <= #008b00
    SpringGreen4         =  29, // rgb: #00875f <= #008b45
    Turquoise4           =  30, // rgb: #008787 <= #00868b
    DeepSkyBlue3         =  31, // rgb: #0087af <= #009acd
    DodgerBlue           =  32, // rgb: #0087d7 <= #1e90ff
    DodgerBlue1          =  33, // rgb: #0087ff <= #1e90ff
    ForestGreen          =  34, // rgb: #00af00 <= #228b22
    Indigo2              =  35, // rgb: #00af5f <= #218868
    DarkCyan             =  36, // rgb: #00af87 <= #008b8b
    LightSeaGreen        =  37, // rgb: #00afaf <= #20b2aa
    DeepSkyBlue2         =  38, // rgb: #00afd7 <= #00b2ee
    DeepSkyBlue1         =  39, // rgb: #00afff <= #00bfff
    Green3               =  40, // rgb: #00d700 <= #00cd00
    SpringGreen3         =  41, // rgb: #00d75f <= #00cd66
    SpringGreen2         =  42, // rgb: #00d787 <= #00ee76
    Cyan3                =  43, // rgb: #00d7af <= #00cdcd
    DarkTurquoise        =  44, // rgb: #00d7d7 <= #00ced1
    Turquoise2           =  45, // rgb: #00d7ff <= #00e5ee
    Green1               =  46, // rgb: #00ff00 <= #00ff00
    SpringGreen          =  47, // rgb: #00ff5f <= #00ff7f
    SpringGreen1         =  48, // rgb: #00ff87 <= #00ff7f
    MediumSpringGreen    =  49, // rgb: #00ffaf <= #00fa9a
    Cyan2                =  50, // rgb: #00ffd7 <= #00eeee
    Cyan1                =  51, // rgb: #00ffff <= #00ffff
    Firebrick4           =  52, // rgb: #5f0000 <= #8b1a1a
    VioletRed4           =  53, // rgb: #5f005f <= #8b2252
    Indigo               =  54, // rgb: #5f0087 <= #4b0082
    Purple4              =  55, // rgb: #5f00af <= #551a8b
    Purple3              =  56, // rgb: #5f00d7 <= #7d26cd
    BlueViolet           =  57, // rgb: #5f00ff <= #8a2be2
    Gold4                =  58, // rgb: #5f5f00 <= #8b7500
    Grey37               =  59, // rgb: #5f5f5f <= #5e5e5e
    MediumPurple4        =  60, // rgb: #5f5f87 <= #5d478b
    SlateBlue3           =  61, // rgb: #5f5faf <= #6959cd
    SlateBlue            =  62, // rgb: #5f5fd7 <= #6a5acd
    RoyalBlue1           =  63, // rgb: #5f5fff <= #4876ff
    Chartreuse4          =  64, // rgb: #5f8700 <= #458b00
    DarkSeaGreen4        =  65, // rgb: #5f875f <= #698b69
    PaleTurquoise4       =  66, // rgb: #5f8787 <= #668b8b
    SteelBlue            =  67, // rgb: #5f87af <= #4682b4
    SteelBlue3           =  68, // rgb: #5f87d7 <= #4f94cd
    CornflowerBlue       =  69, // rgb: #5f87ff <= #6495ed
    OliveDrab            =  70, // rgb: #5faf00 <= #6b8e23
    MediumSeaGreen       =  71, // rgb: #5faf5f <= #3cb371
    MediumAquamarine     =  72, // rgb: #5faf87 <= #66cdaa
    CadetBlue            =  73, // rgb: #5fafaf <= #5f9ea0
    SkyBlue3             =  74, // rgb: #5fafd7 <= #6ca6cd
    SteelBlue1           =  75, // rgb: #5fafff <= #63b8ff
    Chartreuse3          =  76, // rgb: #5fd700 <= #66cd00
    SgiChartreuse        =  77, // rgb: #5fd75f <= #71c671
    SeaGreen3            =  78, // rgb: #5fd787 <= #43cd80
    Aquamarine3          =  79, // rgb: #5fd7af <= #66cdaa
    MediumTurquoise      =  80, // rgb: #5fd7d7 <= #48d1cc
    LightSkyBlue         =  81, // rgb: #5fd7ff <= #87cefa
    LawnGreen            =  82, // rgb: #5fff00 <= #7cfc00
    SeaGreen2            =  83, // rgb: #5fff5f <= #4eee94
    LightGreen           =  84, // rgb: #5fff87 <= #90ee90
    SeaGreen1            =  85, // rgb: #5fffaf <= #54ff9f
    Aquamarine           =  86, // rgb: #5fffd7 <= #7fffd4
    DarkSlateGray2       =  87, // rgb: #5fffff <= #8deeee
    DarkRed              =  88, // rgb: #870000 <= #8b0000
    DeepPink4            =  89, // rgb: #87005f <= #8b0a50
    DarkMagenta          =  90, // rgb: #870087 <= #8b008b
    DarkOrchid4          =  91, // rgb: #8700af <= #68228b
    DarkViolet           =  92, // rgb: #8700d7 <= #9400d3
    Purple2              =  93, // rgb: #8700ff <= #912cee
    Orange4              =  94, // rgb: #875f00 <= #8b5a00
    LightPink4           =  95, // rgb: #875f5f <= #8b5f65
    Plum4                =  96, // rgb: #875f87 <= #8b668b
    Orchid4              =  97, // rgb: #875faf <= #8b4789
    MediumPurple3        =  98, // rgb: #875fd7 <= #8968cd
    SlateBlue1           =  99, // rgb: #875fff <= #836fff
    Yellow4              = 100, // rgb: #878700 <= #8b8b00
    Wheat4               = 101, // rgb: #87875f <= #8b7e66
    Grey53               = 102, // rgb: #878787 <= #878787
    LightSlateGrey       = 103, // rgb: #8787af <= #778899
    MediumPurple         = 104, // rgb: #8787d7 <= #9370db
    LightSlateBlue       = 105, // rgb: #8787ff <= #8470ff
    OliveDrab4           = 106, // rgb: #87af00 <= #698b22
    Burlywood4           = 107, // rgb: #87af5f <= #8b7355
    DarkSeaGreen         = 108, // rgb: #87af87 <= #8fbc8f
    SgiLightBlue         = 109, // rgb: #87afaf <= #7d9ec0
    LightSkyBlue3        = 110, // rgb: #87afd7 <= #8db6cd
    SkyBlue2             = 111, // rgb: #87afff <= #7ec0ee
    Chartreuse2          = 112, // rgb: #87d700 <= #76ee00
    YellowGreen          = 113, // rgb: #87d75f <= #9acd32
    PaleGreen3           = 114, // rgb: #87d787 <= #7ccd7c
    PaleGreen            = 115, // rgb: #87d7af <= #98fb98
    DarkSlateGray3       = 116, // rgb: #87d7d7 <= #79cdcd
    SkyBlue1             = 117, // rgb: #87d7ff <= #87ceff
    Chartreuse1          = 118, // rgb: #87ff00 <= #7fff00
    OliveDrab1           = 119, // rgb: #87ff5f <= #c0ff3e
    PaleGreen1           = 120, // rgb: #87ff87 <= #9aff9a
    Aquamarine2          = 121, // rgb: #87ffaf <= #76eec6
    Aquamarine1          = 122, // rgb: #87ffd7 <= #7fffd4
    DarkSlateGray1       = 123, // rgb: #87ffff <= #97ffff
    Firebrick            = 124, // rgb: #af0000 <= #b22222
    Maroon4              = 125, // rgb: #af005f <= #8b1c62
    MediumVioletRed      = 126, // rgb: #af0087 <= #c71585
    Maroon3              = 127, // rgb: #af00af <= #cd2990
    Magenta3             = 128, // rgb: #af00d7 <= #cd00cd
    Purple               = 129, // rgb: #af00ff <= #a020f0
    DarkOrange3          = 130, // rgb: #af5f00 <= #cd6600
    Maroon               = 131, // rgb: #af5f5f <= #b03060
    SgiBeet              = 132, // rgb: #af5f87 <= #8e388e
    MediumOrchid3        = 133, // rgb: #af5faf <= #b452cd
    MediumOrchid         = 134, // rgb: #af5fd7 <= #ba55d3
    DarkOrchid1          = 135, // rgb: #af5fff <= #bf3eff
    DarkGoldenrod        = 136, // rgb: #af8700 <= #b8860b
    Peru                 = 137, // rgb: #af875f <= #cd853f
    RosyBrown            = 138, // rgb: #af8787 <= #bc8f8f
    Grey63               = 139, // rgb: #af87af <= #a1a1a1
    SlateGray3           = 140, // rgb: #af87d7 <= #9fb6cd
    MediumPurple1        = 141, // rgb: #af87ff <= #ab82ff
    Goldenrod3           = 142, // rgb: #afaf00 <= #cd9b1d
    DarkKhaki            = 143, // rgb: #afaf5f <= #bdb76b
    NavajoWhite3         = 144, // rgb: #afaf87 <= #cdb38b
    Grey69               = 145, // rgb: #afafaf <= #b0b0b0
    LightSteelBlue3      = 146, // rgb: #afafd7 <= #a2b5cd
    LightSteelBlue       = 147, // rgb: #afafff <= #b0c4de
    Chartreuse           = 148, // rgb: #afd700 <= #7fff00
    DarkOliveGreen3      = 149, // rgb: #afd75f <= #a2cd5a
    DarkSeaGreen3        = 150, // rgb: #afd787 <= #9bcd9b
    DarkSeaGreen2        = 151, // rgb: #afd7af <= #b4eeb4
    LightCyan3           = 152, // rgb: #afd7d7 <= #b4cdcd
    LightSkyBlue1        = 153, // rgb: #afd7ff <= #b0e2ff
    GreenYellow          = 154, // rgb: #afff00 <= #adff2f
    DarkOliveGreen2      = 155, // rgb: #afff5f <= #bcee68
    PaleGreen2           = 156, // rgb: #afff87 <= #90ee90
    DarkSeaGreen1        = 157, // rgb: #afffaf <= #c1ffc1
    PaleTurquoise        = 158, // rgb: #afffd7 <= #afeeee
    PaleTurquoise1       = 159, // rgb: #afffff <= #bbffff
    Firebrick2           = 160, // rgb: #d70000 <= #ee2c2c
    Crimson              = 161, // rgb: #d7005f <= #dc143c
    DeepPink3            = 162, // rgb: #d70087 <= #cd1076
    VioletRed            = 163, // rgb: #d700af <= #d02090
    Magenta              = 164, // rgb: #d700d7 <= #ff00ff
    MediumOrchid2        = 165, // rgb: #d700ff <= #d15fee
    OrangeRed3           = 166, // rgb: #d75f00 <= #cd3700
    IndianRed            = 167, // rgb: #d75f5f <= #cd5c5c
    HotPink3             = 168, // rgb: #d75f87 <= #cd6090
    HotPink2             = 169, // rgb: #d75faf <= #ee6aa7
    Orchid               = 170, // rgb: #d75fd7 <= #da70d6
    MediumOrchid1        = 171, // rgb: #d75fff <= #e066ff
    Orange3              = 172, // rgb: #d78700 <= #cd8500
    LightSalmon3         = 173, // rgb: #d7875f <= #cd8162
    LightPink3           = 174, // rgb: #d78787 <= #cd8c95
    Pink3                = 175, // rgb: #d787af <= #cd919e
    Plum3                = 176, // rgb: #d787d7 <= #cd96cd
    Violet               = 177, // rgb: #d787ff <= #ee82ee
    Gold3                = 178, // rgb: #d7af00 <= #cdad00
    LightGoldenrod3      = 179, // rgb: #d7af5f <= #cdbe70
    Tan                  = 180, // rgb: #d7af87 <= #d2b48c
    MistyRose3           = 181, // rgb: #d7afaf <= #cdb7b5
    Thistle3             = 182, // rgb: #d7afd7 <= #cdb5cd
    Plum2                = 183, // rgb: #d7afff <= #eeaeee
    Yellow3              = 184, // rgb: #d7d700 <= #cdcd00
    Khaki                = 185, // rgb: #d7d75f <= #f0e68c
    Khaki3               = 186, // rgb: #d7d787 <= #cdc673
    LightYellow3         = 187, // rgb: #d7d7af <= #cdcdb4
    Grey84               = 188, // rgb: #d7d7d7 <= #d6d6d6
    LightSteelBlue1      = 189, // rgb: #d7d7ff <= #cae1ff
    Yellow2              = 190, // rgb: #d7ff00 <= #eeee00
    OliveDrab2           = 191, // rgb: #d7ff5f <= #b3ee3a
    DarkOliveGreen1      = 192, // rgb: #d7ff87 <= #caff70
    LemonChiffon         = 193, // rgb: #d7ffaf <= #fffacd
    Honeydew2            = 194, // rgb: #d7ffd7 <= #e0eee0
    LightCyan1           = 195, // rgb: #d7ffff <= #e0ffff
    Red1                 = 196, // rgb: #ff0000 <= #ff0000
    DeepPink2            = 197, // rgb: #ff005f <= #ee1289
    DeepPink             = 198, // rgb: #ff0087 <= #ff1493
    DeepPink1            = 199, // rgb: #ff00af <= #ff1493
    Magenta1             = 200, // rgb: #ff00d7 <= #ff00ff
    Magenta2             = 201, // rgb: #ff00ff <= #ee00ee
    OrangeRed1           = 202, // rgb: #ff5f00 <= #ff4500
    IndianRed1           = 203, // rgb: #ff5f5f <= #ff6a6a
    VioletRed1           = 204, // rgb: #ff5f87 <= #ff3e96
    HotPink              = 205, // rgb: #ff5faf <= #ff69b4
    HotPink1             = 206, // rgb: #ff5fd7 <= #ff6eb4
    Orchid3              = 207, // rgb: #ff5fff <= #cd69c9
    DarkOrange           = 208, // rgb: #ff8700 <= #ff8c00
    Salmon1              = 209, // rgb: #ff875f <= #ff8c69
    LightCoral           = 210, // rgb: #ff8787 <= #f08080
    PaleVioletRed1       = 211, // rgb: #ff87af <= #ff82ab
    Orchid2              = 212, // rgb: #ff87d7 <= #ee7ae9
    Orchid1              = 213, // rgb: #ff87ff <= #ff83fa
    Orange1              = 214, // rgb: #ffaf00 <= #ffa500
    SandyBrown           = 215, // rgb: #ffaf5f <= #f4a460
    LightSalmon1         = 216, // rgb: #ffaf87 <= #ffa07a
    LightPink1           = 217, // rgb: #ffafaf <= #ffaeb9
    Pink1                = 218, // rgb: #ffafd7 <= #ffb5c5
    Plum1                = 219, // rgb: #ffafff <= #ffbbff
    Gold1                = 220, // rgb: #ffd700 <= #ffd700
    LightGoldenrod2      = 221, // rgb: #ffd75f <= #eedc82
    LightGoldenrod       = 222, // rgb: #ffd787 <= #eedd82
    NavajoWhite1         = 223, // rgb: #ffd7af <= #ffdead
    MistyRose1           = 224, // rgb: #ffd7d7 <= #ffe4e1
    Thistle1             = 225, // rgb: #ffd7ff <= #ffe1ff
    Yellow1              = 226, // rgb: #ffff00 <= #ffff00
    LightGoldenrod1      = 227, // rgb: #ffff5f <= #ffec8b
    Khaki1               = 228, // rgb: #ffff87 <= #fff68f
    Wheat1               = 229, // rgb: #ffffaf <= #ffe7ba
    Cornsilk1            = 230, // rgb: #ffffd7 <= #fff8dc
    Grey100              = 231, // rgb: #ffffff <= #ffffff
    Grey3                = 232, // rgb: #080808 <= #080808
    Grey7                = 233, // rgb: #121212 <= #121212
    Grey11               = 234, // rgb: #1c1c1c <= #1c1c1c
    Grey15               = 235, // rgb: #262626 <= #262626
    Grey19               = 236, // rgb: #303030 <= #303030
    Grey23               = 237, // rgb: #3a3a3a <= #3b3b3b
    Grey27               = 238, // rgb: #444444 <= #454545
    Grey30               = 239, // rgb: #4e4e4e <= #4d4d4d
    Grey35               = 240, // rgb: #585858 <= #595959
    Grey39               = 241, // rgb: #626262 <= #636363
    Grey42               = 242, // rgb: #6c6c6c <= #6b6b6b
    Grey46               = 243, // rgb: #767676 <= #757575
    Grey50               = 244, // rgb: #808080 <= #7f7f7f
    Grey54               = 245, // rgb: #8a8a8a <= #8a8a8a
    Grey58               = 246, // rgb: #949494 <= #949494
    Grey62               = 247, // rgb: #9e9e9e <= #9e9e9e
    Grey66               = 248, // rgb: #a8a8a8 <= #a8a8a8
    Grey70               = 249, // rgb: #b2b2b2 <= #b3b3b3
    Grey74               = 250, // rgb: #bcbcbc <= #bdbdbd
    Grey78               = 251, // rgb: #c6c6c6 <= #c7c7c7
    Grey82               = 252, // rgb: #d0d0d0 <= #d1d1d1
    Grey85               = 253, // rgb: #dadada <= #d9d9d9
    Grey89               = 254, // rgb: #e4e4e4 <= #e3e3e3
    Grey93               = 255, // rgb: #eeeeee <= #ededed
};

// aliases for the first default 8 color codes defined by curses
pub const COLOR_BLACK   = @intToEnum(PalleteCell, c.COLOR_BLACK);    // 0
pub const COLOR_RED     = @intToEnum(PalleteCell, c.COLOR_RED);      // 1
pub const COLOR_GREEN   = @intToEnum(PalleteCell, c.COLOR_GREEN);    // 2
pub const COLOR_YELLOW  = @intToEnum(PalleteCell, c.COLOR_YELLOW);   // 3
pub const COLOR_BLUE    = @intToEnum(PalleteCell, c.COLOR_BLUE);     // 4
pub const COLOR_MAGENTA = @intToEnum(PalleteCell, c.COLOR_MAGENTA);  // 5
pub const COLOR_CYAN    = @intToEnum(PalleteCell, c.COLOR_CYAN);     // 6
pub const COLOR_WHITE   = @intToEnum(PalleteCell, c.COLOR_WHITE);    // 7

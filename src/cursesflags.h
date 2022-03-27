// https://github.com/ziglang/zig/issues/2070
#include <curses.h>

// zig can't translate macro definitions of these functions
// so that we need function wrappers for them.
void get_yx   (WINDOW *win, int *y, int *x) { getyx   (win, *y, *x); }
void get_paryx(WINDOW *win, int *y, int *x) { getparyx(win, *y, *x); }
void get_begyx(WINDOW *win, int *y, int *x) { getbegyx(win, *y, *x); }
void get_maxyx(WINDOW *win, int *y, int *x) { getmaxyx(win, *y, *x); }

#include <errno.h>

// zig can't address errno global variable for some reason.
int get_errno() {
  return errno;
}


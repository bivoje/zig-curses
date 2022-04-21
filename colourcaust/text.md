# ColourCaust

> When I called her name,
> she came to me
> and became a flower.
>   - kim chun soo ([translate](https://jaypsong.blog/2013/01/16/the-flower-by-kim-chun-soo/)

Colors have no names. We only use _values_ to refer them.

And there are _some_ mnemonic for those values in our convenience,
which are frequently incomplete.


## Other's works

One such list is X11 color names.
It is defined to be used in X11 windows system.
[jskowron](https://www.astrouw.edu.pl/~jskowron/colors-x11/rgb.html)
[ubuntu](https://www.apt-browse.org/browse/ubuntu/trusty/main/all/x11-common/1:7.7+1ubuntu8/file/etc/X11/rgb.txt)

These are from `rgb.txt` file usually found on systems with X11.

We have to find identifiers for terminal 256 colors; colors of
```bash
for i in {0..255} ; do
    printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
    if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
        printf "\n";
    fi
done
```
or in
`curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash`
(code found in [here](https://askubuntu.com/a/821163)).

We may find good names for 256 color values in X11 names.

The problem is not only the two lists of X11 color names don't match exactly,
the values in the lists are not even close to those of terminal 256 colors.
```
python3 rgbmatch.py
```

Luckily, someone have already mapped the names for us, not sure how official is it though.
[vim wiki page](https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim)
[ditig](https://www.ditig.com/256-colors-cheat-sheet)

The two lists are almost identical.
But yet some colors have the same identifier assigned.

[This repository](https://github.com/jonasjacek/colors) gives json data that contains basically same information as `ditig`


## First attempt

I have tried to find X11 identifiers that represents each 256 color value the best, by manually selecting them.
```
python3 script.py
```
... hopping there are not much of the conflicts that should be handled manually.

But, almost for every color values in 256 colors, no color name is mapped to distinctively closely.
In turn I had to view & select every colors by hand.
`rbg`, `rgbs`, `rgbh` scripts were helpful doing that.

When a 256 color that deserves a x11 name the most appears after I assigned it for another 256 color,
I had to revert it and do select it again.
It soon ended in unmanagable state.


## Second attempt

I started to compare x11 color refrences.

```
diff <(cut -f3 ditig | tail -n+2 | sort)  <(cut -f3 umsiko | tail -n+2 | sort) | grep -o "^>\|<" | sort | uniq -c
```
`umsiko` only has 138 pairs, whehre the color codes does not matches with `ditig`.

```
diff <(cut -f3 ditig | tail -n+2 | sort)  <(cat calmar | tr ' ' '\n' | grep "^#\S" | sort)
```
`ditig` has 256 pairs and almost matches with calmar,
with exception of 2.

```
take #626262 for 241 (ditig) rather #606060 (calmar)
take #6c6c6c for 242 (ditig) rather #666666 (calmar)
```

By looking at color rendered using `rgbh`, I think ditig is more accurate.

Some other references also specifies that,

[jskowron](https://www.astrouw.edu.pl/~jskowron/colors-x11/rgb.html)
states 616161 for grey38.

[ubuntu](https://www.apt-browse.org/browse/ubuntu/trusty/main/all/x11-common/1:7.7+1ubuntu8/file/etc/X11/rgb.txt)
states 636363 for grey 38.

ok, guess there's no consensus, and i'll take what ditig gives.

The problem with ditig is, color names it provieds has duplicated entries.
Only 204 uniq names are used for 256 colors.

And theses 48 names are the responsibles.
```
cut -f2 ditig | sort | uniq -c | grep -v "^\s\+1"
```

At least, they are used at most 3 time, mostly twice.
Need to make program to manually select alternative names for colors.

```
python3 resolve.py
```
This is a monkey-patched dirty script that just works.
It reads `jskowron` for x11 names, `ditig` 256 colors + preset.
Then it prompts the user to select color names from the candidates
for every names that are used more than once in the preset.
Then write the result into `matching` file in `C` or `zig` variable assignment form.

Though one pass is not sufficient to remove all duplicated names,
as the script does not support backtracking (revert previous selection
to assign better matching).
If you think name AAA is the best fit for i'th color, but AAA is already taken,
you would have to write `i -> AAA` on notepad, assign random name to `i'th color`,
then after finishing, edit i'th entry in `matching` file, (AAA is now duplicated in matching file)
and run `resolve.py` again with the matching file as a preset.

Also, non duplicated names in preset values
gets right into matchings file without checking if the user already specified
the name for another name.

So I had to run multiple passes until there are no duplicate in resulting file.
A slightly modified file `resolve1.py` is used in second & third pass.
`matching3` is indeed the final mapping file without a duplication.

This is going to be in zig-curses library code.


## Notes
to render colors properly on tmux you should start tmux session with `-2` option given.
https://unix.stackexchange.com/a/1098

you can see the 256 color coverage by
https://askubuntu.com/a/821163


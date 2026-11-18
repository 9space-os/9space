# The desktop: wsys and its theme

9space's desktop is **wsys** (`wsys(4)`), with **wbar** along the top and
programs of **ui** (`ui(4)`), term and draw(3) in its windows. Its colours,
fonts and scale are the *theme*: a text file of `name value` lines that wsys
holds as `/dev/theme` (in every window) and `/mnt/wsys/theme`. ui and term
follow it as it changes.

## The theme 9space

`/lib/theme/9space` is 9space's own: rio's colours, warmer. Rio's grey
desktop (`#777777`), paper and ink, its pale yellow selection; umber, ochre
and sand for what is current or chosen; moss, brick and ochre for success,
danger and warning. Text has a contrast of 12:1 or more against its window,
every colour of text 5.6:1 or more. The window buttons are on the right.

It has a light and a dark palette (`dark.<name>` lines in the same file);
`mode` chooses:

```rc
echo mode dark >/dev/theme     # the desktop dark, at once (wsys, ui, term)
echo mode light >/dev/theme
```

wbar's menu has *theme: 9space*, *theme: light* and *theme: dark*;
*theme: classic* (rio's own colours) and *theme: modern* are there as well.

## New and existing installations

A **new installation** starts wsys with 9space: the profile it copies to
`$home/lib/profile` (`sys/lib/dist/usr/glenda/lib/profile`) gives wsys
`-t /lib/theme/9space`, or `-t $home/lib/theme` if that file exists.

A system **installed before** keeps its own `$home/lib/profile`: wsys
starts without `-t`, in the theme `classic`. To have 9space there:

- for the moment: wbar's menu *theme: 9space*, or
  `cat /lib/theme/9space >/dev/theme`;
- for good: add `-t /lib/theme/9space` where `lib/profile` starts wsys
  (`wsys $wsysflags -t /lib/theme/9space -i riostart`), or take over the
  new profile's lines that choose the theme:

```rc
wsystheme=()
if(test -e $home/lib/theme)
	wsystheme=(-t $home/lib/theme)
if not if(test -e /lib/theme/9space)
	wsystheme=(-t /lib/theme/9space)
# ... and wsys $wsysflags $wsystheme -i riostart
```

A theme of one's own: copy `/lib/theme/9space` to `$home/lib/theme` and
change it; the profile above prefers it.

## Its keys

Besides `back`, `border`, `borderinactive`, `window`, `text`, `select`,
`menuhigh`, `scroll`, `hold`, `holdinactive` (wsys' own), a theme has
`accent`, `surface`, `secondary`, `separator`, `danger`, `success` and
`warning` for ui; `title`, `font`, `uifont`, `monofont`, `scale`; `mode`.
Writing lines to `/dev/theme` changes what they name, at once; a line wsys
does not know is an error and changes nothing. See `wsys(4)`.

#!/usr/bin/env python3
# updatepack.py STAGE LIST OUT ARCH MANIFEST DRY: an update archive (dist/bin/mkupdate,
# mkfirmware) from a staged tree and its list (path, mode with Plan 9's DMDIR, owner,
# group, tab-separated; scripts/guest/stage-dist.sh's): root/ with the files, the
# list's modes and owners, without what an installed machine makes its own;
# apply.rc, which copies root/ over a running system (and a kernel in it into
# 9fat); MANIFEST. DRY 1: count only, no archive.
import io, os, sys, tarfile, time
stage, lst, out, arch, manifest, dry = sys.argv[1:]
skip = ('adm', 'cfg', 'usr', 'mail', 'lib/ndb/local', 'lib/ndb/auth')
def skipped(p):
	return any(p == s or p.startswith(s + '/') for s in skip)
kern = {'amd64': '9pc64', '386': '9pc'}[arch]
apply = '''#!/bin/rc
# apply.rc: this update over the running system (mkupdate in 9space's dist/bin)
rfork ne
here=`{pwd}
test -d $here/root || { echo apply: no root/ here >[1=2]; exit noroot }
cat $here/MANIFEST
fs=()
for(s in /srv/hjfs.cmd /srv/cwfs.cmd)
	if(test -w $s)
		fs=($fs $s)
fn sigexit{ for(s in $fs) echo disallow >>$s }
for(s in $fs) echo allow >>$s
echo apply: copying root/ over /
dircp $here/root / || { echo apply: copy failed >[1=2]; exit copy }
if(test -e $here/root/%(a)s/%(k)s && 9fs 9fat >[2]/dev/null){
	if(test -e /n/9fat/%(k)s)
		cp /n/9fat/%(k)s /n/9fat/%(k)s.orig
	cp /%(a)s/%(k)s /n/9fat/%(k)s && echo apply: kernel /%(a)s/%(k)s into 9fat, the old one as %(k)s.orig
	unmount /n/9fat
}
echo 'apply: done: reboot (fshalt -r) into the updated system'
''' % {'a': arch, 'k': kern}
n = 0; size = 0
tf = None if dry == '1' else tarfile.open(out + '.new', 'w:gz', format=tarfile.GNU_FORMAT)
def add(name, data, mode=0o664):
	ti = tarfile.TarInfo(name); ti.size = len(data); ti.mode = mode; ti.mtime = int(time.time())
	ti.uname = ti.gname = 'sys'
	tf.addfile(ti, io.BytesIO(data))
for line in open(lst):
	f = line.rstrip('\n').split('\t')
	if len(f) < 4 or skipped(f[0]):
		continue
	path, mode, owner, group = f[0], int(f[1], 8), f[2], f[3]
	src = os.path.join(stage, path)
	isdir = bool(mode & 0x80000000) or os.path.isdir(src)
	if not isdir and not os.path.isfile(src):
		continue
	n += 1
	if not isdir:
		size += os.path.getsize(src)
	if tf is None:
		continue
	# a directory from the list alone (some are only names in the stage's view)
	if isdir:
		ti = tarfile.TarInfo('root/' + path)
		ti.type = tarfile.DIRTYPE
		ti.mtime = int(time.time())
	else:
		ti = tf.gettarinfo(os.path.realpath(src), 'root/' + path)
	ti.mode = mode & 0o777
	ti.uname, ti.gname = owner, group
	ti.uid = ti.gid = 0
	if isdir:
		tf.addfile(ti)
	else:
		with open(src, 'rb') as fp:
			tf.addfile(ti, fp)
if tf is not None:
	add('apply.rc', apply.encode(), 0o775)
	add('MANIFEST', open(manifest, 'rb').read())
	tf.close()
	os.rename(out + '.new', out)
print('mkupdate: %d entries, %d MB of files%s' % (n, size >> 20, '' if tf is None else ' in ' + out))

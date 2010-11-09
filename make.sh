#!/bin/bash

# Another way to create DVD repository 
#
# Copyright (C) 2010  Mahyuddin Susanto <udienz@blankonlinux.or.id>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License with
#  the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
#  if not, write to the Free Software Foundation, Inc., 59 Temple Place,
#  Suite 330, Boston, MA  02111-1307  USA
#

if [ ! $1 ]; then
	echo "Use Make.sh profile.conf"
	exit 0
fi

. $1

make_partial () {
rm -rf $DEST/*
debpartial --dist=$DIST --section=$section --arch=$arch --size=$size --nosource --dirprefix=Ubuntu-$size- --ignore-large-packages $SOURCE $DEST
}

make_file () {
	echo "========================"
	echo "processing $DEST/$1"
	echo "========================"
	diskdefines=$DEST/$1/README.diskdefines
	debcopy -l $SOURCE $DEST/$1
	mkdir -p $DEST/$1/.disk
cat > $diskdefines <<EOF
#define DISKNAME $file Repository $arch $DESC - Release $arch
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  i386
#define ARCHi386  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF
	echo "Ubuntu $file Repository $DESC - Release $arch (`date +%Y%m%d`)" > $DEST/$1/.disk/info
#	cp $BASE/strach/$DIST/cdromupgrade $DEST/$1/cdromupgrade
	cd $DEST/$1/
	ln -s . ubuntu
#	rsync $SOURCE/dists/$DIST/main/dist-upgrader-all/ $DEST/$file/dists/$DIST/main/dist-upgrader-all/ -avh
	
	ls -lRh > ls-lR
	gzip -9c ls-lR > ls-lR.gz
	rm ls-lR
	cd -
}

make_jigdo () {
	jigdo-file make-template --force -j $to/$1-$DIST-$arch-`date +%Y%m%d`.template -j $to/$1-$DIST-$arch-`date +%Y%m%d`.jigdo -i $to/$1-$DIST-$arch-`date +%Y%m%d`.iso -c $to/$DIST-$arch.db --label Debian=$SOURCE --uri Debian=http://archive.ubuntu.com/ubuntu/ --servers-section $SOURCE//

}

make_image () {
genisoimage -J -r -l -f -o "$to/$1-$DIST-$arch-`date +%Y%m%d`.iso" $DEST/$1
}
if [ ! -d $logdir ]; then
	mkdir $logdir
	fi

if [ ! -d $DEST ]; then
	mkdir $DEST
	fi

if [ ! -d $to ]; then
	mkdir $to
	fi
	
exec >"$LOG" 2>&1

make_partial

cd $DEST
ls -alh | awk {'print$8'} | grep Ubuntu-$size > /tmp/list2.txt
cd -

cat /tmp/list2.txt | while read file
do
	make_file $file
	make_image $file
	make_jigdo $file
	done
cd -
savelog $LOG > /dev/null

#! /usr/bin/env bash
set -euxo pipefail

# configurable parameters
BASEDIR="${BASEDIR:-/usr/share/doc}"
VERSION="${VERSON:-9.1}"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
REPODIR="${REPODIR:-$SCRIPTDIR}"

cd "$REPODIR"

function build_books {
  for BOOK in {,b}lfs ; do
    BV="$BOOK-$VERSION"

    if [[ ! -d "$BV" ]] ; then
      svn co svn://svn.linuxfromscratch.org/${BOOK^^}/tags/$VERSION $BV                        || return $?
      pushd $BV                                                                                || return $?
    else
      pushd $BV                                                                                || return $?
      svn revert --recursive .                                                                 || return $?
    fi

    eval build_$BOOK                                                                           || return $?

    popd
    unset BV
  done
}

function build_lfs {
  "$SCRIPTDIR"/dump-commands.awk Makefile > Makefile.better                                    || return $?

  MYDIR="$BASEDIR/$BV"
  DUMPDIR="$BASEDIR/$BV-commands"
  sudo rm -rf "$MYDIR" "$DUMPDIR"                                                              || return $?
  sudo make -f Makefile.better "BASEDIR=$MYDIR" "DUMPDIR=$DUMPDIR" all dump-commands           || return $?
  lynx -dump "$MYDIR/LFS-BOOK.html" | sudo tee "$MYDIR/LFS-BOOK.txt" > /dev/null               || return $?
  unset MYDIR DUMPDIR
  return 0
}

function build_blfs {
  MYDIR="$BASEDIR/$BV"
  DUMPDIR="$BASEDIR/$BV-commands"
  sudo rm -rf "$MYDIR" "$DUMPDIR"                                                              || return $?
  sudo make "BASEDIR=$MYDIR" "DUMPDIR=$DUMPDIR"                                                || return $?
  for tgt in nochunks validate blfs-patch-list dump-commands ; do
    sudo make "BASEDIR=$MYDIR" "DUMPDIR=$DUMPDIR" $tgt                                         || return $?
  done
  lynx -dump "$MYDIR/blfs-book.html" | sudo tee "$MYDIR/blfs-book.txt" > /dev/null             || return $?
  unset MYDIR DUMPDIR
}

# check dependencies
INST=0
PKGLIST='xsltproc asciidoc xmlto fop tidy'

for k in svn xmllint $PKGLIST ; do
  [[ `command -v $k` ]] || { INST=1 ; break ; }
done

(( ! "$INST" )) ||
for k in docbook{,-xsl} ; do
  [[ `dpkg --get-selections | awk '$1 == "'$k'" && $2 == "install" {exit 0} END {exit 1}'` ]] || { INST=1 ; break ; }
done

# install dependencies
(( ! "$INST" )) ||
sudo apt-fast install -qy subversion libxml2-utils docbook{,-xsl} $PKGLIST

unset INST PKGLIST

# do the thing
build_books


#!/bin/sh

# path of MoinMoin shared files
SHARE=/opt/share/moin

# path to target instance location
INSTANCE=$1

USER=`/opt/bin/id -un`
GROUP=`/opt/bin/id -gn`

if [ ! $1 ]
then
  echo "You must specify an instance (relative or absolute path)"
  exit
fi

if test -e $1 -o -d $1
then
  echo "$1 already exists"
  exit
fi

mkdir -p $INSTANCE

cp -R $SHARE/data $INSTANCE
/opt/bin/tar -C $INSTANCE -xf $SHARE/underlay.tar.gz
cp $SHARE/config/wikiconfig.py $INSTANCE

cp $SHARE/wikiserver.py $INSTANCE
sed -i -e '1s|#!.*|#!/opt/bin/python2.5|' $INSTANCE/wikiserver.py
cp $SHARE/wikiserverconfig.py $INSTANCE
cp $SHARE/wikiserverlogging.conf $INSTANCE

chown -R $USER.$GROUP $INSTANCE
chmod -R ug+rwX $INSTANCE
chmod -R o-rwx $INSTANCE

if [ $? ]
then
  echo "Done."
fi


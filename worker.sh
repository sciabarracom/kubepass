#!/bin/bash
if test "$(hostname)" == "kube-master"
then echo "I am the master, not a worker" ; exit 0
fi
test -e /tmp/kube-join.sh && rm /tmp/kube-join.sh
while ! test -s /tmp/kube-join.sh
do sudo arp-scan -l | tail +3 | head -n -3 | awk '{ print $1 }' \
 | while read a
   do echo Checking $a
      echo get kube-join.sh /tmp/kube-join.sh | tftp $a
      if test -s /tmp/kube-join.sh
      then break
      fi
   done
done
bash /tmp/kube-join.sh

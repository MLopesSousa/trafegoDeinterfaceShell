#!/bin/bash

if [ ! $1 ]; then exit 1; fi

function main {
        if [ $(grep "$1:" /proc/net/dev |wc -l) -eq 0 ]; then exit; fi

        icrx=0;
        ictx=0;

        while true; do
                rx=$(grep "$1:" /proc/net/dev |awk '{print $1}' |awk -F':' '{print $2}')
                tx=$(grep "$1:" /proc/net/dev |awk '{print $2}')

                if [ $icrx -eq 0 ]; then
                        icrx=$rx;
                        ictx=$tx;
                else
                        dfrx=$(( $rx - $icrx ))
                        dftx=$(( $tx - $ictx ))
                        vfrx=$(echo "scale=6; $dfrx / 1024" |bc)
                        vftx=$(echo "scale=6; $dftx / 1024" |bc)

                        if [ ! $(echo $vfrx |awk -F'.' '{print $1}') ]; then vfrx="$(echo $vfrx |sed 's/\./0./g') B/S"; else vfrx="$(echo $vfrx |awk -F'.' '{print $1}') KB/S"; fi
                        if [ ! $(echo $vftx |awk -F'.' '{print $1}') ]; then vftx="$(echo $vftx |sed 's/\./0./g') B/S"; else vftx="$(echo $vftx |awk -F'.' '{print $1}') KB/S"; fi

                        echo -n -e \\r $1: RX: $vfrx \\t TX: $vftx
                        icrx=$rx
                        ictx=$tx
                fi
                sleep 1
        done
}

main $1;

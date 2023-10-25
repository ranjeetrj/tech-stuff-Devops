#!/bin/bash
ls *.tar > tar
while read -r line; 
do 
        echo "$line extracting..." ; 
	ctr -n=k8s.io images import $line
	echo "$line extraced into containerd"
done < tar
rm tar


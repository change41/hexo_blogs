#!/bin/bash
for i in $(cat md.txt)
do
filename=$(echo $i | awk -F . '{print $1}')
cp $(cat $i | grep wp | awk -F '"' '{print $1}' | sed -e s/^.*wp/wp/g) ${filename}
sed -i /wp/s/\(.*\"1/\(1/g $i
sed -i /png/s/\"//g  $i
done


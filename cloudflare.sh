#!/bin/bash

key="83ba6fa46633ca5ea36c6e852c32a1d5"
albums=("Street" "Wildlife" "Cars" "Portraits" "Motorsports" "Nature")

for i in ${albums[@]}; do mkdir content/$i; done

for i in ${albums[@]}; do 
	curl "https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=$key&photoset_id=$(curl "https://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=$key&user_id=202977498@N08" 2>/dev/null | grep -e "photoset id" -e "title" | sed 's/.*photoset\ id=\"//g' | sed 's/\".*//g' | grep "$i" -B 1 | head -1)&user_id=202977498@N08&extras=url_o" 2>/dev/null | sed 's/.*url_o=\"//g' | sed 's/\".*//g' | grep .jpg$ | while read j; do 
		wget --no-clobber $j -O "content/$i/$(curl "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=$key&photo_id=$(echo $j | cut -d/ -f5 | cut -d_ -f1)" 2>/dev/null | grep title | sed 's/.*<title>//g' | sed 's/<\/title.*//g').jpg";
	done;
done

./subalbums.sh

rm ./*.tar.gz 2>/dev/null

wget "https://go.dev/dl/$(curl -s https://api.github.com/repos/golang/go/git/matching-refs/tags/go | grep ref | grep -v url | grep -v beta | tail -1 | awk -F\/ {' print $3 '} | sed 's/",//').linux-amd64.tar.gz"
tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

wget $( curl -L -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | grep "extended" | grep -v "withdeploy" | cut -d\" -f4 )
tar -xvzf ./hugo*.tar.gz hugo
chmod u+x ./hugo

./hugo --minify

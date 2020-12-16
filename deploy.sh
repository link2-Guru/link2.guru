#!/bin/sh

if [ ! -n $0 ]
then
    echo "Println commit msg"
    exit 1;
fi

git add .
git commit -m $0
if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old docs publication"
rm -rf docs

echo "Generating site"
hugo

echo "Push to origin master"
git push origin master
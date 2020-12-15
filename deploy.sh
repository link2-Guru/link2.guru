#!/bin/sh
git add .
git commit -m "ff"
if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf doc
mkdir doc

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "Push to origin master"
git push origin master
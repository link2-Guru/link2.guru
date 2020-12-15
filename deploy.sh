#!/bin/sh

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
rm -rf .git/worktrees/public/

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo --publishDir = docs

echo "Push to origin master"
git push origin master
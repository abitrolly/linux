#!/usr/bin/env bash

# usage: amend-pr.sh <url>
#
# example url https://github.com/hyperledger/fabric/pull/244
#
# untested and most likely doesn't work on:
# - PR in the same repo
# - PR in renamed repo

PR=$(basename $1)
SRCDIR=/tmp/amend-pr-$PR
REPO=$(dirname $(dirname $1))
PROJECT=$(basename $REPO)

echo "..Getting username and branch for pushing.."

# value="abitrolly:patch-1" aria-label="Copied!"><sv
# -o, --only-matching
# -P, --perl-regexp
# https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
# -s - be silent
# -S - but show errors
NAMEBRANCH=$(curl -sS $1 | grep -oP '(?<=value=").+?(?=" aria-label="Copied!)' | head -1)
# abitrolly:patch-1
echo $NAMEBRANCH
# https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split
NAME=${NAMEBRANCH%:*}    # remove :* from the end
BRANCH=${NAMEBRANCH#*:}  # remove *: from the beginning

RWREPO=git@github.com:$NAME/$PROJECT
echo "..Cloning $RWREPO.."

git clone $RWREPO $SRCDIR
cd $SRCDIR
#git fetch origin pull/$PR/head:pr-$PR
#git checkout pr-$PR
git checkout $BRANCH

echo "Run 'exit $PR' to commit and push changes."
PS1="$SRCDIR ($BRANCH)$ " bash
RET=$?
if [[ $RET == $PR ]]; then
  echo "Good! Pushing the PR"
  git push -f
fi

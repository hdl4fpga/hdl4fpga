#!/bin/sh
git remote add upstream https://github.com/hdl4fpga/hdl4fpga.git
git fetch upstream
git checkout master
git merge upstream/master

# to change alredy pushed commits to github
# git log
# git rebase -i <commit hex number here>
# git push origin +master

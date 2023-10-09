#!/bin/bash
# Tim H 2022

# fixes the issue where brew casks don't show up in OS X dock
# I think a reboot is still necessary after this

sudo launchctl config user path "$(brew --prefix)/bin:${PATH}"

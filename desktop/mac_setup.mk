# makefile to install tools
# Usage: make -f mac_setup.mk <target.below>
# Testing on MacOS Desktop
# If this file was cut n' pasted, make sure to use tabs and not spaces
SHELL=bash

#===============================
# 1. Setup the Desktop
#===============================
setHome:
	# Sets up my preferred environment
	mkdir -p ~/Documents/GitStuff
	mkdir -p ~/bin
	mkdir -p ~/ws

getUtils:
	# Tools for Versioning (Currently not able to run??)
	brew cask install meld
	# Setup git tools
	git config --global core.editor "micro"
	git config --global alias.st status
	git config --global diff.tool "meld"
	git config --global merge.tool "meld"

getHomeBrew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

getIterm2:
	brew cask install iterm2

getOhmyzsh:
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

getTmux:
	# 	sudo apt -y install tmux
	$(eval path:=~/Documents/GitStuff/tmux)
	rm -rf $(path)
	git clone https://github.com/gpakosz/.tmux $(path)
	ln -sf $(path)/.tmux.conf ~/.tmux.conf
	ln -sf $(path)/.tmux.conf.local ~/.tmux.conf.local
	# Enable mouse (this actually writes to a real file)
	sed -i 's/#set -g mouse on/set -g mouse on/g' ~/.tmux.conf.local
	# For `micro`
	$(eval XTERM:='\n\nset -g default-terminal "xterm-256color"')
	grep -q xterm-256color ~/.tmux.conf.local || echo -e $(XTERM) >> ~/.tmux.conf.local

setupDesktop: setHome getUtils getHomeBrew getIterm2 getOhmyzsh getTmux

#===============================
# 2. Setup Editors
#===============================
getMicro:
	# NOTE: To work in tmux, do `export TERM=xterm-256color`
	#  or in tmux `set -g default-terminal "xterm-256color"`
	brew install micro

getSublime:
	brew cask install sublime-text
	# Move sublime to Application folder
	ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

getJava:
	# For use of Markdown Enhanced Preview
	brew cask install java

getVsCode: getJava
	brew cask install visual-studio-code

todoSublimePkgs:
	#----Install these packages for Sublime----
	#  EasyClangComplete
	#  gitgutter
	#  Set Theme to adaptive
	#  SideBarEnhancements
	#  Toks
	#  Diagram
	#  DoxyDoxygen
	#  Diagram
	#  TodoReview
	#

todoVsCodePkgs:
	#----Install these packages for VsCode----
	#  Markdown Preview Enhanced
	#  C/C++ - "ms-vscode.cpptools"
	#  Python - "ms-python.python"
	#  Sublime Text Keymap
	#  GitLens
	#

#----Setup Fun Stuff---
setupFun:
	sudo apt -y install youtube-dl

setupEditors: getMicro getSublime getVsCode
todoEditor: todoSublimePkgs todoVsCodePkgs

# Desktop Deployment
setup: setupDesktop setupEditors todoEditor
	@echo "========================="
	@echo "All Done"
	@echo "========================="
# makefile to install tools
# Usage: make -f rpi_setup.mk <target.below>
# Testing on Raspian Desktop
# If this file was cut n' pasted, make sure to use tabs and not spaces
SHELL=bash
DEFAULT_PYTHON_VERSION=3.7.6

help:
	@echo "------------------------------------------------"
	@echo "---Howard's Standard Development Environment----"
	@echo "------------------------------------------------"
	@echo "Usage: make -f rpi_setup.mk <target>"
	@echo "targets:"
	@echo "  SetupDefault                       Setup the system for standard development environment"
	@echo "  SetupAstrocam                      Setup the system for an outdoor astro camera"
	@echo "  "
	@echo "  setupDesktop                       Setup Desktop environment (Directory, tmux, base utilities"
	@echo "  setupEditors                       Setup preferred Editors (Micro, Sublime, VsCode"
	@echo "  setupPython [VERSION=3.7]          Setup Python and virtual environment (pyenv)"
	@echo "  setupDevtools                      Setup Standard develop environment"
	@echo "  setupML                            Setup for ML Tools (Scikit, Jupyter)"
	@echo "  setupVM                            Setup for VM Player (Samba, VMShare)"
	@echo "  setupDocker                        Setup for Docker"

#===============================
# 1. Setup the Desktop
#===============================
setHome:
	# Sets up my preferred environment
	mkdir -p ~/Documents/GitStuff
	mkdir -p ~/bin
	mkdir -p ~/ws

getUtils:
	# sudo apt -y install tree
	# sudo apt -y install htop
	sudo apt -y install gawk
	sudo apt -y install p7zip
	# sudo apt -y install curl
	# Tools for Versioning
	sudo apt -y install meld
	# sudo apt -y install git
	# Setup git tools
	git config --global core.editor "micro"
	git config --global alias.st status
	git config --global diff.tool "meld"
	git config --global merge.tool "meld"
	# Add .bash_aliases
	echo "alias ll='ls -la'" > ~/.bash_aliases

getTmux:
	sudo apt -y install tmux
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

setupDesktop: setHome getUtils getTmux

#===============================
# 2. Setup Editors
#===============================
getMicro: setHome
	# NOTE: To work in tmux, do `export TERM=xterm-256color`
	#  or in tmux `set -g default-terminal "xterm-256color"`
	curl https://getmic.ro | bash
	mv micro ~/bin

getMu:
	sudo apt -y install mu-editor

getVsCode:
	wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
	curl -L https://raw.githubusercontent.com/headmelted/codebuilds/master/docs/installers/apt.sh | sudo bash

todoVsCodePkgs:
	#----Install these packages for VsCode----
	#  Markdown Preview Enhanced
	#  C/C++ - "ms-vscode.cpptools"
	#  Python - "ms-python.python"
	#  Sublime Text Keymap
	#  GitLens
	#

setupEditors: getMicro getMu getVsCode
todoEditor: todoVsCodePkgs

#----Python----
getPyenv:
	# https://github.com/pyenv/pyenv-installer
	# Step 1: Install Ubuntu prerequisites (https://github.com/pyenv/pyenv/wiki/Common-build-problems)
	sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
	xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
	# Step 2: Check if pyenv is already installed
	$(eval hasPyenv:= $(shell grep -c pyenv ~/.bashrc))
	# Step 2a: Using automatic installer (https://github.com/pyenv/pyenv-installer)
	@if [ "$(hasPyenv)" == "0" ]; then \
		curl https://pyenv.run | bash ; \
	fi
	# Step 2b: Add pyenv to .bashrc
	@if [ "$(hasPyenv)" == "0" ]; then \
		echo 'Updating ~/.bashrc' ; \
		echo 'export PATH="/home/${USER}/.pyenv/bin:$$PATH"' >> ~/.bashrc ; \
		echo 'eval "$$(pyenv init -)"' >> ~/.bashrc ; \
		echo 'eval "$$(pyenv virtualenv-init -)"' >> ~/.bashrc ; \
	fi

__getPython:
	# For Simple python install to System!!  NOT local environment
	$(eval version := $(if $(VERSION),$(VERSION),$(DEFAULT_PYTHON_VERSION)))
	sudo apt update
	sudo apt install software-properties-common
	sudo add-apt-repository ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install python$(version)

__getPythonCommon:
	# For Simple python install to System!!  NOT local environment
	$(eval user:=$(if $(LOCAL),--user))
	sudo apt -y install python3-pip
	sudo apt -y install python3-tk
	pip3 install $(user) pyserial
	pip3 install $(user) wheel
	# Utilties for Web
	pip3 install $(user) urllib3

setupMyPy:
	$(eval version := $(if $(VERSION),$(VERSION),$(DEFAULT_PYTHON_VERSION)))
	$(shell pyenv install $(version))
	$(shell pyenv virtualenv $(version) mypy)

getPyRequirements:
	# Generate requirements.txt
	@echo "pyserial==3.4" > requirements.txt
	@echo "urllib3==1.25.9" >> requirements.txt
	pip install -r requirements.txt
	rm requirements.txt

setupPython: getPyenv setupMyPy
	# Next steps:
	pyenv activate mypy
	pip3 install --upgrade pip

#----General Tools----
setupDevTools:
	# Compilation Tools
	sudo apt -y install clang
	sudo apt -y install unifdef
	# Unittest
	sudo apt -y install ccache
	sudo apt -y install lcov
	sudo apt -y install texlive
	# Documentation tools
	sudo apt -y install graphviz
	sudo apt -y install mscgen
	sudo apt -y install doxygen
	sudo apt -y install plantuml
	# Debug tools
	sudo apt -y install ddd
	sudo apt -y install minicom

#----VM Setup----
getNetwork:
	# https://tutorials.ubuntu.com/tutorial/install-and-configure-samba#0
	sudo apt -y install net-tools
	sudo apt -y install samba

#----Docker----
setupDocker: ;

#----PiCamera----
~/Documents/GitStuff/PiCameraApp:
	# For camera support
	sudo apt-get install python-picamera python3-picamera
	sudo pip install Pillow --user
	git clone https://github.com/Billwilliams1952/PiCameraApp.git ~/Documents/GitStuff/PiCameraApp

getCamera: ~/Documents/GitStuff/PiCameraApp
	@echo "================================================"
	@echo "Don't forget to enable camera via 'raspi-config'"
	@echo "------------------------------------------------"

getVideo:
	sudo apt-get install kdenlive
	sudo apt-get install openshot

getBlender:
	sudo apt-get install blender

#----HyperPixel----
# https://blog.adafruit.com/2017/11/02/new-product-pimoroni-hyperpixel-3-5-hi-res-display-for-raspberry-pi/
# https://github.com/pimoroni/hyperpixel
getHyperpixel:
	curl https://get.pimoroni.com/hyperpixel | bash

makeAstroScript:
	@#https://github.com/pimoroni/hyperpixel/issues/11
	$(eval script := ~/Desktop/AstroMode.sh)
	@echo "#!/bin/bash" > $(script)
	@echo "gpio -g mode 19 pwm" >> $(script)
	@echo "gpio -g pwm 19 25" >> $(script)
	$(eval picam_dir := ~/Documents/GitStuff/PiCameraApp/Source)
	@echo "cd $(picam_dir) && python3 PiCameraApp.py &" >> $(script)
	chmod +x $(script)

#----ML Environment----
getJupyter:
	$(eval user:=$(if $(LOCAL),--user))
	#===Setup jupyter kernel with pyenv===
	ipython kernel install --name mypy --user
	#===Add ipywidgets support===
	# https://ipywidgets.readthedocs.io/en/latest/user_install.html
	pip3 install $(user) ipywidgets
	# jupyter nbextension enable --py widgetsnbextension
	# > If there is an error launching jupyter-notebook
	# sudo apt-get remove python-pexpect python3-pexpect
	# pip3 install $(user) pexpect

getML:
	$(eval user:=$(if $(LOCAL),--user))
	# Install machine learning and data science kits
	pip3 install $(user) ipython
	pip3 install $(user) numpy
	pip3 install $(user) pandas
	pip3 install $(user) matplotlib
	pip3 install $(user) pymongo
	pip3 install $(user) jupyter
	pip3 install $(user) -U scikit-learn
	pip3 install $(user) scikit-image
	pip3 install $(user) seaborn

setupML: getML getJupyter

#----Standard Development Environment----
SetupDefault: setupDesktop setupEditors setupDevTools setupPython todoEditor
	@echo "========================="
	@echo "All Done"
	@echo "========================="

SetupAstroCam: setupDesktop setupEditors setupPython getHyperpixel getCamera makeAstroScript
	@echo "========================="
	@echo "Final Steps:"
	@echo "-------------------------"
	@echo "1. Enable camera via raspiconfig"
	@echo "2. Lower brightness with"
	@echo "    gpio -g mode 19 pwm"
	@echo "    gpio -g pwm 19 25"
	@echo "========================="
#!/bin/bash

## show.sh
# git-submodules-ascii-demo script by Carsten Nielsen <carsten@redpill-linpro.com>


## Settings
#
# Set an alternative path for your testsetup here.
path="/home/carsten/git";


## Run

sl=0
auto=0
time=0
ssl=1
cmd=$1
message=""
mes=""
script=0

##The array of commands
scriptcmd[0]="cd $path;"
scriptcmd[15]='ls -a; ls -a public; ls -a local' 
scriptcmd[16]="cd local; git clone $path/public/project.git; ls -a; ls -a project"
scriptcmd[18]="cd project; mkdir ext; git submodule add $path/public/extension.git ext/extension"
scriptcmd[19]='git status; cat .gitmodules';
scriptcmd[20]='ls -a ext/extension';
scriptcmd[21]='git add .; git commit -m "Push it!"; git push';
scriptcmd[23]='git diff HEAD^';
scriptcmd[25]="cd ..; ls -a; git clone $path/public/project.git others; ls -a others";
scriptcmd[26]='cd others; ls -a ext/extension'
scriptcmd[28]='git submodule init; git submodule update'
scriptcmd[29]="cd ..; rm -Rf others; git clone --recursive $path/public/project.git others; ls others/ext/extension";
scriptcmd[31]='cd project/ext/extension; echo "A new file in extension." > newfile.txt; ls; git status; git add .; git status; git commit -m "Add a new file."; git log'
scriptcmd[32]='cd ../..; echo "A new file in project." > newprojectfile.txt; ls; git status; git add . ; git status; git commit -m "Add a new file to project."; git log; git push'
scriptcmd[33]='cd ../others; git pull; git submodule update'
scriptcmd[34]='cd ../../public/extension.git; git log'

reader='read -sn1 -p "${mes}(${sl})>" IN';

esc=$(eval 'echo -en "\e"');
help='echo -e "
\e[1mh\e[0m or \e[1m?\e[0m - show this help ;-)\n
\e[1menter\e[0m - start and next\n
\e[1mf\e[0m - first page is opened\n
\e[1ms\e[0m - save actual position\n
\e[1mg\e[0m - go to saved position\n
\e[1mq\e[0m - quit the presentation\n
\e[1ma\e[0m - start automatic presentation\n
\e[1mp\e[0m - pause automatic presentation\n
\e[1m>\e[0m - open console\n\n

You can use PgUp, PgDn, left, right, up, down and numeric values to jump to slides.\n\n

If you see a "'*'" at the prompt, there are some commands to execute for the actual slide.\n\n
Press > to open console. If you hit enter, the commands in the brackets will be executed and the output is shown."';

if [ "$1" == "install" ]; then
  if [ ! -d $path ]; then
    echo "Seems the target directory ($path) is not existing!"
    exit;
  elif [ "$(ls $path)" ]; then
    echo "Seems the target directory ($path) is not empty!"
    exit;
  else
    cd $path
    mkdir ./public
    mkdir ./local
    cd public
    git init --bare project.git
    git init --bare extension.git
    cd ../local
    unset GIT_DIR
    git clone $path/public/project.git
    echo "The first project file." > project/project.txt
    cd project
    git add .
    git commit -m "Initial import to project."
    git push origin master
    unset GIT_DIR
    cd ..
    git clone $path/public/extension.git
    echo "The first extension file." > extension/extension.txt
    cd extension
    git add .
    git commit -m "Initial import to extension."
    git push origin master
    cd $path
    rm -Rf local/*
    echo
    echo "OK. Setup done. Now go for the presentation!"
    exit;
  fi
elif [ "$1" != "" ]; then
  echo "Welcome! To start just press enter...(or ? for a bit help)";
else 
  echo "Uuups! You have to define a command with a counting placeholder (?) like:
  > show.sh \"cat path/file?.txt\"
  or use 
  > show.sh install
  to setup the demo environment. You can adjust the installation path in this scriptfile.";
  echo $help
  exit
fi

cd $path;

##lets go then
while true; do
  #only if not in script mode...
  if [[ $script == 0 ]]; then
    #input
    if [[ -n "${scriptcmd[$sl]}" ]]; then 
      mes=$mes" [*]" 
    fi
    eval $reader
    mes=""
    case "$IN" in
      $esc)
        IN=""
        while read -sn1 a; do
          case $a in
            "A" | "B" | "C" | "D" | "E" | "~" | "H" | "F" | "S" | "R" | "Q" | "P")
              IN=$IN$a
              break;;
            *)
              IN=$IN$a;;
          esac
        done;;
      ">")
        clear
        script=1
        ssl=$sl;;
      [0-9]*)
        echo -n $IN
        while read -sn1 a; do
          echo -n $a
          case $a in
            [0-9]*)
              IN=$IN$a;;
            *)
              break;;
          esac
        done;;
    esac
  fi
  
##only if not in script mode...
  if [[ $script == 0 ]]; then
    case "$IN" in
      "a") 
        read -p "Time in seconds:" time
        if [[ $time == 0 || $time == "" ]]; then 
          message="Error: Please define a numeric value greater than 0."
        else
          auto=1
          reader='read -t ${time} -sn1 -p "auto ${time}s (${sl})>" IN'
        fi
        ;;
      "?" | "h")
        echo "Need some help?" 
        eval $help
        continue;;
      
      "f" | "OH")
        sl=1;;
        
      "s")
        mes="Position ${sl} saved. "
        ssl=$sl;;
        
      "g")
        mes="Opened stored slide. "
        sl=$ssl;;
        
      "q")
        echo "Bye bye!"
        exit;;
        
      "p")
        mes="Automatic paused. "
        auto=0
        reader='read -sn1 -p "${mes}(${sl})>" IN';;
      
      "[B" | "[D" | "[6~" | "b")
        (( sl-- ));;
        
      [0-9]*)
        sl=$IN
        mes="Jumped to slide ${sl}. ";;
        
      "[A" | "[C" | "[5~" | *)
        (( sl++ ));;
    esac
  fi
  
##output
  if [[ $message != "" ]]; then
    echo $message
    message=""
  elif [[ $script == 1 ]]; then
    echo -n "[1m"
    if [ -n "${scriptcmd[$ssl]}" ]; then
      read -p "me@local:$PWD $ [0m(${scriptcmd[$ssl]}) [1m>" IN
    else
      read -p "me@local:$PWD $> " IN
    fi
    if [ -z "$IN" ]; then
      OIFS=$IFS
      IFS=';'
      arr="${scriptcmd[$ssl]}"
      for x in $arr
      do
        echo
        echo -n "[1m"
        echo "me@local:$PWD $> $x"
        echo -n "[0m"
        eval "${x}"
      done
      IFS=$OIFS
      scriptcmd[$ssl]=''
      IN=""
    fi
    echo -n "[0m"
    case $IN in
      q)
        script=0
        clear
        eval ${cmd/\?/$ssl}
        echo;;
      *)    
        eval $IN
        echo;;
    esac;
  else
    clear
    eval ${cmd/\?/$sl};
    echo
  fi
done;

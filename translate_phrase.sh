#!/bin/bash

###############################
##  translate_phrase.sh  
###############################
#  This script echos the English translation of a foreign phrase,
#  passed as a parameter by visiting the webpage
#  https://translate.google.com, using xvfb, xautomation and chromium

#  Requirements: linux, xvfb, xautomation, xclip, curl 

#  License: GNU GPL v3

#exec &> /dev/tty
# Check if the script is running in an interactive shell
if [[ $- == *i* ]]; then
    exec 1> /dev/tty
fi
exec 2> /dev/null
# WARNING: THE BELOW DIRS WILL BE DELETED
CACHEDIR=/tmp/temp-disk-cache-dir
XVFB_DIR=/tmp/xvfb_dir


output_screenshots=1
step_temp_dir=/tmp/$(basename $0 ".sh")
vpn_dir=/opt/scripts/vpn/
SCRIPT=`realpath $0`
# SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
WEBROWSER=chromium-browser

rm -rf "$CACHEDIR"
mkdir -p "$CACHEDIR" 
rm -rf "$step_temp_dir"
mkdir -p "$step_temp_dir"
rm -rf "$XVFB_DIR"
mkdir -p  "$XVFB_DIR"
step=0

urlencode() {
    echo -n "$1" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-
}

urltxt="$1"
urlencodedtxt=$(urlencode "$urltxt")
addr1="https://translate.google.com/#view=home&sl=auto&op=translate&tl=en&text=${urlencodedtxt}"
# text="안녕하세요, how are you?"
# encoded_text=$(urlencode "$text")
# echo "Encoded: $encoded_text"
# ./translate_phrase.sh "안녕하세요"

remove_last_character_from_string_if_its_forward_slash () {
    if [[ ${1:${#1}-1:1} == "/" ]]; then
	echo ${1:0:${#1}-1}
    else
	echo $1
    fi       
}


kill_xvfb() {
    PROCEXISTS=`ps -ef | grep $XVFB_DIR | wc | awk '{print $1}'`
    if  [ ! $PROCEXISTS = 1 ]; then
	PROCNUM=`ps -ef | grep $XVFB_DIR | awk 'NR==1{print $2}'`
	kill -9 $PROCNUM
    fi
}

kill_webbrowser() {
   kill -9 `ps -ef | grep "${WEBROWSER}"  | awk 'NR==1{print $2}'`
}

is_display_free() {
    xdpyinfo -display $1 >/dev/null 2>&1 && echo 0 || echo 1
}

find_free_display() {
    DSP_NUM=99
    while [ $(is_display_free ":$DSP_NUM") -eq 0 ]; do
	DSP_NUM=$(( $DSP_NUM - 1 ))
    done
    echo ":$DSP_NUM"
}

DSP=$(find_free_display)

rnd() {
python3 -S -c "import random; print( random.randrange($1,$2))"
}

rnd_offset() {
python3 -S -c "import random; print(random.randrange($1,$(($1 + $2))))"
}



alt_tab (){
    
    
    DISPLAY=$DSP xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
    DISPLAY=$DSP xte "sleep 1"
}
click_page () {

    DISPLAY=$DSP xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    DISPLAY=$DSP xte "usleep 50000"
}

set_default() {
    
    DISPLAY=$DSP xte "keydown Control_L" "str 0" "usleep 40000"

    DISPLAY=$DSP xte "keyup Control_L" "sleep 2"
    }


    


select_all_ctrl_c () {
    DISPLAY=$DSP xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    DISPLAY=$DSP xte "keydown Control_L" "usleep 50000" "str a" "usleep 150000" "str c" "usleep 150000" "keyup Control_L"
    DISPLAY=$DSP xte "sleep 1"
}


random_number() {
    python3 -S -c "import random; print( random.randrange($1,$2))"
}


set_25_percent () {
    
    DISPLAY=$DSP xte "keydown Control_L" "str 0" "sleep 2"
    DISPLAY=$DSP xte "usleep $(rnd 800000 1400000) " "str -"

    DISPLAY=$DSP xte "usleep $(rnd 800000 1400000)" "str -"
    

    DISPLAY=$DSP xte "usleep $(rnd 800000 1400000)" "str -"
    DISPLAY=$DSP xte "usleep $(rnd_offset 2000000 1000000)" "str -"
    
    DISPLAY=$DSP xte "usleep $(rnd_offset 2000000 1000000)" "str -"
    
    DISPLAY=$DSP xte "usleep $(rnd_offset 3000000 1000000)" "str -"

    DISPLAY=$DSP xte "usleep $(rnd_offset 4000000 1000000)" "str -"

    DISPLAY=$DSP xte "keyup Control_L" "usleep $(rnd_offset 2000000 1000000)"
}

page_down () {
    DISPLAY=$DSP xte "key Page_Down"
    DISPLAY=$DSP xte "usleep $(rnd_offset 3000000 2000000)"

}


get_md5 () {
    rm -f /tmp/targ.ppm
    DISPLAY=$DSP scrot -a $1,$2,$3,$4 /tmp/targ.ppm
    tmpmd5=`md5sum /tmp/targ.ppm | awk '{print $1}'`

    if [ $output_screenshots = 1 ]; then
	cp /tmp/targ.ppm $step_temp_dir/$(printf "%.3d" $step)\ -$tmpmd5.ppm
	rm -f /tmp/fullscreen.ppm
	DISPLAY=$DSP scrot /tmp/fullscreen.ppm
	cp /tmp/fullscreen.ppm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
	./draw_a_rectangle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $1 $2 $3 $4
	./draw_a_circle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $(($1+$3/2)) $(($2+$4/2)) $3
	convert $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm  $step_temp_dir/$(printf "%.3d" $step)\ -\ $1\ $2\ $3\ $4.png
	rm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
    fi
    echo $tmpmd5
}


echo $$ > /tmp/killthis

# have to start out by killing any opened chromium sessions or the script will try to use an already opened session
kill_webbrowser
kill_xvfb

sleep 1

rm -rf "$XVFB_DIR"
mkdir -p "$XVFB_DIR"

Xvfb $DSP -fbdir "$XVFB_DIR" &
sleep 1 

DISPLAY=$DSP $WEBROWSER --incognito --user-data-dir="$CACHEDIR" --disk-cache-dir="$CACHEDIR" --profile-directory="Profile 3" "$addr1" &

status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "$addr1")
CNTR=0
EXPECTED_STATUS=200
while [ ! "$status_code" -eq "$EXPECTED_STATUS" ]; do
  sleep 1 
  status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "$addr1")
  CNTR=$(( CNTR + 1 ))
  if [ $CNTR -eq 5 ]; then
      case "${status_code}" in
	  000)
	      echo "error: no response"

	      kill_xvfb
	      exit 110
	      ;;
	  006)
	      echo "error: could not resolve host"

	      kill_xvfb
	       exit 113
	      ;;
	  007)
	      echo "error: could not connect"

	      kill_xvfb
	      exit 111
	      ;;
	  *)
	      echo "error: ${status_code}"

	      kill_xvfb
	      exit 1
	      ;;
      esac
  fi
done
sleep 5

 tabpause=100000   
 DISPLAY=$DSP xte "key Tab" "usleep $tabpause" "key Tab" "usleep $tabpause" "key Tab" "usleep $tabpause"

 DISPLAY=$DSP xte "key Tab" "usleep $tabpause" "key Tab" "usleep $tabpause" "key Tab" "usleep $tabpause"

 DISPLAY=$DSP xte "key Tab" "key Tab" "sleep 1"
 DISPLAY=$DSP xte "key Return" "sleep 1"
 var=$(DISPLAY=$DSP xclip -out -selection clipboard)

 kill_xvfb
 echo "$var"

 

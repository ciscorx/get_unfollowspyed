#!/bin/bash

###############################
##  rip_naver_chinese_daily_conversation.sh  
###############################
#  This script visits the webpage https://linedict.com, using xvfb,
#  xautomation and chromium.  If an argument is passed to the script
#  then the script will execute alt tab and assume there is a browser
#  there pointed at the correct webpage.  If the argument passed is
#  "justaudio" then skip the translating and just record the audio.
#  If the argument is "noaudio" then just translate the text.
 
#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+,
#  chromium-browser, Imagemagick (for optionally outputting
#  screenshots), gcc (to optionally compile the c programs for marking
#  up screen shots), sox, curl
#  Required scripts in same directory:
#    translate_korean_to_en.py
#    translate_chinese_to_en.py
#    translate_phrase.sh
#    translate_phrase_print_pronunciation.sh

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3

#set -x
# WARNING: THE BELOW DIRS WILL BE DELETED
CACHEDIR=/tmp/temp-disk-cache-dir
XVFB_DIR=/tmp/xvfb_dir


# addr1=https://dict.naver.com/linedict/zhendict/#/cnen/todayexpr?data=20230521
addr1=https://learn.dict.naver.com/conversation#/cndic/
output_screenshots=0
step_temp_dir=/tmp/$(basename $0 ".sh")
vpn_dir=/opt/scripts/vpn/
SCRIPT=`realpath $0`
# SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RIP_DIRECTORY=/tmp/rip_linedict_files/
WEBROWSER=google-chrome
tabduration=1000000
tabduration_offset=200000
FILENAME_BASE=

mkdir -p  "${RIP_DIRECTORY}"
rm -rf "$CACHEDIR"
mkdir -p "$CACHEDIR" 
#rm -rf "$step_temp_dir"
#mkdir -p "$step_temp_dir"
rm -rf "$XVFB_DIR"
mkdir -p  "$XVFB_DIR"
step=0

remove_last_character_from_string_if_its_forward_slash () {
    if [[ ${1:${#1}-1:1} == "/" ]]; then
	echo ${1:0:${#1}-1}
    else
	echo $1
    fi       
}

pause_until_audio_stops_playing() {
    audio_is_playing=true
    while [ $audio_is_playing = true ]; do
	if pacmd list-sink-inputs | grep -q "state: RUNNING"; then
	    sleep 5
	else
	    audio_is_playing=false
	fi
    done
	
}


kill_xvfb() {
    PROCEXISTS=`ps -ef | grep $XVFB_DIR | wc | awk '{print $1}'`
    if  [ "$PROCEXISTS" != "1" ]; then
	PROCNUM=`ps -ef | grep $XVFB_DIR | awk 'NR==1{print $2}'`
	kill -9 $PROCNUM
    fi
}

kill_webbrowser() {
   kill -9 `ps -ef | grep chromium | awk 'NR==1{print $2}'`
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

#DSP=$(find_free_display)
#echo using DISPLAY $DSP

rnd() {
python3 -S -c "import random; print( random.randrange($1,$2))"
}

rnd_offset() {
python3 -S -c "import random; print(random.randrange($1,$(($1 + $2))))"
}

tab_to_listen_all() {

    xte "keydown Control_L" "str l" "usleep $(rnd 100000 300000)" "keyup Control_L" "usleep $(rnd_offset 500000 200000)" 
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"

    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"


    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"
    xte "key Tab" "usleep $(rnd_offset ${tabduration} ${tabduration_offset})"


    xte "key Return"

}


alt_tab (){
    
    
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
    xte "sleep 1"
}
click_page () {

#    xte "mousemove $(rnd  1310 1710) $(rnd 490 690)" "usleep $(rnd 100000 100000)" "mouseclick 1" "usleep 50000"

    xte "mousemove $(rnd_offset 300 100) $(rnd_offset 400 100)" "usleep $(rnd_offset 300000 100000)" "mouseclick 1" "usleep 50000"
    xte "usleep $(rnd_offset 500000 500000)"
}

play_all () {
#    xte "mousemove $(rnd 5 20) $(rnd 556 560)" "usleep $(rnd_offset 50000 100000)" 'mouseclick 1'  "usleep $(rnd_offset 50000 5)"
    #    xte "usleep 50000"

    tab_to_listen_all
}

click_previous_page () {

    xte "mousemove $(rnd 5 20) $(rnd 440 444)" "usleep $(rnd_offset 50000 100000)" 'mouseclick 1'  "usleep $(rnd_offset 3000000 1000000)"
    #xte "mousemove $(rnd 260 310) $(rnd 240 290)" "usleep $(rnd_offset 50000 100000)" 'mouseclick 1'  "usleep $(rnd_offset 50000 50000)"
    #    xte "usleep 50000"
#    tab_to_previous
}

set_default() {
    
    xte "keydown Control_L" "str 0" "usleep 40000"

    xte "keyup Control_L" "sleep 2"
    }


    
alt_tab_select_all_ctrl_c () {
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
    xte "sleep 1"
    xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    xte "keydown Control_L" "usleep 50000" "str a" "usleep 50000" "str c" "usleep 50000" "keyup Control_L"
    xte "sleep 1"
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
}


select_all_ctrl_c () {
    xte "keydown Control_L" "usleep 50000" "str a" "usleep 150000" "str c" "usleep 150000" "keyup Control_L"
    xte "sleep 1"
}


random_number() {
    python3 -S -c "import random; print( random.randrange($1,$2))"
}


set_25_percent () {
    click_page
   
    xte "keydown Control_L" "str 0" "sleep 2"
    xte "usleep $(rnd 800000 1400000) " "str -"

    xte "usleep $(rnd 800000 1400000)" "str -"
    

    xte "usleep $(rnd 800000 1400000)" "str -"
    xte "usleep $(rnd_offset 2000000 1000000)" "str -"
    
    xte "usleep $(rnd_offset 2000000 1000000)" "str -"
    
    xte "usleep $(rnd_offset 3000000 1000000)" "str -"

    xte "usleep $(rnd_offset 4000000 1000000)" "str -"

    xte "keyup Control_L" "usleep $(rnd_offset 2000000 1000000)"
}

page_down () {
    xte "key Page_Down"
    xte "usleep $(rnd_offset 3000000 2000000)"

}


get_md5 () {
    rm -f /tmp/targ.ppm
    scrot -a $1,$2,$3,$4 /tmp/targ.ppm
    tmpmd5=`md5sum /tmp/targ.ppm | awk '{print $1}'`

    if [ $output_screenshots = 1 ]; then
	cp /tmp/targ.ppm $step_temp_dir/$(printf "%.3d" $step)\ -$tmpmd5.ppm
	rm -f /tmp/fullscreen.ppm
	scrot /tmp/fullscreen.ppm
	cp /tmp/fullscreen.ppm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
	./draw_a_rectangle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $1 $2 $3 $4
	./draw_a_circle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $(($1+$3/2)) $(($2+$4/2)) $3
	convert $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm  $step_temp_dir/$(printf "%.3d" $step)\ -\ $1\ $2\ $3\ $4.png
	rm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
    fi
    echo $tmpmd5
}




record_audio() {
        play_all 

	parec | sox -t raw -r 44.1k -e signed -b 16 -c 2 - -C 192 /tmp/tmpoutput.wav&
	PARCEC_PID=$!
	xte  "usleep $(rnd_offset 20000000 1000000)"

	pause_until_audio_stops_playing
	# stop recording audio by killing the sox process
	kill "${PARCEC_PID}"

	wait "${PARCEC_PID}" 2>/dev/null
	sleep 1
	# trim silence from audio
	sox -V /tmp/tmpoutput.wav /tmp/output.wav reverse silence 1 2 0.5% reverse

	# convert from wav to mp3
	sleep 1
	ffmpeg  -i /tmp/output.wav -ar 44100 -ab 192k -af volume=7 /tmp/output.mp3
	cp /tmp/output.mp3 "${RIP_DIRECTORY}${FILENAME_BASE}.mp3"
        sleep 1
	rm -f /tmp/screen_stops_changing.ppm /tmp/output.wav /tmp/tmpoutput.wav /tmp/output.mp3
	}

echo $$ > /tmp/killthis


    # if no argument is passed to the script then call a browser, otherwise just assume  there is already a browser opened  and pointed at the correct web page, 
if [ $# -eq 0 ]; then
    $WEBROWSER $addr1 &
else
    alt_tab
fi

## reset zoom if applied
## DISPLAY=$DSP xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 10



	


 #   DISPLAY=$DSP xte "keydown Control_L" "str l" "usleep $(rnd 100000 300000)" "keyup Control_L" "usleep $(rnd 100000 200000)" 
    
 #   DISPLAY=$DSP xte "str https://learn.dict.naver.com/conversation#/cndic/" "usleep $(rnd 1000000 3000000)" "key Return"


    
	sleep 1
	select_all_ctrl_c
	sleep  2
	FILENAME_BASE=`xclip  -o| head -n 7 | tail -n 1 | awk '{print $1}'`
year="${FILENAME_BASE:0:4}"
month="${FILENAME_BASE:4:2}"
day="${FILENAME_BASE:6:2}"
formatted_date="$year.$month.$day"
FILENAME_BASE="${formatted_date}"
sleep 1
      

if [ ! -z "$1" ] && [ "$1" = "justaudio" ]; then
    record_audio
    alt_tab
    exit 0
fi

	xclip  -o | sed '1,7d; 8,9d; 12,18d'| sed '/오늘 이 문장/,/ʕ•̯ᴥ•̯ʔ/d' | head -n -4 |  sed ':a; /^\s*$/N; /\n\s*$/D' | awk 'NR==3{print "\n--------------\n"}1' 	    > /tmp/tmpfile.txt

        perl -pi -e 's/^관련 단어$/related words/g;' /tmp/tmpfile.txt
	perl -pi -e 's/^출처:.*//g;' /tmp/tmpfile.txt
	

	  # delete  line that ends with .talk along with the 2 preceding lines
        awk -v lineNum=$(grep -n "\.talk$" "/tmp/tmpfile.txt" | cut -d: -f1) ' NR != (lineNum-2) && NR != (lineNum-1) && NR != lineNum { print }' "/tmp/tmpfile.txt" > /tmp/tmpfile_mod.txt
	mv /tmp/tmpfile_mod.txt /tmp/tmpfile.txt
	
	perl -pi -e 's/듣기$//g;' /tmp/tmpfile.txt

	sed -i "1i${addr1}${year}${month}${day}" /tmp/tmpfile.txt 
	sed -i "1i${FILENAME_BASE}" /tmp/tmpfile.txt 
	
	sleep 1
	./translate_korean_to_en.py "/tmp/tmpfile.txt" "/tmp/tmpfile_nokorean.txt"

	tmpfile_chinese_translated=/tmp/tmpfile_nochinese.txt
        ./translate_chinese_to_en.py "/tmp/tmpfile_nokorean.txt" "${tmpfile_chinese_translated}"
	
	sed -i '/^Send feedback$/,/^Translation results available$/d' "${tmpfile_chinese_translated}"
	   # remove blank lines if 2 or more consecutive blank lines
	sed -i ':a; /^\s*$/N; /\n\s*$/D'  "${tmpfile_chinese_translated}" 

	cp "${tmpfile_chinese_translated}"  "${RIP_DIRECTORY}${FILENAME_BASE}.txt"

	if [ -z "$1" ] || [ ! "$1" = "noaudio" ] ; then
	    record_audio
	fi
	sleep 1

	alt_tab

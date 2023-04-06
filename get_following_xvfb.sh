#!/bin/sh

###############################
##  get_following_xvfb.sh  
###############################
#  This script visits the webpage https://twitter.com, using xvfb,
#  xautomation and chromium, and logins in under the LOGIN thats
#  specified in the variables and finds out all the people who arent
#  following you back.  This might violate terms of service with
#  twitter.  But, even if it does, its very difficult to detect.  So,
#  scroo that doge punk.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+,
#  chromium-browser, Imagemagick (for optionally outputting
#  screenshots), gcc (to optionally compile the c programs for marking
#  up screen shots), gedit

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3



# WARNING: THE BELOW DIRS WILL BE DELETED
CACHEDIR=/tmp/temp-disk-cache-dir
XVFB_DIR=/tmp/xvfb_dir

addr1=https://twitter.com/login
twitter_login=LOGIN
twitter_passwd=PASSWORD
output_screenshots=1
step_temp_dir=/tmp/$(basename $0 ".sh")
vpn_dir=/opt/scripts/vpn/
SCRIPT=`realpath $0`
# SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
OUTPUT_FILE="$SCRIPTPATH"/unfollowed.txt
WEBROWSER=chromium

rm -rf "$CACHEDIR"
mkdir -p "$CACHEDIR" 
rm -rf "$step_temp_dir"
mkdir -p "$step_temp_dir"
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


kill_xvfb() {
    PROCEXISTS=`ps -ef | grep $XVFB_DIR | wc | awk '{print $1}'`
    if  [ ! $PROCEXISTS = 1 ]; then
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

DSP=$(find_free_display)
echo using DISPLAY $DSP

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


    
alt_tab_select_all_ctrl_c () {
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
    xte "sleep 1"
    xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    xte "keydown Control_L" "usleep 50000" "str a" "usleep 50000" "str c" "usleep 50000" "keyup Control_L"
    xte "sleep 1"
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
}


select_all_ctrl_c () {
    DISPLAY=$DSP xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    DISPLAY=$DSP xte "keydown Control_L" "usleep 50000" "str a" "usleep 150000" "str c" "usleep 150000" "keyup Control_L"
    DISPLAY=$DSP xte "sleep 1"
}

advance_to_next_page () {
    xte "keydown Shift_L" "usleep 50000"
    xte "key Tab" "usleep 500000"
    xte "key Tab" "usleep 500000"
    xte "key Tab" "usleep 500000"
    xte "key Tab" "usleep 500000"
    xte "key Tab" "usleep 500000"
    xte "keyup Shift_L" "usleep 50000"
    xte "key Return"
    xte "sleep 5"
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

DISPLAY=$DSP $WEBROWSER --user-data-dir="$CACHEDIR" --disk-cache-dir="$CACHEDIR" --profile-directory="Profile 3" $addr1 &
sleep 5
## reset zoom if applied
DISPLAY=$DSP xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 1

logged_in=0

# login 1

#  look for Sign in Twitter message
md5=$(get_md5  385 300 255 33 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "4e9e704f520c75fa1893d2bd88394411" ] || [ $md5 = "add another" ]; then
    


    # look for phone, email, or username message    
    md5=$(get_md5  390 533 214 18)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi
    
    if [ $md5 = "0f2c2546ca147afb273da0b9664a8d23" ] || [ $md5 = "add another" ]; then
	
	echo Clicked the username box of login 1
    
	DISPLAY=$DSP xte  "mousemove  $(rnd_offset 390 214) $(rnd_offset 533 18)"  'mouseclick 1'  "usleep $(rnd 1000000 3000000)"
	DISPLAY=$DSP xte "str $twitter_login" "usleep $(rnd 1000000 3000000)" "key Return"
	DISPLAY=$DSP xte "usleep $(rnd 1000000 3000000)"

	DISPLAY=$DSP xte "str $twitter_passwd" "usleep $(rnd 1000000 3000000)" "key Return" "usleep $(rnd_offset 3000000 3000000)" 

	# look for text of twitter.com/home in address bar    
	md5=$(get_md5 150 55 130 15)
	if [ $output_screenshots = 1 ]; then
	    echo $step - $md5; step=$(($step + 1))  #### step:3
	fi
	
	if [ $md5 = "653bbd5e8cef9ffcb5301ba58ccc176b" ] || [ $md5 = "add another" ]; then
	    echo logged into 1
	    logged_in=1
	fi
    fi
fi


# login 2

#  look for Sign in Twitter message
md5=$(get_md5  385 322 255 33 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:4
fi

if [ $md5 = "4e9e704f520c75fa1893d2bd88394411" ] || [ $md5 = "add another" ]; then
    


    # look for phone, email, or username message    
    md5=$(get_md5  390 555 214 18)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:5
    fi
    
    if [ $md5 = "0f2c2546ca147afb273da0b9664a8d23" ] || [ $md5 = "add another" ]; then
	
	echo Clicked the username box of login 2
    
	DISPLAY=$DSP xte  "mousemove  $(rnd_offset 390 214) $(rnd_offset 555 18)"  'mouseclick 1'  "usleep $(rnd 1000000 3000000)"
	DISPLAY=$DSP xte "str $twitter_login" "usleep $(rnd 1000000 3000000)" "key Return"
	DISPLAY=$DSP xte "usleep $(rnd 1000000 3000000)"

	DISPLAY=$DSP xte "str $twitter_passwd" "usleep $(rnd 1000000 3000000)" "key Return"  "usleep $(rnd_offset 3000000 3000000)" 

	# look for the password message, which if its still there indicates that the password failed
	

	# look for text of twitter.com/home in address bar    
	md5=$(get_md5 323 480 60 15)
	if [ $output_screenshots = 1 ]; then
	    echo $step - $md5; step=$(($step + 1))  #### step:6
	fi
	
	if [ $md5 = "92c64f480e084d79cfd63b598223375c" ] || [ $md5 = "add another" ]; then
	    echo password failed
	    logged_in=0
	fi

	
	# look for text of twitter.com/home in address bar    
	md5=$(get_md5 150 55 130 15)
	if [ $output_screenshots = 1 ]; then
	    echo $step - $md5; step=$(($step + 1))  #### step:6
	fi
	
	if [ $md5 = "653bbd5e8cef9ffcb5301ba58ccc176b" ] || [ $md5 = "add another" ]; then
	    echo logged into 2
	    logged_in=1
	fi
    fi
fi


# look for text of twitter.com/home in address bar    
md5=$(get_md5 150 55 130 15)
if [ $output_screenshots = 1 ]; then
    echo $step - $md5; step=$(($step + 1))  #### step:7
fi
	

if [ $md5 = "653bbd5e8cef9ffcb5301ba58ccc176b" ] || [ $md5 = "add another" ]; then
    echo already logged into 1 or 2
    logged_in=1
    sleep 1
fi

if [ $logged_in = 1 ]; then
    DISPLAY=$DSP xte "keydown Control_L" "str l" "usleep $(rnd 100000 300000)" "keyup Control_L" "usleep $(rnd 100000 200000)" 
    
    DISPLAY=$DSP xte "str https://twitter.com/$twitter_login/following" "usleep $(rnd 1000000 3000000)" "key Return"



    echo "following:" > /tmp/following.txt
    click_page
    set_25_percent

    rm -f /tmp/screen_stops_changing.ppm
    DISPLAY=$DSP scrot /tmp/screen_stops_changing.ppm
    lastmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
    #    echo screen changing $md5
    tmpmd5="tmpmd5"
    sleep 2
    
    #  keep page down scrolling until screen stops changing 
    until [ $tmpmd5 = $lastmd5 ]; do 
	select_all_ctrl_c
	DISPLAY=$DSP xclip -o | dd of=/tmp/following.txt oflag=append conv=notrunc 
	DISPLAY=$DSP xte "key Page_Down"
	DISPLAY=$DSP xte "usleep $(random_number 2000000 4000000)"
        DISPLAY=$DSP xte "sleep 2"
	
	rm -f /tmp/screen_stops_changing.ppm
	DISPLAY=$DSP scrot /tmp/screen_stops_changing.ppm
	lastmd5=$tmpmd5
	tmpmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
	#	echo screen changing $tmpmd5
	echo -n .
	sleep 1
    done
    
    echo .
    rm -f /tmp/screen_stops_changing.ppm
    set_default

    
    grep -A1 '^@' /tmp/following.txt | grep -B1 '^Follows you' | grep -e "@" | sort | uniq > /tmp/follows_you.txt
    cp /tmp/follows_you.txt /mnt/disk/bkup/follows_you/`date +%y%m%d`.txt
    
fi

kill_xvfb
echo "exited script at end"

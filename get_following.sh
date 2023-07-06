#!/bin/sh

###############################
##  get_following_xvfb.sh  
###############################
#  This script visits the webpage https://twitter.com, using 
#  xautomation and chromium, and logins in under the LOGIN thats
#  specified in the variables and finds out all the people who arent
#  following you back.  This might violate terms of service with
#  twitter.  But, even if it does, its very difficult to detect.  So,
#  scroo that doge punk.

#  Requirements: linux,  xautomation, scrot 0.8-18+,
#  chromium-browser, Imagemagick (for optionally outputting
#  screenshots), gcc (to optionally compile the c programs for marking
#  up screen shots), gedit

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3



OUTPUT_FILE=/mnt/disk/bkup/follows_you/`date +%y%m%d_%H%M%S`.txt

output_screenshots=1
step_temp_dir=/tmp/$(basename $0 ".sh")
SCRIPT=`realpath $0`
# SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


rm -rf "$step_temp_dir"
mkdir -p "$step_temp_dir"
step=0

remove_last_character_from_string_if_its_forward_slash () {
    if [[ ${1:${#1}-1:1} == "/" ]]; then
 	echo ${1:0:${#1}-1}
    else
	echo $1
    fi       
}






rnd() {
python3 -S -c "import random; print( random.randrange($1,$2))"
}

rnd_offset() {
python3 -S -c "import random; print(random.randrange($1,$(($1 + $2))))"
}



alt_tab (){
    
    
    xte "keydown Alt_L" "usleep 50000" "key Tab" "usleep 50000" "keyup Alt_L"
    xte "sleep 1"
}


click_page () {

    xte "mousemove $(rnd  10 280) $(rnd 180 950)" "usleep $(rnd 100000 100000)" "mouseclick 1" "usleep 50000"
    xte "usleep 50000"
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
    xte "mousemove 300 600" "usleep 50000" "mouseclick 1" "usleep 50000"
    xte "keydown Control_L" "usleep 50000" "str a" "usleep 150000" "str c" "usleep 150000" "keyup Control_L"
    xte "sleep 1"
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


echo $$ > /tmp/killthis

sleep 1

## reset zoom if applied
# xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 1


    alt_tab
  #  echo "following:" > /tmp/following.txt
    click_page
#    set_25_percent
    set_default



# # look for text of twitter.com/home in address bar    
# md5=$(get_md5 150 55 130 15)
# if [ $output_screenshots = 1 ]; then
#     echo $step - $md5; step=$(($step + 1))  #### step:7
# fi
	

# if [ $md5 = "653bbd5e8cef9ffcb5301ba58ccc176b" ] || [ $md5 = "add another" ]; then
#     echo already logged into 1 or 2
#     logged_in=1
#     sleep 1
# fi

# if [ $logged_in = 1 ]; then
#     xte "keydown Control_L" "str l" "usleep $(rnd 100000 300000)" "keyup Control_L" "usleep $(rnd 100000 200000)" 
    
#     xte "str https://twitter.com/$twitter_login/following" "usleep $(rnd 1000000 3000000)" "key Return"



    echo "following:" > /tmp/following.txt
    click_page
    set_25_percent

    rm -f /tmp/screen_stops_changing.ppm
    scrot /tmp/screen_stops_changing.ppm
    lastmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
    #    echo screen changing $md5
    tmpmd5="tmpmd5"
    sleep 2
    
    #  keep page down scrolling until screen stops changing 
    until [ $tmpmd5 = $lastmd5 ]; do 
	select_all_ctrl_c
	xclip -o | dd of=/tmp/following.txt oflag=append conv=notrunc 
	xte "key Page_Down"
	xte "usleep $(random_number 2000000 5000000)"
        xte "sleep 2"
	
	rm -f /tmp/screen_stops_changing.ppm
	scrot /tmp/screen_stops_changing.ppm
	lastmd5=$tmpmd5
	tmpmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
        echo screen changing= $tmpmd5
	sleep 1
    done
    
    echo .
    rm -f /tmp/screen_stops_changing.ppm
    set_default

    
    grep -A1 '^@' /tmp/following.txt | grep -B1 '^Follows you' | grep -e "@" | sort | uniq > /tmp/follows_you.txt
    cp /tmp/follows_you.txt $OUTPUT_FILE
    

echo "exited script at end"

#!/bin/sh

###############################
##  get_unfollowspyed.sh  
###############################
#  Logs into Twitter and unfollowspy.com, using xvfb and chromium, and
#  gets the names of all those people that unfollowed you today!
#  Although, it will only get the first page of unfollowers.  Useful
#  for headless servers or if you have no X11 display manager.

#  Requirements: linux, X11, xvfb, xautomation, scrot 0.8-18+,
#  chromium-browser, Imagemagick (for outputting debug screenshots),
#  gcc (to compile the c programs for marking up the screen shots),
#  gedit

#  To configure this script to work on your computer you may need to
#  run it several times, adding the proper md5 values to each match
#  condition for each step of the process.  The md5 values and their
#  respective images for each run can be found in the
#  /tmp/get_unfollowspyed directory.  The title of the files are
#  comprised of the md5sums, and the image geometries.

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3

#  Version 1



addr1=http://mobile.twitter.com
addr2=http://unfollowspy.com
addr3=http://google.com
TWITTER_LOGIN="login"
TWITTER_PASSWD="password"
TMP_RESULTS_FILE=/tmp/savetheseresults.txt
output_screenshots=1
step_temp_dir=/tmp/$(basename $0 ".sh")
#SCRIPT=`realpath $0`
#SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
OUTPUT_FILE="$SCRIPTPATH"/unfollowed.txt
WEBROWSER=chromium

# WARNING: THE BELOW DIRS WILL BE DELETED
CACHEDIR=/tmp/temp-disk-cache-dir
XVFB_DIR=/tmp/xvfb_dir

rm -f "$TMP_RESULTS_FILE"
rm -rf "$CACHEDIR"
mkdir -p "$CACHEDIR" 
rm -rf "$step_temp_dir"
mkdir -p "$step_temp_dir"
rm -rf "$XVFB_DIR"
mkdir -p  "$XVFB_DIR"
step=0

kill_xvfb() {
    PROCEXISTS=`ps -ef | grep $XVFB_DIR | wc | awk '{print $1}'`
    if  [ ! $PROCEXISTS = 1 ]; then
	PROCNUM=`ps -ef | grep $XVFB_DIR | awk 'NR==1{print $2}'`
	kill -9 $PROCNUM
    fi
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
python -S -c "import random; print( random.randrange($1,$2))"
}

rnd_offset() {
python -S -c "import random; print(random.randrange($1,$(($1 + $2))))"
}

# DO NOT USE THIS because of video ads
sleep_until_screen_stops_changing ()
 {
    MAX_SLEEP_ITERATIONS=10
    sleep_iteration=0
    rm -f /tmp/screen_stops_changing.ppm
    DISPLAY=$DSP scrot /tmp/screen_stops_changing.ppm
    lastmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
#    echo screen changing $md5
    tmpmd5="tmpmd5"
    
    sleep 2
    
    until [ $tmpmd5 = $lastmd5 ] || [ $sleep_iteration -eq $MAX_SLEEP_ITERATIONS ]; do 
	rm -f /tmp/screen_stops_changing.ppm
	DISPLAY=$DSP scrot /tmp/screen_stops_changing.ppm
	lastmd5=$tmpmd5
	tmpmd5=`md5sum /tmp/screen_stops_changing.ppm | awk '{print $1}'`
#	echo screen changing $tmpmd5
	echo -n .
	sleep_iteration=$(($sleep_iteration + 1))
	sleep 2
    done
    echo .
    rm -f /tmp/screen_stops_changing.ppm
   }
   
save_results () {
    rm -f "$TMP_RESULTS_FILE"
    DISPLAY=$DSP xte  "mousemove  $(rnd_offset 26 67) $(rnd_offset 280 13)"  'mouseclick 1'  "usleep $(rnd 2000000 4000000)" 
    echo saving results to "$TMP_RESULTS_FILE"
    
    sleep 3
    DISPLAY=$DSP scrot /tmp/test.ppm
    sleep 1
    DISPLAY=$DSP xte 'keydown Control_L' 'str a' "usleep 300000" 'str c' 'keyup Control_L'
    sleep 2
    DISPLAY=$DSP gedit&
    sleep 5
    
    DISPLAY=$DSP xte 'keydown Control_L' 'str v' 'keyup Control_L' 'usleep 1000000'
    DISPLAY=$DSP xte 'keydown Control_L' 'str s' 'keyup Control_L' 'usleep 1000000' "str ${TMP_RESULTS_FILE}" 'key Return'
    sleep 2

    DISPLAY=$DSP xte 'keydown Control_L' 'str q' 'keyup Control_L' 'usleep 1000000' 
    # check for ad
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

# have to start out by killing any opened chromium sessions or the script will try to use an already opened session
pkill $WEBROWSER
kill_xvfb
sleep 1
rm -rf "$XVFB_DIR"
mkdir -p "$XVFB_DIR"
Xvfb $DSP -fbdir "$XVFB_DIR" &
sleep 1 

DISPLAY=$DSP $WEBROWSER --user-data-dir="$CACHEDIR" --disk-cache-dir="$CACHEDIR" --profile-directory="Profile 3" $addr2 &
#DISPLAY=$DSP chromium --user-data-dir=/tmp --disk-cache-dir=/tmp --profile-directory="Profile 3" http://unfollowspy.com &
#  to click brower options : click 1035 60
#  save password is @ 913,383,38,18 = ppm md5 02a5dc4c2397ddd0e61f9a28ddfcc25d   mouseclick 923 393
#  x out of sync passwords is @ 962,87,10,10 = ppm md5 898fad93904253462a4129497474c7bc   mouseclick 970 92

#  Sign in with Twitter messager is @ 597,306,142,20 = ppm md5 31be6c4dd572e82e8f31a9866f873a92
#  authorize app is @ 222,266,98,17 = ppm md5 12ed592fbb0f75b874c009a359dc9a57 mouseclick 270 274
#  0 unfollowed message @ 310,210,84,70 = ppm md5 a124f8a66b441e6dc2fc111117144240
#  manage users v @ 46,246,120,14 = ppm md5 b0f1596f3b375be34278355e0abc93d6
#  unfollowed @ 26,280,67,13 = ppm md5 8b4af18ad0ac038e7d3f0b1031f61efc
#  doesnt follow back @ 26,340,123,13 = ppm md5 6aaebc619a22881e5f7169e24a34fb75 
# up 40 left 40

# back button on browser:
# DISPLAY=$DSP xte "mousemove $(rnd_offset 28 10) $(rnd_offset 56 12)" 'mouseclick 1'
                                                                                    # 27 56 10 12 3a9ce1f3cc78e2c96e8499c2164afecc

sleep 10

## reset zoom if applied
 DISPLAY=$DSP xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
 sleep 1

 

#debug
# check for default browser
md5=$(get_md5 35 110 375 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "6827ff4ef9c930807d12636d9b9cf477" ]; then
    echo Chrome isnt your default browser
    sleep 3
     
fi


#debug
# check for the x Cancel button on set default browser prompt and click it
md5=$(get_md5 1034 115 12 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:2
fi

if [ $md5 = "a42c9b7f21a1eb148c110b78fc9f4303" ]; then
    ## Set as Default button has focus
    # click Set As Default
    # DISPLAY=$DSP xte 'mousemove 510 216' 'mouseclick 1'
    # click x Cancel
    DISPLAY=$DSP xte 'mousemove 1040 121' 'mouseclick 1'  'sleep 1'
       echo clickd cancel button on set default browser prompt
fi



# check for default browser - archlinux
md5=$(get_md5 60 95 265 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "6f856b170716b4ca16a9f82d42951cb4" ]; then
    echo Chrome isnt your default browser - archlinux
    sleep 3
     
    #debug
    # check for the x Cancel button on set default browser prompt and click it
    md5=$(get_md5 1030 100 12 12)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi

    if [ $md5 = "2d2268d91e99626344cc9bbf5550db37" ]; then
	## Set as Default button has focus
	# click Set As Default
	# DISPLAY=$DSP xte 'mousemove 510 216' 'mouseclick 1'
	# click x Cancel
	DISPLAY=$DSP xte 'mousemove 1036 106' 'mouseclick 1'  'sleep 1'
	echo clickd cancel button on set default browser prompt - archlinux 
    fi
fi

# check for cookies note - archlinux
md5=$(get_md5 150 100 120 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "1481ec135171f794ec383d0666bc59c7" ] || [ $md5 = "05f59759c98f4a07a19667ad22090896" ]; then
    echo Cookie note message encountered
    sleep 3
     
    #debug
    # check for the Continue button on cookies note prompt and click it
    md5=$(get_md5 748 100 78 20)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi

    if [ $md5 = "0cc836310c4db56af8523c53167ff1e2" ] || [ $md5 = "2b3940e8f4cf5714e5e53291eabb55f4" ]; then
	## Set as Default button has focus
	# click Set As Default
	# DISPLAY=$DSP xte 'mousemove 510 216' 'mouseclick 1'
	# click x Cancel
	DISPLAY=$DSP xte "mousemove $(rnd_offset 748 78) $(rnd_offset 110 20)" 'mouseclick 1'  'sleep 1'
	echo clickd cancel button on set default browser prompt - archlinux or r4pi
    fi
fi


# check for Sign in with Twitter button
md5=$(get_md5 597 306 142 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:0
fi

if [ $md5 = "31be6c4dd572e82e8f31a9866f873a92" ] || [ $md5 = "cb038df5e4151eff8fc6e35d6ab1150e" ]; then
#    DISPLAY=$DSP xte  'key Tab' "usleep $(rnd 1000000 3500000)" 'key Tab' "usleep $(rnd 1900000 3500000)"  'key Return' 'usleep 5000000'
    DISPLAY=$DSP xte "mousemove $(rnd_offset 597 140) $(rnd_offset 308 14)" 'mouseclick 1'
                                                      # 597 308 140 14 368961c31f0cf1fe538eb28cea261e49
    echo pressed the Return key to Sign with Twitter
    sleep_until_screen_stops_changing
fi

sleep 5

# check for Authorize Unfollowspy to access your account? - archlinux
md5=$(get_md5 200 170 360 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "d4756d659d38651d890b663e3a0e4aff" ] || [ $md5 = "d4756d659d38651d890b663e3a0e4af" ] || [ $md5 = "a8377f028911034f43464307e6d4d0af" ] ; then
    echo encountered Authorize Unfollowspy to access your account message - archlinux
    sleep 3
     
    #debug
    # check password prompt has focus
    md5=$(get_md5 207 272 215 33)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi

    if [ $md5 = "552438929ba132d65a7a88457524899b" ] || \
	   [ $md5 = "9563a4b337b12edf0990294c4c6c8e44" ] || \
	   [ $md5 = "0e56ee011235d5cb5b1771ffaa4aa33a" ] || \
	   [ $md5 = "9235867fad35fb1d06adb1738c811624" ]; then
	DISPLAY=$DSP xte "str $TWITTER_LOGIN"  "usleep $(rnd_offset 300000 3000000)" 'key Tab' "usleep $(rnd_offset 300000 3000000)" "str TWITTER_PASSWD" "usleep $(rnd_offset 300000 3000000)" 'key Return'
	echo entered twitter login and password
	sleep 3
#	sleep_until_screen_stops_changing 
# check for Save Password - archlinux
	md5=$(get_md5 676 210 130 20)
	if [ $output_screenshots = 1 ]; then
	    echo $step - $md5; step=$(($step + 1))  #### step:1
	fi

	if [ $md5 = "6b045c2401b47c69e563cb25673a64f7" ]; then
	    echo encountered Save Password? prompt - archlinux
	    sleep 3
	    
    #debug
	    # check for Save Password Button
	    md5=$(get_md5 910 350 42 16)
	    if [ $output_screenshots = 1 ]; then
		echo $step - $md5; step=$(($step + 1))  #### step:2
	    fi
	    
	    if [ $md5 = "7bac2e33e15ab864488834d62a6cdf6e" ]; then
		DISPLAY=$DSP xte "mousemove $(rnd_offset 910 42) $(rnd_offset 350 16)"  'mouseclick 1'   # save password button @ 910 350 42 16 7bac2e33e15ab864488834d62a6cdf6e
		#DISPLAY=$DSP xte "mousemove $(rnd_offset 830 42) $(rnd_offset 350 16)"  'mouseclick 1'   # never save password button @ 830 350 42 16 831fe04cb0c1519dadd4b5b5031c2f92
		#DISPLAY=$DSP xte "mousemove $(rnd_offset 961 12) $(rnd_offset 87 12)"  'mouseclick 1'   # x out of save password prompt @ 961 87 12 12 4bbb60c811e530b7c4d4d3feda2c42e5
		echo clicked Save Password button
	    fi
	fi
	

	
    fi  # password prompt has focus

    # look for Authorize app button
    md5=$(get_md5 225 270 95 12)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:1
    fi
    
    if [ $md5 = "fcf4e2916f51a99c9b8c9162fe116fbf" ]; then
	
	DISPLAY=$DSP xte "mousemove $(rnd_offset 225 95) $(rnd_offset 270 12)"  'mouseclick 1'  "usleep $(rnd 6000000 10000000)" 

	echo encountered Authorize app button and pressed it 
	# sleep_until_screen_stops_changing
    fi
    
fi # encountered Authorize Unfollowspy prompt

#debug    
#  authorize app button is @ 222,266,98,17 = ppm md5 12ed592fbb0f75b874c009a359dc9a57 mouseclick 270 274
md5=$(get_md5 222 266 98 17) 
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:3
fi

if [ $md5 = "12ed592fbb0f75b874c009a359dc9a57" ]; then
#    DISPLAY=$DSP xte  "mousemove  $(rnd_offset 222 98) $(rnd_offset 266 17)"  'mouseclick 1'  "usleep $(rnd 4000000 8000000)" 
    DISPLAY=$DSP xte 'key Tab' 'key Tab' 'key Tab' 'key Tab' 'key Tab' 'key Tab' 'key Return'  "usleep $(rnd 6000000 10000000)" 
    echo clicked authorize app
    
    # sleep_until_screen_stops_changing
fi


# check for 0 unfollowed message @ 310,210,84,70 = ppm md5 a124f8a66b441e6dc2fc111117144240
md5=$(get_md5 310 210 84 70 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:4
fi

if [ $md5 = "a124f8a66b441e6dc2fc111117144240" ] || [ $md5 = "6f0974780debe36304a6b1bf655fe39c" ]; then
    echo There are zero unfollowed, so quitting.
    DISPLAY=$DSP xte "keydown Control_L" "str q" "keyup Control_L"
    kill_xvfb
    exit 2
    
fi

#  click manage users v @ 46,246,120,14 = ppm md5 b0f1596f3b375be34278355e0abc93d6
md5=$(get_md5 46 246 120 14 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:5
fi

if [ $md5 = "b0f1596f3b375be34278355e0abc93d6" ] || [ $md5 = "28d7857457238b0b2f1af57a9aa98bf0" ]; then
    echo Clicked managee users v
    
    DISPLAY=$DSP xte  "mousemove  $(rnd_offset 46 120) $(rnd_offset 246 14)"  'mouseclick 1'  "usleep $(rnd 1000000 3000000)" 
fi

#  click unfollowed @ 26,280,67,13 = ppm md5 8b4af18ad0ac038e7d3f0b1031f61efc
md5=$(get_md5 26 280 67 13 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:6
fi

if [ $md5 = "8b4af18ad0ac038e7d3f0b1031f61efc" ] || [ $md5 = "72352b4a091861222fb2954dfa719c3d" ]; then

    save_results
    add_encountered=0
    checkforad=`cat "$TMP_RESULTS_FILE" | grep Ad | sed '1q'`
    
    if [ "$checkforad" = 'Ad' ]; then
	# remove the add window
	echo Ad encountered
	add_encountered=1
    fi
    
    checkforad=`cat "$TMP_RESULTS_FILE" | grep Close | sed '1q'`
    
    if [ "$checkforad" = 'Close' ]; then
	# remove the add window
	echo Ad Close button encountered
	add_encountered=1
    fi

    if [ "$add_encountered" -eq 1 ]; then

	DISPLAY=$DSP xte 'key Return'
	sleep 4
	save_results
    fi
    
    cat "$TMP_RESULTS_FILE" | sed 1,3d | grep ^@ >> "$OUTPUT_FILE"
    echo "updated $OUTPUT_FILE"
    kill_xvfb
    echo "ok"
fi

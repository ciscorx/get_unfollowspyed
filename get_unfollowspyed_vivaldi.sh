#!/bin/sh

###############################
##  get_unfollowspyed_vivaldi.sh  
###############################
#  Logs into Twitter and unfollowspy.com, using Xvfb and vivaldi, and
#  gets the names of all those people that unfollowed you today!
#  Although, it will only get the first page of unfollowers.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+,
#  vivaldi-stable, Imagemagick (for optionally outputting
#  screenshots), gcc (to optionally compile the c programs for marking
#  up screen shots), gedit

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3

#  Version 1

# WARNING: THE BELOW DIRS WILL BE DELETED
CACHEDIR=/tmp/temp-disk-cache-dir
XVFB_DIR=/tmp/xvfb_dir

addr1=http://mobile.twitter.com
addr2=http://unfollowspy.com
addr3=http://google.com
TWITTER_LOGIN="login"
TWITTER_PASSWD="password"
TMP_RESULTS_FILE=/tmp/savetheseresults.txt
output_screenshots=1
step_temp_dir=/tmp/$(basename $0)
SCRIPT=`realpath $0`
# SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
OUTPUT_FILE="$SCRIPTPATH"/unfollowed.txt
WEBROWSER=vivaldi-stable

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

# back button on browser:
# DISPLAY=$DSP xte "mousemove $(rnd_offset 28 10) $(rnd_offset 56 12)" 'mouseclick 1'
                                                                                    # 27 56 10 12 3a9ce1f3cc78e2c96e8499c2164afecc

sleep 10

## reset zoom if applied
 DISPLAY=$DSP xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
 sleep 1

 

#debug

# check for cookies note 
md5=$(get_md5 275 108 117 16)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "4df4a87e0cc5569bda4e4e35e3c2a6fa" ] ; then
    echo Cookie note message encountered
    sleep 3
     
    #debug
    # check for the Continue button on cookies note prompt and click it
    md5=$(get_md5 873 108 73 16)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi

    if [ $md5 = "ef26872b290621b918909eee0584515c" ] ; then
	## Set as Default button has focus
	DISPLAY=$DSP xte "mousemove $(rnd_offset 873 73) $(rnd_offset 108 16)" 'mouseclick 1'  'sleep 1'
	echo clickd Continue on cookies note prompt
    fi
fi


# check for Sign in with Twitter button
md5=$(get_md5  720 313 142 16)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:0
fi

if [ $md5 = "fe5dc1e075bd548d8d725b298ae60d4c" ]; then
#    DISPLAY=$DSP xte  'key Tab' "usleep $(rnd 1000000 3500000)" 'key Tab' "usleep $(rnd 1900000 3500000)"  'key Return' 'usleep 5000000'
    DISPLAY=$DSP xte "mousemove $(rnd_offset 720 142) $(rnd_offset 313 16)" 'mouseclick 1'
    echo pressed the Return key to Sign with Twitter
fi

sleep 5
sleep_until_screen_stops_changing
echo sleep_until_screen_stop_changing 1
# check for Authorize Unfollowspy to access your account? 
md5=$(get_md5 326 173 350 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "533c656260d42a8f286286e08f8dadb7" ] || [ $md5 = "989235671ffa98cc329f7a2648b978cd" ]; then
    echo encountered Authorize Unfollowspy to access your account message
    sleep 3
     
    #debug
    # check password prompt has focus
    md5=$(get_md5 326 276 200 33)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))  #### step:2
    fi

    if [ $md5 = "c092cfb7c437d87cfc147c8054e88e51" ] || \
	   [ $md5 = "63f89821cd9ace8e156baeb15dc95ccf" ]; then
	DISPLAY=$DSP xte "str $TWITTER_LOGIN"  "usleep $(rnd_offset 300000 3000000)" 'key Tab' "usleep $(rnd_offset 300000 3000000)" "str $TWITTER_PASSWD" "usleep $(rnd_offset 1000000 3000000)" 'key Return'
	echo entered twitter login and password
	sleep 5
	echo sleep_until_screen_stops_changing 2
	sleep_until_screen_stops_changing 
# check for Save Password prompt
	md5=$(get_md5 961 33 130 20)
	if [ $output_screenshots = 1 ]; then
	    echo $step - $md5; step=$(($step + 1))  #### step:1
	fi

	if [ $md5 = "029a7d835ba0763b57ad584bb57d010d" ]; then
	    echo encountered Save Password? prompt
	    sleep 3
	    
    #debug


	    # check for x out of save password button
	    
	    md5=$(get_md5 1245 26 10 10 )
	    if [ $output_screenshots = 1 ]; then
		echo $step - $md5; step=$(($step + 1))  #### step:2
	    fi
	    
	    if [ $md5 = "e1756483ba5cc9ca65a3e7c0a30cb876" ]; then
		
		DISPLAY=$DSP xte  "mousemove  $(rnd_offset 1245 10) $(rnd_offset 26 10)"  'mouseclick 1'  "usleep $(rnd 2000000 4000000)"
		echo clicked x out of save password 
	    fi
	    
	    # check for Save Password Button
	    md5=$(get_md5 1197 159 33 12)
	    if [ $output_screenshots = 1 ]; then
		echo $step - $md5; step=$(($step + 1))  #### step:2
	    fi
	    
	    if [ $md5 = "a5956f72e3efdbce31b86b7fb039a37b" ]; then
		#DISPLAY=$DSP xte "mousemove $(rnd_offset 1197 33) $(rnd_offset 159 12)"  'mouseclick 1'
		            # save password button @ 1197 159 33 12 a5956f72e3efdbce31b86b7fb039a37b

		#DISPLAY=$DSP xte "mousemove $(rnd_offset 1116 40) $(rnd_offset 159 12)"  'mouseclick 1'
		            # never save password button @ 1116 159 40 12 7cb7d1f96707929f14f8f2dac81183e0

		#DISPLAY=$DSP xte "mousemove $(rnd_offset 1245 10) $(rnd_offset 26 10)"  'mouseclick 1'
		            # x out of save password prompt @ 961 87 12 12 4bbb60c811e530b7c4d4d3feda2c42e5
		echo clicked Save Password button
	    fi
	fi
	

	
    fi  # password prompt has focus

    # look for Authorize app button (not configured yet)
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


# check for 0 unfollowed message 
md5=$(get_md5 395 210 84 70 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:4
fi

if [ $md5 = "44e78ea7cf2a83d856e7e1ba7d5d6e76" ]; then
    echo There are zero unfollowed, so quitting.
    DISPLAY=$DSP xte "keydown Control_L" "str q" "keyup Control_L"
    kill_xvfb
    exit 2
    
fi

#  click manage users v @ 46,246,120,14 = ppm md5 b0f1596f3b375be34278355e0abc93d6
md5=$(get_md5 76 250 120 14)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:5
fi

if [ $md5 = "00534992427e308538378ae91ebccc7d" ]; then
    echo Clicked managee users v
    
    DISPLAY=$DSP xte  "mousemove  $(rnd_offset 76 120) $(rnd_offset 250 14)"  'mouseclick 1'  "usleep $(rnd 1000000 3000000)" 
fi

#  click unfollowed @ 26,280,67,13 = ppm md5 8b4af18ad0ac038e7d3f0b1031f61efc
md5=$(get_md5 77 284 88 13 )
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:6
fi

if [ $md5 = "4f27f9c8d16b5ab77ba19a20e884afc3" ]; then

    DISPLAY=$DSP xte  "mousemove  $(rnd_offset 77 88) $(rnd_offset 284 13)"  'mouseclick 1'  "usleep $(rnd 1000000 3000000)" 
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

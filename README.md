# get_unfollowspyed

Logs into Twitter and unfollowspy.com, using xvfb and chromium, and
gets the names of all those people that unfollowed you today!
Although, it will only get the first page of unfollowers.  Useful
for headless servers or if you have no X11 display manager.

Requirements: linux, X11, xvfb, xautomation, scrot 0.8-18+,
chromium-browser, Imagemagick (for outputting debug screenshots),
gcc (to compile the c programs for marking up the screen shots),
gedit

To configure this script to work on your computer you may need to run
it several times, adding the proper md5 values to each match condition
for each step of the process.  The md5 values and their respective
images for each run can be found in the /tmp/get_unfollowspyed
directory.  The title of the files are comprised of the md5sums, and
the image geometries.

The get_unfollowspyed_vivaldi.sh script uses the Vivaldi-stable web
brower in lieu of Chromium, tested on vivaldi version 2.0.1309.37
running on Raspberry Pi 4 buster.

The run_get_unfollowspyed_vivaldi_timed.sh script uses the linux at
command to run it at a random time, useful if you dont want to appear
like a robot, always logging in at the same precise minute, in the
case of cron scheduling.  Its assumed the scripts are stored in the
/opt/get_unfollowspyed directory by default.

Authors/maintainers: ciscorx@gmail.com
License: GNU GPL v3
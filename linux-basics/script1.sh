# ABSOLUTE BASICS
# super user do - user with rights can call sudo to gain admin rights to call a command
sudo
# view manual for cmd
man #cmd
man ls
# dir contents
ls #dir
ls #lists pwd contents
#present working dir
pwd
#change directory
cd #dir
cd / #switches to root dir
# print to console
echo #txt
echo "Hello world!"
#prints current user
whoami
#switch users within current shell session, retains environment
su # no user specified -> root user
# switch user and create a new login shell session, resetting the env
su - #or su --login
# start a new bash session
bash
# start a bash session as the root user
sudo bash
whoami #root
# switch back
su #username
# add user
useradd #username
useradd johndoe
# add/change password of user
passwd johndoe # enter new password, retype it...
# delete user
userdel johndoe
# add new group
groupadd #groupname
groupadd techies
# delete group
groupdel techies
# create a file in current dir
touch #filename
touch helloworld.txt
# overwrite file contents
echo "Hello world!" > helloworld.txt
# insert into file contents
echo "Good morning!" >> helloworld.txt # pushes "Good morning!" onto the end of the file
# text editor
vi helloworld.txt #opens the helloworld.txt file in cmdline text editor
:wq # write & quit -> saves file and exits the text editor
# view contents of file
cat #filename
cat helloworld.txt
# some basic cat options
cat -d # numbers all output lines, starting at 1
cat -n # numbers all non-blank lines, ignoring empty lines
cat -s # supresses repeated blank lines => replaces multiple consecutive blank lines into single blank line
cat -E # shows $ at the end of each line, making line boundaries visible
# copy file or dir
cp #[options] [source] [destination]
cp helloworld.txt /home/johndoe/ # copies the helloworld.txt file into johndoe directory without overwriting the original file
cp helloworld.txt helloworld1.txt # creates a new helloworld1.txt file and copies the helloworld.txt file contents into the new destination file
# you can also use multiple sources with destination at the end
cp helloworld.txt helloworld1.txt /home/johndoe/ # copies both files into destination dir and replaces existing files with the same filename
cp -n # prevents overwriting of existing destination files
cp -i # interactive mode => if some file is going to be overwritten, the cmdline asks you before overwriting it
# use . to say pwd
# go 1 step back in directory tree by using ../
cp ../somefile1.txt ../somefile2.txt . # copies both files into pwd
# recursive copying => directory that contains files cannot be copied into an new unexisting directory
cp somedir1 somedir3 # error -> omits somedir1
cp -r somedir1 somedir3 # successfully recursively copies somedir1 with it's contents into somedir3
# let's break it down... somedir1 cannot be copied into a new unexisting dir because it first need to transfer the somedir1 into somedir3, and then transfer the files
cp -vR somedir1 somedir3 # -v for verbose:
# 'somedir1' -> 'somedir3/somedir1'
# 'somedir1/somefile1.txt' -> 'somedir3/somedir1/somefile1.txt'
# 'somedir1/somefile2.txt' -> 'somedir3/somedir1/somefile2.txt'
# see memory usage by process
top
# see memory usage in machine-friendlier format (batch mode)
top -b
# search simple text in file contents
grep # [searched_text] [filepath]
grep DELETE fake_webserver_logs.txt
# pipeline cat to grep
cat fake_webserver_logs.txt | grep DELETE
# look for all occurences of divs in all html files in pwd
grep div *.html
# note that grep prints the whole lines in which the looked-for term occurs
# we can print the count by using the -c option
grep div *.html -c
# case insensitive search
grep div *.html -i
# every line that doesn't match the searched term
grep div *.html -v
# count of unmatching lines
grep div *.html -vc
# the -x option searches for absolute matches => the whole line must match with the searched term
grep -x "</html>" *.html
# the -w flag searches for whole matches, so "div" won't match when we're looking for the term "iv"
grep iv *.html # outputs the lines with "div" because it contains "iv"
grep -w iv *.html # outputs only lines with "iv", so "div" doesn't count
# practical use of grep => looking for -a flag in lsof manual:
man lsof | grep '-a' # results in an error, because the syntax is wrong - grep doesn't have an -a flag
man lsof | grep -- '-a' # explicitly state that you are not passing any flags and that -a is the searched term => successfully looks for occurences of -a in man lsof
# print 3 lines BEFORE the line containing "iv"
grep -w -B 3 iv *.html
# -B [num] prints [num] lines BEFORE
# -A [num] prints [num] lines AFTER
# -C [num] prints [num] lines both BEFORE and AFTER
grep '^FROM' # ^ prints the line that starts with FROM, not lines that contain FROM but not at the start of the line
grep '80$' # $ prints the line that ends with 80, not lines that contain 80 but not at the end of the line
# also we can use these two together + the asterisk
cat index.html | grep '^.*$' # prints all lines
cat index.html | grep '^<.*>$' # prints lines that begin with < and end with >, therefore single elements in the context of html
# look for words that begin with searched term => \b
grep '\biv' *.html # outputs lines that contain a word that begins with "iv"
grep '\bi' *.html # outputs lines that contain a word that begins with "i" (ex. initial, items,..)
# \b is used as a boundary
grep '\b404\b' fake_webserver_logs.txt # same as using the -w flag => looks for delineated 404 occurences
# usage of OR operator
grep '404\|500' fake_webserver_logs.txt # looks for all occurences of 404 OR 500
# or use the -E flag if you dont want to use the backslash to escape the | operator
grep -E '404|500' fake_webserver_logs.txt
# search for 4xx by using range of digits [0-9] (regex)
grep '.4[0-9][0-9]' fake_webserver_logs.txt
# use case for ip addresses
grep -E '([0-9]{3})\.{3}[0-9]{1,3}' fake_webserver_logs.txt # looks for digits 0-9 3 times in a row + escaped dot symbol, and repeats that 3 times (first 3 octets), and then digits 0-9 1, 2 or 3 times in a row (fourth octet)
# awk => data manipulation tool, designed for pattern scanning and processing - both a cmdline utility and a full programming language
ps # displays a snapshot of currently running processes
ps | awk '{print $1}' # prints column 1 (PID)
ps | awk '{print $2}' # prints column 2 (TTY)
ps | awk '{print $0}' # prints ps itself

cat /etc/passwd/ # cats all users on linux system - column-formatted file
# print all usernames in linux system
awk -F ":" '{print $1}' /etc/passwd # -F flag => input field separator (how awk splits each input line into fields, default => whitespace)
awk -F ":" '{print $1 $6 $7}' /etc/passwd # prints columns 1, 6 and 7 using colons as separators
awk -F ":" '{print $1 " " $6 " " $7}' /etc/passwd # puts spaces between that for readability
awk -F ":" '{print $1 "\t" $6 "\t" $7}' /etc/passwd # puts tabs between that for even better readability
# we can use actions to use field separators and insert different field separators
awk 'BEGIN{FS=":"; OFS="-"} {print $1,$6,$7}' /etc/passwd

cat /etc/shells # cats all open shells in my system
# what if i want to print the shell names without the full paths?
awk -F "/" '/^\// {print $NF}' /etc/shells # sets field separatior to "/", matches only lines that start with a slash (^\/) and prints the last field ($NF)
# /.../ => awk's pattern delimiters
# ^\/ => inner regex
awk -F "/" '/^\// {print $NF}' /etc/shells | uniq | sort # by using pipelines, i can sort this even further...

# another column formatted command => df => reports the amount of available and used disk space on file systems (disk-free)
df | awk '/\/dev\/nvme/ {print $1"\t"$2"\t"$3}' # pipe df into awk => look for /dev/nvme and print the first 3 columns with tabs inbetween
df | awk '/\/dev\/nvme/ {print $1"\t"$2 + $3}' # i can perform arithmetic operations on the columns

# i just found a cool command => "cd ../" sets you back by 1 step in the file tree

# you can filter the results by length of the line itself
cat /etc/shells
awk 'length{$0} > 7' /etc/shells # print lines that are longer than 7 characters
awk 'length{$0} <= 7' /etc/shells # print lines that are shorter than or equal to 7 characters
# list all processes (ps -e) in a full format (-f)
ps -ef
ps -ef | awk '{ if($NF == "/bin/bash") print $0}' # print every process that is running on bash

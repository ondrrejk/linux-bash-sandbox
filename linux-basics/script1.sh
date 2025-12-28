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

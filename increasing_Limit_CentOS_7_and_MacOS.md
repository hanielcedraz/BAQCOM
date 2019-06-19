# Increasing File limits (Cent OS 7 and macOS)
Operating systems (Linux and macOS included) have settings which limit the number of files and processes that are allowed to be open. This limit protects the system from being overrun. But its default is usually set too low, when machines had way less power. Thus a “gotcha” that is only apparent when “too many files open” crashes appear only under load (as in during a stress test or production spike).


# On CentOS 7
    # Commands require root access

## Find the default limit – check the open files line – it will be 1024
    $ sudo ulimit -a

## To increase edit nano /etc/sysctl.conf add the below line, save and exit
    fs.file-max = 100000

## We also need to increase hard and soft limits
  #Edit /etc/security/limits.conf add the below lines before the "#End of file" line, save and exit

    * soft nproc 65535
    * hard nproc 65535
    * soft nofile 65535
    * hard nofile 65535

## Next run the command
    $ sudo sysctl -p

Font: https://naveensnayak.com/2015/09/17/increasing-file-descriptors-and-open-files-limit-centos-7/ 

<br>
<br>
<br>

# On macOS

## Obtain the current limit:
    $ launchctl limit maxfiles

## The response output should have numbers like this:
    # maxfiles    65536          200000

    # The first number is the “soft” limit and the second number is the “hard” limit.

## Configuration changes are necessary if lower numbers are displayed, such as:

    # maxfiles    256            unlimited
    
## If the soft limit is too low (such as 256), set the current session to:

    $ sudo launchctl limit maxfiles 65536 200000
    
    # Some set it to 1048576 (over a million).


Font: https://wilsonmar.github.io/maximum-limits/


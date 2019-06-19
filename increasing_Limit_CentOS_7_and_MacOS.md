# Increasing File Descriptors and Open Files Limit on CentOS 7

Some programs like Apache and MySQL require a higher number of file descriptors.
This is how you can increase that limit for all users in CentOS 7
Commands require root access

## Find the default limit – check the open files line – it will be 1024
    $ sudo ulimit -a

## To increase edit nano /etc/sysctl.conf add the below line, save and exit
    fs.file-max = 100000

## We also need to increase hard and soft limits
  #Edit /etc/security/limits.conf add the below lines before the "#End of file", save and exit

    * soft nproc 65535
    * hard nproc 65535
    * soft nofile 65535
    * hard nofile 65535

## Next run the command
    $ sudo sysctl -p



# Increasing File Descriptors and Open Files Limit on macOS
## Obtain the current limit:
    $ launchctl limit maxfiles

## The response output should have numbers like this:
    maxfiles    65536          200000

    The first number is the “soft” limit and the second number is the “hard” limit.

## Configuration changes are necessary if lower numbers are displayed, such as:

    maxfiles    256            unlimited
    
## If the soft limit is too low (such as 256), set the current session to:

    $ sudo launchctl limit maxfiles 65536 200000
    
    Some set it to 1048576 (over a million).




Font: https://naveensnayak.com/2015/09/17/increasing-file-descriptors-and-open-files-limit-centos-7/ <br>
Font: https://wilsonmar.github.io/maximum-limits/ - macOS and others


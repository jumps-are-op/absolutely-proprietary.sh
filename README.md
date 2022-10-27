# ABSOLUTELY PROPRIETARY.sh

Shell script to find ABSOLUTELY PROPRIETARY packages for arch-based distros. Compares your installed packages against Parabola's package [blacklist](https://git.parabola.nu/blacklist.git/plain/blacklist.txt) and [aur-blacklist](https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt) and then prints your Stallman Freedom Index (free/total).

# Original creator
[absolutely-proprietary.sh](https://github.com/jumps-are-op/absolutely-proprietary.sh)
is rewrite of
[absolutely-proprietary](https://github.com/vmavromatis/absolutely-proprietary)
in fast POSIX shell instead of slow python

Difference between this and Vasilis Mavromatis's program
* caching and ability to disable it
* ability to ignore libre/ repo packages
* ability to save output list as text, markdown, and html at the same time
* POSIX complaint script
* VERY FAST SPEED

# Install
```
git clone https://github.com/jumps-are-op/absolutely-proprietary.sh.git
cd absolutely-proprietary.sh
```
# Update
```
cd absolutely-proprietary.sh
git pull https://github.com/jumps-are-op/absolutely-proprietary.sh.git
```
# Run
```
./absolutely-proprietary.sh [arguments]
```

Explanation of terms:
- *nonfree*: This package is blatantly nonfree software.
- *semifree*: This package is mostly free, but contains some nonfree software.
- *uses-nonfree*: This package depends on, recommends, or otherwise inappropriately integrates with other nonfree software or services.

# Help
```
[jumps@logic]$ absolutely-proprietary.sh --help

absolutely-proprietary.sh  Shell script to find ABSOLUTELY PROPRIETARY packages
Copyright (C) 2022 jumps are op
This software is under GPLv3 and comes with ABSOLUTE NO WARRANTY

USAGE: absolutely-proprietary.sh [-flS] [-n|-c] [-s file] [-m file] [-h file]

OPTIONS:
 -f, --full          Print any proprietary packages, not just nonfree.
                     this include (but not limited to) semifree, uses-nonfree,
                     branding, antifeatures.
 -l, --nolibrerepo   Execlude any package from libre/ repo when sreaching.
 -S, --sync          Sync blacklist files (disable cache).
 -s, --save file     Save output list into `file'.
 -m, --markdown file Save output list into `file' as markdown format.
 -h, --html file     Save output list info `file' as html format.
 -c, --color         Add color to output.
 -n, --nocolor       Do not add color to output.

if neither of -c or -n is specifed, auto terminal dectection will be used.
```
# Example output
```
[jumps@logic]$ absolutely-proprietary.sh -f

Retrieving local packages (including AUR)...
Downloading blacklist.txt...
Downloaded blacklist.txt. (cache)
Downloading aur-blacklist.txt...
Downloaded aur-blacklist.txt. (cache)
Comparing local packages to remote...
=================================================
7 ABSOLUTELY PROPRIETARY PACKAGES INSTALLED
=================================================

Your GNU/Linux operating system is infected with 7 proprietary packages
out of 1320 total installed.
Your Stallman Freedom Index is 99.5.

+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| Name                 | Status             | Libre Alternative          | Description                                              |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| filesystem           | FIXME:description  | libre/filesystem           |                                                          |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| gst-plugins-bad-libs | uses-nonfree       | libre/gst-plugins-bad-libs | depends on nonfree package faac                          |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| java-runtime-common  | FIXME:description  | libre/java-runtime-common  |                                                          |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| licenses             | uses-nonfree       | libre/licenses             | Remove non-free CC -NC and -ND licenses (also add WTFPL) |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| syslinux             | FIXME:description  | libre/syslinux             |                                                          |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| systemd              | recommends-nonfree | libre/systemd              | Say GNU/Linux, use FSDG distros as examples              |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
| unzip                | semifree           | libre/unzip                | contains a source file that doesn't mention modification |
+----------------------+--------------------+----------------------------+----------------------------------------------------------+
```

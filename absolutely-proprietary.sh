#!/bin/sh
# shellcheck disable=SC2059

# Made by jumps-are-op
# This software is under GPLv3 and comes with ABSOLUTE NO WARRANTY

main(){
	set -e
	color=1
	while [ $# != 0 ];do
		case $1 in
			--full)full=1;;
			--nolibrerepo)nolibrerepo=1; librerepo=$(pacman -Slq libre);;
			--sync)nocache=1;;
			--save)shift; savefile=$1;;
			--markdown)shift; markdownfile=$1;;
			--html)shift; htmlfile=$1;;
			--color)color=2;;
			--nocolor)color=0;;
			--help)
				cat >&2 <<-EOF
${0##*/}  Shell script to find ABSOLUTELY PROPRIETARY packages
Copyright (C) 2022 jumps are op
This software is under GPLv3 and comes with ABSOLUTE NO WARRANTY

USAGE: ${0##*/} [-flS] [-n|-c] [-s file] [-m file] [-h file]

OPTIONS:
 -f, --full          Print any proprietary packages, not just nonfree.
                     this include (but not limited to) semifree, uses-nonfree,
                     branding, antifeatures.
 -l, --nolibrerepo   Execlude any package from libre/ repo when sreaching.
 -S, --sync          Sync blacklist files (disable cache).
 -s, --save file     Save output list into \`file'.
 -m, --markdown file Save output list into \`file' as markdown format.
 -h, --html file     Save output list info \`file' as html format.
 -c, --color         Add color to output.
 -n, --nocolor       Do not add color to output.
				
if neither of -c or -n is specifed, auto terminal dectection will be used.
				EOF
				exit 1
			;;
			-*)
				first=${1#-}
				while [ "$first" != "" ];do
					case ${first%"${first#?}"} in
						f)full=1;;
						l)nolibrerepo=1; librerepo=$(pacman -Slq libre);;
						S)nocache=1;;
						s)
							first=${first#s}
							[ "$first" = "" ] && shift
							savefile=${first:-$1}
							first=
						;;
						m)
							first=${first#m}
							[ "$first" = "" ] && shift
							markdownfile=${first:-$1}
							first=
						;;
						h)
							first=${first#h}
							[ "$first" = "" ] && shift
							htmlfile=${first:-$1}
							first=
						;;
						c)color=2;;
						n)color=0;;
						*)
						echo "$0: -${first%"${first#?}"}: Invalid argument" >&2
						exit 1
						;;
					esac

					first=${first#?}
				done
			;;
			*)
				echo "$0: $1: Invalid argument" >&2
				exit 1
			;;
		esac

		[ $# = 1 ] && break
		shift
	done

	[ "$color" = 1 ] && [ -t 1 ] && istty=yes
	[ "$color" = 2 ] && istty=yes
	RED=${istty+[0;31m}
	GREEN=${istty+[0;32m}
	YELLOW=${istty+[0;33m}
	RESET=${istty+[0m}

	set -- https://git.parabola.nu/blacklist.git/plain/blacklist.txt \
			a-blacklist.txt \
		https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt \
			b-aur-blacklist.txt

	echo "Retrieving local packages (including AUR)..."
	cachedir="${XDG_CACHE_HOME:-${HOME:-.}/.cache}/absolutely-proprietary.sh"
	mkdir -p -- "$cachedir"

	while [ $# != 0 ];do
		printf "Downloading %s..." "${2#??}"
		if [ "$nocache" != 1 ] &&
			[ -e "$cachedir/$2" ] &&
			[ "$(find "$cachedir/$2" -atime +1 2>/dev/null || true)" = "" ];then
			printf "\rDownloaded %s. (cache)\n" "${2#??}"
		else
			wget "$1" -O "$cachedir/$2" 2>/dev/null
			printf "\rDownloaded %s.   \n" "${2#??}"
		fi

		[ $# -le 2 ] && break
		shift 2
	done

	blacklistedpackages=$(
	sed 's/^[\s]*#//g;s/:.*/\\|/g;s/\\|$/$\\|/g;s/^/\^/g' "$cachedir"/* |
		tr -d '\n' )
	blacklistedpackages=${blacklistedpackages%??}

	echo "Comparing local packages to remote..."
	packages=$(pacman -Qq)
	total=$(echo "$packages" | wc -l)
	proprietary=0
	longestpackage="Name"
	longestreason="Status"
	longestalt="Libre Alternative"
	longestdescription="Description"
	set --
	while read -r package;do
		# skip pacman packages
		[ "${package#pacman}" != "$package" ] && continue

		# check if package is in libre/ repo
		[ "$nolibrerepo" = 1 ] && echo "$librerepo" | grep "^$package$" -q &&
			continue

		# get package info
		info=$(grep "^$package:" "$cachedir"/* | head -n 1)
		info=${info#*:}

		# check reason
		reason=${info##*[}
		reason=${reason%%]*}
		[ "$reason" = technical ] && continue

		proprietary=$((proprietary+1))
		[ "$full" != 1 ] && [ "$reason" != nonfree ] && continue
		displayedpackage=1

		alt=${info#*:}
		alt=${alt%%:*}
		[ "$alt" = "$package" ] && alt=libre/$alt
		description=${info##*]}
		description=${description# }

		[ "${#longestpackage}" -lt "${#package}" ] &&
			longestpackage=$package
		[ "${#longestreason}" -lt "${#reason}" ] &&
			longestreason=$reason
		[ "${#longestalt}" -lt "${#alt}" ] &&
			longestalt=$alt
		[ "${#longestdescription}" -lt "${#description}" ] &&
			longestdescription=$description

		set -- "$@" "$package" "$reason" "$alt" "$description"
	done <<-EOF
		$(echo "$packages" | grep "$blacklistedpackages" || true)
	EOF

	osname=$(uname -o) || osname=GNU/Linux
	if [ "$proprietary" != 0 ];then
		freedomindex=$((100 - (proprietary*100/total)))
		if [ "$freedomindex" -gt 95 ];then
			color=$GREEN
		elif [ "$freedomindex" -gt 25 ];then
			color=$YELLOW
		else
			color=$RED
		fi
	
		freedomindex=$(echo "scale=3;100 - $proprietary/$total*100" | bc)
		freedomindex=${freedomindex%?}
		freedomindex=${freedomindex%0}
		freedomindex=${freedomindex%0}
		freedomindex=${freedomindex%.}
		if [ "$displayedpackage" ];then
			printf "%s%$((${#freedomindex}+45))s\n" "$color" | tr ' ' '='
			echo   "$proprietary ABSOLUTELY PROPRIETARY PACKAGES INSTALLED"
			printf "%$((${#freedomindex}+45))s\n$RESET" | tr ' ' '='
			setterm -linewrap off
			printlist "$proprietary" "$total" "$osname" "$freedomindex" \
				${#longestpackage} ${#longestreason} ${#longestalt} \
				${#longestdescription} \
				"name" "status" "libre alternative" "description" "$@"
			setterm -linewrap on
		else
			cat <<-EOF

It seems to be no \`nonfree' packages,
You can display the other $proprietary proprietary packages with -f or --full.
For more info see --help.
			EOF
		fi
	else
		printlist 0 "$total" "$osname"
	fi
	echo
	color=
	RESET=

	if [ "$savefile" != "" ];then
		printlist "$proprietary" "$total" "$osname" "$freedomindex" \
		${#longestpackage} ${#longestreason} ${#longestalt} \
		${#longestdescription} \
		"Name" "Status" "Libre Alternative" "Description" "$@" >"$savefile"
		echo "list saved to \`$savefile'."
	fi

	if [ "$markdownfile" != "" ];then
		printmarkdownlist "$proprietary" "$total" "$osname" "$freedomindex" \
		"Name" "Status" "Libre Alternative" "Description" "$@" >"$markdownfile"
		echo "list saved to \`$markdownfile' as markdown."
	fi

	if [ "$htmlfile" != "" ];then
		printhtmllist "$proprietary" "$total" "$osname" "$freedomindex" \
		"Name" "Status" "Libre Alternative" "Description" "$@" >"$htmlfile"
		echo "list saved to \`$htmlfile' as html."
	fi
}

# print $@ as a list
# $1  number of absolutely proprietary packages
# $2  number of total packages
# $3  is operating system name
# $4  is freedom index
# $5  throw $8  is headers length
# $9  throw $12 is headers for the list
# $13 throw $@  is the body of the list
printlist(){
	if [ "$1" = 0 ];then
		cat <<-EOF

			You have 0 proprietary packages from $2 total packages.
			Your system is 100% free software.
			Thank you for using a free $3 operating system.
		EOF
		return
	fi

	cat <<-EOF
Your $3 operating system is infected with $color$1$RESET proprietary packages
out of $color$2$RESET total installed.
Your Stallman Freedom Index is $color$4$RESET.

	EOF

	len1=$5
	len2=$6
	len3=$7
	len4=$8

	sep=$(printf "+-%${len1}s-+-%${len2}s-+-%${len3}s-+-%${len4}s-+\\\\n" |
		tr ' ' '-')
	printf "$sep"

	shift 8
	printf "| %-${len1}s | %-${len2}s | %-${len3}s | %-${len4}s |\n$sep" "$@"
}

# print $@ as a markdown list
# $1 number of absolutely proprietary package
# $2 number of total packages
# $3 is operating system name
# $4 is freedom index
# $5 throw $8 is headers for the list
# $9 throw $@ is the body of the list
printmarkdownlist(){
	if [ "$1" = 0 ];then
		cat <<-EOF
			# You have 0 proprietary packages from $2 total packages.
		EOF
		return
	fi

	cat <<-EOF
# List of $1 ABSOLUTELY PROPRIETARY INSTALLED PACKAGES, From $2 total packages.
 Your $3 operating system is infected with $1 proprietary packages. 
 Your Stallman Freedom Index is $4.

|$5|$6|$7|$8|
|-|
	EOF

	[ $# -le 8 ] && return 0
	shift 8
	
	printf "|%s|%s|%s|%s|\n" "$@"
}

# print $@ as a html list
# $1 number of absolutely proprietary package
# $2 number of total packages
# $3 is operating system name
# $4 is freedom index
# $5 throw $8 is headers for the list
# $9 throw $@ is the body of the list
printhtmllist(){
	if [ "$1" = 0 ];then
		cat <<-EOF
			<h1>You have 0 proprietary packages from $2 total packages.</h1>
		EOF
		return
	fi

	cat <<-EOF
		<h1>List of $1 ABSOLUTELY PROPRIETARY INSTALLED PACKAGES,
		From $2 total installed.
		Your $3 operating system is infected with $1 proprietary packages.
		Your Stallman Freedom Index is $4</h1>

		<table><thead>
		<tr><th>$5</th><th>$6</th><th>$7</th><th>$8</th></tr>
		</thead></table>
	EOF

	[ $# -le 8 ] && return
	shift 8

	echo "<tbody><table>"
	printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n" "$@"
	echo "</tbody></table>"
}

main "$@"

#!/usr/bin/env bash

#LICENSE: BSD see LICENSE file




##################vars
cur_step_read=-1;
MAX_LINES=10
MAX_LONG_LINE=80
ai_step_file="/tmp/ai-helper-step"

################## init #############

LAST_STEP=3

script_dir="$(realpath "$(dirname "$0")")"
translate_dict=""


###hacky, cleaner way needed
if [ ! -f "$ai_step_file" ] || [[ "$(cat "$ai_step_file")" = "" ]] || [[ "$(cat "$ai_step_file")" = "-1" ]]; then
  echo 1 > "$ai_step_file"
fi
if [ -e "$script_dir/po" ]; then
TEXTDOMAINDIR="$script_dir/po"

fi
########################### init-end ###################


help()
{
	echo "Welcome to the step by step install guide"
	echo "Usage:"
	echo "  next: continue one step forwards"
	echo "  back: go one step back"
	echo "  repeat: repeat current step"
	echo "  reset: begin from begin"
	echo "  set <step>: go to step"
}

############################
##print text 
# $1 for text
print_text()
{
	text_o="$1"
	if [[ "$(echo "$text_o" | wc -l)" -le "$MAX_LINES"  ]] && [[ "$(echo "$text_o" | wc -L)" -le "$MAX_LONG_LINE"  ]];then
		echo "$1"
	else
		echo "$1" | less
	fi
	
}


###################

######### steps ###########




step_1()
{
text='Step one (or feel comfortable)
We begin with some adjustments to the install environment

To change the keyboard layout, use: loadkeys <layoutcode> e.g. loadkeys de
To change locale, use: export LANG="<lang>"
'
print_text "$text"
	
}

step_2()
{
	echo "Second step (or example)"
	
}


step_3()
{
	echo "Would be nice to fill these steps so beginners have a good guide"
	
}
####### steps-end #########

#######contains name of step for search

declare -A insteps
insteps=(
["prep"]=1
["lvm"]=2




)




#gruelsome code
#$1 string to verify, returns 1 if false else 0 but this doesn't work so fall back to  cur_step_read=-1
sanitized_input()
{
	tmp_verify=$(echo "$1" | grep -o "^-\?[0-9]\+")
	
	if [ "$tmp_verify" = "" ]; then
		echo "Error: No number could be read from input"
		cur_step_read=-1
		return 1
	fi
	
	if [[ $tmp_verify -lt 1 || $tmp_verify -gt $LAST_STEP ]] ; then

		echo "Error: step out of range"
		cur_step_read=-1
		return 1
	fi
	
	cur_step_read=$tmp_verify
	return 0
	
}


#reads file into internal variable
read_in()
{
	sanitized_input "$(cat "$ai_step_file")"
	if [[ "$cur_step_read" = "-1" ]] ; then
		echo "Error: Fileinput error"
		exit 1
	fi
	
	#return $cur_step_read
}

#writes internal navigation variable into file
write_in_file()
{
	echo "$cur_step_read" > "$ai_step_file"
	return
}

cur_step()
{
	read_in
	case $cur_step_read in
		1)step_1;;
		2)step_2;;
		3)step_3;;
		*)echo  "Error: step not implemented";;
	esac
	return
	
}


for_step()
{
	read_in
	if [ "$cur_step_read" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	if [[ $cur_step_read -ge $LAST_STEP ]]; then
		echo "Error: Already at the end of installation progress"
		exit 1
	else
		((cur_step_read+=1))
	fi
	
	write_in_file
	cur_step
	return
}

back_step()
{
	read_in
	if [ "$cur_step_read" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	
	if [[ $cur_step_read -le 1 ]]; then
		echo "Error: Already at the begin of installation progress"
		exit 1
	else
		((cur_step_read-=1))
	fi
	write_in_file
	cur_step
	return
}


user_set_step()
{
	if [ "$2" = "" ]; then
		echo "The steps ranges from 1 to $LAST_STEP"
		exit 1
	fi
	
	sanitized_input "$2"
	if [[ "$cur_step_read" = "-1" ]] ; then
		echo "Error: step invalid"
		exit 1
	else
		write_in_file
		cur_step
	fi
	return
}


userinput()
{
	text_user="$1"
	
	case "$text_user"  in
		"next")for_step;;
		"repeat"|"") cur_step;;
		"back")back_step;;
		"reset") cleanup;;
		"set") user_set_step $*;;
		*) help;;
	esac
		
	return
	
}



cleanup()
{

rm "$ai_step_file" > /dev/null
}


userinput $@


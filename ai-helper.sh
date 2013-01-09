#!/usr/bin/env bash

cur_step_read=-1;
LAST_STEP=1

ai_step_file="/tmp/ai-helper-step"

help()
{
	echo "Welcome to the step for step install guide"
	echo "Usage:"
	echo "  next: continue one step forwards"
	echo "  back: go one step back"
	echo "  repeat: repeat current step"
	echo "  reset: begin from begin"
	echo "  set <step>: go to step"
}



######### steps ###########




step_1()
{
	echo "Step one (or feel comfortable)"
	echo "We begin with some adjustments to the install environment"
	echo ""
	echo "To change the keyboard layout, use: loadkeys <layoutcode> e.g. loadkeys de"
	echo "To change locale, use: export LANG=\"<lang>\""
	
}


####### steps-end #########

#reads file into internal variable
read_in()
{
	if ! tmp_read_step="$(grep -o "^[0-9]*" "$ai_step_file")"; then
		echo "Error: Fileinput error"
		exit 1
	fi
	
	if [ "$tmp_read_step" = "" ]; then
		echo "Error: No number could be read from file ($ai_step_file)"
	fi
	
	if [[ $tmp_read_step -lt 1 || $tmp_read_step -gt $LAST_STEP ]] ; then

		echo "Error:  read step out of range"
		exit 1
	fi
	
	cur_step_read=$tmp_read_step
	#return $cur_step_read
}

#writes internal navigation variable into file
write_in_file()
{
	echo "$cur_step_read" > "$ai_step_file"
}

cur_step()
{
	case $cur_step_read in
		1)step_1;;
		
		*)help;;
	esac
	
	
}


for_step()
{
	if [ "$cur_step_read" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	if [[ $cur_step_read -ge $LAST_STEP ]]; then
		echo "Error: Already at the End"
		exit 1
	else
		((cur_step_read+=1))
	fi
	
	write_in_file
	cur_step
}

back_step()
{
	
	if [ "$cur_step_read" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	
	if [[ $cur_step_read -le 1 ]]; then
		echo "Error: Already at the begin"
		exit 1
	else
		((cur_step_read-=1))
	fi
	write_in_file
	cur_step
}


user_set_step()
{
	if [ "$2" = "" ]; then
		echo "The steps ranges from 1 to $LAST_STEP"
		exit 1
	fi
	if [[ "$2" = "" ]] || echo "$2" | grep -q "[[:alpha:]]" ; then
		echo "Error: not a valid step"
		exit 1
	fi
	
	if [[ $2 -lt 1 || $2 -gt LAST_STEP ]]; then
		echo "Error: step out of range"
		exit 1
	fi
	cur_step_read=$2
	write_in_file
	cur_step
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
		
	
	
}

init()
{
if [ ! -e "$ai_step_file" ]; then
  echo 1 > "$ai_step_file"
fi
read_in
}


cleanup()
{

rm "$ai_step_file" > /dev/null
}

init
userinput $@


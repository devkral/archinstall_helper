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
	if ! tmp_read_step="$(cat "$ai_step_file")"; then
		cur_step_read=-1
	fi
	
	if [[ !'' && *[0-9]* ]] ; then
		cur_step_read=$tmp_read_step
	else
		cur_step_read=-1
	fi
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



userinput()
{
	text_user="$1"
	echo "$text_user"
	
	case "$text_user"  in
		"next")for_step;;
		"repeat"|"") cur_step;;
		"back")back_step;;
		"reset") cleanup;;
		"set") echo "$2" > "$ai_step_file";read_in; cur_step ;;
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


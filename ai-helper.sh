#!/usr/bin/env bash

cur_step_read=-1;
ai_step_file="/tmp/ai-helper-step"

help()
{
	echo "Welcome to the step for step install guide"
	echo "Usage:"
	echo "  next: continue one step forwards"
	echo "  last: go one step back"
	echo "  repeat: repeat current step"
	echo "  reset: begin from begin"
	echo "  set <step>: go to step"
}

init()
{
if [ ! -e "$ai_step_file" ]; then
  echo 0 > "$ai_step_file"
fi

}


cleanup()
{

rm "$ai_step_file" > /dev/null
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
	read_in
	if [ "$(read_step)" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	((cur_step_read+=1))
	write_in_file
	cur_step
}

back_step()
{
	read_in
	if [ "$(read_step)" = "-1" ]; then
		echo "Error: invalid step."
		cleanup
	fi
	
	((cur_step_read-=1))
	write_in_file
	cur_step
}



userinput()
{
	case read  in
		"next")for_step;;
		"repeat") cur_step;;
		"back")back_step;;
		"reset") cleanup;;
		"set") echo "$2" > "$ai_step_file"; cur_step ;;
		*) help;;
	esac
		
	
	
}
userinput


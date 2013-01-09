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

#$1 string to verify, returns 1 if false else 0
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
		
		*)help;;
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

init()
{
if [ ! -f "$ai_step_file" ] || [[ "$(cat "$ai_step_file")" = "" ]] || [[ "$(cat "$ai_step_file")" = "-1" ]]; then
  echo 1 > "$ai_step_file"
fi

}


cleanup()
{

rm "$ai_step_file" > /dev/null
}

init

userinput $@


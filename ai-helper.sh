#! /usr/bin/env bash

cur_step_read=-1
ai_step_file="/tmp/ai-helper-step"

help()
{
	print("Welcome to the step for step install guide")
	print("Usage:")
	print("  next: continue one step forwards")
	print("  last: go one step back")
	print("  repeat: repeat current step")
	print("  reset: begin from begin")
	print("  set: go to step")
	print("  lang <language>: set install guide's language (not implemented yet)")
}

init()
{
if [ ! -e "$ai_step_file" ]; then
  touch "$ai_step_file"
fi

}


cleanup()
{

rm "$ai_step_file" > /dev/null
}

######### steps ###########




step_1()
{
	print("Step one (or feel comfortable)")
	print("We begin with some adjustments to the install environment")
	print()
	print("To change the keyboard layout use: loadkeys <layoutcode> e.g. loadkeys de")
	
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
	case($cur_step_read) in
		1)step_1();
		
		*)
	esac
	
	
}


for_step()
{
	read_in
	if [ "$(read_step)" = "-1" ]; then
		print("Error: invalid step.")
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
		print("Error: invalid step.")
		cleanup
	fi
	
	((cur_step_read-=1))
	write_in_file
	cur_step
}



userinput()
{
	case(read) in
		"next")for_step;;
		"repeat") cur_step();;
		"back")back_step;;
		"reset") cleanup;;
		"set") echo "$2" > "$ai_step_file"; cur_step() ;;
		"lang")printf("Not implemented yet");;
		*) help;;
	esac
		
	
	
}



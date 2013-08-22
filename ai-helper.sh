#!/usr/bin/env bash

#LICENSE: BSD see LICENSE file




################# vars ##############
cur_step_read=-1;
MAX_LINES=10
MAX_LONG_LINE=80
ai_step_file="/tmp/ai-helper-step"

#### locale
export TEXTDOMAINDIR="123replacemedestdir321/share/locale/"
export TEXTDOMAIN="archinstall_helper"
#### locale-end

################## init #############

###create file if it doesn't exist
if [ ! -f "$ai_step_file" ] || [[ "$(cat "$ai_step_file")" = "" ]]; then
  echo "0" > "$ai_step_file"
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
  echo "  index: index with topics"
  echo "  set <step>: go to step"
}

############################
##print text 
# $1 for text, $2 for text which wont be put into gettext
print_text()
{
  text_o="$1:\n$(gettext -s "$1")"
  if [ "$2" != "" ]; then
   text_o="${text_o}\n---\n$2"
  fi
	
  if [[ "$(echo "$text_o" | wc -l)" -le "$MAX_LINES"  ]] && [[ "$(echo "$text_o" | wc -L)" -le "$MAX_LONG_LINE"  ]];then
    echo -e "$text_o"
  else 
    echo -e "$text_o" | less
  fi
	
}


###################

#######contains name of step for search

#declare -a insteps
insteps=(
"prepare"
"network"
"partitioning"
"crypto"
"lvm"
"filesystems"
"mount"
"install"
"chroot"
"fine-tuning"
"cleanup"

)

# $1 search term echo number or -1
search()
{
  if [ "$1" != "" ]; then
    for (( tempa=0; tempa<${#insteps[@]}; tempa+=1 )); do
      if echo "${insteps[$tempa]}" | grep -q "$1"; then
        echo "$tempa"
        return 0
      fi
    done
  fi
  echo "-1"
  return 2
}


index()
{
  for (( tempa=0; tempa<${#insteps[@]}; tempa+=1 )); do
    echo "$tempa: ${insteps[$tempa]}"
  done
}


#$1 string to verify, returns 1 if false else 0 but this doesn't work so fall back to  cur_step_read=-1
sanitized_input()
{
  tmp_verify="$(echo "$1" | grep -o "^-\?[0-9]\+")"

  if [ "$1" = "" ]; then
    return 3
  fi

  if [ "$tmp_verify" = "" ]; then
    tempnew="$(search "$1")"
    if [ "$tempnew" -ge "0" ]; then
      echo "$tempnew"
      return 0
    fi
    echo "Error: No valid step could be read from input" >&2
    return 2
  fi
	
  if [[ $tmp_verify -lt 0 || $tmp_verify -gt ${#insteps[@]} ]] ; then

    echo "Error: step out of range" >&2
    return 1
  fi
  echo "$tmp_verify"
  return 0
	
}


#reads file into internal variable
read_in()
{
  cur_step_read="$(sanitized_input "$(cat "$ai_step_file")")"
  readstatus="$?"
  if [[ "$readstatus" = "0" ]] ; then
	echo "$cur_step_read"
	return
  elif [[ "$readstatus" = "0" ]] ; then
	echo "Error: Stepfile empty. Try to fix this" >&2
  else
    echo "Error: File error. Try to fix this" >&2
  fi
  write_in_file "0"
  exit 1
  
}

# writes internal navigation variable into file
# $1 thing to write
write_in_file()
{
  if [ "$1" = "" ]; then
    echo "Error: tried to write something empty"
    exit 1
  fi
  echo "$1" > "$ai_step_file"
  return
}

cur_step()
{
  #read_in
  case "$(read_in)" in
    0)print_text "adjustenvironment"
    echo ""
    help;;
    1)print_text "network";;
    2)print_text "partitioning";;
    3)print_text "crypto";;
    4)print_text "lvm";;
    5)print_text "filesystems";;
    6)print_text "mount";;
    7)print_text "install";;
    8)print_text "chroot";;
    9)print_text "fine-tuning";;
    10)print_text "cleanup";;
  esac
  return
	
}


for_step()
{
  cur_step_read="$(read_in)"
  if [ "$cur_step_read" = "-1" ]; then
    echo "Error: invalid step." >&2
    cleanup
  fi
	
  if [[ $cur_step_read -ge ${#insteps[@]} ]]; then
    echo "Already at the end of installation progress"
    exit 0
  else
    ((cur_step_read+=1))
  fi
  write_in_file "$cur_step_read"
  cur_step
  return
}

back_step()
{
  cur_step_read="$(read_in)"
  if [ "$cur_step_read" = "-1" ]; then
    echo "Error: invalid step." >&2
    cleanup
  fi
	
	
  if [[ $cur_step_read -le 0 ]]; then
    echo "Already at the begin of installation progress"
    exit 0
  else
    ((cur_step_read-=1))
  fi
  write_in_file "$cur_step_read"
  cur_step
  return
}


user_set_step()
{
  if [ "$2" = "" ]; then
    echo "The steps ranges from 0 to $(((${#insteps[@]}-1)))" >&2
    exit 1
  fi

  cur_step_read="$(sanitized_input "$2")"
  if [[ "$cur_step_read" = "-1" ]] ; then
    echo "Error: step invalid" >&2
    exit 1
  else
    write_in_file "$cur_step_read"
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
    "index") index;;
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


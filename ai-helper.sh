#!/usr/bin/env bash

#LICENSE: BSD see LICENSE file




################# vars ##############
cur_step_read=-1;
MAX_LINES=10
MAX_LONG_LINE=80

dynamicdir="/tmp/ai-helper"
ai_step_file="$dynamicdir/ai-helper-step"

#### locale
langfileprefix="lang"
localfiles="123replacemedestdir321/share/ai_helper/${langfileprefix}"
syncurl=""
lang="$(echo "$LANG" | sed -e "s/_.*$//" -e "s/^C$/en/" )"
#### locale-end

################## init #############


### create folder
mkdir -p "$dynamicdir"

###create stepfile if it doesn't exist
if [ ! -f "$ai_step_file" ] || [[ "$(cat "$ai_step_file")" = "" ]]; then
  echo "0" > "$ai_step_file"
fi


########################### init-end ###################

##now done via gettext
help_old()
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
  #text_o="$(gettext -s "$1")"
	text_o="$(cat "$dynamicdir/$langfileprefix/$lang/$1")"
  if [ "$2" != "" ]; then
   text_o="${text_o}\n---\n$2"
  fi
	
  if [[ "$(echo "$text_o" | wc -l)" -le "$MAX_LINES"  ]] && [[ "$(echo "$text_o" | wc -L)" -le "$MAX_LONG_LINE"  ]];then
    echo -e "$text_o"
  else 
    echo -e "$text_o" | less
  fi
	
}

print_info()
{
  echo "$(cat "$dynamicdir/$langfileprefix/$lang/$1")"
	
}

print_error()
{
  echo "$(cat "$dynamicdir/$langfileprefix/$lang/$1")" >&2
	
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
    print_error "ErrorStepformat"
    return 2
  fi
	
  if [[ $tmp_verify -lt 0 || $tmp_verify -gt ${#insteps[@]} ]] ; then

    print_error "ErrorRange"
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
	print_error "ErrorEmptyStep"
  else
    print_error "ErrorFileOther"
  fi
  write_in_file "0"
  exit 1  
}

# writes internal navigation variable into file
# $1 thing to write
write_in_file()
{
  if [ "$1" = "" ]; then
    print_error "ErrorEmptyText"
    exit 1
  fi
  echo "$1" > "$ai_step_file"
}

update_files()
{
  if [ "$syncurl" != "" ] && ping -q -w 1 "$syncurl" > /dev/null; then
	  wget -r -P "$dynamicdir/$lang" -l 1 "$syncurl/*"
	else
		cp -r "$localfiles/*" "$dynamicdir/$lang"

	fi

}

cur_step()
{
  #read_in
  case "$(read_in)" in
    0) update_files
		print_text "adjustenvironment"
    echo ""
    print_text "help";;
    1)print_text "network";;
    2)update_files #update after network is set up
					print_text "partitioning";;
    3)print_text "crypto";;
    4)print_text "lvm";;
    5)print_text "filesystems";;
    6)print_text "mount";;
    7)print_text "install";;
    8)print_text "chroot";;
    9)print_text "fine-tuning";;
    10)print_text "cleanup";;
  esac
}


for_step()
{
  if [[ $cur_step_read -ge ${#insteps[@]} ]]; then
    print_info "InfoEnd"
    exit 0
  else
    ((cur_step_read+=1))
  fi
  write_in_file "$cur_step_read"
  cur_step
}

back_step()
{
  if [[ $cur_step_read -le 0 ]]; then
    print_info "InfoBeginning"
    exit 0
  else
    ((cur_step_read-=1))
  fi
  write_in_file "$cur_step_read"
  cur_step
}


user_set_step()
{
  if [ "$2" = "" ]; then
    echo "InfoRange" "$(((${#insteps[@]}-1)))"
    exit 1
  fi

  cur_step_read="$(sanitized_input "$2")"
  if [[ "$?" = "0" ]] ; then
    write_in_file "$cur_step_read"
    cur_step
  fi
}


reset()
{
  rm "$ai_step_file" > /dev/null
}

userinput()
{
  option_user="$1"
	
  case "$option_user"  in
    "next")for_step;;
    "repeat"|"") cur_step;;
    "back")back_step;;
    "reset") reset;;
    "index") index;;
    "set") user_set_step $*;;
    *) print_text "help";;
  esac	
}


userinput $@


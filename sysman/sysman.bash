#!/bin/bash

if command -v zenity > /dev/null 2>&1; then
  echo "Zenity framework is installed"
  echo "Welcome to LINUX SYSTEM MANAGER"
else
  sudo apt install zenity
fi

status=$(ip link show | grep 2 | awk -F',' '{print $3}')
gateway=$(ip route | grep default | awk '{print $3}')
interface=$(ip link show | grep 2: | awk '{print $2}')
hostname=$(hostname)
ip=$(hostname -I)
mac=$(ip addr show | grep ether | awk '{print $2}')
user_name=$(whoami)
network="Name: $hostname Interface: $interface IP: $ip Gateway: $gateway MAC: $mac Status: $status"
network_info=$(echo -e $network)
selected_user=""


create_1_column_window() {
  local title=$1
  local header=$2
  local body=$3

  zenity --list --width=800 --height=600 --title="$title" \
  --column $header \
  $body
}


create_2_column_window() {
  local title=$1
  local header=$2
  local header_2=$3
  local body=$4

  zenity --list --width=800 --height=600 --title="$title" \
  --column $header --column $header_2 \
  $body
}


create_add_remove_window() {
  local title=$1
  local header=$2
  local input=$3

  get_input=$(zenity --forms --title="$title" \
  --text "$header" \
  --add-entry "$input")
  echo $get_input
}


create_error_message() {
  zenity --error \
  --text "Ops... Something went wrong! This operation has been cancelled"
}


zenity --info --title="LINUX SYSTEM MANAGER" \
  --text="Welcome to linux help manager! 

This program was created for Linux newbies for whom operating system using terminal may be a difficult task. 

In this manager you can create new users and groups in your Linux system. You can also assign appropriate access permissions to files or folders and view network informations. The program allows you to manage users, groups, folders and files without having to enter commands into the terminal. It will also show you some most important informations about your Linux system and current network. 

In Linux you can change the permissions of a file or directory. There are two primary modes for specifying permissions with chmod: numeric mode and symbolic mode. 

Numeric mode involves using a three-digit octal (base-8) representation to specify the permissions for user, group, and others: Read (r): 4, Write (w): 2, Execute (x): 1. 

Example: 640 file_name. 


Symbolic mode in chmod allows you to modify file permissions using symbols and operators. 

Example: -rw-r--r-- 1 user group 0 Dec 24 12:00 example_file.txt. 


We hope you will enjoy using this manager!"

while true;
do
  choose_option=$(create_1_column_window "LINUX SYSTEM MANAGER" "choose~option" "Network~Info Group~Management User~Management Folder~Management")

  #Network Info
  if [ "$choose_option" == "Network~Info" ]; then
    create_2_column_window "Network Information" "Title" "Description" "$network_info"

  #Group Management
  elif [ "$choose_option" == "Group~Management" ]; then
    choose_option2=$(create_1_column_window "Group Management" "Choose" "Group~Add Group~Delete Group~List~&~Group~View Group~Modify")

    #Group Add
    if [ "$choose_option2" == "Group~Add" ]; then
      group_name=$(create_add_remove_window "Add new group" "You are adding new group" "Choose name")
      out_put=$(sudo groupadd "$group_name" 2>&1)
      if [ $? == 0 ]; then
        zenity --info --text="SUCCESS. New group $group_name added."
      else
        echo "$out_put" > /dev/null
        zenity --info --text="No name entered"
      fi

    #Group Delete
    elif [ "$choose_option2" == "Group~Delete" ]; then
      group_name=$(create_add_remove_window "Delete group" "You are removing existing group" "Choose group you want to remove")
      oudput=$(sudo groupdel -f "$group_name" 2>&1)
      if [ $? == 0 ]; then
        zenity --info --text="SUCCESS. Group $group_name deleted"
      else
        echo "$oudput" > /dev/null
        zenity --info --text="This group does not exist!"
      fi

    #Group List & Group View
    elif [ "$choose_option2" == "Group~List~&~Group~View" ]; then
      group_list=$(awk -F':' '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group)
      selected_group=$(create_1_column_window "Group List" "Group~Name" "$group_list")
      if [ -z "$selected_group" ]; then
        continue
      fi
      selected_group_name=$(getent group $selected_group | cut -d: -f1)
      selected_group_users=$(getent group $selected_group | cut -d: -f4)
      if [ -z "$selected_group_users" ]; then
        print_info=$selected_group_name
        create_1_column_window "User in group" "Users~in~group" "$print_info"
      else
        print_info=$selected_group_users
        create_1_column_window "Users in group" "Users~in~group" "$print_info"
      fi

    #Group Modify
    elif [ "$choose_option2" == "Group~Modify" ]; then
      choose_option5=$(create_1_column_window "Group Modify" "Choose" "Add~user~to~group Remove~user~from~group")
      if [ "$choose_option5" == "Add~user~to~group" ]; then
        add_user_to_group=$(zenity --forms --title="Add user" \
        --text "You are adding user to a group. User and group must be created first. Check if user and group already exist before you continue" \
        --add-entry "Add user" \
        --add-entry "To group")
        existing_user=$(echo "$add_user_to_group" | awk -F'|' '{print $1}')
        existing_group=$(echo "$add_user_to_group" | awk -F'|' '{print $2}')
        out_pudd=$(sudo usermod -a -G "$existing_group" "$existing_user" 2>&1)
        if [ $? != 0 ]; then
          zenity --info --text="$out_pudd"
        fi
      elif [ "$choose_option5" == "Remove~user~from~group" ]; then
        delete_user=$(zenity --forms --title="Delete User" \
        --text "You are deleting user from group. User and group must be created first. Check if user and group already exist before you continue" \
        --add-entry "Delete user" \
        --add-entry "From group")
        existing_user=$(echo "$delete_user" | awk -F'|' '{print $1}')
        existing_group=$(echo "$delete_user" | awk -F'|' '{print $2}')
        out_pu=$(sudo gpasswd -d "$existing_user" "$existing_group" 2>&1)
        if [ $? != 0 ]; then
          zenity --info --text="$out_pu"
        fi
      fi
    fi

  #User Management
  elif [ "$choose_option" == "User~Management" ]; then
    choose_option3=$(create_1_column_window "User Management" "Choose" "User~Add User~List~&~User~View User~Modify User~Delete")

    #User Add
    if [ "$choose_option3" == "User~Add" ]; then
      add_user=$(zenity --forms --title="Add User" \
      --text "Enter user information" \
      --add-entry "Username" \
      --add-password "Password" \
      --add-entry "Full Name")
      user=$(echo "$add_user" | awk -F'|' '{print $1}')
      passw=$(echo "$add_user" | awk -F'|' '{print $2}')
      full_name=$(echo "$add_user" | awk -F'|' '{print $3}')
      out_puty=$(echo -e "$passw\n$passw" | sudo adduser --home /home/"$user" --gecos "$full_name" --shell /bin/bash --force-badname "$user" 2>&1)
      if [ $? == 0 ]; then
        zenity --info --text="User: $user successfully added!"
      else
        echo "$out_puty" > /dev/null
        zenity --info --text="$out_puty"
      fi

    #User List & User View
    elif [ "$choose_option3" == "User~List~&~User~View" ]; then
      users=$(awk -F':' '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
      selected_user=$(create_1_column_window "User List" "Choose~user" "$users")
      if [ -z "$selected_user" ]; then
        zenity --info --text="Choose user"
        continue
      fi
      user=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $1}')
      pass=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $2}')
      user_id=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $3}')
      group_id=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $4}')
      comment=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $5}')
      formatted_comment=$(echo "$comment" | sed 's/ /~/g')
      dir=$(eval echo ~$selected_user)
      shell=$(echo $SHELL)
      groups=$(groups $selected_user 2> /dev/null | awk -F':' '{print $2}')
      formatted_groups=$(echo "$groups" | sed 's/ /~/g')
      user_info="User: $user Password: $pass UserID: $user_id GroupID: $group_id Comment: $formatted_comment Directory: $dir Shell: $shell Groups: $formatted_groups"
      if [ -z "$selected_user" ]; then
        zenity --info --text="Choose user"
      else
        create_2_column_window "Properties for user: $selected_user" "Info" "Description" "$user_info"
      fi

    #User modify
    elif [ "$choose_option3" == "User~Modify" ]; then
      users=$(awk -F':' '$3 >= 1000 && $1 != "nobody" && $1 != "user" {print $1}' /etc/passwd)
      selected_user=$(create_1_column_window "Change user properties" "Select~the~user~for~whom~you~want~to~change~properties" "$users")
      echo "$selected_user"
      if [ -z "$selected_user" ]; then
        zenity --info --text="Choose user"
      else
        user=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $1}')
        pass=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $2}')
        user_id=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $3}')
        group_id=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $4}')
        comment=$(cat /etc/passwd | grep $selected_user | awk -F':' '{print $5}')
        dir=$(eval echo ~$selected_user)
        shell=$(echo $SHELL)
        formatted_comment=$(echo "$comment" | sed 's/ /~/g')
        get_input=$(zenity --forms --title="Change user properties" \
        --add-entry "Username:" --text="$user" \
        --add-password "Recent~password:" \
        --add-password "New~password:" \
        --add-entry "ID:" \
        --add-entry "GroupID:" \
        --add-entry "Comment:" \
        --add-entry "Directory:" \
        --add-entry "Shell:")
        if [ $? != 0 ]; then
          continue
        else
          new_username=$(echo "$get_input" | awk -F'|' '{print $1}')
          old_pass=$(echo "$get_input" | awk -F'|' '{print $2}')
          new_pass=$(echo "$get_input" | awk -F'|' '{print $3}')
          new_id=$(echo "$get_input" | awk -F'|' '{print $4}')
          new_group_id=$(echo "$get_input" | awk -F'|' '{print $5}')
          new_comment=$(echo "$get_input" | awk -F'|' '{print $6}')
          new_dir=$(echo "$get_input" | awk -F'|' '{print $7}')
          new_shell=$(echo "$get_input" | awk -F'|' '{print $8}')
          output=$(sudo usermod -l "$new_username" "$user" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output"
          fi
          output1=$(echo "$new_username:$new_pass" | sudo chpasswd 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output1"
          fi
          output2=$(sudo usermod -u "$new_id" "$new_username" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output2"
          fi
          output3=$(sudo usermod -g "$new_group_id" "$new_username" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output3"
          fi
          output4=$(sudo usermod -c "$new_comment" "$new_username" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output4"
          fi
          output5=$(sudo usermod -m "$new_dir" "$new_username" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output5"
          fi
          output6=$(sudo usermod -s "$new_shell" "$new_username" 2>&1)
          if [ $? != 0 ]; then
            zenity --info --text="$output6"
          fi
        fi
      fi

    #User Delete
    elif [ "$choose_option3" == "User~Delete" ]; then
      users=$(awk -F':' '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
      selected_user=$(create_1_column_window "Delete User" "Choose~user~you~want~to~remove" "$users")
      zenity --question --text="Deleting a user is irreversible. Do you want to continue?"
      if [ $? == 0 ]; then
        command=$(sudo userdel "$selected_user" 2>&1)
        if [ $? == 0 ]; then
          zenity --info --text="SUCCESS: User $selected_user is deleted"
        else
          echo "$command" > /dev/null
          zenity --info --text="No such user! ERROR: $command"
        fi
      fi
    fi

  #Folder Management
  elif [ "$choose_option" == "Folder~Management" ]; then
    choose_option4=$(create_1_column_window "User Management" "Choose" "Folder~Add Folder~List Folder~View~&~Folder~Modify Folder~Delete")

    #Folder Add
    if [ "$choose_option4" == "Folder~Add" ]; then
      folder_name=$(create_add_remove_window "Folder Add" "Create new folder" "New~folder~name~or~path:")
      response=$(mkdir "$folder_name" 2>&1)
      if [ $? == 0 ]; then
        zenity --info --text="New folder $folder_name is created"
      else
        echo "$response" > /dev/null
        zenity --info --text="$response"
      fi

    #Folder List
    elif [ "$choose_option4" == "Folder~List" ]; then
      zenity --file-selection --title="File manager" 2> /dev/null

    #Folder View & Folder Modify
    elif [ "$choose_option4" == "Folder~View~&~Folder~Modify" ]; then
      choose_opt=$(create_1_column_window "Folder View & Folder Modify" "Choose" "Modify~Folder~Permissions Folder~Manager Show~Permissions Quick~Preview Get~Help How~To~Read~Permissions?")
      if [ "$choose_opt" == "Folder~Manager" ]; then
        zenity --info --text="Choose folder you want to inspect"
        selected_folder=$(zenity --file-selection --directory --title="Choose folder")
        if [ $? == 0 ]; then
          chosen=$(zenity --list --title="Folder Manager" \
          --column "Folder" --column "properties" \
          "1." "View folder properties" \
          "2." "Modify folder properties")
          if [[ $chosen  == "1." || $chosen == "View folder properties" ]]; then
            owner=$(stat -c %U "$selected_folder")
            group=$(stat -c %G "$selected_folder")
            permissions=$(stat -c %a "$selected_folder")
            modified=$(stat -c %y "$selected_folder")
            zenity --info --title="Folder properties" --text="Folder: $selected_folder\n\nOwner: $owner\nGroup: $group\nPermissions: $permissions\nLast modified: $modified"
          elif [[ $chosen == "2." || $chosen == "Modify folder properties" ]]; then
            new_permissions=$(zenity --entry --title="Change permissions in $selected_folder" --text="Give permissions in octal (example: 2776)")
            if [ -n "$new_permissions" ]; then
              chmod "$new_permissions" "$selected_folder"
              zenity --info --text="Permissions changed in $selected_folder"
            else
              zenity --info --text="Wrong format! Try again."
            fi
          fi
        else
          zenity --info --text="ERROR: No folder has been selected!"
        fi
      elif [ "$choose_opt" == "Modify~Folder~Permissions" ]; then
        option=$(zenity --list --title="Folder modify" --column "What do you want to do with folder?" "Change owner" "Change group" "Set user id" "Set group id" "Set sticky bit")
        if [ $? != 0 ]; then
          continue
        elif [ -z "$option" ]; then
          continue
        else
          folder=$(zenity --entry --title="Folder modify" --text="Which folder do you want to modify? Provide the complete absolute path (e.g. /home/user/folder_name)")
          if [ "$option" == "Change owner" ]; then
            new_owner=$(zenity --entry="New owner" --text="Enter new folder owner:")
            if [ $? != 0 ]; then
              continue
            elif [ -z $new_owner ]; then
              continue
            else
              com1=$(sudo chown "$new_owner" "$folder" 2>&1)
              if [ $? == 0 ]; then
                zenity --info --text="New folder owner: $new_owner"
              else
                echo "$com1" > /dev/null
                zenity --info --text="$com1"
              fi
            fi
          elif [ "$option" == "Change group" ]; then
            new_group=$(zenity --entry="New group" --text="Enter new group for the folder you selected:")
            if [ $? != 0 ]; then
              continue
            elif [ -z $new_group ]; then
              continue
            else
              com2=$(sudo chown :"$new_group" "$folder" 2>&1)
              if [ $? == 0 ]; then
                zenity --info --text="New group for the folder: $new_group"
              else
                echo "$com2" > /dev/null
                zenity --info --text="$com2"
              fi
            fi
          elif [ "$option" == "Set user id" ]; then
            setuid=$(zenity --entry --title="Set user ID" --text="Write again absolute path to folder you want to have UID on")
            if [ $? != 0 ]; then
              continue
            elif [ -z $setuid ]; then
              continue
            else
              com3=$(sudo chmod u+s "$setuid" 2>&1)
              if [ $? == 0 ]; then
                zenity --info --text="Setuid was added"
              else
                echo "$com3" > /dev/null
                zenity --info --text="$com3"
              fi
            fi
          elif [ "$option" == "Set group id" ]; then
            setgid=$(zenity --entry --title="Set group ID" --text="Write again absolute path to folder you want to have GID on")
            if [ $? != 0 ]; then
              continue
            elif [ -z "$setgid" ]; then
              continue
            else
              com4=$(sudo chmod g+s "$setgid" 2>&1)
              if [ $? == 0 ]; then
                zenity --info --text="Setgid was added"
              else
                echo "$com4" > /dev/null
                zenity --info --text="$com4"
              fi
            fi
          elif [ "$option" == "Set sticky bit" ]; then
            sbit=$(zenity --entry --title="Set sticky bit" --text="Write again absolute path to folder you want to have StickyBit on")
            if [ $? != 0 ]; then
              continue
            elif [ -z "$sbit" ]; then
              continue
            else
              com5=$(sudo chmod o+t "$sbit" 2>&1)
              if [ $? == 0 ]; then
                zenity --info --text="Sticky bit was added"
              else
                echo "$com5" > /dev/null
                zenity --info --text="$com5"
              fi
            fi
          else
            create_error_message
          fi
        fi
      elif [ "$choose_opt" == "Show~Permissions" ]; then
        ask=$(zenity --entry --title="List Folder&Files Permissions" --text="Enter the path of the directory you want to list:")
        if [ -z "$ask" ]; then
          create_error_message
          continue
        else
          permis=$(ls -la "$ask" 2>&1)
          if [ $? == 0 ]; then
            zenity --info --title="Folder&Files Permissions" --text="$permis"
          else
            echo "$permis" > /dev/null
            zenity --info --text="$permis"
          fi
        fi
      elif [ "$choose_opt" == "Get~Help" ]; then
        info=$(echo "Read (r): Allows users to view the contents of a file or list the files within a directory. For directories, it enables the ability to read the names of files and subdirectories but does not grant the ability to modify them.\n\nWrite (w): Permits users to modify the contents of a file or create, delete, and rename files within a directory. For directories, it grants the ability to create or delete files and subdirectories within that directory.\n\nExecute (x): For files, it allows the execution of a program or script. For directories, it grants the ability to enter (cd) into the directory and access its contents.\n\nSetuid (s): When the s is set in the user execute permission slot (e.g., -rwsr-xr-x), it indicates the setuid permission. This means that the executable file will run with the privileges of the file's owner, rather than the user who is executing the file. This is often used for programs that require elevated privileges to perform certain tasks.\n\nUppercase setuid (S): Similar to s, but in this case, the setuid permission is set without the execute permission for the owner. For example, if the owner does not have execute permission, you will see S instead of s (e.g., -rwSr--r--).\n\nSetgid (s): When setgid is applied to a directory, files created within that directory inherit the group ownership of the parent directory. This ensures consistency in group ownership for files created by different users in the same directory. Symbolic representation: drwxr-sr-x for a directory. Numerical representation: 2.\n\nUppercase setgid (S): Similar to setgid, but the user execute permission is not set. It means that the setgid is effective only for the group. If the owner does not have execute permission S is displayed instead of s. Symbolic representation: drwxr-Sr-x for a directory without owner execute permission.\n\nThe sticky bit is another special permission in Linux file systems. When applied to a directory, it has specific effects on the control of file deletion within that directory. The symbolic representation for the sticky bit on a directory is t: drwxrwxrwt.\n\nd stands for directory\n\n– stands for regular file\n\nl stands for symbolic link\n\nexample:\n$ ls -l\ndrwxr-xr-x 2 user1 users  4096 Jan 13 10:00 my_directory\n-rw-r--r-- 1 user1 users 1024 Jan 13 09:45 my_file.txt\nlrwxrwxrwx 1 user1 users 8 Jan 13 09:30 my_symlink -> somefile")
        zenity --info --title="Get Help" --text="$info"
      elif [ "$choose_opt" == "Quick~Preview" ]; then
        chosen_one=$(zenity --file-selection --directory --title="Choose Folder")
        if [ $? == 1 ]; then
          continue
        elif [ -z "$chosen_one" ]; then
          zenity --info --text="No path or file has been selected."
        else
          perm=$(ls -ld "$chosen_one" | awk '{print $1}' 2> /dev/null)
          ownero=$(ls -ld "$chosen_one" | awk '{print $3}' 2> /dev/null)
          groupa=$(ls -ld "$chosen_one" | awk '{print $4}' 2> /dev/null)
          zenity --info --title="Folder Ownership And Permissions for $chosen_one" --text="Directory rights: $perm\n\nOwner: $ownero\n\nGroup: $groupa"
        fi
      elif [ "$choose_opt" == "How~To~Read~Permissions?" ]; then
        xdg-open hmod.jpg
      elif [ -z "$choose_opt" ]; then
        zenity --info --text="No option selected. Return to the main menu."
      else
        create_error_message
      fi

    #Folder Delete
    elif [ "$choose_option4" == "Folder~Delete" ]; then
      folder=$(create_add_remove_window "Folder Delete" "Which folder you want to delete?" "Folder~name")
      if [ $? == 0 ]; then
        you_sure=$(zenity --info --text="The folder and its content will be deleted. Do you want to continue?")
        if [ $? == 0 ]; then
          yes=$(zenity --info --text="The folder, its subfolders and the files they contain will be lost. Are you sure that you want to continue?")
          if [ $? == 0 ]; then
            respon=$(sudo rm -r "$folder" 2>&1)
            if [ $? == 0 ]; then
              zenity --info --text="SUCCESS: folder has been deleted!"
            else
              echo "$respon" > /dev/null
              zenity --info --text="$respon"
              create_error_message
            fi
          fi
        fi
      fi
    fi
  else
    echo "Thank you for using LINUX SYSTEM MANAGER"
    echo "Bye bye!"
    break
  fi
done

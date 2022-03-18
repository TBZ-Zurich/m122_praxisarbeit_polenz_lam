#! /bin/bash

# gets options from cli
while getopts u:b:p:d: optvar ; do
    case $optvar in
        u) CONFIG_FILE="${OPTARG}";;
        b) BACKUP_CONFIG="${OPTARG}";;
        p) DEFAULT_PASSWORD="${OPTARG}";;
        d) DIRECTORY_TEMPLATE="${OPTARG}";;
    esac
done

# returns usage guide and exits
usage () {
    echo "Usage: ./script.sh -p <default_password> -d <path_to_template_dir> -u <path_to_user_config> -b <path_to_backup_config_dir>"
    exit 0
}

# checks dependencies needed for script 
check_dependencies () {
    if ! [ $(which mkpasswd) ]
    then
        echo "mkpasswd is required, install with apt install whois"
        exit 0
    fi

    logger "Dependencies: validated"
}

#checks if input directories exist
check_input () {
    if ! [ -f $CONFIG_FILE ]; then usage; fi
    if ! [ -d $BACKUP_CONFIG ]; then usage; fi
    if ! [ -d $DIRECTORY_TEMPLATE ]; then usage; fi
    if ! [ $DEFAULT_PASSWORD ]; then usage; fi

    logger "Agrs: validated"
}

#logs log data with timestamp to file
logger () {
    DATE=`date '+%Y.%m.%d'`
    TIME=`date '+%H:%M:%S'`
    file=$DATE.txt
    echo $1
    echo "$TIME: $1" >> $file
}

#ensures that userfile is valid and can be used
ensure_file_integrity () {
    while IFS= read -r line; do
        stringArr=($line)

        if [[ ${#stringArr[@]} != 4 ]] && [[ ${#stringArr[@]} != 0 ]]
        then
            echo "Invalid file: $CONFIG_FILE"
            exit 0
        fi
    
    done < $CONFIG_FILE
    logger "Config: validated"
}

#checks if group exists, if not warns user and creates it
check_group_existance () {
    if ! [ $(getent group $1) ];
    then
        echo "group $1 does not exist, creating group"
        logger "Creating group $1"
        groupadd $1
    fi
}

#reads group bachup files and checks if group is backed up
check_backup_status () {
    for i in ../etc/userwizzard/backup.g*g.config;
    do
        if [ $i -eq "../etc/userwizzard/backup.g$2g.config" ]
        then 
            return
        fi
    done 
    
    logger "Users in $2 are not backed up"
    echo "Be aware, all users in the $2 group are currently not backed up."
}

#checks user existance and creates if it does not
check_user_existance () {
    if ! [ $(getent passwd $1) ];
    then
        echo "User $1 does not exist, creating user and setting default password"
        useradd -g $2 -p $(mkpasswd --hash=SHA-512 $DEFAULT_PASSWORD) $1
        logger "Created user $1"
        chage -d 0 $1
    fi
}

#generates homedir based on configs
generate_user_homedir () {
    TEMPLATE_FILE="$1$3.template"

    if ! [ -f TEMPLATE_FILE ];
    then
        logger "Use default directory template"
        TEMPLATE_FILE="../etc/dirtemplate.conf"
    fi

    echo $TEMPLATE_FILE

    while IFS= read -r line; do
        mkdir -p /home/$2$line
    done < $TEMPLATE_FILE

    logger "Created directory template"
}

check_dependencies
check_input
ensure_file_integrity

# handels steps for createing a user and groups in one loop
while IFS= read -r line; do
    if ! [[ "$line" =~ ^[a-z] ]]
    then
        continue
    fi
    stringArr=($line)

    check_group_existance ${stringArr[1]} 
    check_backup_status $BACKUP_CONFIG ${stringArr[1]}
    check_user_existance ${stringArr[0]} ${stringArr[1]}
    generate_user_homedir $DIRECTORY_TEMPLATE ${stringArr[0]} ${stringArr[1]}

    logger "User ${stringArr[0]} configured."
done < $CONFIG_FILE
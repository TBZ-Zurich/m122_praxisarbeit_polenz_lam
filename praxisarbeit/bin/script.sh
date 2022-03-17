    #!/bin/sh

    # Creates a log file
    # Check for update
    CWD='pwd'		# current working directory
    HOME=
    CONF='/etc/userwizzard/backupdata.config'
    BACKUP='/etc/userwizzard/backup._example_.config'
    DONTBACKUP='/etc/userwizzard/dontbackup._example_.config'
    DIR='/etc/userwizzard/'
    KEEPINDAYS=1
    FILENAME='backup'
    BACKUPLOCATION='/root/backuptest/'
    BACKUPCOUNTER=0
    tar='tar -czvf'
    DATE=$(date +'%Y-%m-%d_%H:%M:%S')


    log=$(date +'%Y-%m-%d_%H:%M:%S'_backup.log)

    printf 'Logfile: ' > $log

    date >> $log

    echo 'Created log' $log >> $log 

    # Initializes the sample config files and directory
    initialize() {
        echo 'Starting initializing process' >> $log
        check_dir
        echo 'Initializing done' >> $log
    }

    # Checks if the location of the config directory exists
    check_dir() {
        echo 'Checking the config directories if they exists' >> $log
        if [ -d "$DIR" ]; 
            then check_files 
            else mkdir /etc/userwizzard/
            echo 'Created directory' >> $log
            check_dir
        fi
    } 

    check_files() {
        echo 'Checking config files' >> $log

        echo 'Checking if the' $CONF 'file exists' >> $log
        if [ ! -f "$CONF" ];
            then echo 'Getting the' $CONF 'file' >> $log
            wget -O $CONF.sample https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backupdata.conf.sample.conf
            wget -O $CONF https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backupdata.conf.sample.conf
        echo 'Success the' $CONF 'file is downloaded' >> $log
        fi

        echo 'Checking if the' $BACKUP 'file exists' >> $log
        if [ ! -f "$BACKUP" ];
            then echo 'Getting the' $BACKUP 'file' >> $log
            wget -O $BACKUP.sample https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backup.conf.sample.conf
            wget -O $BACKUP https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backup.conf.sample.conf
        echo 'Success the' $BACKUP 'file is downloaded' >> $log
        fi

        echo 'Checking if the' $DONTBACKUP 'file exists' >> $log
        if [ ! -f "$DONTBACKUP" ];
            then echo 'Getting the' $DONTBACKUP 'file' >> $log
            wget -O $DONTBACKUP.sample https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backupdata.conf.sample.conf
            wget -O $DONTBACKUP https://eu2.contabostorage.com/25769b182180466ebc74ade7c7beb614:mydata/backupdata.conf.sample.conf
        echo 'Success the' $DONTBACKUP 'file is downloaded' >> $log
        fi

        echo 'All files exists' >> $log

    }

    read_conf() {

        . $CONF
        echo 'Adding parameter keep in days'$keepindays >> $log
        KEEPINDAYS=$keepindays
        echo 'Adding parameter filename'$filename >> $log
        FILENAME=$filename
        echo 'Adding parameter backuplocation'$backuplocation >> $log
        BACKUPLOCATION=$backuplocation
    }

    read_backup() {

        for i in /etc/userwizzard/backup.*.config; do
            BACKUPCOUNTER=$((BACKUPCOUNTER+0))
            echo 'Filename '$i >> $log
            echo 'Amount of matching log file '$BACKUPCOUNTER >> $log
            if [ $BACKUPCOUNTER -eq '1' ];
            then 
            echo 'Everything will be saved' >> $log
            tar="${tar}/home"
            else 
            case $i in
                /etc/userwizzard/backup._*_.config)
                directory=`echo "$i" | grep -oP '(?<=backup._).*?(?=_.config)'`
                directory=`echo "$directory" | tr "-" /`
                echo 'Add directory: '$directory >> $log 
                tar="${tar} /${directory}"
                echo 'Creating Tar' $tar 
                ;;
                 /etc/userwizzard/backup.g*g.config)
                group=`echo "$i" | grep -oP '(?<=backup.g).*?(?=g.config)'`
                echo $group
                if [ $(getent group "$group") ]; then
                echo "group "$group" exists" >> $log
                else
                echo -e "\033[33mgroup "$group" does not exist.\e[0m"
                fi
                echo 'Creating Tar' $tar 
                ;;
            esac
            fi
        done
    }

    read_dontbackup() {

    for i in /etc/userwizzard/dontbackup.*.config; do
            echo 'Filename '$i >> $log
            case $i in
                /etc/userwizzard/dontbackup._*_.config)
                directory=`echo "$i" | grep -oP '(?<=dontbackup._).*?(?=_.config)'`
                directory=`echo "$directory" | tr "-" /`
                directory="--exclude=/${directory}"
                echo 'Add dontbackup directory: '$directory >> $log 
                tar="${tar} ${directory}"
                echo $tar
                ;;
            esac
        done

    }

check_amount() {
    if [[ -d "$BACKUPLOCATION" ]]; then
    files=( "$BACKUPLOCATION"/*"$FILENAME"* )
    num_files=${#files[@]}
    else
    num_files=0
    fi
    echo $num_files

    find "$BACKUPLOCATION" -type f -mtime +"$KEEPINDAYS" -delete 

    }

    create_backup() {
        read_conf
        if [ -d "$BACKUPLOCATION" ]; then
            echo 'Directory exists' $BACKUPLOCATION >> $log
            else 
            mkdir "$BACKUPLOCATION"
        fi
        cd $BACKUPLOCATION
        check_amount
        tar="${tar} ${FILENAME} ${DATE}.tar.gz "
        echo 'Statement: '$tar >> $log
        read_backup
        read_dontbackup
        $tar
    }

    initialize
    create_backup

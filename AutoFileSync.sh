#!/usr/bin/env bash


# CREATOR: Mike Lu
# CHANGE DATE: 2023/2/24


read -p "Please input server's User name: " LOGIN_USER
read -p "Please input server's IP: " SERVER_IP
HOST="$LOGIN_USER@$SERVER_IP"
SOURCE_DIR="~/Desktop/Share"	# SSH Server
DESTINATION_DIR=$HOME/Desktop/Backup	# SSH Client
CRON_LOG="$HOME/Desktop/Report.log"	# SSH Client
TIME=$(date +"%Y/%m/%d - %H:%M:%S")


# [Client => Generate SSH keys] 
[[ -f $HOME/.ssh/id_rsa && -f $HOME/.ssh/id_rsa.pub ]] || ssh-keygen -q


# [Client => Copy SSH public key to server] 
ssh-copy-id -i ~/.ssh/id_rsa.pub $HOST > /dev/null 2>&1


# Manually check there's a file "authorized_keys" created under server's ~/.ssd 


# [Initialize file sync]
[[ -d $DESTINATION_DIR ]] || mkdir $DESTINATION_DIR
echo -e  "Now syncing files....\n"
rsync -azh --delete --progress --out-format="%t  %f  %l" -e "ssh -i ~/.ssh/id_rsa" $HOST:$SOURCE_DIR/ $DESTINATION_DIR && echo -e "\n\nAll files sync completed!" 
[ $? -ne 0 ] && echo -e "\n$TIME File sync FAILED!!" && exit


# [Create cron job - output both changes and errors]
[[ -d $DESTINATION_DIR ]] || mkdir $DESTINATION_DIR
crontab -l > mycron
grep -h ''$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR'' mycron > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo '*/10 * * * * rsync -azh --delete --out-format="\%t  \%f  \%l" -e "ssh -i ~/.ssh/id_rsa" '$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR' >> '$CRON_LOG' || echo "$(date +"\%Y/\%m/\%d \%H:\%M:\%S")  [NETWORK ERROR !!!] File sync failed with error code: $?" >> '$CRON_LOG'' >> mycron
    crontab mycron
fi
rm mycron


# [Create cron job - output changes only]  Uncomment to take effect 
<<COMMENT
[[ -d $DESTINATION_DIR ]] || mkdir $DESTINATION_DIR
crontab -l > mycron
grep -h ''$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR'' mycron > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo '* * * * * rsync -azh --delete --out-format="\%t  \%f  \%l" -e "ssh -i ~/.ssh/id_rsa" '$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR' >> '$CRON_LOG'' >> mycron
    crontab mycron
fi
rm mycron
COMMENT


# [Create cron job - output errors only]   Uncomment to take effect 
<<COMMENT
[[ -d $DESTINATION_DIR ]] || mkdir $DESTINATION_DIR
crontab -l > mycron
grep -h ''$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR'' mycron > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo '* * * * * rsync -avzh --delete -e "ssh -i ~/.ssh/id_rsa" '$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR' || echo "$(date +"\%Y/\%m/\%d - \%H:\%M:\%S") -- Rsync failed with error code $?" >> '$CRON_LOG'' >> mycron
     crontab mycron    
fi
rm mycron
COMMENT


# [Delete cron job]   Uncomment to take effect 
<<COMMENT
crontab -l > mycron && > mycron && crontab mycron && rm mycron 
systemctl restart cron
rm $CRON_LOG
COMMENT


# [Error handling for SSH fingerprint (publisc key) not prompted]  Uncomment to take effect
<<COMMENT
ssh-keygen -R $SERVER_IP
COMMENT



#!/usr/bin/env bash


read -p "Please input server's User name: " LOGIN_USER
read -p "Please input server's IP: " SERVER_IP
HOST="$LOGIN_USER@$SERVER_IP"
SOURCE_DIR="~/Desktop/Share"	# SSH Server
DESTINATION_DIR=$HOME/Desktop/Backup	# SSH Client
CRON_LOG="$HOME/Desktop/Update.log"	# SSH Client

# [Client => Generate SSH keys] 
[[ -f $HOME/.ssh/id_rsa && -f $HOME/.ssh/id_rsa.pub ]] || ssh-keygen -q


# [Client => Copy SSH public key to server] 
ssh-copy-id -i ~/.ssh/id_rsa.pub $HOST > /dev/null 2>&1


# Note: Manually check there's a file "authorized_keys" created under server's ~/.ssd 


# [Client => Enable crontab and output status log for any changes and errors]
[[ -d $DESTINATION_DIR ]] || mkdir $DESTINATION_DIR
crontab -l > mycron
grep -h ''$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR'' mycron > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo '* * * * * rsync -azh --delete --out-format="\%t  \%f  \%l" -e "ssh -i ~/.ssh/id_rsa" '$HOST':'$SOURCE_DIR'/ '$DESTINATION_DIR' >> '$CRON_LOG' || echo "$(date +"\%Y/\%m/\%d \%H:\%M:\%S")  [NETWORK ERROR !!!] File sync failed with error code: $?" >> '$CRON_LOG'' >> mycron
    crontab mycron
fi
rm mycron



# [Client => Enable crontab and output status log for changes Only]  Uncomment to take effect 
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



# [Client => Enable crontab and output error code if sync fails]   Uncomment to take effect 
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



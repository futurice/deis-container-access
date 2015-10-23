#!/usr/bin/env bash
# Usage: KEY=~/.ssh/deis HOST="core@DEISCTL" bash install.sh
set -o errexit
set -o nounset
set -o xtrace

U=${U:=dca}
TDIR=/tmp/$U/

# rsa key for user
ssh-keygen -t rsa -f dca||true

ssh -i $KEY $HOST mkdir -p $TDIR
scp -i $KEY dca.pub $HOST:$TDIR
scp -i $KEY *.sh $HOST:$TDIR
scp -i $KEY systemd/* $HOST:$TDIR

ssh -A -i $KEY $HOST U=$U TDIR=$TDIR '
HOME_DIR="/home/$U/"
OBIN="/opt/bin/"

sudo cp ${TDIR}dca_sshd_config /etc/ssh/

# ForceCommand wrapper.sh
sudo cp ${TDIR}wrapper.sh $OBIN
sudo chmod +x ${OBIN}wrapper.sh

# disable ssh on port 22 for dca user
SSH_CONFIG=/etc/ssh/sshd_config
sudo cp $SSH_CONFIG ${SSH_CONFIG}_orig
sudo rm $SSH_CONFIG
sudo cp ${SSH_CONFIG}_orig $SSH_CONFIG
DENYSTR="DenyUsers $U" 
if sudo grep -q "$DENYSTR" $SSH_CONFIG; then :; else echo $DENYSTR|sudo tee -a $SSH_CONFIG >/dev/null; fi

# sshd.systemd
# Do sshd@.service configs need copies too?
sudo cp ${TDIR}dca-sshd.service /etc/systemd/system/

sudo systemctl enable dca-sshd.service
sudo systemctl start dca-sshd.service

# dca container communication
sudo chmod +x ${TDIR}send.sh 
sudo cp ${TDIR}settings.sh $OBIN
sudo cp ${TDIR}send.sh $OBIN
sudo cp ${TDIR}container.sh $OBIN
sudo cp ${TDIR}output.sh $OBIN

sudo cp ${TDIR}dca.service /etc/systemd/system/
sudo cp ${TDIR}dca.timer /etc/systemd/system/

sudo systemctl start dca.timer
sudo systemctl enable dca.timer
sudo systemctl daemon-reload

# ssh user
sudo useradd -m $U
cat ${TDIR}dca.pub|sudo tee ${HOME_DIR}.ssh/authorized_keys >/dev/null
sudo chmod 0600 ${HOME_DIR}.ssh/authorized_keys
sudo chown $U.$U ${HOME_DIR}.ssh/authorized_keys
NEWPWD=$(openssl rand -base64 16)
echo "$U:$NEWPASSWD"|sudo chpasswd
sudo usermod -G docker $U
'

echo "\n"
OK=$(echo $?); if [ $OK -eq 0 ]; then echo "Success"; else echo "Something went wrong..."; fi


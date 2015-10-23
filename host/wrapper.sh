#! /bin/sh
log="logger -t ssh-wrapper"
IP=`echo $SSH_CONNECTION | cut -d " " -f 1`

printf -v COMMAND "%q" "$SSH_ORIGINAL_COMMAND"
$log $IP $USER $COMMAND

exec /bin/sh -c "docker exec -it $COMMAND bash"

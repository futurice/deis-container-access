DCA_CONTAINER=${DCA:=dca}
docker ps|grep ".cmd."|grep "$DCA_CONTAINER"|awk '{print $1}';

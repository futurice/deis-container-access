
# Deis Container Access

Configure the Deis cluster to be able to access its containers.

- adds second sshd instance running on port 222
- adds "dca" -user
- denies access for this user on port 22
- (optionally) creates rsa key for user
- sets ForceCommand to direct connections on 222 to requested container (can not issue commands on Deis hosts)
- adds scripts to periodically update container information to "dca" -container

# Install

1. Install required environment on each Deis instance

```
$ cd host/
$ cp settings.sh.template settings.sh
$ # configure settings.sh to fit your environment
$ KEY="~/.ssh/deis" HOST="core@DEISCTL" bash install.sh
```

2. Open port 222 on your firewall (eg. AWS Security Group).

3. (optional) Create container named "dca" for listing available containers
```
$ deis apps:create dca
$ git push deis master
```

# Usage

Access a container in Deis

```
$ ssh -t dca@DEISCTL -p 222 containerId
```

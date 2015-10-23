
# Deis Container Access

Configure the [Deis](http://deis.io/) cluster to be able to access its containers as App developer.

# What?

By default only an Admin with access to the Deis cluster can access containers using `deisctl`.
This did not seem developer friendly enough for debugging and running one-off commands that rely on a complex
infrastructure. Time to let the app developers in:

Changes:
- adds second sshd instance running on port 222
- adds dca-user
- sets `ForceCommand` to direct connections on 222 to the requested container
  - dca-user can not issue commands on actual Deis hosts
- denies access for dca-user on port 22
- (optionally) creates rsa key for user
- adds systemd scripts to periodically update container information to dca-container available in JSON

Current version is meant for trusted environments.

# Install

1. Install on each Deis instance

```
$ cd host/
$ cp settings.sh.template settings.sh
$ # configure settings.sh to fit your environment
$ KEY="~/.ssh/deis" HOST="core@DEISCTL" bash install.sh
```

2. Open port 222 on your firewall (eg. AWS Security Group).

3. (optional) Create dca-container for listing available containers
```
$ deis apps:create dca
$ git push deis master
```

# Usage

Access a container in Deis

```
$ ssh -p 222 -t -i dca dca@DEISCTL containerId
```

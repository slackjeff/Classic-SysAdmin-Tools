# !/usr/bin/env bash
##########################################################
# > Classic SysAdmin Tools <
# Consistent SSH configuration for Debian, Slackware
# Author: Slackjeff <slackjeff@riseup.net>
#
# READ
# We set default authentication keys. You must first
# send your keys to the server and authenticate them in
# order to succeed =)
##########################################################

#############################
# Configure
#############################

file='/etc/ssh/sshd_config'

#############################
# Functions
#############################
backup_ssh_config()
{
        if [ ! -f "${file}.backup" ]; then
            echo "Backup of $file"
            cp -pv "$file" "${file}.backup"
        else
            rm -v "$file"
            return 0
	fi
}

insert_config()
{
	echo "Create new configure: $file"
	cat <<EOF > $file
# Dont use port 22
Port 2226

# Limit Users’ SSH Access
# change and delimiter with spaces.
# "user1 user2 user3" etc...
AllowUsers "slackjeff"

# Disable Root Logins
PermitRootLogin no

# Disable Empty Passwords
PermitEmptyPasswords no

# Disable password authentication forcing use of key
PasswordAuthentication no

# Force Only SSH Protocol 2
Protocol 2

#AuthorizedKeysFile     .ssh/authorized_keys

# Configure Idle Timeout Interval
# 360 = 6 minutes
ClientAliveInterval 360
ClientAliveCountMax 0

# Authentication TRY and Max Sessions SSH
MaxAuthTries 3
MaxSessions 6

# X11
X11Forwarding no

# Comment with no need sftp service.
Subsystem       sftp    /usr/lib/openssh/sftp-server
EOF
}

reload_service()
{
	# Which distribution?
	distro="$(grep "\bID=\b" /etc/os-release | cut -d = -f 2)"
	case $distro in
		slackware)
			# Don't use restart.
			/etc/rc.d/rc.sshd stop
			/etc/rc.d/rc.sshd start
		;;
		debian|ubuntu)
			systemctl restart sshd
		;;
	esac
}

#############################
# Main
#############################

backup_ssh_config
insert_config
reload_service

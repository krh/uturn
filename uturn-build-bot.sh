#!/bin/sh

host=irc.freenode.net
port=6667
nick=uturn-builder
channel=#wayland-bots
fifo=uturn-bot-fifo

exec 3<>/dev/tcp/$host/$port || exit 1

function do_quit {
    echo -ne "QUIT :Ugh, be right back...\r\n" >&3
}

trap do_quit INT EXIT

# IFS="\r\n\t "

echo -ne "NICK $nick\r\n" >&3
echo -ne "USER $nick $nick $nick :The uturn build bot (owner is krh)\r\n" >&3
echo -ne "JOIN $channel\r\n" >&3

function handle_bot_msg {
    case $1 in

	# :post-update repo old-hash new-hash ref
	:post-update)
	    ./uturn-builder.sh rebuild $2 $5 2>&1 | while read line; do
		echo -ne "PRIVMSG $channel :$line\r\n" >&3
	    done
	    ;;
    esac
}

while read line <&3; do
    echo "$line"
    case "$line" in
	:uturn-bot*)
	    handle_bot_msg ${line##*$channel } & ;;
	PING*)
	    echo -ne "PONG ${line##PING }" >&3 ;;
    esac
done


#!/bin/sh

host=irc.freenode.net
port=6667
nick=uturn-bot
channel=#wayland
fifo=uturn-bot-fifo

exec 3<>/dev/tcp/$host/$port || exit 1

test -e $fifo && unlink $fifo
mkfifo $fifo

function do_quit {
    echo -ne "QUIT :Ugh, be right back...\r\n" >&3
    unlink $fifo
}

trap do_quit INT EXIT

echo -ne "NICK $nick\r\n" >&3
echo -ne "USER $nick $nick $nick :The uturn build bot (owner is krh)\r\n" >&3
echo -ne "JOIN $channel\r\n" >&3

while read line <&3; do
    echo "$line"
    case "$line" in
	PING*)
	    echo -ne "PONG ${line##PING }" >&3 ;;
    esac
done &

while read msg <$fifo; do
    echo -ne "PRIVMSG $channel :$msg\r\n" >&3
done


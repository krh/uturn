#!/bin/sh

host=irc.freenode.net
port=6667
nick=uturn-bot
owner=krh
channel=##krh-bot-sandbox
fifo=uturn-bot-fifo

exec 3<>/dev/tcp/$host/$port || exit 1

test -e $fifo && unlink $fifo
mkfifo $fifo

function do_quit {
    printf "QUIT Ugh, be right back...\r\n" >&3
    unlink $fifo
}

trap do_quit INT EXIT

printf "NICK $nick\r\n" >&3
printf "USER $nick $nick $nick :Hello\r\n" >&3
printf "JOIN $channel\r\n" >&3

{
    while read msg <$fifo; do
	printf "PRIVMSG $channel :$msg\r\n" >&3
    done
} &

while read line <&3; do
    echo "$line"
    case "$line" in
	PING*)
	    printf "PONG ${line##PING }" >&3 ;;
    esac
done

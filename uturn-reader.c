#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <error.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
	struct pollfd pfd[2];
	char fifo_name[256];
	char buffer[1024];
	int len;

	snprintf(fifo_name, sizeof fifo_name, "uturn-fifo-%d", getpid());
	mkfifo(fifo_name, 0666);

	pfd[0].fd = 0;
	pfd[0].events = POLLIN;

	/* Open fifo with O_NONBLOCK so we don't block here waiting
	 * for the first writer.  If we block here we won't be able to
	 * catch stdin closing if ssh disconnects. */

	pfd[1].fd = open(fifo_name, O_RDONLY | O_NONBLOCK);
	pfd[1].events = POLLIN;

	while (1) {
		poll(pfd, 2, -1);
		if (pfd[0].revents & POLLHUP)
			break;
		if (pfd[1].revents) {
			len = read(pfd[1].fd, buffer, sizeof buffer);
			write(1, buffer, len);
		}
	}

	unlink(fifo_name);

	return 0;
 }

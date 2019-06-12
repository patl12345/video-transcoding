FROM ntodd/video-transcoding:latest
MAINTAINER Pat Lambe <pat@maru.org.uk>

RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && echo Europe/London > /etc/timezone

RUN apt-get update && apt-get install -y \
    cron

ADD transcodeVideos.sh /usr/sbin/transcodeVideos.sh

RUN echo "25 8 * * * root /usr/sbin/transcodeVideos.sh > /proc/1/fd/1 2>/proc/1/fd/2" >> /etc/crontab

CMD ["cron", "-f"]

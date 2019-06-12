FROM ntodd/video-transcoding:latest
MAINTAINER Pat Lambe <pat@maru.org.uk>

RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && echo Europe/London > /etc/timezone

ADD transcodeVideos.sh /usr/sbin/transcodeVideos.sh

CMD ["/usr/sbin/transcodeVideos.sh"]

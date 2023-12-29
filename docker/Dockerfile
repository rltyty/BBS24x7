# ###########################################################################
#                              Instructions
# 1. Build the image:
#
# docker build -t <img_name> -f docker/Dockerfile .
#
# 2. Launch the container:
#
# docker run -it [-h <hostname>] --name <container_name> <image_name>

# Note: luit 2.0 has been introduced since Deiban 12, no need to manually
# build from the source anymore.

# ###########################################################################
ARG RELEASE=12
FROM debian:${RELEASE}-slim

# 1. User and group
ARG USER=appuser
ARG UID=1000
ARG GROUP=appgroup
ARG GID=1000
ARG PASSWORD=apppass

# 2. Arg. and Env.
ARG DEBUG=0
ARG SSHCONF=".gitignore"
ARG CRON_SCHED="@hourly"
ARG APP="bbs24x7"
ENV APP="/home/$USER/$APP"
ARG LOCAL=".gitignore"

# 3. Dependencies
RUN apt update && \
    apt install -y tmux openssh-client luit expect tcl tcllib \
        locales cron && \
    if [ $DEBUG = 1 ]; then \
        apt install -y procps vim; \
    fi \
    && apt -y autoremove && rm -rf /var/lib/apt/lists/*

# 4. Post-install configuration as root

## 4.1 Create user & group
RUN groupadd --gid $GID $GROUP \
    && useradd --uid $UID -g $GROUP -m $USER \
    && echo "$USER:$PASSWORD" | chpasswd

## 4.2 Configure daemons: cron
### Add setuid/guid special mode to cron for non-root user's execution.
RUN chmod u+s /usr/sbin/cron

## 4.3 Set the locale from default POSIX to UTF-8
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# 5. Switch to non-root user
USER $USER

# 6. Deploy app and configuration
## Copy user files under LOCAL from host to $APP/local during image build
## Mount user files from host to $APP/external during container start
RUN install -d -o $USER -g $GROUP -m 0755 $APP \
    && install -d -o $USER -g $GROUP -m 0755 $APP/local \
    && install -d -o $USER -g $GROUP -m 0755 $APP/external \
    && install -d -o $USER -g $GROUP -m 0755 /home/$USER/tmp

WORKDIR "$APP"
COPY --chown=$USER:$GROUP "$LOCAL" local/
COPY --chown=$USER:$GROUP "$SSHCONF" .
COPY --chown=$USER:$GROUP --chmod=755 ./tmux.sh .
COPY --chown=$USER:$GROUP --chmod=755 expscripts expscripts

COPY --chown=$USER:$GROUP --chmod=755 ./docker/main.sh .

## Configure Tmux
COPY --chown=$USER:$GROUP ./tmux.conf /home/$USER/.tmux.conf

## Configure SSH
RUN install -d -o $USER -g $GROUP -m 0755 /home/$USER/.ssh \
&& if [ -n "$SSHCONF" ] && [ "$SSHCONF" != ".gitignore" ]; then \
        cat ${SSHCONF##*/} >> /home/$USER/.ssh/config \
        && rm ${SSHCONF##*/}; \
    fi

# Configure user crontab
RUN echo "LANG=en_US.UTF-8\n\
LANGUAGE=en_US:en\n\
LC_ALL=en_US.UTF-8\n\
APP=$APP\n\
$CRON_SCHED $APP/main.sh $APP/local $APP/external > /dev/null \
2>>${HOME}/tmp/bbs24x7-err.log" \
> crontab.bbs24x7 && crontab -u $USER crontab.bbs24x7


ENTRYPOINT [ "./main.sh" ]

# vim: tw=78:ts=8:sts=4:sw=4:ft=dockerfile:norl:

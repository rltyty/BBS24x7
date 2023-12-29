# Docker Usage

## Pull image from dockerhub

    docker pull arg6/bbs24x7

## Build image

### A basic build without any user data
    docker build -t arg6/bbs24x7 -f docker/Dockerfile .

### Add user data from `LOCAL` to image
    docker build -t bbsimg -f docker/Dockerfile --build-arg SSHCONF=config --build-arg CRON_SCHED="0-59/2 * * * *"  --build-arg LOCAL=./loc .

### Build options(--build-arg KEY=VALUE)

    RELEASE     debian release(default:12)
    DEBUG       1 to add more utility packages for testing (default:0)
    LOCAL       directory from which all user data are copied into the image
    SSHCONF     SSH configuration copied into the image
    CRON_SCHED  schedule string like "5 0-23/2 * * *" set in crontab(default:
                @hourly)

    other common options like USER/PASSWORD/GROUP/UID/GID and APP

## Run container

When the main program runs, it reads Tmux session data from two locations:

    $APP/local
    $APP/external

The data in `$APP/local` were copied during image build.
The data in `$APP/external` were mounted from host when conatiner kickoff.

### Run a containter from the basic image

Feed user data through volume mount point of the host:

    docker run -it -d -v ~/.ssh:/home/appuser/.ssh -v ./tests:/home/appuser/bbs24x7/external --name bbs arg6/bbs24x7

If the image gets the user data copied during build like the 2nd example
above, just run:

    docker run -it -d --name bbs bbsimg

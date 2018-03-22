FROM frolvlad/alpine-glibc:alpine-3.7

# Install conda
RUN RESTIC_VERSION="0.8.3" && \
    RESTIC_SHA256_CHECKSUM="1e9aca80c4f4e263c72a83d4333a9dac0e24b24e1fe11a8dc1d9b38d77883705" && \
    \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates bash && \
    \
    wget "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2" -O /bin/restic.bz2 && \
    echo "${RESTIC_SHA256_CHECKSUM}  /bin/restic.bz2" | sha256sum -c && \
    bzip2 -d /bin/restic.bz2 && \
    chmod a+x /bin/restic && \
    \
    touch /var/log/cron.log

COPY backup /root
WORKDIR "/"

# These are configurable from the environment or with -e to docker run
# --------------------------------------------------------------------

# List of local folders to backup. This list must be separated by ":" (colons).
# Example: '/dir1:/dir2:/dir3'
ENV RESTIC_DATA="/data"

# List of remote repositories (BackBlaze B2 buckets or any other supported) to
# back-up the local folders to. Example: 'b2:documents'
ENV RESTIC_REPO="/repo"

# Credentials to use for accessing your BackBlaze account (advise not to
# hard-code it here, but to pass it as an environment variable
ENV B2_ACCOUNT_ID=""
ENV B2_ACCOUNT_KEY=""

# Password to encrypt your backups on the remote repository. Don't set it here,
# but also don't loose it or any hope of recovery is gone!
ENV RESTIC_PASSWORD=""

# Cron daemon settings for launching the backup job script (backup/run.sh)
# The current settings will back-up every day at 1AM (UTC) / 2AM (CET)
ENV BACKUP_CRON="0 1 * * *"

# Global Options for restic (like --limit-download or --limit-upload)
# Do NOT use the --repo flag here - we'll append it ourselves. These are for
# extra stuff you may want to pass to restic itself (look at global options)
ENV RESTIC_OPTIONS=""

# Options for backup (like --exclude). Do **not** set "--hostname", we'll do
# this from the value of the environment variable RESTIC_HOSTNAME
ENV RESTIC_BACKUP_OPTIONS=""

# Captures the value restic will use for the hostname - Important: restic
# backups are organized by hostname, so you must set it from the commandline to
# get this right. Changing the hostname will have implications on the kept
# snapshots (during a "forget") as that is done per hostname.
ENV RESTIC_HOSTNAME="myhost"

# Options for forgetting and prunning the backup repository. This option will
# keep last seven days, the last 8 weeks, last 12 months and last 3 years worth
# of backups. If you decrease this at any time, consequences will happen at the
# next time the backup command will run. Do **not** set "--host", we'll do
# this from the value of the environment variable RESTIC_HOSTNAME
ENV RESTIC_FORGET_OPTIONS="--prune --keep-daily 7 --keep-weekly 9 --keep-monthly 13 --keep-yearly 3"

ENTRYPOINT ["/root/entrypoint.sh"]

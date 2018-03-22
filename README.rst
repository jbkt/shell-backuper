.. image:: https://img.shields.io/docker/pulls/anjos/backuper.svg
   :target: https://hub.docker.com/r/anjos/backuper/

=================================
 Restic_ Backup Docker Container
=================================

This is a docker container I use for backups on my QNAP NAS. It is largely
based on Lobaro's initial framework you can `find here
<https://github.com/Lobaro/restic-backup-docker>`_.

This container runs restic_ backups in regular intervals using cron. It supports
some configurability which helps before full-scale deployment.


Structure
---------

The container is based on:

* a 64-bit Linux binary, that is downloaded from the `restic releases`_ page.
  We don't compile it ourselves, but we check its SHA256 hash for conformity.
  The binary is installed as ``/bin/restic``
* scripts for setting-up the cron job, called ``backup/entrypoint.sh`` and
  running the backup jobs, called ``backup/run.sh``. The file
  ``backup/functions.sh`` contains shared functions between the two scripts and
  checks for environment sanity that are run every time each of these two main
  scripts are called.
* ``backup/entrypoint.sh`` is called once per container instantiation, while
  ``backup/run.sh`` is called everytime we need to perform a scheduled backup.
* The backup program in ``backup/run.sh`` is based on the environment settings
  you must pass when running the docker container using ``-e`` options to
  ``docker run``. You're supposed to override the variables using this
  technique. Alternatively, clone this repository, modify the variables in
  ``Dockerfile`` and rebuild the image to your liking.


The cron job is set up when the container is started. From this point onwards,
the only thing the container outputs is the equivalent of ``tail -f
/var/log/cron.log``.


Builds
------

You can build the container yourself using the following command::

  $ docker build --rm -t anjos/backuper:latest .


Tests
-----

I recommend you start running local tests to check your system is sane before
going for cloud-based setups.


Local filesystem
================

Edit the file ``envs/local.env`` to your liking. Create a data/repo directories
on your working directory and initialize the restic repository::

  $ mkdir data #fill-in with toy-data to "backup"
  $ mkdir repo #don't put anything
  $ restic -r repo init  #use password "test" or change file envs/local.env
  ...


Test the container with the following command::

  $ docker run -t --env-file envs/local.env -v `pwd`/data:/data -v `pwd`/repo:/repo anjos/backuper:latest


If you don't change the values in ``envs/local.env``, the cron job will run every
minute. Use the contents of ``./data`` to add/remove contents simulating your
usage. Backups are stored in ``./repo`` using a simple file backend. The
password is ``test``. The last 3 backups are kept.


Backblaze B2
============

Backblaze's B2 backup solution provides a free-tier which is useful to run
quick tests without incurring in cost. Edit the file ``envs/b2.env`` to your
liking. Create a directory named ``data`` on your working directory that will
contain your test data to backup. Initialize the B2's bucket::

  $ mkdir data #fill-in with toy-data to "backup"
  $ b2 authorized-account <set-account-id> <set-account-key>
  $ b2 create-bucket test allPrivate
  $ B2_ACCOUNT_ID=<set-account-id> B2_ACCOUNT_KEY=<set-account-key> restic -r 'b2:test' init
  ...


Test the container with the following command::

  $ docker run -t --env-file envs/b2.env -v `pwd`/data:/data anjos/backuper:latest


If you don't change the values in ``envs/b2.env``, the cron job will run
every minute. Use the contents of ``./data`` to add/remove contents simulating
your usage. Backups are stored in ``./backup`` using a simple file backend. The
password is ``test``. The last 3 backups are kept.


.. note::

   To delete all files in a bucket and then delete the bucket, do::

     $ mkdir empty
     $ cd empty
     $ b2 authorize-account ...
     $ b2 sync --delete . b2://mybucketname
     $ b2 delete-bucket mybucketname

Debug
-----

To start a new container, execute::

  $ docker run -ti --env-file envs/local.env -v `pwd`/data:/data -v `pwd`/repo:/repo --entrypoint=/bin/bash anjos/backuper:latest '-e'


From this point you can use restic_ and check things for yourself.


.. Your references go here:
.. _restic: https://restic.net
.. _restic releases: https://github.com/restic/restic/releases

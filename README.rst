.. image:: https://img.shields.io/docker/pulls/anjos/restic.svg
   :target: https://hub.docker.com/r/anjos/restic/

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

  $ docker build --rm -t anjos/restic:latest .


Tests
-----

Edit the file ``test.env`` to your liking. Test the container with the
following command::

  $ docker run -t --env-file test.env -v `pwd`/data:/data -v `pwd`/repo:backup anjos/restic:latest

If you don't change the values in ``test.env``, the cron job will run every
minute. Use the contents of ``./data`` to add/remove contents simulating your
usage. Backups are stored in ``./backup`` using a simple file backend. The
password is ``test``. The last 10 backups are kept.


Debug
-----

To enter your container execute::

  $ docker exec -ti backup-test /bin/sh


Now you can use restic_.


.. Your references go here:
.. _restic: https://restic.net
.. _restic releases: https://github.com/restic/restic/releases

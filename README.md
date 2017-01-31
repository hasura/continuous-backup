# Continuous backups on Hasura

We use the continuous archiving method of Postgres to backup your Postgres
database. This gives the flexibility of hot backups and Point-in-time recovery
(PITR).

We use [wal-e](https://github.com/wal-e/wal-e) to push the Postgres backups to
storage services of popular cloud providers. We **do not** keep your backups.

Currently we only support S3.

Support for Azure blob storage, Google container storage and OpenStack Swift is
coming soon.

## Overview

The way Hasura backup works is:

* You setup a S3 bucket, Azure blob storage, GCP container etc. - where you want
  to save your backups.

* Take the collection of sample Kubernetes resources files (in `k8s` folder),
  and edit the two files to put appropriate configuration data.

* Then run the shell script: `configure_backup.sh`. This will configure your
  Postgres instance with continuous backup.


What happens under the hood is, Postgres is configured with the archive command
to start continuous archiving and pushing the backups to your configured cloud
storage using wal-e.

Further reading:

* [Postgres continuous archiving](https://www.postgresql.org/docs/current/static/continuous-archiving.html)

* [Backup strategies on Postgres](https://www.postgresql.org/docs/current/static/backup.html)


# Configure backup on a Hasura project

* Download this repository.

* `k8s` folder lists all the Kubernetes resource files.

* You have to edit 2 files: the secret and configmap files:

  * Copy file `k8s/Secrets.yaml.template` into `k8s/Secrets.yaml`.
  * Open the `k8s/Secrets.yaml` file in an editor and put **base64 encoded**
    string of your AWS Access Key and AWS Secret Key.
  * Copy file `k8s/ConfigMap.yaml.template` into `k8s/ConfigMap.yaml`.
  * Open the `k8s/ConfigMap.yaml` file in an editor and put the path to your S3
    bucket (where you want the backups to be saved), and the AWS region.

* You can put these Kubernetes files in version control. But remember, **do
  not** put the `k8s/Secrets.yaml` and `k8s/ConfigMap.yaml` files in version
control. Or you risk leak of secret data!!

* Once the secrets and configmap are configured, we can run the script to
  configure our cluster.

* Make sure you have `kubectl` installed and the `current-context` is set to
  Hasura project cluster you are configuring the backup for.

* Then run:
  ```shell
  $ ./configure_backup.sh
  ```

### More options

If you ever want to stop the backup process altogether, you can run the
following script to do it.

* First, make sure you have followed the above steps and have configured the
  `k8s/Secrets.yaml` and `k8s/ConfigMap.yaml` files and also have installed and
configured `kubectl` correctly.

* Then run:
  ```shell
  $ ./stop_backup.sh
  ```

**NOTE**: This script is not guaranteed to have rolled back the postgres
deployment correctly. You might need to manually intervene.


# Recover from backup on a Hasura project

## Setup for the recovery

* Download this repository.

* `k8s` folder lists all the Kubernetes resource files.

* You have to edit 2 files: the secret and configmap files:

  * Copy file `k8s/Secrets.yaml.template` into `k8s/Secrets.yaml`.
  * Open the `k8s/Secrets.yaml` file in an editor and put **base64 encoded**
    string of your AWS Access Key and AWS Secret Key.
  * Copy file `k8s/ConfigMap.yaml.template` into `k8s/ConfigMap.yaml`.
  * Open the `k8s/ConfigMap.yaml` file in an editor and put the path to your S3
    bucket (where you want the backups to be saved), and the AWS region.

* You can put these Kubernetes files in version control. But remember, **do
  not** put the `k8s/Secrets.yaml` and `k8s/ConfigMap.yaml` files in version
control. Or you risk leak of secret data!!

## Configure the recovery to start

* Once the secrets and configmap are configured, we can run the script to
  configure our cluster.

* Make sure you have `kubectl` installed and the `current-context` is set to
  Hasura project cluster you are configuring the backup for.

* Then run:
  ```shell
  $ ./recovery.sh
  ```

## Checking status

The recovery process will take some time depending on your data and
size and number of backups.

You can see the status by looking at the logs of the postgres pod:

```shell
$ kubectl logs <postgres-pod-name> -n hasura
```

Alternatively, you can also check for a `recovery.done` file in the `PGDATA`
directory.


## Post recovery steps

**NOTE**: If this step is not completed, you won't be able to use the project.

When the database is recovered from a backup, it is an exact replica of the
source database. Hence everything, including postgres and project admin
paswords, will be as it is in the old project.

As a result, after the recovery is complete, we need to change the passwords of
the current project to that of the older project.

Follow the steps to achieve that:

* Make sure kubectl is pointing to old project:
  ```shell
    $ kubectl config set current-context <old-hasura-project>
  ```

* Then run:
  ```shell
    $ kubectl get secret postgres -n hasura -o yaml
  ```
  The value in postgres.password is the postgres admin password.
  Copy the value in the postgres.password field and keep it.

* Again:
  ```shell
    $ kubectl get secret auth -n hasura
  ```
  The value in django.sapass is the project admin password.
  Copy the value in the django.sapass field and keep it.

* Now switch to new project:
  ```shell
    $ kubectl config set current-context <new-hasura-project>
  ```

* Then run:
  ```shell
    $ kubectl edit secret postgres -n hasura
  ```
  In the postgres.password field, paste the value from previous step.

* And:
  ```shell
    $ kubectl edit secret auth -n hasura
  ```
  In the django.sapass field, paste the value from previous step.

* Now restart auth and data pods:

  ```shell
    $ kubectl delete pod <auth-pod-name> -n hasura
    $ kubectl delete pod <data-pod-name> -n hasura
  ```

Now you should be able to login to your new project with old project's
credentials.

# utapass-espresso-init.sh

This tool is used to initialize espresso environment.

It will do:
1. clone utapass android source code
2. cleaning up some legacy scripts in folder used by espresso
3. clong utapass espresso scripts

Here is an example:

```shell
$ pwd
/Users/paservanyu/git/utapass-sqa-tools

$ ls -l
total 16
-rw-r--r--  1 paservanyu  staff    19 Aug  9 10:15 README.md
-rw-r--r--@ 1 paservanyu  staff  1484 Aug  9 10:47 utapass-espresso-init.sh

$ sh ./utapass-espresso-init.sh
============================================================
Cloning Souce Code - Utapass Android
============================================================
Cloning into 'utapass'...
remote: Counting objects: 283378, done.
remote: Compressing objects: 100% (564/564), done.
remote: Total 283378 (delta 404), reused 715 (delta 242), pack-reused 282316
Receiving objects: 100% (283378/283378), 175.98 MiB | 2.68 MiB/s, done.
Resolving deltas: 100% (160356/160356), done.

============================================================
Cleaning Folder - utapass/app/src/androidTest/java/com/kddi/android/UtaPass
============================================================
Done

============================================================
Cloning Souce Code (submodule) - Utapass Espresso
============================================================
Cloning into '/Users/paservanyu/git/utapass-sqa-tools/utapass/app/src/androidTest/java/com/kddi/android/UtaPass/sqa_espresso'...
remote: Counting objects: 267, done.
remote: Compressing objects: 100% (106/106), done.
remote: Total 267 (delta 184), reused 237 (delta 158), pack-reused 0
Receiving objects: 100% (267/267), 52.65 KiB | 261.00 KiB/s, done.
Resolving deltas: 100% (184/184), done.

$ ls -l utapass
total 80
-rw-r--r--  1 paservanyu  staff  1907 Aug  9 10:49 README.md
drwxr-xr-x  7 paservanyu  staff   224 Aug  9 10:49 app
-rw-r--r--  1 paservanyu  staff  1326 Aug  9 10:49 build.gradle
drwxr-xr-x  8 paservanyu  staff   256 Aug  9 10:49 common
drwxr-xr-x  5 paservanyu  staff   160 Aug  9 10:49 daogenerator
drwxr-xr-x  7 paservanyu  staff   224 Aug  9 10:49 data
-rw-r--r--  1 paservanyu  staff  7486 Aug  9 10:49 dependencies.gradle
drwxr-xr-x  6 paservanyu  staff   192 Aug  9 10:49 domain
drwxr-xr-x  3 paservanyu  staff    96 Aug  9 10:49 gradle
-rw-r--r--  1 paservanyu  staff    53 Aug  9 10:49 gradle.properties
-rwxr-xr-x  1 paservanyu  staff  5080 Aug  9 10:49 gradlew
-rw-r--r--  1 paservanyu  staff  2404 Aug  9 10:49 gradlew.bat
-rw-r--r--  1 paservanyu  staff   877 Aug  9 10:49 settings.gradle
-rw-r--r--  1 paservanyu  staff  3102 Aug  9 10:49 testing_tasks.gradle

$ ls -l utapass/app/src/androidTest/java/com/kddi/android/UtaPass/sqa_espresso
total 32
-rw-r--r--  1 paservanyu  staff  1774 Aug  9 10:50 BasicTest.java
-rw-r--r--  1 paservanyu  staff  3861 Aug  9 10:50 MyTest.java
-rw-r--r--  1 paservanyu  staff    18 Aug  9 10:50 README.md
-rw-r--r--  1 paservanyu  staff  4074 Aug  9 10:50 StreamRatTest.java
drwxr-xr-x  7 paservanyu  staff   224 Aug  9 10:50 common
drwxr-xr-x  8 paservanyu  staff   256 Aug  9 10:50 pages
drwxr-xr-x  9 paservanyu  staff   288 Aug  9 10:50 util

$
```

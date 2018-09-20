To setup this demo, first you need to provision the project and kafka via strimzi using this script:

```
cd support
./strimzi-master.sh
```

And then run the setup.sh script to create the whole project:

```
./setup.sh 192.168.86.250.nip.io
```

Where the parameter is the wildcard domain used for apps (could be ```apps.ocplab.com``` for example in a full installation of Openshift.

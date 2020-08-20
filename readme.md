Cloud native ci and build box

Cloud native ci and build box. Has all the features for building S2I images, helm charts, operators, docker, ansible and deployment to kubernetes and openshift.

If Selinux is set to enforcing run those commadn first:

```bash
chcon -Rt svirt_sandbox_file_t $(HOME)/.kube 
chcon -Rt svirt_sandbox_file_t $(pwd)
```

```bash
docker run -it -v $HOME/.kube:/root/.kube -v $(pwd):/src -w /src xrowgmbh/s2i bash
```

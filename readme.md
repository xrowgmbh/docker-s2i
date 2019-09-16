Cloud native ci and build box

Cloud native ci and build box. Has all the features for building S2I images, helm charts, operators, docker, ansible and deployment to kubernetes and openshift.

docker run -it -v /root/.kube:/root/.kube -v $(pwd):/root/files xrowgmbh/s2i bash

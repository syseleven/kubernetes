REGISTRY=syseleven
VERSION=$(shell if [ -n "$$TRAVIS_TAG" ]; then echo "$$TRAVIS_TAG"; else hack/print-workspace-status.sh | grep gitVersion | awk '{print $$2}'; fi)

default: compile create-and-tag-image

compile:
	build/run.sh make all KUBE_BUILD_PLATFORMS=linux/amd64 KUBE_VERBOSE=2

create-and-tag-image:
	$(MAKE) -C cluster/images/hyperkube REGISTRY=$(REGISTRY) VERSION=$(VERSION) build

ci-push-image:
	echo "$$DOCKER_PASSWORD" | docker login -u "$$DOCKER_USERNAME" --password-stdin
	docker push "$(REGISTRY)/hyperkube-amd64:$(VERSION)"

ci-upload-kubelet-binary:
	docker run -e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY -v $(PWD)/_output/dockerized/bin/linux/amd64:/binaries schickling/s3cmd --host=s3.dbl.cloud.syseleven.net --host-bucket='%(bucket).s3.dbl.cloud.syseleven.net' put -P /binaries/kubelet s3://sys11-metakube-kubelet/$(VERSION)/

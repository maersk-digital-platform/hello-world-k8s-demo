ifneq (,)
This makefile requires GNU Make.
endif

# Git variables
GIT_COMMIT ?= $(shell git log -1 --pretty=format:"%H")
GIT_COMMIT_SHORT ?= $(shell git log -1 --pretty=format:"%h")
GIT_BRANCH ?= $(shell git branch | grep '*' | sed 's/* //')
SAFE_GIT_BRANCH ?= $(shell echo $(GIT_BRANCH) | sed 's@/@-@' | tr -s -c '\n\-\+a-z0-9' | tr '[:upper:]' '[:lower:]')

# K8s manifests variables
IMAGE_ID := maerskao.azurecr.io/k8s-hello-world-k8s
NAMESPACE := k8s-hello-world-k8s-${GIT_BRANCH}
TAG := v1
# TAG := v2

docker_build:
	@test -n "$(IMAGE_ID)" || (echo "Variable IMAGE_ID not set"; exit 1)
	@test -n "$(GIT_COMMIT)" || (echo "Variable GIT_COMMIT not set"; exit 1)
	docker build -t "${IMAGE_ID}:${TAG}" --build-arg version="${TAG}" .
.PHONY: docker_build

docker_push:
	docker push "${IMAGE_ID}:${TAG}"
.PHONY: docker_push

tag-latest:
	docker tag ${IMAGE_ID}:${TAG}

_replace_vars:
	$(eval DOMAIN := hello-world-k8s.dev.maersk-digital.net)

	rm -rf ./.tmp_k8s &> /dev/null
	sleep 1 # prevent rm -rf to race against mkdir. BUG found on docker/ubuntu
	mkdir -p ./.tmp_k8s
	for file in ./k8s/*; do \
		cat $$file | \
			sed -e "s#__IMAGE_ID__#$(IMAGE_ID)#" | \
			sed -e "s#__GIT_COMMIT__#$(GIT_COMMIT)#" | \
			sed -e "s#__GIT_BRANCH__#$(SAFE_GIT_BRANCH)#" | \
			sed -e "s#__GIT_COMMIT_SHORT__#$(GIT_COMMIT_SHORT)#" | \
			sed -e "s#__NAMESPACE__#$(NAMESPACE)#" | \
			sed -e "s#__DOMAIN__#$(DOMAIN)#" \
			sed -e "s#__TAG__#$(TAG)#" \
		>> ./.tmp_k8s/`basename $$file` ;\
	done
.PHONY: _replace_vars

k8s_deploy: _test_variables _replace_vars
	@test -n "$(NAMESPACE)" || (echo "Variable NAMESPACE not set"; exit 1)
	kubectl get ns "${NAMESPACE}" || kubectl create ns "${NAMESPACE}"
	kubectl apply -R -f ./.tmp_k8s/
.PHONY: k8s_deploy

_test_variables:
	@test -n "$(IMAGE_ID)" || (echo "Variable IMAGE_ID not set"; exit 1)
	@test -n "$(GIT_COMMIT)" || (echo "Variable GIT_COMMIT not set"; exit 1)
	@test -n "$(GIT_COMMIT_SHORT)" || (echo "Variable GIT_COMMIT_SHORT not set"; exit 1)
	@test -n "$(GIT_BRANCH)" || (echo "Variable GIT_BRANCH not set"; exit 1)
	@test -n "$(SAFE_GIT_BRANCH)" || (echo "Variable SAFE_GIT_BRANCH not set"; exit 1)
	@test -n "$(NAMESPACE)" || (echo "Variable NAMESPACE not set"; exit 1)
.PHONY: _test_variables

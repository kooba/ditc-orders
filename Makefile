CONTEXT ?= docker-for-desktop
NAMESPACE ?= default
TAG ?= $(shell git rev-parse HEAD)
REF ?= $(shell git branch | grep \* | cut -d ' ' -f2)

# docker

run-wheel-builder:
	docker run --rm \
		-v "$$(pwd)":/application -v "$$(pwd)"/wheelhouse:/wheelhouse \
		jakubborys/ditc-wheel-builder:latest;

build-image:
	docker build -t jakubborys/ditc-orders:$(TAG) .;

push-image:
	docker push jakubborys/ditc-orders:$(TAG)

build: run-wheel-builder build-image push-image

# Kubernetes

test-chart:
	helm upgrade orders-$(NAMESPACE) charts/orders --install \
	--namespace=$(NAMESPACE) --kube-context $(CONTEXT) \
	--dry-run --debug --set image.tag=$(TAG)

install-chart:
	helm upgrade orders-$(NAMESPACE) charts/orders --install \
	--namespace=$(NAMESPACE) --kube-context=$(CONTEXT) \
	--set image.tag=$(TAG)

lint-chart:
	helm lint charts/orders --strict

# Bridage

install-brigade-deps:
	yarn install

lint-brigade:
	./node_modules/.bin/eslint brigade.js

run-brigade:
	echo '{"name": "$(ENV_NAME)"}' > payload.json
	brig run -c $(TAG) -r $(REF) -f brigade.js -p payload.json \
	kooba/ditc-orders --kube-context $(CONTEXT) --namespace brigade
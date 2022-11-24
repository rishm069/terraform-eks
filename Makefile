TERRAFORM_DIR = ./terraform
HELM_RELEASE_NAME = dummy-app
HELM_RELEASE_DIR = ./helm
HELM_RELEASE_NAMESPACE = $(shell terraform -chdir=${TERRAFORM_DIR} output -raw app_namespace)
APP_HOSTNAME := example.com
IMAGE_TAG = 1.0.0

up-all: up-infra up-app
up-infra: auto-terraform-apply
up-app: configure-kubectl build-and-push helm-dry-run helm-deploy

build-and-push: docker-build docker-login docker-push
docker-build:
	docker build ./app -f docker/Dockerfile -t $(shell terraform -chdir=${TERRAFORM_DIR} output -raw registry_url):${IMAGE_TAG}
docker-login:
	aws ecr get-login-password --region $(shell terraform -chdir=${TERRAFORM_DIR} output -raw region) | docker login --username AWS --password-stdin $(shell terraform -chdir=${TERRAFORM_DIR} output -raw registry_url | cut -d'/' -f1) 
docker-push:
	docker push $(shell terraform -chdir=${TERRAFORM_DIR} output -raw registry_url):${IMAGE_TAG}

helm-dry-run:
	helm install $(HELM_RELEASE_NAME) $(HELM_RELEASE_DIR) \
		--dry-run --debug -n ${HELM_RELEASE_NAMESPACE} \
		--set image.tag=${IMAGE_TAG} \
		--set image.repository=$(shell terraform -chdir=${TERRAFORM_DIR} output -raw registry_url) \
		--set ingress.host=$(APP_HOSTNAME)
helm-deploy:
	helm upgrade $(HELM_RELEASE_NAME) $(HELM_RELEASE_DIR) \
		--install --atomic --debug -n ${HELM_RELEASE_NAMESPACE} \
		--set image.tag=${IMAGE_TAG} \
		--set image.repository=$(shell terraform -chdir=${TERRAFORM_DIR} output -raw registry_url) \
		--set ingress.host=$(APP_HOSTNAME)

local-check:
	kubectl -n ${HELM_RELEASE_NAMESPACE} port-forward $(shell kubectl get pods --no-headers -o custom-columns=":metadata.name" -n ${HELM_RELEASE_NAMESPACE} | tail -n1) 8080:80

get-lb-ip:
	kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq .status.loadBalancer.ingress[].hostname

configure-kubectl:
	aws eks --region $(shell terraform -chdir=${TERRAFORM_DIR} output -raw region) update-kubeconfig --name $(shell terraform -chdir=${TERRAFORM_DIR} output -raw cluster_name)

init:
	terraform -chdir=${TERRAFORM_DIR} init
plan:
	terraform -chdir=${TERRAFORM_DIR} plan
apply:
	terraform -chdir=${TERRAFORM_DIR} apply
destroy:
	terraform -chdir=${TERRAFORM_DIR} destroy

auto-terraform-%:
	terraform -chdir=${TERRAFORM_DIR} $* -auto-approve

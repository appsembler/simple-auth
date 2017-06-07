.PHONY = clean build baked migrate shell run db-shell db-restore createsuperuser collectstatic \
	test makemigrations repl push pull

IMAGE_NAME = denibertovic/simple-auth
REPO_VERSION ?= $(shell git rev-parse --short HEAD 2> /dev/null)

# ============= Docker (Dockerfiles and Images) =============== #
build:
	@docker build --rm -t $(IMAGE_NAME):onbuild-$(REPO_VERSION) -f Dockerfile.onbuild .
	@docker tag $(IMAGE_NAME):onbuild-$(REPO_VERSION) $(IMAGE_NAME):onbuild-latest

baked: build
	@docker build --rm -t $(IMAGE_NAME):latest -f Dockerfile .
	# @docker tag $(IMAGE_NAME):$(REPO_VERSION) $(IMAGE_NAME):latest

pull:
	@docker pull $(IMAGE_NAME):onbuild-$(REPO_VERSION)
	@docker pull $(IMAGE_NAME):onbuild-latest
	@docker pull $(IMAGE_NAME):$(REPO_VERSION)
	@docker pull $(IMAGE_NAME):latest

push:
	@docker push $(IMAGE_NAME):onbuild-$(REPO_VERSION)
	@docker push $(IMAGE_NAME):onbuild-latest
	@docker push $(IMAGE_NAME):$(REPO_VERSION)
	@docker push $(IMAGE_NAME):latest


# ============== Misc ================ #
clean:
	@rm -rf .coverage cover
	@find . -name '*.pyc' -exec rm '{}' ';'

# # "bash -c" doesn't open an interactive session so we run another bash instance from it
shell:
	@docker exec -it `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth; bash"

db-restore:
	@if [ ! -f simpleauthdb.sql ]; then \
		echo "Aborting! Can't find backup file. Database backup file must be named simpleauth.sql and located in the current directory!"; \
		exit 1; \
	fi
	@echo "Restoring database from backup file: simpleauth.sql"
	@cat simpleauth.sql | docker exec -i `docker-compose ps -q postgres` psql -Upostgres

# ================ Django Tests =================== #
## To pass additional parameters to py.test, use e.g. `make test what='-k TestContainerAccessPoints'`
## -- that will run only the tests from the TestContainerAccessPoints test case
##
## Read more at https://pytest.org/latest/usage.html#specifying-tests-selecting-tests
test:
	@docker exec -it `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && TEST_ENV=1 py.test $(what)"

# =========== Django Commands ================= #
makemigrations:
	@docker exec -it `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && python manage.py makemigrations $(app)"

collectstatic:
	@docker exec -i `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && python manage.py collectstatic --noinput"

createsuperuser:
	@docker exec -it `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && python manage.py createsuperuser"

db-shell:
	@echo "Starting interactive database prompt (current dir mounted to /tmp/codebase)...";
	@docker exec -it `docker-compose ps -q postgres` psql -Upostgres

migrate:
	@docker exec -i `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && python manage.py migrate $(what)"

repl:
	@docker exec -it `docker-compose ps -q web` /bin/bash -c "cd /opt/simple-auth/simple_auth && ./manage.py shell"


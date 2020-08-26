## The Makefile includes instructions on running the commands

docker-build: docker build --tag=capstone .

lint:
	hadolint Dockerfile

all: install lint test

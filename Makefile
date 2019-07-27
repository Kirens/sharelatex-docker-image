# Makefile
build:
	docker build -f Dockerfile -t dtek/sharelatex .


run: build
	docker-compose up

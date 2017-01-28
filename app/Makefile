registry := hasura
version := 9.6.1-r1

export PG_MAJOR=9.6
export PG_VERSION=9.6.1-1.pgdg80+1

image: Dockerfile
	docker build -t $(registry)/postgres-wal-e:$(version) .

push: Dockerfile
	docker push $(registry)/postgres-wal-e:$(version)

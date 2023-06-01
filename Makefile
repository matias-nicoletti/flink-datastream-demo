PROJECT_NAME=flink-datastream-demo
PROJECT_VERSION=0.0.1-SNAPSHOT
JAR_FILE=${PROJECT_NAME}-${PROJECT_VERSION}.jar
FLINK_VERSION=1.16.0
SCALA_VERSION=2.12
JAVA_HOME_VERSION=11
AMD64_CORRETTO_JAVA_VERSION=11-x64
ARM64_CORRETTO_JAVA_VERSION=11-aarch64
DOCKER_IMAGE_NAME=flink-datastream-demo
MAIN_CLASS=com.matiasnicoletti.flinkdatastreamdemo.UnboundedSourceSampleJob

mvn-build:
	mvn clean install

start-cluster: mvn-build
	# Build the image based on the architecture of the processor on current env
	$(eval ARCHITECTURE=$(shell uname -m))
	if [ "$(ARCHITECTURE)" = "x86_64" ]; then\
		docker build --build-arg CORRETTO_JAVA_VERSION=$(AMD64_CORRETTO_JAVA_VERSION) --build-arg JAVA_HOME_VERSION=$(JAVA_HOME_VERSION) --build-arg FLINK_VERSION=$(FLINK_VERSION) --build-arg SCALA_VERSION=$(SCALA_VERSION) --build-arg ARCHITECTURE="x86_64" -f Dockerfile . -t $(DOCKER_IMAGE_NAME) ; \
    fi
	if [ "$(ARCHITECTURE)" = "arm64" ]; then\
		docker build --build-arg CORRETTO_JAVA_VERSION=$(ARM64_CORRETTO_JAVA_VERSION) --build-arg JAVA_HOME_VERSION=$(JAVA_HOME_VERSION) --build-arg FLINK_VERSION=$(FLINK_VERSION) --build-arg SCALA_VERSION=$(SCALA_VERSION) --build-arg ARCHITECTURE="aarch64" -f Dockerfile . -t $(DOCKER_IMAGE_NAME) ; \
	fi
	# Run the container, create binding for UI
	docker run -e USER -t -d -p 8081:8081 --name $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE_NAME)
	# Copy the job jar to the container
	docker cp ./target/${JAR_FILE} ${DOCKER_IMAGE_NAME}:/
	# Start up the flink cluster
	docker exec ${DOCKER_IMAGE_NAME} /bin/bash -c "/flink-$(FLINK_VERSION)/bin/start-cluster.sh"
	docker exec ${DOCKER_IMAGE_NAME} /bin/bash -c  "/flink-$(FLINK_VERSION)/bin/flink run -c ${MAIN_CLASS} /${JAR_FILE}"

stop-cluster:
	docker stop ${DOCKER_IMAGE_NAME} || true
	docker rm ${DOCKER_IMAGE_NAME} || true
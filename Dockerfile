# Container image that runs your code
FROM alpine:3.10

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY create_maven_settings.sh /create_maven_settings.sh

# Code file to execute when the docker container starts up (`create_maven_settings.sh`)
ENTRYPOINT ["/create_maven_settings.sh"]
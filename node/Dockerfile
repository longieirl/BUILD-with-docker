#
# NodeJS Dockerfile
#

# Base
FROM longieirl/build-base

MAINTAINER Build Team

VOLUME ["/app"]
WORKDIR /app

# Ensure node is configured
RUN node -v && \
    npm -v

# Run the application
CMD [ "node" ]
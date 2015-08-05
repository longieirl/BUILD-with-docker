#
# NodeJS Dockerfile
#

# Base image
FROM longieirl/node:0.10.38

MAINTAINER jlongieirl@gmail.com

# Bundle app source
ADD build /build

VOLUME ["/build"]
WORKDIR /build

# Run the application
CMD ["node", "/build/server/app.js"]
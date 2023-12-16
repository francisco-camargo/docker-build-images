FROM node:14.16.0-alpine3.13
    # base image, don't ever use the "latest" tag
    # we went to dockerhub and found a tag that corresponds to an image we are happy with
RUN addgroup app && adduser -S -G app app
    # Let's add a user
    # Run any commands that we would normally run in a terminal session
    # This command is run when the image is being built; it is a buildtime instruction
USER app
    # Switch to this user
    # can check the current user with the whoami terminal command
    # run ls -l to view permissions of each file
    # By switching to the app user here, all the Dockerfile
        # commands that remain will be run as the app user
WORKDIR /app
    # Make /app the working directory of the image
COPY package.json .
RUN npm install
COPY . .
    # Copy all files in current directory into the image
ENV API_URL=http://api.myapp.com/
    # Set environment variables
    # view all environment variables in Linux with the printenv terminal command
    # or specify the variable; printenv API_URL or echo $API_URL
EXPOSE 3000
    # To tell what port this container will be listening on
CMD ["npm", "start"]
    # Command instruction in "Exec form"; this avoids spinning up another shell process
    # only the last CMD in a Dockerfile will take effect
    # CMD is a runtime instruction; it is executed when starting a container
# ENTRYPOINT ["npm", "start"]
    # could use this instead of CMD, this is nice because it takes a bit more
        # effort to accidentaly do something else, ie. pass a CMD option as a suffix
        # when running docker run which would override the CMD in this Dockerfile

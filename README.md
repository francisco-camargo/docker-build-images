Getting Started with Create React App
====================

***This project is based on the course [The Ultimate Docker Course](https://codewithmosh.com/p/the-ultimate-docker-course) by Mosh Hamedani. This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).***

Francisco Camargo

# Docker

Docker provides [samples](https://docs.docker.com/samples/) of Dockerfiles.

An image can be stored in any registry, not just DockerHub. Consequently, a `Dockerfile` can point to an image (using `FROM`) from any registry.

View this projects `Dockerfile` as example with comments.

Similar to `.gitignore`, the `.dockerignore` file is used to excludes files from being added to the image we will build.

## Building and Running Images

Build an image

`docker build --tag react-app .`

List images

`docker image ls`

or

`docker images`

View running processes

`docker ps`

View all processes with `-a`, including stopped once with

`docker ps -a`

### Run Images
Run image

`docker run -it react-app sh`

We use `sh` to use shell because the image we have defined does not have bach installed. Use `-it` to run image in interactive move. To exit the image use the `exit` command or the shortcut `Ctrl+D` (or `Ctrl+C`?). [Guide](https://vsupalov.com/exit-docker-container/), also talks about deamon mode.

Instead of running in interactive mode, we could instead direct the `docker run` command to run `npm start`

`docker run react-app npm start`

Exit with `Ctrl+C`

If we don't want to have to add the `npm start` suffix to the `docker run` command, we can add this to the `Dockerfile`

`--name` option let's us assign the name of a container ourselves

#### Detached Mode
Can run containers in detached mode (in the background) such that you can still work in the terminal

`docker run -d react-app`

This let's us spin up multiple containers in the background using the same terminal

#### Container Logs
`docker logs --help`

The `-f` option to follow lets us see logs in real-time
`-n` let's us see the last `n` lines

`docker logs -n 10 <identifier>`

`-t` adds timestamps to each line

### Ports
Having run `npm start` we see

```bash
  Local:            http://localhost:3000
  On Your Network:  http://172.17.0.2:3000
```
By looking at Local, we see that the webserver started on port 3000. This is port 3000 of the container, not localhost. That means, if we go to this address in the browser, we won't see our application.

`docker run -d -p <host port>:<container port> --name <container name> <id>`

`docker run -d -p 80:3000 --name big-bird react-app:1.0.0`

View logs

`docker logs -n 10 big-bird`

View containers which will tell us about the ports

`docker ps`

In the host machine, can now go to `http://localhost:<host port>` and we should see the React app working! Eg. `http://localhost:80`

### Image Layers
View image layers with

`docker history react-app`

To rebuild using cached layers (to avoid long wait times in running `docker run`) we need to avoid having an early layer that depends on frequent changes that are made to the source code. Instead let's have early layers be concerned with installing third-party dependencies. So let's split `COPY . .` into `COPY package.json .` and in a later layer use `COPY . .`. Note that to see the effects of caching, you have to build the image at least a second time.

In summary, instructions that change infrequently should be towards the top of the `Dockerfile`, and vice-versa.

### Remove Images
As we rebuilt the same images, older images remained but lost their tag. You can see this by running 

`docker images`

First get rid of any unwanted containers

`docker container prune`

This will remove all stopped/exited containers. Now we can prune unwanted images,

`docker image prune`

will remove imaged without tags. To remove specific images, run

`docker image rm <id>`

Where `<id>` is either the tag (`REPOSITORY`) or `IMAGE ID` (can use first 3 characters of the ID)

### Explicit Tags
Use explicit tags to keep track of images. This is critical when images will be used in production.

Can tag an image while building it

`docker build -t <image name>:<tag> .`

`docker build -t react-app:1.0.0 .`

To tag an image after building it

`docker image tag <old id> react-app:<new tag>` 

where `<old id>` can be the current tag (eg. `react-app:latest`) or the `IMAGE ID`

Warning: the `latest` tag may end up not actually being the latest version of the image! Thus you should avoid depending on images with the `latest` tag and instead tag images explicitly!

## Sharing Images

### Push Images to dockerhub
Create a repository on [dockerhub](hub.docker.com) and whatever the name of the repo is, use that as the tag to the image. For example, I have created the repo `franciscocamargo/react-app` so tag an image as

`docker image tag b50 franciscocamargo/react-app:1.0.0`

You will end up with multiple tags that point to the same image; you can see this by observing that when you run `docker images` there are multiple rows (tags) with the same `IMAGE ID`.

Now let's login

`docker login`

And push

`docker push franciscocamargo/react-app:1.0.0`

### Sharing Image as Files

To save an image to a `tar` file, run

`docker image save -o <output file name> <id>`

`docker image save -o react-app.tar react-app:1.0.0`

If we look inside the resulting `tar` file we will see folders corresponding to the individual layers of the image.

To load an image from a file, run

`docker image load -i <filename>`

`docker image load -i react-app.tar`

Warning: if you are continuing to build images, be sure that the (large) `tar` file is not being added to the build, this could otherwise cause unnecessary slowdowns and bloat.

## Working with Containers

### Docker Execute
Execute command in a running container

`docker exec big-bird ls`

This will print out the contents of the working directory (which was set in `Dockerfile` via `WORKDIR`)

Note: `docker run` starts a *new* container and runs a command

Let's instead start an interactive shell instance in this same container

`docker exec -it big-bird sh`

### Stopping and Starting Containers

`docker stop big-bird`

`docker start big-bird`

Where as `docker run` kick-off a new instance of a container from an image, `docker start` restarts a stopped container.

### Remove Containers
`docker container rm big-bird`

`docker rm big-bird`

But you cannot remove a running container, so `docker stop` the container and then `docker rm`. Or we could force the removal

`docker rm -f big-bird`

To [stop](https://stackoverflow.com/questions/45357771/stop-and-remove-all-docker-containers) all active containers

`docker stop $(docker ps -a -q)`

then run `docker container prune`
or to remove all containers

`docker container rm -f $(docker container ls -aq)`

Then to deal with the images

`docker image rm $(docker image ls -q)`

However, if multiples tags reference the same `IMAGE ID`, you will have to remove those manually.

### Persisting Data using Volumes
Persist files using space in the host machine, that is, `Volumes`

`docker volume create <folder name>`

`docker volume create app-data`

List volumes

`docker volume ls`

Get meta-data of a volume

`docker volume inspect <folder name>`

This will tell you the `Mountpoint`, that is, the location on the host machine where this `Volume` is. 

On a Windows machine using WSL with Docker running, I found volumes in `\\wsl.localhost\docker-desktop-data\mnt\wslg\distro\data\docker\volumes`, but you may have took look around as there are varied [possibilities](https://stackoverflow.com/questions/43181654/locating-data-volumes-in-docker-desktop-windows).

Let's map the volume in the host machine to a location in the container of interest, we do this with the `-v` option

`docker run -d -p <host port>:<container port> -v <volume>:<container folder> <container name>`

`docker run -d -p 4000:3000 -v app-data:/app/data react-app:1.0.0`

If either the volume or the target container folder does not exist, they will be created when this command is executed. The trouble with this, is the Docker will only give write permissions to the `<container folder>` to the `root` user.

So let's circumvent this by making the desired `/data` directory in the `Dockerfile` after `USER app`. This way, the `app` user has write permissions. We do this by adding a `RUN mkdir data` line right after the line `WORKDIR /app`.

So build a new image now that we have modified the `Dockerfile` 

`docker build -t react-app .`

and run it

`docker run -d -p 5000:3000 -v app-data:/app/data react-app`

Let's open up shell within this new container

`docker exec -it <id> sh`

`docker exec -it 75a sh`

We can immediately see that there is a `/data` directory if we run `ls`. Let's create a text file and place it within `/app/data`

`echo data > data/data.txt`

The punch-line: even if this container gets deleted, the files inside of `/app/data` will still exist! They persist in the local host (wherever `Mountpoint` is). Furthermore, you can share a volume across multiple containers.

#### Sharing Source Code with a Container
If we want to push to production, you should always make a new image of the most updated version of the project. However, during development we need a way to make changes to the source code and have them reflected within the containerized application. To do this we will use volumes to map the current working directory of the host which contains the source code to the working directory of the container. With these two directories linked, when a change is made to the source code in the host machine it will instantly be reflected within the container.

Set user to `root` to make sure permissions isn't the problem.

`docker run -d -p 5001:3000 -v "$(pwd):/app" react-app`

Syntax may [vary](https://stackoverflow.com/questions/41485217/mount-current-directory-as-a-volume-in-docker-on-windows-10) depending on the host operating system.

Seems like running `docker` within VSCode which thus uses WSL2 has problems. So let's try sharing code by running `docker run` from Windows PowerShell

From [Mosh](https://forum.codewithmosh.com/t/help-im-unable-to-map-a-local-working-dir-to-container/15775/2) [forum](https://forum.codewithmosh.com/t/using-docker-run-with-pwd-on-windows-powershell/7262/2), added `.env` file and rebuild image.

Can use a relative path, but this did not remedy the problem
`docker run -d -p 1001:3000 -v ~/Desktop/git/docker-build-images:/app react-app`
The app runs but it does not have a live feed of the source code in the host.

Have not been able to get this to work...

### Copy Files Between the Host and the Containers

Copy a file from a container to the host

`docker cp <container id>:<filepath> <host path>`

`docker cp 849:/app/data/data.txt .`

Where `.` point to the current directory in the host.

The reverse is also possible, move a file from the host into a container. So for example, from the host working directory run

`echo hello > secret.txt`

`docker cp secret.txt 849:/app`

At this point we have made a file and moved it. We can verify by interacting with the container

`docker exec -it 849 sh`

`ls`

and we will see `secret.txt` listed.

Note that this exemplifies how we can handle a secret file which must not live in the code repo but is needed within the container in order for the application to function.

# Available Scripts

In the project directory, you can run:

## `yarn start`

Runs the app in the development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.
You will also see any lint errors in the console.

## `yarn test`

Launches the test runner in the interactive watch mode.
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

## `yarn build`

Builds the app for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

## `yarn eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

# Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

## Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

## Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

## Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

## Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

## Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

## `yarn build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)

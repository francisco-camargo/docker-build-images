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

### Ports
Having run `npm start` we see

```bash
  Local:            http://localhost:3000
  On Your Network:  http://172.17.0.2:3000
```
By looking at Local, we see that the webserver started on port 3000. This is port 3000 of the container, not localhost. That means, if we go to this address in the browser, we won't see our application.

### Image Layers
View image layers with `docker history react-app`

To rebuild using cached layers (to avoid long wait times in running `docker run`) we need to avoid having an early layer that depends on frequent changes that are made to the source code. Instead let's have early layers be concerned with installing third-party dependencies. So let's split `COPY . .` into `COPY package.json .` and in a later layer use `COPY . .`. Note that to see the effects of caching, you have to build the image at least a second time.

In summary, instructions that change infrequently should be towards the top of the `Dockerfile`, and vice-versa.

### Remove Images
As we rebuilt the same images, older images remained but lost their tag. You can see this by running `docker images`

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
`docker image tag b50 franciscocamargo/react-app`

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

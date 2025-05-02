# Charoom with Salt
This is a repo meant for documentation of me practicing Salt. Here I've built a saltstack 
which will setup a live chatroom where users can, without registering, enter into
a chatroom and talk to other users connected via websockets. Users can create 
their own rooms or chat in the default main room where users are introduced to 
upon entering the chat service after choosing (or not choosing) a name.

## How to set it up?
To begin, this repository should be cloned into a directory where your salt master can reach
the .sls files. In my case this is in `/srv/salt`.

```bash
cd /srv/salt
git clone git@github.com:p-lemonish/chatroom-salt.git
```

Then, for example in the home directory, clone my repositories `chatroom-react` 
and `chatroom-go`.

```bash
git clone git@github.com:p-lemonish/chatroom-go.git
git clone git@github.com:p-lemonish/chatroom-react.git
```

Go into the `chatroom-react`-directory and clean install & build. After it's done,
tarball the `dist`-directory and move it to `/srv/salt/chatroom/frontend`.

```bash
cd chatroom-react/
npm ci && npm run build
tar cvf dist.tar.gz dist
mv dist.tar.gz /srv/salt/chatroom/frontend/
```

Next go into `chatroom-go` and build the docker image then tag it as stage as 
currently this practice is done in a staging environment before deploying to
my own server. After tagging, save it as `.tar`, then move it to 
`/srv/salt/chatroom/backend`.

```bash
cd chatroom-go/
docker build -t chatroom-backend .
docker tag chatroom-backend:latest chatroom-backend:stage
docker save chatroom-backend:stage -o chatroom-backend.tar
mv chatroom-backend.tar /srv/salt/chatroom/backend/
```

Almost there! Now assuming your minion is up and listening. Running the following
commands should run it all up. Replace `'*'` with your the minion name if required.

```bash
sudo salt '*' state.apply chatroom.frontend
sudo salt '*' state.apply chatroom.backend
```

Next, since the `nginx` configuration file has set the vhost as `chatroom-example.com`
add a temporary line in your `/etc/hosts/`

```bash 
YOUR-MINION-IP chatroom-example.com
```

Now entering `chatroom-example.com` on the browser should present you with the 
starting page of the chatroom! Enter a name or leave it blank and press the "Chat!"
button to see the chatting interface. Next this should be spun up on a server where
other people can also interact with the chat.

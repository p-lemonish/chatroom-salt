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
git clone git@github.com:p-lemonish/chatroom-salt.git chatroom
```

Note that the directory should be named `chatroom`.

Then, for example into the home directory, clone my repositories `chatroom-react` 
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

Next go into `chatroom-go` and build the docker image, then tag it as dev or prod
depending on if you're deploying this image into production (on a server requiring ssl)
or locally (can use self signed certs).

After tagging, save it as `.tar` using 
`docker save` and give sufficient rights (mode 644), then move it to `/srv/salt/chatroom/backend`.

The example below sets the tag as `dev`. For prod, append `-prod` to the tarfile instead.

```bash
cd chatroom-go/
docker build -t chatroom-backend:latest .
docker tag chatroom-backend:latest chatroom-backend:dev
docker save chatroom-backend:dev -o chatroom-backend-dev.tar
chmod 644 chatroom-backend-dev.tar
mv chatroom-backend-dev.tar /srv/salt/chatroom/backend/
```

Before running the Salt state, we should check up with pillars.

### Pillar examples

Under `chatroom-salt/pillar/examples/` you’ll find four `.example` files

- `chatroom.sls` (shared SSL paths)
- `dev.sls` (dev mode and domain)
- `prod.sls` (prod mode and domain)
- `top.sls` (mapping minions -> pillar sets)

Copy them into your real pillar directory and edit the values as needed

```bash
cd /srv/pillar
cp /srv/salt/chatroom/pillar/examples/* ./
```

Then open both `dev.sls` / `prod.sls` and set your own domain and mode

```yaml
# dev.sls
chatroom:
  mode: dev
  domain: chatroom-dev-domain.com

# prod.sls
chatroom:
  mode: prod
  domain: chat.prod-domain.com
```

### Bringing the chatroom up

Now assuming your minion is up and listening. Running the following
commands should run it all up. Replace `'salt-minion'` with your minion name if required.

```bash
sudo salt 'salt-minion' state.apply 
```

Next, if you're in dev and you're locally hosting the chatroom, add a temporary line in your `/etc/hosts/`

```bash 
YOUR-MINION-IP chatroom-dev-domain.com
```

Now entering `chatroom-dev-domain.com` on the browser should present you with the 
starting page of the chatroom! Enter a name or leave it blank and press the "Chat!"
button to see the chatting interface. Next, this should be spun up on a server where
other people can also interact with the chat.


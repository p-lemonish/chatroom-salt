docker.io:
  pkg.installed:
    - name: docker

docker-service:
  service.running:
    - name: docker
    - enable: True

/tmp/chatroom-backend.tar:
  file.managed:
    - source: salt://chatroom/backend/chatroom-backend.tar
    - mode: 644

load-backend-image:
  cmd.run:
    - name: docker load -i /tmp/chatroom-backend.tar
    - unless: docker image inspect chatroom-backend:stage >/dev/null 2>&1
    - require:
      - file: /tmp/chatroom-backend.tar
      - service: docker-service

run-backend:
  cmd.run:
    - name: |
        if docker ps --filter name=chatroom-backend --filter ancestor=chatroom-backend:stage | grep -q chatroom-backend; then
          docker restart chatroom-backend
        else
          docker run -d --name chatroom-backend -p 8080:8080 chatroom-backend:stage
        fi
    - require:
      - cmd: load-backend-image
      - service: docker-service

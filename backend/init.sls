python3-pip:
  pkg.installed:
    - name: python3-pip

docker-sdk:
  pip.installed:
    - name: docker
    - require:
      - pkg: python3-pip

docker-pkg:
  pkg.installed:
    - name: docker.io

/tmp/chatroom-backend.tar:
  file.managed:
    - source: salt://chatroom/backend/chatroom-backend.tar
    - mode: 644

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-pkg

backend-image:
  docker_image.present:
    - name: chatroom-backend
    - tag: stage
    - load:
      - source: /tmp/chatroom-backend.tar
    - require:
      - file: /tmp/chatroom-backend.tar
      - service: docker-service

backend-container:
  docker_container.running:
    - name: chatroom-backend
    - image: chatroom-backend:stage
    - port_bindings:
      - 8080:8080
    - restart_policy: unless-stopped
    - require:
      - docker_image: backend-image
      - service: docker-service

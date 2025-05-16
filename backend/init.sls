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

docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-pkg

{% set domain = pillar['chatroom']['domain'] %}
{% set mode = pillar['chatroom']['mode'] %}
backend-image:
  docker_image.present:
    - name: chatroom-backend
    - tag: {{ mode }}
    - load: salt://chatroom/backend/chatroom-backend-{{ mode }}.tar
    - force: True
    - require:
      - service: docker-service

install_apparmor:
  pkg.installed:
    - name: apparmor

backend-container:
  docker_container.running:
    - name: chatroom-backend
    - image: chatroom-backend:{{ mode }}
    - port_bindings:
      - 8080:8080
    - restart_policy: unless-stopped
    - log_driver: journald
    - log_opt: 
      - tag: chatroom-backend
    - environment:
      - ALLOWED_ORIGIN=https://{{ domain }}
    - require:
      - docker_image: backend-image
      - service: docker-service

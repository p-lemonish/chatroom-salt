{% set mode   = pillar['chatroom']['mode'] %}
{% set domain = pillar['chatroom']['domain'] %}

include:
  - chatroom.base

install_certbot:
  pkg.installed:
    - pkgs:
      - certbot
      - python3-certbot-nginx

ssl_directory:
  file.directory:
    - name: /etc/nginx/ssl
    - user: root
    - group: root
    - mode: 700

{% if mode == 'prod' %}
obtain_certificate:
  cmd.run:
    - name: >
        certbot certonly
        --agree-tos
        --non-interactive
        --email patrikmihelson@gmail.com
        --webroot
        -w /var/www/html
        -d {{ domain}}
    - unless: test -f /etc/letsencrypt/live/{{ domain}}/fullchain.pem
    - require:
      - pkg: install_certbot
      - file: ssl_directory
    - watch_in:
      - service: nginx-reload

{% else %}
obtain_certificate:
  cmd.run:
    - name: |
        mkdir -p /etc/nginx/ssl
        openssl req -x509 -nodes -days 1 \
          -newkey rsa:2048 \
          -keyout {{ pillar['chatroom']['ssl']['dev_key'] }} \
          -out    {{ pillar['chatroom']['ssl']['dev_cert'] }} \
          -subj "/CN={{ domain }}"
    - unless: test -f {{ pillar['chatroom']['ssl']['dev_cert'] }}
    - require:
      - file: ssl_directory
{% endif %}

nginx-reload:
  service.running:
    - name: nginx
    - reload: True
    - watch:
      - cmd: obtain_certificate

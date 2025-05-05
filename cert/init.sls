{% set mode   = pillar['chatroom']['mode'] %}
{% set domain = pillar['chatroom']['domain'] %}
{% if mode == 'prod' %}
install_certbot:
  pkg.installed:
    - pkgs:
      - certbot
      - python3-certbot-nginx

obtain_certificate:
  cmd.run:
    - name: >
        certbot certonly
        --agree-tos
        --non-interactive
        --email {{ pillar['chatroom']['email'] }}
        --webroot
        -w /var/www/html
        -d {{ domain}}
    - unless: test -f /etc/letsencrypt/live/{{ domain}}/fullchain.pem
    - require:
      - pkg: install_certbot
    - watch_in:
      - service: nginx-reload

{% else %}
ssl_directory:
  file.directory:
    - name: /etc/nginx/ssl
    - user: root
    - group: root
    - mode: 700

obtain_certificate:
  cmd.run:
    - name: |
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

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

obtain_certificate:
  cmd.run:
    - name: >
        certbot certonly
        --agree-tos
        --non-interactive
        --email patrikmihelson@gmail.com
        --webroot
        -w /var/www/html
        -d chat.mihelson-adamson.com
    - unless: test -f /etc/letsencrypt/live/chat.mihelson-adamson.com/fullchain.pem
    - require:
      - pkg: install_certbot
      - file: ssl_directory
    - watch_in:
      - service: nginx-reload

nginx-reload:
  service.running:
    - name: nginx
    - reload: True

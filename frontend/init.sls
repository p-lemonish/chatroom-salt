nginx-pkg:
  pkg.installed:
    - name: nginx

/tmp/frontend-dist.tar.gz:
  file.managed:
    - source: salt://chatroom/frontend/dist.tar.gz
    - mode: 644

/var/www/html:
  file.directory:
    - mode: 755
    - makedirs: True

untar-dist:
  cmd.run:
    - name: tar xf /tmp/frontend-dist.tar.gz -C /var/www/html
    - unless: test -f /var/www/html/index.html
    - require:
      - file: /tmp/frontend-dist.tar.gz
    - watch_in:
      - service: nginx-service

/etc/nginx/sites-available/frontend.conf:
  file.managed:
    - source: salt://chatroom/frontend/frontend.conf

/etc/nginx/sites-enabled/frontend.conf:
  file.managed:
    - source: /etc/nginx/sites-available/frontend.conf
    - force: True 
    - require:
      - file: /etc/nginx/sites-available/frontend.conf

nginx-service:
  service.running:
    - name: nginx
    - enable: True 
    - watch:
      - cmd: untar-dist
      - file: /etc/nginx/sites-available/frontend.conf
      - file: /etc/nginx/sites-enabled/frontend.conf


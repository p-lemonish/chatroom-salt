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
    - require:
      - file: /tmp/frontend-dist.tar.gz
    - onchanges:
      - file: /tmp/frontend-dist.tar.gz

/etc/nginx/sites-available/frontend.conf:
  file.managed:
    - source: salt://chatroom/frontend/frontend.conf
    - template: jinja

/etc/nginx/sites-enabled/frontend.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/frontend.conf
    - force: True
    - require:
      - file: /etc/nginx/sites-available/frontend.conf
      - cmd: obtain_certificate

nginx-service:
  service.running:
    - name: nginx
    - enable: True 
    - watch:
      - file: /etc/nginx/sites-available/frontend.conf


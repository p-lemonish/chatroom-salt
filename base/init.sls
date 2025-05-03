install_nginx:
  pkg.installed:
    - name: nginx

/etc/nginx/sites-enabled:
  file.directory:
    - clean: True
    - require:
      - pkg: install_nginx

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://chatroom/base/basenginx.conf

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default
    - force: True

ensure_nginx_service:
  service.running:
    - name: nginx
    - enable: True

mongodb:
  file:
    - managed
    - name: /etc/mongodb.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://mongodb/files/mongodb.conf
  service:
    - running
    - enable: True
    - watch:
      - pkg: mongodb

mongodb-logrotate:
  pkg:
     - latest
     - name: mongodb
  file:
    - managed
    - name: /etc/logrotate.d/mongodb
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://mongodb/files/logrotate.jinja
  service:
     - running
     - enable: True
     - watch:
       - pkg: mongodb



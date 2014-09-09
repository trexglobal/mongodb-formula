{% set source = '/usr/local/src' -%}
{% set base = '/data' -%}
{% set home = '/data/mongodb-home' -%}
{% set install_dir = '/data/mongo' -%}
{% set version = 'mongo-2.6.0-trex-patched' -%}
{% set tag = 'v2.6.0-trex-patched' -%}

{% set mongo_package_name = tag + '.tar.gz' -%}
{% set mongo_package_source = 'https://github.com/trexglobal/mongo/archive/' + mongo_package_name -%}
{% set mongo_package_source_hash = 'sha1=2435fdd7a0e4770e6db1679a37cb5912c7e03532' -%}
{% set mongo_package = source + '/' + mongo_package_name -%}
{% set mongo_source_home = home + '/' + version -%}


mongo_group:
  group.present:
    - name: mongodb

/data:
  file.directory:
    - name: {{ base }}
    - group: mongodb
    - mode: 0755
    - makedirs: True

mongo_user:
  file.directory:
    - name: {{ home }}
    - user: mongodb
    - group: mongodb
    - mode: 0755
    - require:
      - user: mongo_user
      - group: mongo_group
  user.present:
    - name: mongodb
    - home: {{ home }}
    - groups:
      - mongodb
    - require:
      - group: mongo_group

mongo_log:
  file.directory:
    - name: {{ install_dir + '/log' }}
    - user: mongodb
    - group: mongodb
    - mode: 0755
    - makedirs: True
    - require:
      - user: mongo_user
      - group: mongo_group

mongo_etc:
  file.directory:
    - name: {{ install_dir + '/etc' }}
    - user: mongodb
    - group: mongodb
    - mode: 0755
    - require:
      - user: mongo_user
      - group: mongo_group

mongo_data:
  file.directory:
    - name: {{ install_dir + '/db' }}
    - user: mongodb
    - group: mongodb
    - mode: 0755
    - require:
      - user: mongo_user
      - group: mongo_group

get-mongo:
  pkg.installed:
    - names:
      - mongodb-clients
      - git-core
      - build-essential
      - scons
  file.managed:
    - name: {{ mongo_package }}
    - source: {{ mongo_package_source }}
    - source_hash: {{ mongo_package_source_hash }}
  cmd.wait:
    - cwd: {{ source }}
    - name: tar -zxf {{ mongo_package }} -C {{ home }}
    - require:
      - file: mongo_user
      - pkg: get-mongo
    - watch:
      - file: get-mongo

mongo_conf:
  file.managed:
    - name: {{ install_dir + '/etc/mongod.conf' }}
    - template: jinja
    - user: root
    - group: root
    - mode: 444
    - source: salt://mongodb/files/mongodb/etc/mongod.conf

mongod:
  cmd.wait:
    - cwd: {{ mongo_source_home }}
    - names:
      - scons all
      - scons --prefix={{ install_dir }} install
    - watch:
      - cmd: get-mongo
    - require:
      - cmd: get-mongo
    - require_in:
      - service: mongod
  file.managed:
    - name: /etc/init/mongod.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://mongodb/files/mongodb/etc/init/mongod.conf
    - require:
      - cmd: mongod
  service.running:
    - enable: True
    - watch:
      - file: mongo_conf
    - require:
      - file: mongo_log
      - file: mongo_data
      - file: mongo_conf
      - cmd: mongod

/etc/logrotate.d/mongodb:
  file:
    - managed
    - user: root
    - group: root
    - mode: 440
    - source: salt://mongodb/files/mongodb/etc/logrotate.d/mongodb

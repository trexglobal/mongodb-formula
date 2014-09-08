mongodb-formula
===============

Installing our own MongoDB version


## Install

1. Add remotes to /etc/salt/master

  ```yaml
  gitfs_remotes:
    - git://github.com/trexglobal/mongodb-formula
  ```
2. Add mongodb to your server [state file](http://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html)

  ```yaml
  include:
      - mongodb
  ```

  or to the [top.sls](http://docs.saltstack.com/en/latest/ref/states/top.html) file


  ```yaml
  base:
    'some.server.example.com':
      - mongodb
  ```

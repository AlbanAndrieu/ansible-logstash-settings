## [![Nabla](https://debops.org/images/debops-small.png)](https://github.com/AlbanAndrieu) alban_andrieu_logstash_settings

<!-- This file was generated by Ansigenome. Do not edit this file directly but
     instead have a look at the files in the ./meta/ directory. -->

[![License](http://img.shields.io/:license-apache-blue.svg?style=flat-square)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![Travis CI](https://img.shields.io/travis/AlbanAndrieu/ansible-logstash-settings.svg?style=flat)](https://travis-ci.org/AlbanAndrieu/ansible-logstash-settings)
[![Branch](http://img.shields.io/github/tag/AlbanAndrieu/ansible-logstash-settings.svg?style=flat-square)](https://github.com/AlbanAndrieu/ansible-logstash-settings/tree/master)
[![Donate](https://img.shields.io/gratipay/AlbanAndrieu.svg?style=flat)](https://www.gratipay.com/~AlbanAndrieu)
<!--[![Ansible Galaxy](https://img.shields.io/badge/galaxy-alban.andrieu.logstash--settings-660198.svg?style=flat)](https://galaxy.ansible.com/detail#/role/3083)-->
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-alban.andrieu.logstash--settings-660198.svg?style=flat)](https://galaxy.ansible.com/alban.andrieu/logstash-settings)
[![Platforms](http://img.shields.io/badge/platforms-ubuntu-lightgrey.svg?style=flat)](#)
[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=AlbanAndrieu&url=https://github.com/AlbanAndrieu/ansible-logstash-settings&title=ansible-logstash-settings&language=en_GB&tags=github&category=software)

Ensures that logstash is properly installed and configured on `Ubuntu` using `Ansible` script.
This ``Simple`` role allows you to configure [Logstash](http://www.elasticsearch.org/overview/logstash/) with basic configuration.

Goal of this role is to gather as much logstash scripts as possible.
So do not hesitate to add your own and to contribute.

Note that this role installs a syslog grok pattern by default; if you want to add more filters, please add them inside the `/etc/logstash/conf.d/` directory. As an example, you could create a file named `13-myapp.conf` with the appropriate grok filter and restart logstash to start using it. Test your grok regex using the [Grok Debugger](http://grokdebug.herokuapp.com/).

###Requirements

Though other methods are possible, this role is made to work with Elasticsearch as a backend for storing log messages.


### Role dependencies

- `geerlingguy.logstash`
- `geerlingguy.redis`
- `geerlingguy.kibana`
### Installation

This role requires at least Ansible `v2.3.0.0`. To install it, run:

Using `ansible-galaxy`:
```shell
$ ansible-galaxy install alban.andrieu.logstash-settings
```

Using `arm` ([Ansible Role Manager](https://github.com/mirskytech/ansible-role-manager/)):
```shell
$ arm install alban.andrieu.logstash-settings
```

Using `git`:
```shell
$ git clone https://github.com/AlbanAndrieu/ansible-logstash-settings.git
```

### Documentation

<!---
More information about `alban.andrieu.logstash-settings` can be found in the
[official alban.andrieu.logstash-settings documentation](https://docs.debops.org/en/latest/ansible/roles/ansible-logstash-settings/docs/).
-->


### Role variables

List of default variables available in the inventory:

```YAML
---
logstash_monitor_local_syslog: yes
logstash_monitor_local_collectd: no
logstash_monitor_collectd_syslog: no
logstash_monitor_jenkins_enabled: no
logstash_monitor_nexus_enabled: no
logstash_monitor_apache_enabled: no
logstash_monitor_nginx_enabled: no
logstash_monitor_tomcat_enabled: no
logstash_monitor_jetty_enabled: no
logstash_monitor_sensu_enabled: no
logstash_monitor_jboss_enabled: no
logstash_monitor_elasticsearch_enabled: no
logstash_monitor_redis_enabled: no
logstash_monitor_miscellaneous_enabled: no
logstash_monitor_application_enabled: no
logstash_monitor_sybase_enabled: no
logstash_monitor_log4j_enabled: no

#user: "{{ lookup('env','USER') }}"
user: "root"
shell_owner: "{{ user }}"
shell_group: "{{ shell_owner }}"
##home: '~' #please override me
#home: "{{ lookup('env','HOME') }}"
#shell_owner_home: "{{ home }}"
shell_dir_tmp: "/tmp" # or override with "{{ tempdir.stdout }} in order to have be sure to download the file"

logstash_elasticsearch_host: "localhost"
redis_bind_interface: "127.0.0.1"

logstash_change_log_dir: "/var/log/"
logstash_change_log_dir_enabled: no

kibana_root: "/var/www/kibana3"
kibana_dashboard: "{{ kibana_root }}/app/dashboards"
kibana_dashboard_enabled: yes

#tomcat_catalina_home_dir: "/usr/share/tomcat7"
tomcat_catalina_base_dir: "/var/lib/tomcat7"

tomcat_catalina_log_dir: "{{ tomcat_catalina_base_dir }}/logs"
tomcat_catalina_out: "{{ tomcat_catalina_log_dir }}/catalina.out"

jenkins_home: "/var/lib/jenkins"
jenkins_user: "jenkins"
jenkins_owner: "{{ jenkins_user }}"
jenkins_group: "{{ jenkins_owner }}"
application_dir: ""
application_user: "{{ user }}"
application_home: "{{ application_dir }}/home/{{ application_user }}"
application_name: "nabla"
sybase_dir: "{{ application_dir }}/sybase"
sybase_user: "{{ application_user }}"
sybase_log_file: "SYBASE.log"
sybase_version: "ASE-15_0"

# General options
collectd_interval: 10
collectd_readthreads: 7
collectd_hostname: "{{ inventory_hostname }}"
collectd_fdqnlookup: false

collectd_prefix_custom_dir: "/usr/lib/collectd"
collectd_custom_tcp_type: "ESTABLISHED"
collectd_custom_tcp_range: "1024-49151"
collectd_custom_log_dir: "/tmp"

collectd_jmx_host: "localhost"
collectd_jmx_port: "1099"
collectd_connection_host: "{{ collectd_jmx_host }}"
collectd_prefix: /opt/collectd      # The place where Collectd will be installed
collectd_prefix_type: "{{collectd_prefix}}/etc"
collectd_prefix_conf: "{{collectd_prefix}}/etc"
```


### Detailed usage guide

Run the following command :

     `ansible-playbook -i hosts -c local -v logstash.yml -vvvv --ask-sudo-pass | tee setup.log`


### Authors and license

`alban_andrieu_logstash_settings` role was written by:

- [Alban Andrieu](fr.linkedin.com/in/nabla/) | [e-mail](mailto:alban.andrieu@free.fr) | [Twitter](https://twitter.com/AlbanAndrieu) | [GitHub](https://github.com/AlbanAndrieu)

- License: [GPLv3](https://tldrlegal.com/license/gnu-general-public-license-v3-%28gpl-3%29)

Copyright (c) 2017 [Alban Andrieu](https://alban.andrieu.com/)

### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/AlbanAndrieu/ansible-logstash-settings/issues)!

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests and examples for any new or changed functionality.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

***

This role is part of the [Nabla](https://github.com/AlbanAndrieu) project.
README generated by [Ansigenome](https://github.com/nickjj/ansigenome/).

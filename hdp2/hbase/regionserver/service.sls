{% if pillar.hdp2.version.split('.')[1] | int >= 2 %}
{% set hbase_script_dir = '/usr/hdp/current/hbase-regionserver/bin' %}
{% else %}
{% set hbase_script_dir = '/usr/lib/hbase/bin' %}
{% endif %}

#
# Install the HBase regionserver package
#

kill-regionserver:
  cmd:
    - run
    - user: hbase
    - name: {{ hbase_script_dir }}/hbase-daemon.sh stop regionserver
    - onlyif: '. /etc/init.d/functions && pidofproc -p /var/run/hbase/hbase-hbase-regionserver.pid'
    - require:
      - pkg: hbase-regionserver

hbase-regionserver-svc:
  cmd:
    - run
    - user: hbase
    - name: {{ hbase_script_dir }}/hbase-daemon.sh start regionserver
    - unless: '. /etc/init.d/functions && pidofproc -p /var/run/hbase/hbase-hbase-regionserver.pid'
    - require: 
      - pkg: hbase-regionserver
      - cmd: kill-regionserver
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
      - file: {{ pillar.hdp2.hbase.tmp_dir }}
      - file: {{ pillar.hdp2.hbase.log_dir }}
{% if pillar.hdp2.security.enable %}
      - cmd: generate_hbase_keytabs
{% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

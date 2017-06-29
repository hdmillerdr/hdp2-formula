{% set standby = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:hdp2.hadoop.yarn.standby-resourcemanager', 'grains.items', 'compound') %}

# The scripts for starting services are in different places depending on the hdp version, so set them here
{% if pillar.hdp2.version.split('.')[1] | int >= 2 %}
{% set hadoop_script_dir = '/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin' %}
{% set yarn_script_dir = '/usr/hdp/current/hadoop-yarn-resourcemanager/sbin' %}
{% set mapred_script_dir = '/usr/hdp/current/hadoop-mapreduce-historyserver/sbin' %}
{% else %}
{% set hadoop_script_dir = '/usr/lib/hadoop/sbin' %}
{% set yarn_script_dir = '/usr/lib/hadoop-yarn/sbin' %}
{% set mapred_script_dir = '/usr/lib/hadoop-mapreduce/sbin' %}
{% endif %}

##
# Starts the namenode service.
#
# Depends on: JDK7
##

kill-resourcemanager:
  cmd:
    - run
    - user: yarn
    - name: {{ yarn_script_dir }}/yarn-daemon.sh stop resourcemanager
    - onlyif: '. /etc/init.d/functions && pidofproc -p /var/run/hadoop-yarn/yarn-yarn-resourcemanager.pid'
    - env:
      - HADOOP_LIBEXEC_DIR: '{{ hadoop_script_dir }}/../libexec'
    - require:
      - pkg: hadoop-yarn-resourcemanager

{% if standby %}
kill-proxyserver:
  cmd:
    - run
    - user: yarn
    - name: {{ yarn_script_dir }}/yarn-daemon.sh stop proxyserver
    - onlyif: '. /etc/init.d/functions && pidofproc -p /var/run/hadoop-yarn/yarn-yarn-proxyserver.pid'
    - env:
      - HADOOP_LIBEXEC_DIR: '{{ hadoop_script_dir }}/../libexec'
    - require:
      - pkg: hadoop-yarn-proxyserver
{% endif %}

##
# Starts yarn resourcemanager service.
#
# Depends on: JDK7
##
hadoop-yarn-resourcemanager-svc:
  cmd:
    - run
    - user: yarn
    - name: {{ yarn_script_dir }}/yarn-daemon.sh start resourcemanager
    - unless: '. /etc/init.d/functions && pidofproc -p /var/run/hadoop-yarn/yarn-yarn-resourcemanager.pid'
    - env:
      - HADOOP_LIBEXEC_DIR: '{{ hadoop_script_dir }}/../libexec'
    - require: 
      - pkg: hadoop-yarn-resourcemanager
      - cmd: kill-resourcemanager
      - file: bigtop_java_home
    - watch:
      - file: /etc/hadoop/conf

{% if standby %}
hadoop-yarn-proxyserver-svc:
  cmd:
    - run
    - user: yarn
    - name: {{ yarn_script_dir }}/yarn-daemon.sh start proxyserver
    - unless: '. /etc/init.d/functions && pidofproc -p /var/run/hadoop-yarn/yarn-yarn-proxyserver.pid'
    - env:
      - HADOOP_LIBEXEC_DIR: '{{ hadoop_script_dir }}/../libexec'
    - require:
      - pkg: hadoop-yarn-proxyserver
      - cmd: kill-proxyserver
      - file: bigtop_java_home
    - watch:
      - file: /etc/hadoop/conf
{% endif %}


include:
  - hdp2.repo
  - hdp2.hadoop.conf
  - hdp2.landing_page
  {% if pillar.hdp2.encryption.enable %}
  - hdp2.hadoop.encryption
  {% endif %}
  {% if pillar.hdp2.security.enable %}
  - hdp2.hadoop.hdfs.security
  {% endif %}

hadoop-client: 
  pkg:
    - installed
    - require:
      - cmd: repo_placeholder
      {% if pillar.hdp2.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if pillar.hdp2.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

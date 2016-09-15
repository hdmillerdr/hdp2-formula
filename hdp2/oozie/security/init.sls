{% if pillar.hdp2.security.enable %}
generate_oozie_keytabs:
  cmd:
    - script 
    - source: salt://hdp2/oozie/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/oozie/conf
    - require:
      - module: load_admin_keytab
      - cmd: generate_http_keytab
{% endif %}

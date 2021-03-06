include:
  - hdp2.repo
  - hdp2.sentry.conf
  - krb5
  - hdp2.security
  - hdp2.security.stackdio_user
  - hdp2.sentry.security
  {% if salt['pillar.get']('hdp2:sentry:start_service', True) %}
  - hdp2.sentry.service
  {% endif %}

sentry:
  pkg:
    - installed 
    - pkgs:
      - sentry
      - cyrus-sasl-gssapi
    - require:
      - cmd: repo_placeholder
    - require_in:
      - cmd: generate_sentry_keytabs

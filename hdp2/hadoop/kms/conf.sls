/etc/ranger/kms/conf:
  file:
    - recurse
    - source: salt://hdp2/etc/ranger/kms/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - exclude_pat: '.*.swp'

/etc/ranger/admin/conf:
  file:
    - recurse
    - source: salt://hdp2/etc/ranger/admin/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - exclude_pat: '.*.swp'
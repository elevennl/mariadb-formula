{%- set os_name = salt['grains.get']('os')|lower %}
{%- set lsb_codename = salt['grains.get']('lsb_distrib_codename') %}
{%- set stable_version = '10.1' %}
{%- set repo_version = salt['pillar.get']('mariadb:repo_version') %}
{%- set version = salt['pillar.get']('mariadb:version', 'latest') %}
{%- set repourl = salt['pillar.get']('mariadb:repourl', 'http://ftp.nluug.nl/db/mariadb') %}

{% if sls == "mariadb.client.repo" %}{% set id_prefix = "mariadb_client" -%}
{% elif sls == "mariadb.server.repo" %}{% set id_prefix = "mariadb_server" -%}
{% else %}{% set id_prefix = "mariadb" -%}
{% endif -%}

# Starting with Ubuntu 16.04 the signing key has changed
{%- set repo_key = salt['pillar.get']('mariadb:repokey', "0xcbcb082a1bb943db") %}
{%- if salt['grains.get']('osfullname') == 'Ubuntu' and salt['grains.get']('osrelease')|float() >= 16.04 %}
{%- set repo_key = "0xF1656F24C74CD1D8" %}
{%- endif %}

# Deal with difference between stable/repo version and explicit versions
{%- if version is defined and version != 'latest' %}
# Use the specific version
{%- set repo_url_partial = 'mariadb-' ~ version ~ '/repo' %}
{%- elif repo_version is defined %}
# Use the repo version (e.g. 10.3)
{%- set repo_url_partial = 'repo/' ~ repo_version %}
{%- else %}
# Fall back to default
{%- set repo_url_partial = 'repo/' ~ stable_version %}
{%- endif %}

# Install MariaDB repository
{{ id_prefix }}_repo:
  pkgrepo.managed:
    - humanname: MariaDB PPA
    - name: deb {{ repourl }}/{{ repo_url_partial }}/ubuntu {{ lsb_codename }} main
    - dist: {{ lsb_codename }}
    - file: /etc/apt/sources.list.d/mariadb.list
    - keyid: "{{ repo_key }}"
    - keyserver: keyserver.ubuntu.com
    - refresh: True
    - clean_file: True

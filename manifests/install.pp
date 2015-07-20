# Installs default heka packages
class heka::install {
  package { ['heka',]: ensure => $heka::package_ensure, }
}

# == Define: heka::snippet
#
# Configure a heka plugin.
#
# === Parameters
#
# [*content*]
#   File content for the plugin config.
#   Default: undef
#
# [*source*]
#   File source for the plugin config.
#   Default: undef
#
define heka::snippet ($ensure = 'file', $content = undef, $source = undef,) {
  include ::heka

  if !($content or $source) {
    fail('content or source param must be provided')
  }

  if ($content and $source) {
    fail('content and source params are mutually exclusive')
  }

  file { "/etc/heka/${name}.toml":
    ensure  => $ensure,
    content => $content,
    source  => $source,
    notify  => Service['heka'],
    require => Class['heka::config'],
  }
}


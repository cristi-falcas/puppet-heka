# == Define: heka::logrotate
#
# Manages heka log rotation.
#
# === Parameters
#
# === Examples

# === Authors
#
class heka::logrotate ($log_file = '/var/log/hekad.log') {
  if $heka::service_provider == 'init' {
    logrotate::rule { 'heka':
      path         => $log_file,
      rotate       => 5,
      rotate_every => 'day',
      size         => '100k',
      postrotate   => '/sbin/service heka restart',
      compress     => true,
      missingok    => true,
    }
  }
}

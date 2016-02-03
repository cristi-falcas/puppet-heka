# Takes care of starting heka service
class heka::service {
  service { 'heka':
    ensure => running,
    enable => true,
  }
}

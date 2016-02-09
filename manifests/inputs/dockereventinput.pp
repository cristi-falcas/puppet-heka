# The DockerEventInput plugin connects to the Docker daemon and watches the Docker events API, sending all events to the Heka
# pipeline
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Input Parameters::   Check heka::inputs::tcpinput for the description
#
### Docker Event Input Parameters
# $endpoint::                    A Docker endpoint.
#                                Defaults to "unix:///var/run/docker.sock".
#
# $cert_path::                   Path to directory containing client certificate and keys. This value works in the same way as
#                                DOCKER_CERT_PATH.
#
define heka::inputs::dockereventinput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = undef,
  $log_decode_failures          = true,
  # Docker Event Input
  $endpoint                     = undef,
  $cert_path                    = undef,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # Docker Event Input
  validate_string($endpoint)
  if $cert_path { validate_string($cert_path) }

  $plugin_name = "dockereventinput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/dockereventinput.toml.erb"),
  }
}

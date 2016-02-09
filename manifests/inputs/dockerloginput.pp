# The DockerLogInput plugin attaches to all containers running on a host and sends their logs messages into the Heka pipeline.
# The plugin is based on Logspout by Jeff Lindsay.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
### Common Input Parameters::   Check heka::inputs::tcpinput for the description
#
### Docker Log Input Parameters
#
# $endpoint::                    A Docker endpoint. Defaults to "unix:///var/run/docker.sock".
#                                String
#
# $cert_path::                   Path to directory containing client certificate and keys. This value works in the same way as
#                                DOCKER_CERT_PATH.
#                                String (optional)
#
# $name_from_env_var::           Overwrite the ContainerName with this environment variable on the Container if exists.
#                                If left empty the container name will still be used.
#                                String (optional)
#
# $fields_from_env::             A list of environment variables to extract from the container and add as fields.
#                                Array
#
define heka::inputs::dockerloginput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  $splitter                     = undef,
  $log_decode_failures          = true,
  # Docker Log Input
  $endpoint                     = 'unix:///var/run/docker.sock',
  $cert_path                    = undef,
  $name_from_env_var            = undef,
  $fields_from_env              = undef,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  if $splitter { validate_string($splitter) }
  if $log_decode_failures { validate_bool($log_decode_failures) }
  # Docker Log Input
  validate_string($endpoint)
  if $cert_path { validate_string($cert_path) }
  if $name_from_env_var { validate_string($name_from_env_var) }
  if $fields_from_env { validate_string($fields_from_env) }

  $plugin_name = "dockerloginput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/dockerloginput.toml.erb"),
  }
}

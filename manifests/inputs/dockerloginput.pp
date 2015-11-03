# The DockerLogInput plugin attaches to all containers running on a host and sends their logs messages into the Heka pipeline.
# The plugin is based on Logspout by Jeff Lindsay.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $decoder::                     Decoder to be used by the input. This should refer to the name of a registered
#                                decoder plugin configuration. If supplied, messages will be decoded before being
#                                passed on to the router when the InputRunner’s Deliver method is called.
#                                No default decoder is specified.
#
# $synchronous_decode::          If synchronous_decode is false, then any specified decoder plugin will be
#                                run by a DecoderRunner in its own goroutine and messages will be passed in
#                                to the decoder over a channel, freeing the input to start processing the
#                                next chunk of incoming or available data. If true, then any decoding will
#                                happen synchronously and message delivery will not return control to the
#                                input until after decoding has completed. Defaults to false.
#
# $send_decode_failures::        If false, then if an attempt to decode a message fails then Heka will log
#                                an error message and then drop the message. If true, then in addition to
#                                logging an error message, decode failure will cause the original, undecoded
#                                message to be tagged with a decode_failure field (set to true) and delivered
#                                to the router for possible further processing.
#
# $can_exit::                    If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                Heka will continue processing other plugins. Defaults to false on most inputs.
#
# $endpoint::                    A Docker endpoint. Defaults to “unix:///var/run/docker.sock”.
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

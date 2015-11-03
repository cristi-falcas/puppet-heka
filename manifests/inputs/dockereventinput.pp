# The DockerEventInput plugin connects to the Docker daemon and watches the Docker events API, sending all events to the Heka
# pipeline
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $decoder::                     Decoder to be used by the input. This should refer to the name of a registered
#                                decoder plugin configuration. If supplied, messages will be decoded before being
#                                passed on to the router when the InputRunner’s Deliver method is called.
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
#

define heka::inputs::dockereventinput (
  $ensure                       = 'present',
  # Common Input Parameters
  $decoder                      = 'ProtobufDecoder',
  $synchronous_decode           = false,
  $send_decode_failures         = false,
  $can_exit                     = undef,
  # Docker Event Input
  $endpoint                     = 'unix:///var/run/docker.sock',
  $cert_path                    = undef,
) {
  # Common Input Parameters
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  # Docker Event Input
  validate_string($endpoint)
  if $cert_path { validate_string($cert_path) }

  $plugin_name = "dockerevent_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/dockereventinput.toml.erb"),
  }
}

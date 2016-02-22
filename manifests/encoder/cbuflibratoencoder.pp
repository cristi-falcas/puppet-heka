# Extracts data from SandboxFilter circular buffer output messages and uses it to generate time series JSON structures
# that will be accepted by Librato's POST API. It will keep track of the last time it's seen a particular message,
# keyed by filter name and output name. The first time it sees a new message, it will send data from all of the rows
# except the last one, which is possibly incomplete. For subsequent messages, the encoder will automatically extract data
# from all of the rows that have elapsed since the last message was received.
#
# The SandboxEncoder preserve_data setting should be set to true when using this encoder, or else the list of received
# messages will be lost whenever Heka is restarted, possibly causing the same data rows to be sent to Librato multiple times.
# It uses the sandboxencoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### CBUF Librato Parameters
#
# $message_key::                  String to use as the key to differentiate separate cbuf messages from each other.
#                                 Supports message field interpolation.
#                                 Type: string
#
define heka::encoder::cbuflibratoencoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = true,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # CBUF Librato Parameters
  $message_key       = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # CBUF Librato Parameters
  if $message_key { validate_string($message_key) }

  $sandbox_type = 'SandboxEncoder'
  $script_type = 'lua'
  $filename = 'lua_encoders/cbuf_librato.lua'
  $config = {
    'message_key' => $message_key,
  }

  $full_name = "cbuflibratoencoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}

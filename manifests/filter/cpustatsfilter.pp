# Calculates deltas in /proc/stat data. Also emits CPU percentage utilization information.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Filter Parameters::    Check heka::filter::sandboxfilter for the description
#
### Buffering::                   Check heka::filter::sandboxfilter for the description
#
### Common Sandbox Parameters::   Check heka::filter::sandboxfilter for the description
#
### CPU Stats Filter Parameters
#
# $whitelist::                    Only process fields that fit the pattern, defaults to match all.
#                                 Default ""
#                                 Type: string
#
# $extras::                       Process extra fields like ctxt, softirq, cpu fields.
#                                 Default false
#                                 Type: bool
#
# $percent_integer::              Process percentage as whole number.
#                                 Default true
#                                 Type: boolean
#
define heka::filter::cpustatsfilter (
  $ensure              = 'present',
  # Common Filter Parameters
  $message_matcher     = undef,
  $message_signer      = undef,
  $ticker_interval     = undef,
  $can_exit            = undef,
  $use_buffering       = undef,
  # Buffering
  $max_file_size       = undef,
  $max_buffer_size     = undef,
  $full_action         = undef,
  $cursor_update_count = undef,
  # Common Sandbox Parameters
  $preserve_data       = undef,
  $memory_limit        = undef,
  $instruction_limit   = undef,
  $output_limit        = undef,
  $module_directory    = undef,
  # CPU Stats Filter Parameters
  $whitelist           = '',
  $extras              = false,
  $percent_integer     = true,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Filter Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $ticker_interval { validate_integer($ticker_interval) }
  if $can_exit { validate_bool($can_exit) }
  if $use_buffering { validate_bool($use_buffering) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # CPU Stats Filter Parameters
  validate_string($whitelist)
  validate_bool($extras, $percent_integer)

  $script_type = 'lua'
  $filename = 'lua_filters/procstat.lua'
  $config = {
    'whitelist'            => $whitelist,
    'extras'                 => $extras,
    'percent_integer'      => $percent_integer,
  }

  $full_name = "cpustatsfilter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/filter/sandboxfilter.toml.erb"),
  }
}

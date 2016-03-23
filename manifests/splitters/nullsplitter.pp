# The NullSplitter is used in cases where the incoming data is already naturally divided into logical messages, 
# such that Heka doesn't need to do any further splitting. 
# For instance, when used in conjunction with a UdpInput, the contents of each UDP packet will be made into a separate message.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Splitter Parameters:: Check heka::splitters::hekaframingsplitter for the description
#
define heka::splitters::nullsplitter (
  $ensure                   = 'present',
  # Common Splitter Parameters
  $keep_truncated           = false,
  $use_message_bytes        = undef,
  $min_buffer_size          = undef,
  $deliver_incomplete_final = false,
) {
  validate_re($ensure, '^(present|absent)$')
  validate_bool($keep_truncated)
  if $use_message_bytes { validate_bool($use_message_bytes) }
  if $min_buffer_size { validate_integer($min_buffer_size) }
  validate_bool($deliver_incomplete_final)

  $full_name = "nullsplitter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/splitters/nullsplitter.toml.erb"),
  }
}

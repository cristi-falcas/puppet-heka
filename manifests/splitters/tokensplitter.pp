# A TokenSplitter is used to split an incoming data stream on every occurrence (or every Nth occurrence) of a single,
# one byte token character. The token will be included as the final character in the returned record.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Splitter Parameters:: Check heka::splitters::hekaframingsplitter for the description
#
### Token Splitter Parameters
#
# $delimiter::                   String representation of the byte token to be used as message delimiter. Defaults to "\n".
#
# $count::                       Number of instances of the delimiter that should be encountered before returning a record. Defaults
#                                to 1. Setting to 0 has no effect, 0 and 1 will be treated identically. Often used in conjunction with
#                                the deliver_incomplete_final option set to true, to ensure trailing partial records are still delivered.
#
define heka::splitters::tokensplitter (
  $ensure                   = 'present',
  # Common Splitter Parameters
  $keep_truncated           = false,
  $use_message_bytes        = undef,
  $min_buffer_size          = undef,
  $deliver_incomplete_final = false,
  # Token Splitter Parameters
  $delimiter                = '\n',
  $count                    = 1,
) {
  validate_re($ensure, '^(present|absent)$')
  validate_bool($keep_truncated)
  if $use_message_bytes { validate_bool($use_message_bytes) }
  if $min_buffer_size { validate_integer($min_buffer_size) }
  validate_bool($deliver_incomplete_final)
  validate_string($delimiter)
  validate_integer($count)

  $full_name = "tokensplitter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/splitters/tokensplitter.toml.erb"),
  }
}

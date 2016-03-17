# A RegexSplitter considers any text that matches a specified regular expression to represent a boundary on which records should be split. 
# The regular expression may consist of exactly one capture group. If a capture group is specified, then the captured text will be included in the returned record. 
# If not, then the returned record will not include the text that caused the regular expression match.
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

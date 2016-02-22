# A RegexSplitter considers any text that matches a specified regular expression to represent a boundary on which records should be
# split. The regular expression may consist of exactly one capture group. If a capture group is specified, then the captured text
# will be included in the returned record. If not, then the returned record will not include the text that caused the regular
# expression match.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Splitter Parameters:: Check heka::splitters::hekaframingsplitter for the description
#
### Regex Splitter Parameters
#
# $delimiter::                   Regular expression to be used as the record boundary. May contain zero or one specified capture
#                                groups.
#
# $delimiter_eol::               Specifies whether the contents of a delimiter capture group should be appended to the end of a
#                                record (true) or prepended to the beginning (false). Defaults to true. If the delimiter expression
#                                does not specify a capture group, this will have no effect.
#
define heka::splitters::regexsplitter (
  $ensure                   = 'present',
  # Common Splitter Parameters
  $keep_truncated           = false,
  $use_message_bytes        = undef,
  $min_buffer_size          = undef,
  $deliver_incomplete_final = false,
  # Token Splitter Parameters
  # lint:ignore:parameter_order
  $delimiter,
  # lint:endignore
  $delimiter_eol            = true,
) {
  validate_re($ensure, '^(present|absent)$')
  validate_bool($keep_truncated)
  if $use_message_bytes { validate_bool($use_message_bytes) }
  if $min_buffer_size { validate_integer($min_buffer_size) }
  validate_bool($deliver_incomplete_final)
  validate_string($delimiter)
  validate_bool($delimiter_eol)

  $full_name = "regexsplitter_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/splitters/regexsplitter.toml.erb"),
  }
}

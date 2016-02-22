# The RstEncoder generates a reStructuredText rendering of a Heka message, including all fields and attributes.
# It is useful for debugging, especially when coupled with a Log Output.
#
# === Parameters: none
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
define heka::encoder::rstencoder (
  $ensure = 'present',
) {
  validate_re($ensure, '^(present|absent)$')

  $decoder_type = 'RstEncoder'

  heka::snippet { $name:
    ensure  => $ensure,
    content => template("${module_name}/noparamsxxcoder.toml.erb"),
  }
}

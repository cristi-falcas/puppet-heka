# The StatsToFieldsDecoder will parse time series statistics data in the graphite message format and encode the data
# into the message fields, in the same format produced by a Stat Accumulator Input plugin with the emit_in_fields
# value set to true. This is useful if you have externally generated graphite string data flowing through Heka that
# you'd like to process without having to roll your own string parsing code.
#
# This decoder has no configuration options. It simply expects to be passed messages with statsd string data in the payload.
# Incorrect or malformed content will cause a decoding error, dropping the message.
#
# === Parameters
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
define heka::decoder::statstofieldsdecoder (
  $ensure = 'present',
) {
  validate_re($ensure, '^(present|absent)$')

  $decoder_type = 'StatsToFieldsDecoder'

  heka::snippet { $name:
    ensure  => $ensure,
    content => template("${module_name}/noparamsxxcoder.toml.erb"),
  }
}

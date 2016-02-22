# This decoder plugin allows you to specify an ordered list of delegate decoders.
# The MultiDecoder will pass the PipelinePack to be decoded to each of the delegate
# decoders in turn until decode succeeds. In the case of failure to decode,
# MultiDecoder will return an error and recycle the message.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
# $subs::                         An ordered list of subdecoders to which the MultiDecoder will delegate.
#                                 Each item in the list should specify another decoder configuration section
#                                 by section name. Must contain at least one entry.
#                                 Type: string
#
# $log_sub_errors::               If true, the DecoderRunner will log the errors returned whenever a delegate
#                                 decoder fails to decode a message.
#                                 Defaults to false.
#                                 Type: bool
#
# $cascade_strategy::             Specifies behavior the MultiDecoder should exhibit with regard to cascading
#                                 through the listed decoders. Supports only two valid values: "first-wins" and "all".
#                                 With "first-wins", each decoder will be tried in turn until there is a successful
#                                 decoding, after which decoding will be stopped. With "all", all listed decoders
#                                 will be applied whether or not they succeed. In each case, decoding will only be
#                                 considered to have failed if none of the sub-decoders succeed.
#                                 Type: string
#
define heka::decoder::multidecoder (
  $ensure           = 'present',
  # MultiDecoder Parameters
  $subs,
  $log_sub_errors   = false,
  $cascade_strategy = undef,
){
  validate_re($ensure, '^(present|absent)$')
  validate_string($subs)
  validate_bool($log_sub_errors)
  if $cascade_strategy { validate_string($cascade_strategy) }

  $full_name = "multidecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/decoder/multidecoder.toml.erb"),
  }
}

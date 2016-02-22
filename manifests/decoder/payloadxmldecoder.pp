# This decoder plugin accepts XML blobs in the message payload and allows you to map parts of the XML into Field attributes
# of the pipeline pack message using XPath syntax using the xmlpath library.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
# $xpath_map::                    A subsection defining a capture name that maps to an XPath expression. Each expression can
#                                 fetch a single value, if the expression does not resolve to a valid node in the XML blob,
#                                 the capture group will be assigned an empty string value.
#                                 Type: object
#
# $severity_map::                 Subsection defining severity strings and the numerical value they should be translated to.
#                                 hekad uses numerical severity codes, so a severity of WARNING can be translated to 3 by settings
#                                 in this section.
#                                 Type: object
#
# $message_fields::               Subsection defining message fields to populate and the interpolated values that should be used.
#                                 Valid interpolated values are any captured in a regex in the message_matcher,
#                                 and any other field that exists in the message. In the event that a captured name overlaps with a
#                                 message field, the captured name's value will be used
#                                 Type: object
#
# $timestamp_layout::             A formatting string instructing hekad how to turn a time string into the actual time
#                                 representation used internally.
#                                 Example timestamp layouts can be seen in Go's time documentation. In addition to the Go time
#                                 formatting, special timestamp_layout values of 'Epoch", "EpochMilli", "EpochMicro", and
#                                 "EpochNano" are supported for Unix style timestamps represented in seconds, milliseconds,
#                                 microseconds, and nanoseconds since the Epoch, respectively.
#                                 Type: string
#
# $timestamp_location::           Time zone in which the timestamps in the text are presumed to be in. Should be a location name
#                                 corresponding to a file in the IANA Time Zone database (e.g. "America/Los_Angeles"), as parsed
#                                 by Go's time.LoadLocation() function (see http://golang.org/pkg/time/#LoadLocation).
#                                 Not required if valid time zone info is embedded in every parsed timestamp, since those
#                                 can be parsed as specified in the timestamp_layout.
#                                 This setting will have no impact if one of the supported "Epoch*" values is used as the
#                                 timestamp_layout setting.
#                                 Defaults to "UTC". 
#                                 Type: string
#
define heka::decoder::payloadxmldecoder (
  $ensure             = 'present',
  # PayloadXML Parameters
  # lint:ignore:parameter_order
  $xpath_map,
  # lint:endignore
  $severity_map       = undef,
  $message_fields     = undef,
  $timestamp_layout   = undef,
  $timestamp_location = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # PayloadRegex Parameters
  if $timestamp_layout { validate_string($timestamp_layout) }
  if $timestamp_location { validate_string($timestamp_location) }

  $full_name = "payloadxmldecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/decoder/payloadxmldecoder.toml.erb"),
  }
}

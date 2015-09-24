# The Logstreamer plugin scans, sorts, and reads logstreams in a sequential user-defined order,
# differentiating multiple logstreams found in a search based on a user-defined differentiator.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $splitter::                    Splitter to be used by the input. This should refer to the name of a
#                                registered splitter plugin configuration. It specifies how the input
#                                should split the incoming data stream into individual records prior
#                                to decoding and/or injection to the router. Typically defaults to “NullSplitter”,
#                                although certain inputs override this with a different default value.
#
# $decoder::                     Decoder to be used by the input. This should refer to the name of a registered
#                                decoder plugin configuration. If supplied, messages will be decoded before being
#                                passed on to the router when the InputRunner’s Deliver method is called.
#
# $synchronous_decode::          If synchronous_decode is false, then any specified decoder plugin will be
#                                run by a DecoderRunner in its own goroutine and messages will be passed in
#                                to the decoder over a channel, freeing the input to start processing the
#                                next chunk of incoming or available data. If true, then any decoding will
#                                happen synchronously and message delivery will not return control to the
#                                input until after decoding has completed. Defaults to false.
#
# $send_decode_failures::        If false, then if an attempt to decode a message fails then Heka will log
#                                an error message and then drop the message. If true, then in addition to
#                                logging an error message, decode failure will cause the original, undecoded
#                                message to be tagged with a decode_failure field (set to true) and delivered
#                                to the router for possible further processing.
#
# $can_exit::                    If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                Heka will continue processing other plugins. Defaults to false on most inputs.
#
# $hostname::                    The hostname to use for the messages, by default this will be the machine’s qualified hostname.
#                                This can be set explicitly to ensure it’s the correct name in the event the machine has multiple
#                                interfaces/hostnames.
#
# $oldest_duration::             A time duration string (e.x. “2s”, “2m”, “2h”). Logfiles with a last modified time older than
#                                oldest_duration ago will not be included for parsing. Defaults to “720h” (720 hours, i.e. 30 days).
#
# $journal_directory::           The directory to store the journal files in for tracking the location that has been read to thus
#                                far. By default this is stored under heka’s base directory.
#
# $log_directory::               The root directory to scan files from. This scan is recursive so it should be suitably restricted
#                                to the most specific directory this selection of logfiles will be matched under. The log_directory
#                                path will be prepended to the file_match.
#
# $rescan_interval::             During logfile rotation, or if the logfile is not originally present on the system, this interval
#                                is how often the existence of the logfile will be checked for. The default of 5 seconds is usually
#                                fine. This interval is in milliseconds.
#
# $file_match::                  Regular expression used to match files located under the log_directory. This regular expression has $
#                                added to the end automatically if not already present, and log_directory as the prefix. WARNING:
#                                file_match should typically be delimited with single quotes, indicating use of a raw string, rather
#                                than double quotes, which require all backslashes to be escaped. For example, ‘access\.log’ will
#                                work as expected, but “access\.log” will not, you would need “access\\.log” to achieve the same result.
#
# $priority::                    When using sequential logstreams, the priority is how to sort the logfiles in order from oldest to
#                                newest.
#
# $differentiator::              When using multiple logstreams, the differentiator is a set of strings that will be used in the
#                                naming of the logger, and portions that match a captured group from the file_match will have their
#                                matched
#                                value substituted in.
#
# $translation::                 A set of translation mappings for matched groupings to the ints to use for sorting purposes.
#

define heka::inputs::logstreamerinput (
  $ensure               = 'present',
  # Common Input Parameters
  $splitter             = 'TokenSplitter',
  $decoder              = undef,
  $synchronous_decode   = undef,
  $send_decode_failures = undef,
  $can_exit             = undef,
  # LogstreamerInput specific Parameters
  $hostname             = undef,
  $oldest_duration      = undef,
  $journal_directory    = undef,
  $log_directory,
  $rescan_interval      = undef,
  $file_match,
  $priority             = undef,
  $differentiator       = undef,
  $translation          = undef,
) {
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  # LogstreamerInput specific Parameters
  if $hostname { validate_string($hostname) }
  if $oldest_duration { validate_string($oldest_duration) }
  if $journal_directory { validate_string($hostname) }
  if $log_directory { validate_string($log_directory) }
  if $rescan_interval { validate_integer($rescan_interval) }
  if $file_match { validate_string($file_match) }
  if $priority { validate_array($priority) }
  if $differentiator { validate_array($differentiator) }
  if $translation { validate_hash($translation) }

  $plugin_name = "logstreamerinput_${name}"
  heka::snippet { $plugin_name:
    content => template("${module_name}/plugin/logstreamerinput.toml.erb"),
    ensure  => $ensure,
  }
}

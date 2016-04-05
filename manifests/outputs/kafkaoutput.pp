# Output plugin that connects to a Kafka broker and sends messages to the specified topic
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Output Parameters::    Check heka::outputs::tcpoutput for the description
#
### Kafka Output Parameters
#
# $id::                           Client ID string.
#                                 Default is the hostname.
#                                 Type: string
#
# $addrs::                        List of brokers addresses.
#                                 Type: []string
#
# $metadata_retries::             How many times to retry a metadata request when a partition is in the middle of leader election.
#                                 Default is 3.
#                                 Type: int
#
# $wait_for_election::            How long to wait for leader election to finish between retries (in milliseconds).
#                                 Default is 250.
#                                 Type: uint32
#
# $background_refresh_frequency:: How frequently the client will refresh the cluster metadata in the background (in milliseconds).
#                                 Default is 600000 (10 minutes). Set to 0 to disable.
#                                 Type: uint32
#
# $max_open_reqests::             How many outstanding requests the broker is allowed to have before blocking attempts to send.
#                                 Default is 4.
#                                 Type: int
#
# $dial_timeout::                 How long to wait for the initial connection to succeed before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $read_timeout::                 How long to wait for a response before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $write_timeout::                How long to wait for a transmit to succeed before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $partitioner::                  Chooses the partition to send messages to. The valid values are Random, RoundRobin, Hash.
#                                 Default is Random.
#                                 Type: string
#
# $hash_variable::                The message variable used for the Hash partitioner only. The variables are restricted to Type, Logger,
#                                 Hostname, Payload or any of the message's dynamic field values. All dynamic field values will be converted to a
#                                 string representation. Field specifications are the same as with the Message Matcher Syntax e.g. Fields[foo][0][0].
#                                 Type: string
#
# $topic_variable::               The message variable used as the Kafka topic (cannot be used in conjunction with the 'topic' configuration).
#                                 The variable restrictions are the same as the hash_variable.
#                                 Type: string
#
# $topic::                        A static Kafka topic (cannot be used in conjunction with the 'topic_variable' configuration).
#                                 Type: string
#
# $required_acks::                The level of acknowledgement reliability needed from the broker.
#                                 The valid values are NoResponse, WaitForLocal, WaitForAll.
#                                 Default is WaitForLocal.
#                                 Type: string
#
# $timeout::                      The maximum duration the broker will wait for the receipt of the number of RequiredAcks (in milliseconds).
#                                 This is only relevant when RequiredAcks is set to WaitForAll. Default is no timeout.
#                                 Type: uint32
#
# $compression_codec::            The type of compression to use on messages. The valid values are None, GZIP, Snappy.
#                                 Default is None.
#                                 Type: string
#
# $max_buffer_time::              The maximum duration to buffer messages before triggering a flush to the broker (in milliseconds).
#                                 Default is 1.
#                                 Type: uint32
#
# $max_buffered_bytes::           The threshold number of bytes buffered before triggering a flush to the broker.
#                                 Default is 1.
#                                 Type: uint32
#
# $back_pressure_threshold_bytes:: The maximum number of bytes allowed to accumulate in the buffer before back-pressure is applied to QueueMessage.
#                                 Without this, queueing messages too fast will cause the producer to construct requests larger than
#                                 the MaxRequestSize (100 MiB).
#                                 Default is 50 * 1024 * 1024 (50 MiB), cannot be more than (MaxRequestSize - 10 KiB).
#                                 Type: uint32
#
define heka::outputs::kafkaoutput (
  $ensure                        = 'present',
  # Common Output Parameters
  $message_matcher               = undef,
  $message_signer                = undef,
  $encoder                       = 'ProtobufEncoder',
  $use_framing                   = undef,
  $can_exit                      = undef,
  # Buffering
  $max_file_size                 = undef,
  $max_buffer_size               = undef,
  $full_action                   = undef,
  $cursor_update_count           = undef,
  # Kafka Output
  $id                            = undef,
  # lint:ignore:parameter_order
  $addrs,
  # lint:endignore
  $metadata_retries              = undef,
  $wait_for_election             = undef,
  $background_refresh_frequency  = undef,
  $max_open_reqests              = undef,
  $dial_timeout                  = undef,
  $read_timeout                  = undef,
  $write_timeout                 = undef,
  $partitioner                   = undef,
  $hash_variable                 = undef,
  $topic_variable                = undef,
  # lint:ignore:parameter_order
  $topic,                        = undef,
  # lint:endignore
  $required_acks                 = undef,
  $timeout                       = undef,
  $compression_codec             = undef,
  $max_buffer_time               = undef,
  $max_buffered_bytes            = undef,
  $back_pressure_threshold_bytes = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
  # Buffering
  if $max_file_size { validate_integer($max_file_size) }
  if $max_buffer_size { validate_integer($max_buffer_size) }
  if $full_action { validate_re($full_action, '^(shutdown|drop|block)$') }
  if $cursor_update_count { validate_integer($cursor_update_count) }
  # Kafka Output
  if $id { validate_string($id) }
  validate_array($addrs)
  if $metadata_retries { validate_integer($metadata_retries) }
  if $wait_for_election { validate_integer($wait_for_election) }
  if $background_refresh_frequency { validate_integer($background_refresh_frequency) }
  if $max_open_reqests { validate_integer($max_open_reqests) }
  if $dial_timeout { validate_integer($dial_timeout) }
  if $read_timeout { validate_integer($read_timeout) }
  if $write_timeout { validate_integer($write_timeout) }
  if $partitioner { validate_string($partitioner) }
  if $hash_variable { validate_string($hash_variable) }
  if $topic_variable { validate_string($topic_variable) }
  if $topic { validate_string($topic) }
  if $required_acks { validate_string($required_acks) }
  if $timeout { validate_integer($timeout) }
  if $compression_codec { validate_string($compression_codec) }
  if $max_buffer_time { validate_integer($max_buffer_time) }
  if $max_buffered_bytes { validate_integer($max_buffered_bytes) }
  if $back_pressure_threshold_bytes { validate_integer($back_pressure_threshold_bytes) }

  $full_name = "kafkaoutput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/kafkaoutput.toml.erb"),
  }
}

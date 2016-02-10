# Output plugin that connects to a Kafka broker and sends messages to the specified topic
#
# === Parameters:
#
# $ensure::                      	This is used to set the status of the config file: present or absent
#
# $message_matcher::             	Boolean expression, when evaluated to true passes the message to the filter for processing.
#                                	Defaults to matching nothing
#
# $message_signer::              	The name of the message signer. If specified only messages with this signer are passed to the
#                                	filter for processing.
#
# $encoder::                     	Encoder to be used by the output. This should refer to the name of an encoder plugin section that
#                                     	is specified elsewhere in the TOML configuration.
#                                     	Messages can be encoded using the specified encoder by calling the OutputRunner's Encode() method.
#
# $use_framing::                      	Specifies whether or not Heka's Stream Framing should be applied to the binary data returned from
#                                     	the OutputRunner's Encode() method.
#
# $can_exit::                         	Whether or not this plugin can exit without causing Heka to shutdown. Defaults to false.
#
# $id::                               	Client ID string. 
#                                     	Default is the hostname.
#
# $addrs::                            	List of brokers addresses.
#
# $metadata_retries::                 	How many times to retry a metadata request when a partition is in the middle of leader election.
#                                     	Default is 3.
#
# $wait_for_election::                	How long to wait for leader election to finish between retries (in milliseconds).
#                                     	Default is 250.
#
# $background_refresh_frequency::     	How frequently the client will refresh the cluster metadata in the background (in milliseconds).
#                                	Default is 600000 (10 minutes). Set to 0 to disable.
#
# $max_open_reqests::			How many outstanding requests the broker is allowed to have before blocking attempts to send.
#					Default is 4.
#
# $dial_timeout::			How long to wait for the initial connection to succeed before timing out and returning an error (in milliseconds).
#					Default is 60000 (1 minute).
#
# $read_timeout::			How long to wait for a response before timing out and returning an error (in milliseconds).
#					Default is 60000 (1 minute).
#
# $write_timeout::			How long to wait for a transmit to succeed before timing out and returning an error (in milliseconds).
#					Default is 60000 (1 minute).
#
# $partitioner::			Chooses the partition to send messages to. The valid values are Random, RoundRobin, Hash.
#					Default is Random.
#
# $hash_variable::			he message variable used for the Hash partitioner only. The variables are restricted to Type, Logger,
#					Hostname, Payload or any of the message’s dynamic field values. All dynamic field values will be converted to a
#					string representation. Field specifications are the same as with the Message Matcher Syntax e.g. Fields[foo][0][0].
#
# $topic_variable::			The message variable used as the Kafka topic (cannot be used in conjunction with the ‘topic’ configuration). 
#					The variable restrictions are the same as the hash_variable.
#
# $topic::				A static Kafka topic (cannot be used in conjunction with the ‘topic_variable’ configuration).
#
# $required_acks::			The level of acknowledgement reliability needed from the broker. 
#					The valid values are NoResponse, WaitForLocal, WaitForAll.
#					Default is WaitForLocal.
#
# $timeout::				The maximum duration the broker will wait for the receipt of the number of RequiredAcks (in milliseconds).
#					This is only relevant when RequiredAcks is set to WaitForAll. Default is no timeout.
#
# $compression_codec::			The type of compression to use on messages. The valid values are None, GZIP, Snappy.
#					Default is None.
#
# $max_buffer_time::			The maximum duration to buffer messages before triggering a flush to the broker (in milliseconds).
#					Default is 1.
#
# $max_buffered_bytes::			The threshold number of bytes buffered before triggering a flush to the broker.
#					Default is 1.
#
# $back_pressure_threshold_bytes::	The maximum number of bytes allowed to accumulate in the buffer before back-pressure is applied to QueueMessage.
#					Without this, queueing messages too fast will cause the producer to construct requests larger than
#					the MaxRequestSize (100 MiB). Default is 50 * 1024 * 1024 (50 MiB), cannot be more than (MaxRequestSize - 10 KiB).
#

define heka::outputs::kafkaoutput (
  $ensure                       = 'present',
  # Common Output Parameters
  $message_matcher,
  $message_signer               	= undef,
  $encoder                      	= 'ProtobufEncoder',
  $use_framing                  	= undef,
  $can_exit                     	= undef,
  # Kafka Output
  $id					= undef,
  $addrs,
  $metadata_retries             	= undef,
  $wait_for_election			= undef,
  $background_refresh_frequency 	= undef,
  $max_open_reqests			= undef,
  $dial_timeout				= undef,
  $read_timeout				= undef,
  $write_timeout			= undef,
  $partitioner				= undef,
  $hash_variable			= undef,
  $topic_variable			= undef,
  $topic,
  $required_acks			= undef,
  $timeout				= undef,
  $compression_codec			= undef,
  $max_buffer_time			= undef,
  $max_buffered_bytes			= undef,
  $back_pressure_threshold_bytes	= undef,
) {
  # Common Output Parameters
  if $message_matcher { validate_string($message_matcher) }
  if $message_signer { validate_string($message_signer) }
  if $encoder { validate_string($encoder) }
  if $use_framing { validate_bool($use_framing) }
  if $can_exit { validate_bool($can_exit) }
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
  validate_string($topic)
  if $required_acks { validate_string($required_acks) }
  if $timeout { validate_integer($timeout) }
  if $compression_codec { validate_string($compression_codec) }
  if $max_buffer_time { validate_integer($max_buffer_time) }
  if $max_buffered_bytes { validate_integer($max_buffered_bytes) }
  if $back_pressure_threshold_bytes { validate_integer($back_pressure_threshold_bytes) }
  
  $plugin_name = "kafkaoutput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/kafkaoutput.toml.erb"),
  }
}

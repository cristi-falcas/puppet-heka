# Input plugin that connects to a Kafka broker and subscribes to messages from the specified topic and partition
#
# === Parameters:
#
# $ensure::                      	This is used to set the status of the config file: present or absent
#
# $splitter::                    	Splitter to be used by the input. This should refer to the name of a
#                                	registered splitter plugin configuration. It specifies how the input
#                                	should split the incoming data stream into individual records prior
#                                	to decoding and/or injection to the router. Typically defaults to "NullSplitter",
#                                	although certain inputs override this with a different default value.
#
# $decoder::                     	Decoder to be used by the input. This should refer to the name of a registered
#                                	decoder plugin configuration. If supplied, messages will be decoded before being
#                                	passed on to the router when the InputRunner's Deliver method is called.
#
# $synchronous_decode::          	If synchronous_decode is false, then any specified decoder plugin will be
#                                	run by a DecoderRunner in its own goroutine and messages will be passed in
#                                	to the decoder over a channel, freeing the input to start processing the
#                                	next chunk of incoming or available data. If true, then any decoding will
#                                	happen synchronously and message delivery will not return control to the
#                                	input until after decoding has completed. Defaults to false.
#
# $send_decode_failures::        	If false, then if an attempt to decode a message fails then Heka will log
#                                	an error message and then drop the message. If true, then in addition to
#                                	logging an error message, decode failure will cause the original, undecoded
#                                	message to be tagged with a decode_failure field (set to true) and delivered
#                                	to the router for possible further processing.
#
# $can_exit::                    	If false, the input plugin exiting will trigger a Heka shutdown. If set to true,
#                                	Heka will continue processing other plugins. Defaults to false on most inputs.
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
# $topic::				Kafka topic (must be set).
#
# $partition::				Kafka topic partition. 
#					Default is 0.
#
# $group::				A string that uniquely identifies the group of consumer processes to which this consumer belongs.
#					By setting the same group id multiple processes indicate that they are all part of the same consumer group.
#					Default is the id.
#
# $default_fetch_size::			The default (maximum) amount of data to fetch from the broker in each request.
#					The default is 32768 bytes.
#
# $min_fetch_size::			The minimum amount of data to fetch in a request - the broker will wait until at least this many bytes are available.
#					The default is 1, as 0 causes the consumer to spin when no messages are available.
#
# $max_message_size::			The maximum permittable message size - messages larger than this will return MessageTooLarge.
#					The default of 0 is treated as no limit.
#
# $max_wait_time::			The maximum amount of time the broker will wait for min_fetch_size bytes
#					to become available before it returns fewer than that anyways.
#					The default is 250ms, since 0 causes the consumer to spin when no events are available. 
#					100-500ms is a reasonable range for most cases.
# $offset_method::			The method used to determine at which offset to begin consuming messages. The valid values are:
#					 - "Manual" Heka will track the offset and resume from where it last left off (default).
#					 - "Newest" Heka will start reading from the most recent available offset.
#					 - "Oldest" Heka will start reading from the oldest available offset.
#
# $event_buffer_size::			The number of events to buffer in the Events channel. Having this non-zero permits the consumer to
#					continue fetching messages in the background while client code consumes events,greatly improving throughput.
#					The default is 16.
#


define heka::inputs::kafkainput (
  $ensure                       	= 'present',
  # Common Input Parameters
  $splitter             		= 'TokenSplitter',
  $decoder              		= undef,
  $synchronous_decode   		= undef,
  $send_decode_failures 		= undef,
  $can_exit             		= undef,
  # Kafka Input
  $id					= undef,
  $addrs,
  $metadata_retries             	= undef,
  $wait_for_election			= undef,
  $background_refresh_frequency 	= undef,
  $max_open_reqests			= undef,
  $dial_timeout				= undef,
  $read_timeout				= undef,
  $write_timeout			= undef,
  $topic,
  $partition				= undef,
  $group				= undef,
  $default_fetch_size			= undef,
  $min_fetch_size			= undef,
  $max_message_size			= undef,
  $max_wait_time			= undef,
  $offset_method			= undef,
  $event_buffer_size			= undef,
) {
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  # Kafka Input
  if $id { validate_string($id) }
  validate_array($addrs)
  if $metadata_retries { validate_integer($metadata_retries) }
  if $wait_for_election { validate_integer($wait_for_election) }
  if $background_refresh_frequency { validate_integer($background_refresh_frequency) }
  if $max_open_reqests { validate_integer($max_open_reqests) }
  if $dial_timeout { validate_integer($dial_timeout) }
  if $read_timeout { validate_integer($read_timeout) }
  if $write_timeout { validate_integer($write_timeout) }
  validate_string($topic)
  if $partition {validate_integer($partition) }
  if $group { validate_string($group) }
  if $default_fetch_size { validate_integer($default_fetch_size) }
  if $min_fetch_size { validate_integer($min_fetch_size) }
  if $max_message_size { validate_integer($max_message_size) }
  if $max_wait_time { validate_integer($max_wait_time) }
  if $offset_method { validate_string($offset_method) }
  if $event_buffer_size { validate_integer($event_buffer_size) }

  $plugin_name = "kafkainput_${name}"
  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/kafkainput.toml.erb"),
  }
}

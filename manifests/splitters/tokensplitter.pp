# A TokenSplitter is used to split an incoming data stream on every occurrence (or every Nth occurrence) of a single,
# one byte token character. The token will be included as the final character in the returned record.
#
# === Parameters:
#
# $ensure::                      This is used to set the status of the config file: present or absent
#
# $keep_truncated::              If true, then any records that exceed the capacity of the input buffer
#                                will still be delivered in their truncated form. If false, then these records will be dropped.
#                                Defaults to false.
#
# $use_message_bytes::           Most decoders expect to find the raw, undecoded input data stored as the payload of the received
#                                Heka Message struct.
#                                Some decoders, however, such as the ProtobufDecoder, expect to receive a blob of bytes representing
#                                an entire Message struct, not just the payload. In this case, the data is expected to be found on the
#                                MsgBytes attribute of the Message's PipelinePack.
#                                If use_message_bytes is true, then the data will be written as a byte slice to the MsgBytes
#                                attribute, otherwise it will be written as a string to the Message payload. Defaults to false in most
#                                cases, but defaults to true for the HekaFramingSplitter, which is almost always used with the
#                                ProtobufDecoder.
#
# $min_buffer_size::             The initial size, in bytes, of the internal buffer that the SplitterRunner will use for buffering
#                                data streams.
#                                Must not be greater than the globally configured max_message_size. Defaults to 8KiB, although
#                                certain splitters may specify a different default.
#
# $deliver_incomplete_final::    When a splitter is used to split a stream, that stream can end part way through a record.
#                                It's sometimes appropriate to drop that data, but in other cases the incomplete data can still be
#                                useful.
#                                If 'deliver_incomplete_final' is set to true, then when the SplitterRunner's SplitStream method is
#                                used a delivery attempt will be made with any partial record data that may come through immediately
#                                before an EOF.
#                                Defaults to false.
#
# $delimiter::                   String representation of the byte token to be used as message delimiter. Defaults to "\n".
#
# $count::                       Number of instances of the delimiter that should be encountered before returning a record. Defaults
#                                to 1. Setting to 0 has no effect, 0 and 1 will be treated identically. Often used in conjunction with
#                                the deliver_incomplete_final option set to true, to ensure trailing partial records are still delivered.
#

define heka::splitters::tokensplitter (
  $ensure                   = 'present',
  # Common Splitter Parameters
  $keep_truncated           = false,
  $use_message_bytes        = undef,
  $min_buffer_size          = undef,
  $deliver_incomplete_final = false,
  # Token Splitter Parameters
  $delimiter                = '\n',
  $count                    = 1,
) {
  validate_string($ensure)
  validate_bool($keep_truncated)
  if $use_message_bytes { validate_bool($use_message_bytes) }
  if $min_buffer_size { validate_integer($min_buffer_size) }
  validate_bool($deliver_incomplete_final)
  validate_string($delimiter)
  validate_integer($count)

  $plugin_name = "tokensplitter_${name}"

  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/splitters/tokensplitter.toml.erb"),
  }
}

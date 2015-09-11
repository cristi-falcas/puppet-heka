# A RegexSplitter considers any text that matches a specified regular expression to represent a boundary on which records should be
# split. The regular expression may consist of exactly one capture group. If a capture group is specified, then the captured text
# will be included in the returned record. If not, then the returned record will not include the text that caused the regular
# expression match.
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
#                                MsgBytes attribute of the Message’s PipelinePack.
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
#                                It’s sometimes appropriate to drop that data, but in other cases the incomplete data can still be
#                                useful.
#                                If ‘deliver_incomplete_final’ is set to true, then when the SplitterRunner’s SplitStream method is
#                                used a delivery attempt will be made with any partial record data that may come through immediately
#                                before an EOF.
#                                Defaults to false.
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
  $delimiter,
  $delimiter_eol            = true,
) {
  validate_string($ensure)
  validate_bool($keep_truncated)
  if $id { validate_bool($use_message_bytes) }
  if $id { validate_integer($min_buffer_size) }
  validate_bool($deliver_incomplete_final)
  validate_string($delimiter)
  validate_bool($delimiter_eol)

  $plugin_name = "regexsplitter_${name}"

  heka::snippet { $plugin_name:
    content => template("${module_name}/splitters/regexsplitter.toml.erb"),
    ensure  => $ensure,
  }
}

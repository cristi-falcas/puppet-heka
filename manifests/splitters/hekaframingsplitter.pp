# A HekaFramingSplitter is used to split streams of data that use Heka's built- in Stream Framing, with a protocol buffers
# encoded message header supporting HMAC key authentication.
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
#                                an entire Message struct, not just the payload. In this case, the data is expected to be found on
#                                the MsgBytes attribute of the Message's PipelinePack.
#                                If use_message_bytes is true, then the data will be written as a byte slice to the MsgBytes
#                                attribute, otherwise it will be written as a string to the Message payload. Defaults to false in
#                                most cases, but defaults to true for the HekaFramingSplitter, which is almost always used with the
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
# $signer::                      Optional TOML subsection. Section name consists of a signer name, underscore, and numeric version
#                                of the key.
#
# $skip_authentication::         Usually if a HekaFramingSplitter identifies an incorrectly signed message, that message will be
#                                silently dropped. In some cases, however, such as when loading a stream of protobuf encoded Heka
#                                messages from a file system file, it may be desirable to skip authentication altogether.
#                                Setting this to true will do so.
#                                Defaults to false.
#

define heka::splitters::hekaframingsplitter (
  $ensure                   = 'present',
  # Common Splitter Parameters
  $keep_truncated           = false,
  $use_message_bytes        = true,
  $min_buffer_size          = undef,
  $deliver_incomplete_final = false,
  # Token Splitter Parameters
  $signer                   = undef,
  $skip_authentication      = false,
) {
  validate_string($ensure)
  validate_bool($keep_truncated)
  validate_bool($deliver_incomplete_final)
  validate_string($signer)
  validate_bool($skip_authentication)

  $plugin_name = "hekaframingsplitter_${name}"

  heka::snippet { $plugin_name:
    ensure  => $ensure,
    content => template("${module_name}/splitters/hekaframingsplitter.toml.erb"),
  }
}

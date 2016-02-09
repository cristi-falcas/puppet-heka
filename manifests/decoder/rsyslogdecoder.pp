# Parses the rsyslog output using the string based configuration template.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $preserve_data::                True if the sandbox global data should be preserved/restored on plugin shutdown/startup.
#                                 When true this works in conjunction with a global Lua _PRESERVATION_VERSION variable which
#                                 is examined during restoration; if the previous version does not match the current version
#                                 the restoration will be aborted and the sandbox will start cleanly. _PRESERVATION_VERSION should
#                                 be incremented any time an incompatible change is made to the global data schema. If no version
#                                 is set the check will always succeed and a version of zero is assumed.
#
# $memory_limit::                 The number of bytes the sandbox is allowed to consume before being terminated (default 8MiB).
#
# $instruction_limit::            The number of instructions the sandbox is allowed to execute during the
#                                 process_message/timer_event functions before being terminated (default 1M).
#
# $output_limit::                 The number of bytes the sandbox output buffer can hold before being terminated (default 63KiB).
#                                 Warning: messages exceeding 64KiB will generate an error and be discarded by the standard output
#                                 plugins (File, TCP, UDP) since they exceed the maximum message size.
#
# $module_directory::             The directory where 'require' will attempt to load the external Lua modules from. Defaults to ${SHARE_DIR}/lua_modules.
#
# $hostname_keep::                Always preserve the original 'Hostname' field set by Logstreamer's 'hostname' configuration
# setting.
#
# $template::                     The 'template' configuration string from rsyslog.conf.
#                                 http://rsyslog-5-8-6-doc.neocities.org/rsyslog_conf_templates.html
#
# $tz::                           If your rsyslog timestamp field in the template does not carry zone offset information, you may
#                                 set an offset to be applied to your events here. Typically this would be used with the
#                                 "Traditional" rsyslog formats.
#

define heka::decoder::rsyslogdecoder (
  # Common Sandbox Parameters
  $preserve_data          = undef,
  $memory_limit           = undef,
  $instruction_limit      = undef,
  $output_limit           = undef,
  $module_directory       = undef,
  # rsyslog Parameters
  $type                   = $name,
  $hostname_keep          = true,
  $template               = '%TIMESTAMP% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n',
  $tz                     = 'UTC',
) {
  heka::decoder::sandboxdecoder { $name:
    filename => 'lua_decoders/rsyslog.lua',
    config   => {
      'type'          => $type,
      'hostname_keep' => $hostname_keep,
      'template'      => $template,
      'tz'            => $tz,
    },
  }
}

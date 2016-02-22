# Parses the rsyslog output using the string based configuration template.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Check heka::decoder::sandboxdecoder for common parameters
#
### RsyslogDecoder Parameters
# $hostname_keep::                Always preserve the original 'Hostname' field set by Logstreamer's 'hostname' configuration
#                                 setting.
#                                 Type: bool
#
# $template::                     The 'template' configuration string from rsyslog.conf.
#                                 http://rsyslog-5-8-6-doc.neocities.org/rsyslog_conf_templates.html
#                                 Type: string
#
# $tz::                           If your rsyslog timestamp field in the template does not carry zone offset information, you may
#                                 set an offset to be applied to your events here. Typically this would be used with the
#                                 "Traditional" rsyslog formats.
#                                 Type: string
#
define heka::decoder::rsyslogdecoder (
  $ensure            = 'present',
  # Common Sandbox Parameters
  $preserve_data     = undef,
  $memory_limit      = undef,
  $instruction_limit = undef,
  $output_limit      = undef,
  $module_directory  = undef,
  # RsyslogDecoder Parameters
  $type              = $name,
  $hostname_keep     = true,
  $template          = '%TIMESTAMP% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n',
  $tz                = 'UTC',
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Sandbox Parameters
  if $preserve_data { validate_bool($preserve_data) }
  if $memory_limit { validate_integer($memory_limit) }
  if $instruction_limit { validate_integer($instruction_limit) }
  if $output_limit { validate_integer($output_limit) }
  if $module_directory { validate_string($module_directory) }
  # RsyslogDecoder Parameters
  validate_string($type, $template, $tz)
  validate_bool($hostname_keep)

  $sandbox_type = 'SandboxDecoder'
  $script_type = 'lua'
  $filename = 'lua_decoders/rsyslog.lua'
  $config = {
    'type'          => $type,
    'hostname_keep' => $hostname_keep,
    'template'      => $template,
    'tz'            => $tz,
  }

  $full_name = "rsyslogdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/sandbox.toml.erb"),
  }
}

# Parses the rsyslog output using the string based configuration template.
# It uses the sandboxdecoder
#
# === Parameters:
#
# $hostname_keep::                  Always preserve the original ‘Hostname’ field set by Logstreamer’s ‘hostname’ configuration setting.
#
# $template::                       The ‘template’ configuration string from rsyslog.conf. http://rsyslog-5-8-6-doc.neocities.org/rsyslog_conf_templates.html
#
# $tz::                             If your rsyslog timestamp field in the template does not carry zone offset information, you may set an offset to be applied
#                                   to your events here. Typically this would be used with the “Traditional” rsyslog formats.
#
define heka::decoder::rsyslogdecoder (
  $hostname_keep = true,
  $template      = '%TIMESTAMP% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n',
  $tz            = 'UTC',
) {
  heka::decoder::sandboxdecoder { $name:
    filename => "lua_decoders/rsyslog.lua",
    config   => {
      hostname_keep => $hostname_keep,
      template      => $template,
      tz            => $tz,
    }
  }
}

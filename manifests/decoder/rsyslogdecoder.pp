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

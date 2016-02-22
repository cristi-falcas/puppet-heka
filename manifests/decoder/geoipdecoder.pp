# Decoder plugin that generates GeoIP data based on the IP address of a specified field.
# It uses the GeoIP Go project as a wrapper around MaxMind's geoip-api-c library, and thus assumes
# you have the library downloaded and installed. Currently, only the GeoLiteCity database is supported,
# which you must also download and install yourself into a location to be referenced by the db_file config option.
# By default the database file is opened using "GEOIP_MEMORY_CACHE" mode.
# This setting is hard-coded into the wrapper's geoip.go file.
# You will need to manually override that code if you want to specify one of the other modes.
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### GeoIP Parameters
#
# $db_file::                      The location of the GeoLiteCity.dat database.
#                                 Defaults to "/var/cache/hekad/GeoLiteCity.dat"
#
# $source_ip_field::              The name of the field containing the IP address you want to derive the location for.
#
# $target_field::                 The name of the new field created by the decoder.
#
define heka::decoder::geoipdecoder (
  $ensure  = 'present',
  # Geo IP Parameters
  $db_file = '/var/cache/hekad/GeoLiteCity.dat',
  # lint:ignore:parameter_order
  $source_ip_field,
  $target_field,
  # lint:endignore
) {
  validate_re($ensure, '^(present|absent)$')
  validate_string($db_file, $source_ip_field, $target_field)

  $full_name = "geoipdecoder_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/decoder/geoipdecoder.toml.erb"),
  }
}

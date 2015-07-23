# Produces more human readable alert messages.
# It uses the sandboxencoder
#
# === Parameters: none
#
define heka::encoder::alertencoder {
  heka::encoder::sandboxencoder { $name: filename => "lua_encoders/alert.lua", }
}

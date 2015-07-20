define heka::encoder::alertencoder {
  heka::encoder::sandboxencoder { $name: filename => "lua_encoders/alert.lua", }
}

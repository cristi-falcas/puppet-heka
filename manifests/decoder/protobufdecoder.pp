define heka::decoder::protobufdecoder {
  heka::snippet { $name: content => template("${module_name}/decoder/protobufdecoder.toml.erb"), }
}

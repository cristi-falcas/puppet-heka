define heka::encoder::rstencoder {
  heka::snippet { $name: content => template("${module_name}/encoder/rstencoder.toml.erb"), }
}

# The RstEncoder generates a reStructuredText rendering of a Heka message, including all fields and attributes.
# It is useful for debugging, especially when coupled with a Log Output.
#
# === Parameters: none
#
define heka::encoder::rstencoder {
  heka::snippet { $name: content => template("${module_name}/encoder/rstencoder.toml.erb"), }
}

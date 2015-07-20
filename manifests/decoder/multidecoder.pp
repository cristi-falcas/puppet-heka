define heka::decoder::multidecoder (
  $subs,
  $cascade_strategy = undef,
  $log_sub_errors = false,
){
  heka::snippet { $name: content => template("${module_name}/decoder/multidecoder.toml.erb"), }
}

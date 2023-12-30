# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "BITWIDTH"
  ipgui::add_param $IPINST -name "MATSIZE"

}

proc update_PARAM_VALUE.BITWIDTH { PARAM_VALUE.BITWIDTH } {
	# Procedure called to update BITWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BITWIDTH { PARAM_VALUE.BITWIDTH } {
	# Procedure called to validate BITWIDTH
	return true
}

proc update_PARAM_VALUE.MATSIZE { PARAM_VALUE.MATSIZE } {
	# Procedure called to update MATSIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MATSIZE { PARAM_VALUE.MATSIZE } {
	# Procedure called to validate MATSIZE
	return true
}


proc update_MODELPARAM_VALUE.BITWIDTH { MODELPARAM_VALUE.BITWIDTH PARAM_VALUE.BITWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BITWIDTH}] ${MODELPARAM_VALUE.BITWIDTH}
}

proc update_MODELPARAM_VALUE.MATSIZE { MODELPARAM_VALUE.MATSIZE PARAM_VALUE.MATSIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MATSIZE}] ${MODELPARAM_VALUE.MATSIZE}
}


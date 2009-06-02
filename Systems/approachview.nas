
###-------------------------------------------------------------
# Locks the heading and pitch offsets to the 
# defined values

view.manager.register("Approach View", {
	update: func {
		setprop("/sim/current-view/heading-offset-deg",188.5);
		setprop("/sim/current-view/pitch-offset-deg", 3.5);
		setprop("/sim/current-view/roll-offset-deg", 0);
		return 0;
	},
});

###-------------------------------------------------------------
# This utility converts the input angle into a relative bearing
# using the convention of +ve bearing = starboard, -ve = port
#

setlistener("/sim/signals/nasal-dir-initialized", func {
	setlistener("/sim/current-view/heading-offset-deg", func(n) {
		var heading_offset_deg = n.getValue();
		if (heading_offset_deg >= 180){
			setprop("/sim/current-view/heading-offset-rel-deg", 
				heading_offset_deg * -1 + 360);
		} else {
			setprop("/sim/current-view/heading-offset-rel-deg",
				heading_offset_deg * -1);
		}
	});
},1);


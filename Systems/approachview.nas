var loopid = 0;
var appview = view.indexof("Approach View");
var lsoview = view.indexof("Landing Signal Officer View");

###
# Locks the heading and pitch offsets to the 
# defined values

var loop = func(id) {
	id != loopid and return;
	setprop("/sim/current-view/heading-offset-deg",188.5);
	setprop("/sim/current-view/pitch-offset-deg", 3.5);
	setprop("/sim/current-view/roll-offset-deg", 0);
	setprop("/sim/hud/visibility", 0);
	setprop("/sim/hud/visibility[1]", 1);

	settimer(func { loop(id) }, 0);
}

###
# Locks the bearing and pitch offsets to the cuurently selected
# MP model

var lso = func(id) {
	id != loopid and return;

    var view_x = getprop("sim/current-view/viewer-x-m");
	var view_y = getprop("sim/current-view/viewer-y-m");
	var view_z = getprop("sim/current-view/viewer-z-m");
	var self = geo.Coord.new().set_xyz(view_x, view_y, view_z);

	var target_callsign = getprop("sim/current-view/target-callsign");
	var heading = getprop("orientation/heading-deg");
	foreach (var mp; multiplayer.model.list) {
		var n = mp.node;
		var callsign = n.getNode("callsign").getValue();

		if(callsign == target_callsign){
			var x = n.getNode("position/global-x").getValue();
			var y = n.getNode("position/global-y").getValue();
			var z = n.getNode("position/global-z").getValue();
			var ac = geo.Coord.new().set_xyz(x, y, z);
			var ht_ft = n.getNode("position/altitude-ft").getValue();
			var distance = self.distance_to(ac);
			var elevation = math.atan2((ht_ft - 69)* FT2M, distance) * R2D;

			setprop("/sim/current-view/pitch-offset-deg",
				elevation);

			var hdg_offset = (heading - self.course_to(ac));

			if (hdg_offset <= 360) hdg_offset += 360;

			setprop("/sim/current-view/heading-offset-deg",
				hdg_offset);
		}

	}
	settimer(func { lso(id) }, 0)
}

setlistener("/sim/current-view/view-number", func(n) {
	loopid += 1;
	if (n.getValue() == appview)
		loop(loopid);

	if (n.getValue() == lsoview)
		lso(loopid);

}, 1);

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


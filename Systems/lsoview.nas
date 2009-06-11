var lso_view_handler = {
	init: func(node) {
		me.viewN = node;
		me.current = nil;
		me.legendN = 
			props.globals.initNode("/sim/current-view/landing-signal-officer-view", "");
		me.dialog = props.Node.new({ "dialog-name": "lso-view" });
		print("initializing lso view");
	},
	start: func {
		me.listener = setlistener("/sim/signals/multiplayer-updated",
			func me._update_(), 1);
		me.reset();
		fgcommand("dialog-show", me.dialog);
	},
	stop: func {
		fgcommand("dialog-close", me.dialog);
		removelistener(me.listener);
	},
	reset: func {
		me.select(0);
	},
	find: func(callsign) {
		forindex (var i; me.list)
			if (me.list[i].callsign == callsign)
				return i;
		return nil;
	},
	select: func(which) {
		if (num(which) == nil)
			which = me.find(which) or 0;  # turn callsign into index

		me.setup(me.list[which]);
	},
	next: func(step) {
		var i = me.find(me.current);
		i = i == nil ? 0 : math.mod(i + step, size(me.list));
		me.setup(me.list[i]);
	},
	_update_: func {
		var self = { callsign: getprop("/sim/multiplay/callsign"), model:,
				node: props.globals, root: '/' };
		me.list = [self] ~ multiplayer.model.list;
		if (!me.find(me.current))
			me.select(0);
	},
	update: func {
		var view_x = getprop("sim/current-view/viewer-x-m");
		var view_y = getprop("sim/current-view/viewer-y-m");
		var view_z = getprop("sim/current-view/viewer-z-m");
		var self = geo.Coord.new().set_xyz(view_x, view_y, view_z);
		var target_callsign = me.current;
		var heading = getprop("orientation/heading-deg");
        var height=["", "HIGH", "SLIGHTLY HIGH", "GLIDESLOPE", "SLIGHTLY LOW",
            "LOW", "VERY LOW"];

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
				var elevation = math.atan2((ht_ft - 71.932)* FT2M, distance) * R2D;
				var source = 0;
				
				if(distance * M2NM <= 8){

					if ( elevation <= 4.35 and elevation > 4.01 )
						source = 1;
					elsif ( elevation <= 4.01 and elevation > 3.670 )
						source = 2;
					elsif ( elevation <= 3.670 and elevation > 3.330 )
						source = 3;
					elsif ( elevation <= 3.330 and elevation > 2.990 )
						source = 4;
					elsif ( elevation <= 2.990 and elevation > 2.650 )
						source = 5;
					elsif ( elevation <= 2.650 )
						source = 6;
					else
						source = 0;

				}

                setprop("/sim/current-view/distance",
					distance * M2NM);
				setprop("/sim/current-view/height",
					height[source]);
				setprop("/sim/current-view/pitch-offset-deg",
					elevation);

				var hdg_offset = (heading - self.course_to(ac));

				if (hdg_offset <= 360) hdg_offset += 360;

				setprop("/sim/current-view/heading-offset-deg",
					hdg_offset);
			}

		}

		return 0
	},
	setup: func(data) {
		if (data.root == '/') {
		var ident = '[' ~ data.callsign ~ ']';
		} else {
			var ident = '"' ~ data.callsign ~ '" (' ~ data.model ~ ')';
		}

		me.current = data.callsign;
		me.legendN.setValue(ident);

		setprop("/sim/current-view/x-offset-m",-19.7208);
		setprop("/sim/current-view/y-offset-m",21.925);
		setprop("/sim/current-view/z-offset-m",175.307);
		setprop("/sim/current-view/default-field-of-view-deg",25);

		me.viewN.getNode("config").setValues({
			"eye-lat-deg-path":"/" ~ "/position/latitude-deg",
			"eye-lon-deg-path": "/" ~"/position/longitude-deg",
			"eye-alt-ft-path": "/" ~ "/position/altitude-ft",
			"eye-heading-deg-path": "/" ~ "/orientation/heading-deg",
			"target-lon-deg-path": data.root ~ "/position/longitude-deg",
			"target-alt-ft-path": data.root ~ "/position/altitude-ft",
			"target-heading-deg-path": data.root ~ "/orientation/heading-deg",
			"target-pitch-deg-path": data.root ~ "/orientation/pitch-deg",
			"target-roll-deg-path": data.root ~ "/orientation/roll-deg",
		});
	},
};

setlistener("sim/signals/fdm-initialized", func {
	view.manager.register("Landing Signal Officer View", lso_view_handler);
	print("lsoview registered");
});
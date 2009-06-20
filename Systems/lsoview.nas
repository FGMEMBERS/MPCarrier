var lso_view_handler = {
	init: func(node) {
		me.viewN = node;
		me.current = nil;
		me.legendN = 
			props.globals.initNode("/sim/current-view/landing-signal-officer-view", "");
		me.commentaryN = 
			props.globals.initNode("/sim/current-view/lso-commentary", 0, "BOOL");
		me.gearN = 
			props.globals.initNode("/sim/current-view/gear", 0, "DOUBLE");
		me.dialog = props.Node.new({ "dialog-name": "lso-view" });
		me.source = 0;
		me.height = ["", "HIGH", "A LITTLE HIGH", "ON THE GLIDESLOPE", "A LITTLE LOW",
			"LOW", "VERY LOW"];
#      me.commentary;
		me.report3 = 0;
		me.report2 = 0;
		me.report1 = 0;
		me.report0 = 0;
		me.distance = 0;
		me.gear = 0;
		me.flap = 0;
		me.hook = 0;

		print("initializing lso view");
	},
	start: func {
		me.listener = setlistener("/sim/signals/multiplayer-updated",
			func me._update_(), 1);
		me.listener2 = setlistener("/sim/current-view/lso-commentary",
			func me.commentary(), 0);
		me.reset();
		me.commentaryN.setValue(1);
		fgcommand("dialog-show", me.dialog);
	},
	stop: func {
		fgcommand("dialog-close", me.dialog);
		me.commentaryN.setValue(0);
		removelistener(me.listener);
		removelistener(me.listener2);
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
		var heading = getprop("/orientation/heading-deg");

		foreach (var mp; multiplayer.model.list) {
			var n = mp.node;
			var callsign = n.getNode("callsign").getValue();

			if(callsign == target_callsign){
				var x = n.getNode("position/global-x").getValue();
				var y = n.getNode("position/global-y").getValue();
				var z = n.getNode("position/global-z").getValue();
				var ac = geo.Coord.new().set_xyz(x, y, z);
				var ht_ft = n.getNode("position/altitude-ft").getValue();
				var gear_0 = n.getNode("gear/gear/position-norm").getValue();
				var gear_1 = n.getNode("gear/gear[1]/position-norm").getValue();
				var gear_2 = n.getNode("gear/gear[2]/position-norm").getValue();

				if (gear_0 == nil) gear_0 = 0;
				if (gear_1 == nil) gear_1 = 0;
				if (gear_2 == nil) gear_2 = 0;

				me.gear = gear_0 + gear_1 + gear_2;
				me.flap = n.getNode("surface-positions/flap-pos-norm").getValue();
				me.hook = n.getNode("gear/tailhook/position-norm").getValue();

				var distance = self.distance_to(ac);
				var elevation = math.atan2((ht_ft - 71.932)* FT2M, distance) * R2D;
				var source = 0;
				var hdg_offset = heading - self.course_to(ac);

				if (hdg_offset < 0) hdg_offset += 360;
				
				if(distance * M2NM <= 4 ){

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

				} else 
					source = 0;


				setprop("/sim/current-view/distance",
					distance * M2NM);
				setprop("/sim/current-view/height",
						me.height[source]);
				setprop("/sim/current-view/gear",
						me.gear);
				
				if (me.source != source)
					me.commentary();

				me.source = source;

				setprop("/sim/current-view/pitch-offset-deg",
					elevation);

				setprop("/sim/current-view/heading-offset-deg",
					hdg_offset);
			}


		}

		return 0
	},
	commentary: func() {
		var commentary = getprop("/sim/current-view/lso-commentary");

		if (!commentary){
			print("Commentary OFF");
			return;
		}

		var interval = 20;
		var distance = getprop("/sim/current-view/distance");
		var height = getprop("/sim/current-view/height");
		var rel_brg = getprop("/sim/current-view/heading-offset-rel-deg");

		if (rel_brg == nil) rel_brg = 0;

		var warn = reason = "";
		var gear = gear2= "";
		var flap = flap2 = "";
		var hook = "";

#         print ("distance ", me.current, " ", distance, " ", rel_brg);

		if (distance != nil and me.distance != nil 
			and (rel_brg <= -138 or rel_brg >= 122)){

#            print ("updating commentary ",
#				 me.report3, " ", me.report2, " ", me.report1, " ", me.report0);

			if (me.gear < 3){
				gear = " DROP YOUR GEAR";
				gear2 = " NO GEAR";
			}
			if (me.flap < 1){
				flap = " DROP YOUR FLAPS";
				flap2 = " NO FLAPS";
			}
			if (me.hook < 1) hook = " DROP YOUR HOOK";

			if (gear != "" or flap != "" or hook != ""){
				warn = gear ~ flap ~ hook;
				reason = gear2 ~ flap2;
			}

			if (distance > 4 or distance >= me.distance){
				me.report3 = me.report2 = me.report1 = me.report0 = 0;
				
				foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){
					c.getNode("controls/flols/wave-off-lights",1).setValue(0);
				}

			} elsif (distance < 3.1 and distance >=3.0 and !me.report3){
				setprop("/sim/multiplay/chat", 
					me.current ~ ": " ~ "3 MILES");
				me.report3 = 1;
			} elsif (distance < 2.1 and distance >=2.0 and !me.report2){
				setprop("/sim/multiplay/chat", 
					me.current ~ ": " ~ "2 MILES" ~ warn);
				me.report2 = 1;
			} elsif (distance < 1.1 and distance >=1.0 and !me.report1){
				setprop("/sim/multiplay/chat", 
					me.current ~ ": " ~ "1 MILE CALL THE BALL" ~ warn);
				me.report1 = 1;
			} elsif (distance < 0.6 and distance >=0.5 
					and reason != ""  and !me.report0 ){
				setprop("/sim/multiplay/chat", 
					me.current ~ ": " ~ "WAVEOFF WAVEOFF" ~ reason);

				foreach (var c; props.globals.getNode("/ai/models").getChildren("carrier")){
					c.getNode("controls/flols/wave-off-lights",1).setValue(1);
#                   print("wave off ",
#					c.getNode("name",1).getValue(),
#					" ",
#					c.getNode("controls/flols/wave-off-lights",1).getValue());
				}

				me.report0 = 1;
			} elsif (distance < 1.0 and height != "" and !me.report0){
				setprop("/sim/multiplay/chat", 
					me.current ~ ": YOU'RE " ~ height);
				interval = 10;
#			    print(" transmit height ", me.current ~ ": YOU'RE " ~ height);
			}

		}

		me.distance = distance;

		settimer(func { me.commentary() }, interval);

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
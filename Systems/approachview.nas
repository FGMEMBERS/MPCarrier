var loopid = 0;
var appview = view.indexof("Approach View");

var loop = func(id) {
	id != loopid and return;
	setprop("/sim/current-view/heading-offset-deg", 188);
	setprop("/sim/current-view/pitch-offset-deg", 3.5);
	setprop("/sim/current-view/roll-offset-deg", 0);
	settimer(func { loop(id) }, 0);
}

setlistener("/sim/current-view/view-number", func(n) {
	loopid += 1;
	if (n.getValue() == appview)
		loop(loopid);
}, 1);

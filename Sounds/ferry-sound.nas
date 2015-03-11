setlistener("/controls/speed-kts", func(speed) {
    var speed = speed.getValue();
    var vol = speed * 0.028;
    if (vol < 0) vol = vol * -1;
    setprop("/controls/sound-volume", vol);
});

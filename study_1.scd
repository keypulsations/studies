(

~delay   = 4;
~waitFor = { |x, time| (Sweep.kr(0, 1.0) > (~delay * time)) };
~lastFor = { |x, time| (Sweep.kr(0, 1.0) < (~delay * time)) };

x = { |freq=4|
  var lfn = LFPulse.kr(freq);

  var saw = Saw.ar(
    freq: 2,
    mul: LFPulse.kr(
      freq: LFPulse.kr(1).range(1, 10),
      width: 0.1
    )
  );

  var bpf = BPF.ar(in: saw, freq: lfn.range(55, 45), rq: 0.01, mul: 40);

  var gen1 = Gendy3.ar(freq: 404, initCPs: 2) * ~lastFor.set(\time, 4);
  var gen2 = Gendy3.ar(freq: 404, initCPs: 6) * ~waitFor.set(\time, 8);

  var a,t,cycle;
  a = ([ 12, 102, 100, 99, 97, 12, 93, 97, 92, 12, 12, 12 ] - 12).midicps; // ...100, 99, 95/96/97
  b = ([ 12, 102, 100, 99, 97, 12, 93, 97+14, 92+12, 12, 12, 12 ] - 12).midicps; // ...100, 99, 95/96/97
  cycle = a.size * 0.5;
  t = LFSaw.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      a
    ),
    XLine.ar(0.01, 6, 16)
  );
  t = FreeVerb.ar(t, 0.5, 1, 0.25) * ~waitFor.set(\time, 2) * ~lastFor.set(\time, 6);

  u = LFSaw.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      b
    ),
    // XLine.ar(0.01, 4, 4)
    6
  );
  u = FreeVerb.ar(u, 0.5, 1, 0.25) * ~waitFor.set(\time, 6) * ~lastFor.set(\time, 10);

  v = LFSaw.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      a
    ),
    // XLine.ar(0.01, 4, 4)
    10
  );
  v = FreeVerb.ar(v, 0.5, 1, 0.25) * ~waitFor.set(\time, 10);

  ~output = gen1 + gen2 + bpf + t + u + v;

  Pan2.ar(in: ~output, pos: lfn);
}.play;
);
x.set(\freq, 2);
x.set(\freq, 4);
x.set(\freq, 8);

/*
Scale.directory
a = (Scale.spanish.degrees + 80).midicps;
a = ([0, 0, 80, 81, 0, 0, 84, 85, 0, 87, 88, 90 ] + 12).scramble.postln.midicps;

[ 93, 12, 12, 102, 12, 92, 12, 100, 99, 97, 12, 96 ]
[ 12, 99, 96, 100, 93, 92, 97, 12, 102, 12, 12, 12 ]
[ 12, 102, 93, 96, 97, 12, 100, 12, 92, 12, 99, 12 ]
[ 97, 12, 99, 96, 12, 93, 100, 12, 12, 92, 102, 12 ]
[ 12, 102, 100, 99, 96, 12, 93, 97, 92, 12, 12, 12 ]
*/
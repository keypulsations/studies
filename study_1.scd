(

SynthDef.new(\gendrify, { |freq=4,cps=12,gate=1,xNote=97|
  var lfn = LFPulse.kr(freq);

  var saw = Saw.ar(
    freq: 2,
    mul: LFPulse.kr(
      freq: LFPulse.kr(1).range(1, 10),
      width: 0.1
    )
  );

  var bpf = BPF.ar(in: saw, freq: lfn.range(55, 45), rq: 0.01, mul: 40);
  var gen = Gendy3.ar(freq: 404, initCPs: cps);
  var env = Env.adsr(0.001, 0, 1, 0.1, curve: 0);
  var envGen = EnvGen.kr(env, gate, doneAction: 2);
  var a,t,cycle;

  a = ([ 12, 102, 100, 99, xNote, 12, 93, 97, 92, 12, 12, 12 ] - 12).midicps; // ...100, 99, 95/96/97
  cycle = a.size * 0.5;

  t = SinOsc.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      a
    ),
    0,
    1
    // mul: XLine.ar(0.01, 6, 16)
  );
  t = FreeVerb.ar(t, 0.5, 1, 0.25);

  ~output = (gen + bpf + t) * envGen;

  ~output = Pan2.ar(in: ~output, pos: lfn);
  Out.ar([0, 1], ~output);
}).add;
);

(
Pseq([
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, xNote: 97, delta: 8),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, xNote: 96, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, xNote: 95, delta: 8)
]).play;
)

/*
x = Synth(\gendrify);
y = Synth(\gendrify, [\cps, 20]);
x.release;
y.release;
*/
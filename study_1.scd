(
SynthDef.new(\gendrify, {

  |freq=4,cps=12,gate=1,xNote=97,melMul=1,melFadeInTime=0,bpfMul=1,gendyMul=1|

  var lfn = LFPulse.kr(freq);

  var saw = Saw.ar(
    freq: 2,
    mul: LFPulse.kr(
      freq: LFPulse.kr(1).range(1, 10),
      width: 0.1
    )
  );

  var bpf = BPF.ar(in: saw, freq: lfn.range(55, 45), rq: 0.01, mul: 40);
  var gendy = Gendy3.ar(freq: 404, initCPs: cps);
  var env = Env.adsr(0.001, 0, 1, 0.1, curve: 0);
  var envGen = EnvGen.kr(env, gate, doneAction: 2);
  var a,t,cycle;

  a = ([ 12, 102, 100, 99, xNote, 12, 93, 97, 92, 12, 12, 12 ] - 12).midicps; // ...100, 99, 95/96/97
  cycle = a.size * 0.5;

  t = LFSaw.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      a
    ),
    0,
    mul: Line.ar(0, melMul, melFadeInTime)
  );
  t = FreeVerb.ar(t, 0.5, 1, 0.25);

  bpf   = bpf * bpfMul;
  gendy = gendy * gendyMul;

  ~output = (gendy + bpf + t) * envGen;

  ~output = Pan2.ar(in: ~output, pos: lfn);
  Out.ar([0, 1], ~output);
}).add;
);

~scale = Scale.romanianMinor.degrees;
~numZeros = 12 - ~scale.size;
~scale = ~scale ++ (0!~numZeros);

~scale.
~scale = [1,2,3,4]



(

c = ClockFace.new;
c.play;

Pseq([
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 0, delta: 8),
  (instrument: \gendrify, cps: 04, dur: 20, freq: 4, melMul: 1, melFadeInTime: 16, delta: 16),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, melMul: 1.5, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melMul: 2, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melMul: 2, xNote: 96, bpfMul: 0, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 20, freq: 4, melMul: 2, xNote: 97+14, delta: 8)
]).play;
)
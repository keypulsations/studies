(
SynthDef.new(\gendrify, {

  |freq=4,cps=12,gate=1,xNote=10,melMul=1,melFadeInTime=0,bpfMul=1,gendyMul=1,kickMul=0|

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
  var kickGate,kickAmpEnv,kickFreqEnvM,kick;

  // old scale, not so good
  // a = ([ 12, 102, 100, 99, xNote, 12, 93, 97, 92, 12, 12, 12 ] - 12).midicps; // ...100, 99, 95/96/97

  // scale discovery...
  /*
  ~scale = Scale.directory.choose.postln.degrees;
  ~numZeros = 12 - ~scale.size;
  ~scale = ~scale ++ (0!~numZeros);
  ~scale.postln;
  ~scale = ~scale.scramble.postln;
  */

  var scale;
  scale = [ xNote, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 7 ];
  a = (scale + 80).postln.midicps;

  cycle = a.size * 0.5;

  t = SinOsc.ar(
    Select.kr(
      LFSaw.kr(0.5,0.25,cycle,cycle),
      a
    ),
    0,
    mul: Line.ar(0, melMul, melFadeInTime)
  );
  t = FreeVerb.ar(t, 0.35, 1, 0.25);

  bpf   = bpf * bpfMul;
  gendy = gendy * gendyMul;

  kickGate    = Impulse.ar(8, 0) * SinOsc.ar(50);
  kickAmpEnv  =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: kickGate); // try gate: 0
  kickFreqEnvM  =  EnvGen.ar(Env.new([112, 61, 31], [0.005, 0.29], [-4, -5]), gate: kickGate).midicps;
  kick      = LFPulse.ar(kickFreqEnvM, 0, 0.5, 1, -0.5);
  kick      = kick + WhiteNoise.ar(2);
  kick      = RLPF.ar(kick, kickFreqEnvM*1.5, kickAmpEnv);
  kick      = kick + SinOsc.ar(kickFreqEnvM, 0.5, kickAmpEnv);
  kick      = kick.clip2(1) * kickMul;

  ~output = (gendy + bpf + t + kick) * envGen;
  ~output = Pan2.ar(in: ~output, pos: lfn);

  Out.ar([0, 1], ~output);
}).add;

);

(

c = ClockFace.new;
c.play;

Pseq([
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 0, delta: 8),
  (instrument: \gendrify, cps: 04, dur: 20, freq: 4, melMul: 1, melFadeInTime: 16, delta: 16),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, melMul: 1.5, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melMul: 2, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melMul: 2, xNote: 22, bpfMul: 0, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 2, xNote: 20, kickMul: 1.25, delta: 8),
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 2, xNote: 19, kickMul: 1.25, delta: 8),
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 2, xNote: 17, kickMul: 1.25, delta: 8),
  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melMul: 2, xNote: 15, kickMul: 1.25, delta: 8)
]).play;
)

// Scale.kurd
// [ 0, 0, 2, 0, 0, 10, 0, 0, 16, 14, 20, 6 ]
//
// Scale.karjighar
// [ 20, 0, 18, 0, 0, 6, 0, 0, 12, 10, 0, 3 ]
//
// Scale.yakahDesc
// [ 18, 0, 0, 7, 4, 0, 14, 10, 0, 0, 20, 0 ]
//
// Scale.todi
// [ 3, 0, 0, 7, 0, 6, 11, 8, 0, 0, 0, 1 ]
//
// Scale.yu
// [ 10, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 7 ]
//
// ScaleAD.nahawand
// [ 0, 0, 4, 0, 0, 16, 0, 10, 0, 6, 22, 14 ]
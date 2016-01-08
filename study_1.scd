(
SynthDef.new(\gendrify, {

  |freq=4,cps=12,gate=1,vNote=5,wNote=8,xNote=10,melAMul=1,melAFadeInTime=0,melBMul=0,melBFadeInTime=0,bpfMul=1,gendyMul=1,kickMul=0|

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
  var a,b,t,cycleA, cycleB;
  var kickGate,kickAmpEnv,kickFreqEnvM,kick;

  // scale discovery...
  /*
  ~scale = Scale.directory.choose.postln.degrees;
  ~numZeros = 12 - ~scale.size;
  ~scale = ~scale ++ (0!~numZeros);
  ~scale.postln;
  ~scale = (~scale + 68).scramble.postln;
  */

  // ~scale = [ xNote, 0, 0, 0, 0, 0, 3, 0, 0, 0, vNote, 7 ] + 80;
  ~scaleA = [ 0, vNote, 3, 0, wNote, 0, 2, 0, xNote, 7, 0, 0 ] + 68;
  ~scaleA = ~scaleA.midicps;

  ~scaleB = [ 0, vNote, 3, 0, wNote, 0, 2, 0, xNote, 7, 0, 0 ] + 80;
  ~scaleB = ~scaleB.midicps;

  cycleA = ~scaleA.size * 0.5;
  cycleB = ~scaleB.size * 0.5;

  a = SinOsc.ar(
    Select.kr(
      LFSaw.kr(0.5,0.35,cycleA,cycleA),
      ~scaleA
    ),
    0,
    mul: Line.ar(0, melAMul, melAFadeInTime)
  );
  a = FreeVerb.ar(a, 0.35, 1, 0.25);

  b = LFPulse.ar(
    Select.kr(
      LFSaw.kr(0.5,0.35,cycleB,cycleB),
      ~scaleB
    ),
    0,
    mul: Line.ar(0, melBMul, melBFadeInTime)
  );
  b = FreeVerb.ar(b, 0.5, 4, 0.25);

  bpf   = bpf * bpfMul;
  gendy = gendy * gendyMul;

  kickGate    = Impulse.ar(8, 0) * SinOsc.ar(50);
  kickAmpEnv  =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: kickGate); // try gate: 0
  kickFreqEnvM  =  EnvGen.ar(Env.new([112, 61, 31], [0.005, 0.29], [-5, -10]), gate: kickGate).midicps;
  kick      = LFPulse.ar(kickFreqEnvM, 0, 0.5, 1, -0.5);
  kick      = kick + WhiteNoise.ar(2);
  kick      = RLPF.ar(kick, kickFreqEnvM*1.5, kickAmpEnv);
  kick      = kick + SinOsc.ar(kickFreqEnvM, 0.5, kickAmpEnv);
  kick      = kick.clip2(1) * kickMul;

  ~output = (gendy + bpf + a + b + kick) * envGen;
  ~output = Pan2.ar(in: ~output, pos: lfn);

  Out.ar([0, 1], ~output);
}).add;

);

x = Synth(\gendrify, [\melBMul: 2]);

(

// c = ClockFace.new;
// c.play;

Pseq([
/*  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melAMul: 0, delta: 8),
  (instrument: \gendrify, cps: 04, dur: 20, freq: 4, melAMul: 1, melAFadeInTime: 16, delta: 16),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, melAMul: 1.5, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melAMul: 2, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, melAMul: 2.25, delta: 8),
  (instrument: \gendrify, cps: 24, dur: 10, freq: 4, melAMul: 2.5, delta: 8), */
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 27, bpfMul: 0, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 24, kickMul: 1, melBMul:1, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 24, melBMul:1, kickMul: 1, delta: 8)
]).play;
)

/*Scale.huzam
[ 0, 3, 7, 9, 15, 17, 21, 0, 0, 0, 0, 0 ]
[ 97, 80, 80, 80, 89, 80, 80, 101, 95, 83, 87, 80 ]

Scale.hijazDesc
[ 0, 2, 8, 10, 14, 16, 20, 0, 0, 0, 0, 0 ]
[ 80, 80, 82, 80, 90, 96, 94, 80, 80, 100, 88, 80 ]

Scale.egyptian
[ 0, 2, 5, 7, 10, 0, 0, 0, 0, 0, 0, 0 ]
[ 75, 68, 68, 70, 68, 68, 78, 68, 68, 73, 68, 68 ]

Scale.melodicMinorDesc
[ 0, 2, 3, 5, 7, 8, 10, 0, 0, 0, 0, 0 ]
[ 68, 73, 71, 68, 76, 68, 70, 68, 78, 75, 68, 68 ]

Scale.hirajoshi
[ 0, 2, 3, 7, 8, 0, 0, 0, 0, 0, 0, 0 ]
[ 70, 68, 71, 68, 68, 68, 68, 68, 68, 68, 75, 76 ]
*/
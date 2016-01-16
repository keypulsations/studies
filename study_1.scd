(
SynthDef.new(\gendrify, {

  |freq=4,cps=12,gate=1,vNote=5,wNote=8,xNote=10,melAMul=1,melAFadeInTime=0,melBMul=0,melBFadeInTime=0,bpfMul=1,gendyMul=0.5,kickMul=0,hatMul=0|

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
  var env = Env.adsr(0.001, 0, 1, 0.5, curve: 0);
  var envGen = EnvGen.kr(env, gate, doneAction: 2);
  var a,b,t,cycleA, cycleB;
  var kickGate,kickAmpEnv,kickFreqEnvM,kick,hatGate,hatAmpEnv,hatFreqEnvM,hat;
  var outBus=0, amp=0.3;
  var env1, env2, oscs1, noise, n, n2;

  ~scale = [ 0, vNote, 3, 0, wNote, 0, 2, 0, xNote, 7, 0, 0 ] + 68;
  cycle = ~scaleA.size * 0.5;

  a = SinOsc.ar(
    Select.kr(
      LFSaw.kr(0.5,0.35,cycle,cycle),
      ~scaleA.midicps + 68;
    ),
    0,
    mul: Line.ar(0, melAMul, melAFadeInTime)
  );
  a = FreeVerb.ar(a, 0.35, 1, 0.25);

  b = VarSaw.ar(
    [
      Select.kr(
        LFSaw.kr(0.5,0.35,cycle,cycle),
        ~scaleA.midicps + 56;
      ),
      Select.kr(
        LFSaw.kr(0.5,0.35,cycle,cycle),
        ~scaleA.midicps + 56;
      )
    ],
    0,
    0.1,
    mul: Line.ar(0, melBMul, melBFadeInTime)
  );
  b = FreeVerb.ar(b, 0.35, 1, 0.25);

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

  hat = RLPF.ar(
    in: Ringz.ar(
      in: Impulse.ar(2,0.25),
      freq: 6600,
      decaytime: 0.15,
      mul: PinkNoise.ar(6!2)
    ).tanh.madd(LFTri.ar(2.25).range(0.5,0.3)),
    freq: 4000,
    rq: 0.1
  ) * 5;

  hat = FreeVerb.ar(hat, room: 0.25, damp: 0.25);
  hat = hat * hatMul;

  ~output = (a + b + gendy + bpf + hat + kick) * envGen;
  ~output = Pan2.ar(in: ~output, pos: lfn);

  Out.ar([0, 1], ~output);
}).add;

);

(

c = ClockFace.new;
c.play;

Pseq([

  (instrument: \gendrify, cps: 02, dur: 10, freq: 4, melAMul: 0, delta: 8),
  (instrument: \gendrify, cps: 04, dur: 20, freq: 4, melAMul: 1, melAFadeInTime: 16, delta: 16),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, melAMul: 1.5, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melAMul: 2, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, melAMul: 2.25, delta: 8),
  (instrument: \gendrify, cps: 22, dur: 10, freq: 4, melAMul: 2.5, delta: 8),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 27, bpfMul: 0, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 24, gendyMul: 0, delta: 8),

  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 27, bpfMul: 1.5, melBMul: 2, kickMul: 2, hatMul: 1, delta: 8),

  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 24, bpfMul: 1.5, melBMul: 2, kickMul: 1.5, hatMul: 1, delta: 8),

  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 14, vNote: 26, wNote: 27, bpfMul: 1.5, melBMul: 1, kickMul: 2, hatMul: 1.5, delta: 0),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 26, vNote: 38, wNote: 39, bpfMul: 0, melBMul: 1, kickMul: 0, hatMul: 0, delta: 8),

  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 14, vNote: 26, wNote: 24, bpfMul: 1.5, melBMul: 1, kickMul: 2, hatMul: 2, delta: 0),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 26, vNote: 34, wNote: 33, bpfMul: 0, melBMul: 1, kickMul: 0, hatMul: 0, delta: 8),

  (instrument: \gendrify, cps: 24, dur: 10, freq: 4, melAMul: 2, xNote: 34, vNote: 34, wNote: 34, bpfMul: 1.5, melBMul: 1, kickMul: 2, hatMul: 2, delta: 0),
  (instrument: \gendrify, cps: 24, dur: 10, freq: 4, melAMul: 2, xNote: 24, vNote: 24, wNote: 24, bpfMul: 0, melBMul: 1, kickMul: 0, hatMul: 0, delta: 8),

  (instrument: \gendrify, cps: 24, dur: 9, freq: 4, melAMul: 2, xNote: 31, vNote: 31, wNote: 31, bpfMul: 1.5, melBMul: 1, kickMul: 2, hatMul: 2, delta: 0),
  (instrument: \gendrify, cps: 24, dur: 10.75, freq: 4, melAMul: 3, bpfMul: 0, melBMul: 1, delta: 0),
  (instrument: \gendrify, cps: 24, dur: 9, freq: 4, melAMul: 2, xNote: 27, vNote: 27, wNote: 27, bpfMul: 0, melBMul: 1, kickMul: 0, hatMul: 0, delta: 8),

]).play;

)
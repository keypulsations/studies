(
SynthDef.new(\gendrify, {

  |freq=4,cps=12,gate=1,vNote=5,wNote=8,xNote=10,melAMul=1,melAFadeInTime=0,melBMul=0,melBFadeInTime=0,bpfMul=1,gendyMul=0.5,kickMul=0,snareMul=0|

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
  var kickGate,kickAmpEnv,kickFreqEnvM,kick,snareGate,snareAmpEnv,snareFreqEnvM,snare;

  var outBus=0, amp=0.3;
  var env1, env2, hat, oscs1, noise, n, n2;

  ~scaleA = [ 0, vNote, 3, 0, wNote, 0, 2, 0, xNote, 7, 0, 0 ] + 68;
  ~scaleA = ~scaleA.midicps;

  ~scaleB = [ 0, vNote, 3, 0, wNote, 0, 2, 0, xNote, 7, 0, 0 ] + 56;
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

  b = VarSaw.ar(
    [
      Select.kr(
        LFSaw.kr(0.5,0.35,cycleB,cycleB),
        ~scaleB
      ),
      Select.kr(
        LFSaw.kr(0.5,0.35,cycleB,cycleB),
        ~scaleB
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

  snare = RLPF.ar(
    in: Ringz.ar(
      in: Impulse.ar(2,0.25),
      freq: 6600,
      decaytime: 0.15,
      mul: PinkNoise.ar(6!2)
    ).tanh.madd(LFTri.ar(2.25).range(0.5,0.3)),
    freq: 4000,
    rq: 0.1
  ) * 5;

  snare = FreeVerb.ar(snare, room: 0.25, damp: 0.25);
  snare = snare * snareMul;

  n = 5;
  thisThread.randSeed = 4;

  env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
  env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:0);

  oscs1 = Mix.fill(n, {|i|
    SinOsc.ar(
      ( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
      SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
      1/n
    )
  });

  oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
  n2 = 8;
  noise = WhiteNoise.ar;
  noise = Mix.fill(n2, {|i|
    var freq;
    freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
    CombN.ar(noise, 0.04, freq, 0.1)
  }) * (1/n) + noise;
  noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
  noise = BLowShelf.ar(noise, 3000, 0.5, -6);
  noise = BHiPass.ar(noise, 1000, 1.5, env2);

  hat = noise + oscs1;
  hat = hat.softclip;
  hat = hat * amp;



  ~output = (a + b + gendy + bpf + snare) * envGen;
  ~output = Pan2.ar(in: ~output, pos: lfn);

  Out.ar([0, 1], ~output);
}).add;

);

(

c = ClockFace.new;
c.play;

Pseq([

  /*(instrument: \gendrify, cps: 02, dur: 10, freq: 4, melAMul: 0, delta: 8),
  (instrument: \gendrify, cps: 04, dur: 20, freq: 4, melAMul: 1, melAFadeInTime: 16, delta: 16),
  (instrument: \gendrify, cps: 08, dur: 10, freq: 4, melAMul: 1.5, delta: 8),
  (instrument: \gendrify, cps: 16, dur: 10, freq: 4, melAMul: 2, delta: 8),
  (instrument: \gendrify, cps: 20, dur: 10, freq: 4, melAMul: 2.25, delta: 8),
  (instrument: \gendrify, cps: 24, dur: 10, freq: 4, melAMul: 2.5, delta: 8),*/
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 27, bpfMul: 0, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 2, xNote: 14, vNote: 26, wNote: 24, gendyMul: 0, delta: 8),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 14, vNote: 26, wNote: 27, bpfMul: 1.5, melBMul: 1, kickMul: 2, snareMul: 1, delta: 8),
  (instrument: \gendrify, cps: 00, dur: 10, freq: 4, melAMul: 1, xNote: 14, vNote: 26, wNote: 24, bpfMul: 1.5, melBMul: 1, kickMul: 1.5, snareMul: 1, delta: 8),
]).play;
)



















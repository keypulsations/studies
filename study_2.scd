TempoClock.default.tempo = 2;

(
SynthDef.new(\tone, { |note1=62,note2=65,sustain=1,release=1,majMin=4,hiNote=74|

  var seq = [0, majMin, 7, 12, 7, majMin, 0].midiratio;
  var a,s,cycle;

  ~tone  = VarSaw.ar([note1, note2 + 12].midicps, mul: Env.linen(0.01, sustain, release, 0.75).kr(2));
  ~tone  = Mix.ar(~tone);
  ~tone  = FreeVerb.ar(~tone, 0.5, 0.75);

  ~shifter = LFSaw.ar(note2.midicps, mul: Env.linen(0.01, sustain, release, 0.75).kr(2));
  ~result  = PitchShift.ar(~shifter, 0.2, 1, 0, 2);
  ~result  = FreeVerb.ar(~result, 0.5, 0.75, 0.1);

  // ~hiTone  = SinOsc.ar([hiNote, hiNote].midicps, mul: Env.linen(0.01, sustain, release, 0.75).kr(2));
  // ~hiTone  = Mix.ar(~hiTone);
  // ~hiTone  = FreeVerb.ar(~hiTone, 0.5, 0.75);

  ~pulse = SinOsc.ar(freq: [880, 882], mul: LFPulse.ar([2, 3]));
  ~bass  = SinOsc.ar(freq: [880/20, 882/20], mul: LFPulse.ar([3, 3]));

  // ~out = ~hiTone;
  ~out = ~tone + ~pulse + ~bass + ~result;

  Out.ar(0, ~out * 0.25);
}).add;
)

(
SynthDef.new(\lead, {

      var a,s,cycle;
      a = [62, 69, 69, 74, 69, 69, 67, 67, 65, 64, 62, 74].shift(2).midicps;
      a.size.postln;
      cycle = a.size  * 0.5;

      s = VarSaw.ar(
                Select.kr(
                      LFSaw.kr(0.5,0,cycle,cycle),
                      a
                ),
                0.2
      );

  s = FreeVerb.ar(s);
  ~out = Splay.ar(s);

  Out.ar([0, 1], ~out);
}).add;
)

(
Pseq([
  (instrument: \lead, delta: 0),
  (instrument: \tone, sustain: 1, note2: 65, hiNote: 69, delta: 1),
  (instrument: \tone, sustain: 2, note2: 64, hiNote: 74, delta: 2),
  (instrument: \tone, sustain: 1, note2: 67, hiNote: 69, delta: 1),
  (instrument: \tone, sustain: 2, note2: 57, majMin: 3, delta: 2),
  (instrument: \tone, sustain: 1, note2: 67, delta: 1),
  (instrument: \tone, sustain: 2, note2: 65, delta: 2),
  (instrument: \tone, sustain: 1, note2: 64, delta: 1),
  (instrument: \tone, sustain: 2, note2: 62, delta: 2)
], inf).play;
)


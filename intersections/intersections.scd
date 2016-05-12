(
s = Server.local;
s.recSampleFormat = "int16";
s.recChannels = 2;
// s.recHeaderFormat = "WAV";
s.boot;
);

(
~path         = thisProcess.argv[0];
~fullFilePath = thisProcess.argv[1];

f = SCMIRAudioFile(~fullFilePath, [[MFCC, 13],[Chromagram, 12]]);
f.extractFeatures();
f.extractOnsets();
f.gatherFeaturesByOnsets;
l = f.findSections(0,1,10);
l.postln;

~numSections = 4;
~numElements = 5;
~clipLength  = 32;
~sampleRate  = 44100;
~varPath     = ~path ++ "/sections/temp_%" ++ ".wav";

~clock= ExternalClock(TempoClock(2.7725));
~clock.play;

// ClockFace.new.play;

Routine.run({

  8.wait;
  s.waitForBoot({
    s.prepareForRecord(~path ++ "/intersections.aiff");
  });

  ~numSections.do { |i|
    n = rrand(0, l.size - 2);
    f = Buffer.read(s, ~fullFilePath, l[n] * ~sampleRate, (l[n+1] - l[n]) * ~sampleRate);
    f.write(format(~varPath, i), "wav");
  };

  s.sync;
  a = ~numSections.collect({ |i| BBCutBuffer(format(~varPath, i), 16)});
  s.sync;

  ~cutprocA = BBCPPermute(1.0,1,{|i,n| (i**8)%n},{[2, 4].choose});
  ~cutprocB = BBCPPermute(4.0,2,{|i,n| (i**8)%n},{[2, 4].choose});
  ~cutprocC = ThrashCutProc1(0, 0.25, shuffles: 0);
  ~cutprocD = ThrashCutProc1(0, 0.5, 4, shuffles: 0, stopchance: 0);

  ~groupA = ~numElements.collect({ |i| CutGroup(CutBuf2(a[0], dutycycle: CutPBS1({rrand(0.8,1.0)}, 0))) });
  ~groupB = ~numElements.collect({ |i| CutGroup(CutBuf2(a[1], dutycycle: CutPBS1({rrand(0.8,1.0)}, 0))) });
  ~groupC = ~numElements.collect({ |i| CutGroup(CutBuf2(a[2], dutycycle: CutPBS1({rrand(0.8,1.0)}, 0))) });
  ~groupD = ~numElements.collect({ |i| CutGroup(CutBuf2(a[3], dutycycle: CutPBS2({rrand(0.8,1.0)}, 0, 0))) });

  // SECTION I ///////////////////////////////
  ////////////////////////////////////////////

  s.record;
  ~cutsA = ~numElements.collect({ |i| if(i>0){ 8.wait; }; BBCut2(~groupA[i], ~cutprocA).play(~clock); });
  16.wait;

  // ADD
  "add rev 1".postln;
  ~numElements.do { |i| ~groupA[i].add(CutRev1.new(0.25,0.2)); [8, 16].choose.wait; };
  ~numElements.do { |i| ~groupA[i].removeAt(2); };
  4.wait;

  // WARP PROC 1
  "warp proc 1".postln;
  ~numElements.do { |i| ~cutsA[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  2.wait;

  // RETURN PERMUTE
  "return permute".postln;
  ~numElements.do { |i| ~cutsA[i].proc_(BBCPPermute(1.0,1,{|i,n| (i**8)%n},{[2,4].choose})); };
  ~cutsB = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupB[i],~cutprocB).play(~clock); });
  32.wait;

  // WARP PROC 2
  "warp proc 2".postln;
  ~numElements.do { |i| ~cutsA[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  4.wait;

  // RETURN PERMUTE 2
  "return permute 2".postln;
  ~numElements.do { |i| ~cutsA[i].proc_(BBCPPermute(2.0,2,{|i,n| (i**8)%n},{[2, 8].choose})); };
  ~numElements.do { |i| ~cutsB[i].proc_(BBCPPermute(4.0,2,{|i,n| (i**8)%n},{[2, 4].choose})); };
  32.wait;

  // ADD REVS 2
  "add revs 2".postln;
  ~numElements.do { |i| ~groupA[i].add(CutRev1.new(0.25,0.15)); ~groupB[i].add(CutRev1.new(0.25,0.15)); [4, 8].choose.wait; };
  ~numElements.do { |i| ~groupA[i].removeAt(2); ~groupB[i].removeAt(2); };
  4.wait;

  // LAST WARP PROC
  "last warp proc".postln;
  ~numElements.do { |i| ~cutsA[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  ~numElements.do { |i| ~cutsB[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  8.wait;

  ~numElements.do { |i| ~cutsA[i].stop(~clock); };
  // ~numElements.do { |i| ~cutsA[i].free(~clock); };
  ~numElements.do { |i| ~cutsB[i].stop(~clock); };
  // ~numElements.do { |i| ~cutsB[i].free(~clock); };
  ////////////////////////////////////////////
  ////////////////////////////////////////////


  // SECTION II //////////////////////////////
  ///////////////////////////////////////////

  ~blockfunc = { [4, 3].wchoose([0.9, 0.5]) };
  ~cutfunc   = { |len| 1+len};
  ~bpsd      = { |i| [3, 1, 3, 1, 3, 1, 4].wrapAt(i) };

  x          = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(CutBuf2(a[2]), ChooseBlockProc({|left, len| ~blockfunc.value(left, len)}, {|len| ~cutfunc.value(len)}, {|i| ~bpsd.value(i)}), BBCutQuantise1(0.5)).play(~clock); });
  ~bpsd      = { |i| [3, 1, 3, 1, 3, 1, 4].reverse.wrapAt(i) };

  "BAR".postln;
  z          = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupB[i],~cutprocC).play(~clock); });
  8.wait;

  "BAZ".postln;
  y          = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupA[i],~cutprocB).play(~clock); });
  8.wait;

  ~bpsd      = { |i| [2, 2, 2, 2, 4, 2, 2].reverse.wrapAt(i) };

  ~numElements.do { |i| z[i].pause; };
  ~numElements.do { |i| y[i].pause; };

  8.wait;


  "BIZ".postln;
  ~numElements.do { |i| x[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  8.wait;
  ~numElements.do { |i| z[i].resume; };
  ~numElements.do { |i| z[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  8.wait;
  ~numElements.do { |i| y[i].resume; };
  ~numElements.do { |i| y[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[9,19,29].choose},[0.0,0.5,0.5],100.0,{0.8+(0.15.rand)})); };
  8.wait;

  ~numElements.do { |i| z[i].pause;  y[i].pause; };
  4.wait;

  ~numElements.do { |i| z[i].resume; y[i].resume; };
  ~numElements.do { |i| x[i].proc_(ChooseBlockProc({|left, len| ~blockfunc.value(left, len)}, {|len| ~cutfunc.value(len)}, {|i| ~bpsd.value(i)})); };
  ~numElements.do { |i| z[i].proc_(~cutprocA); };
  ~numElements.do { |i| y[i].proc_(~cutprocB); };
  8.wait;

  ~numElements.do { |i| y[i].proc_(~cutprocA); };
  8.wait;

  ~numElements.do { |i| z[i].proc_(~cutprocB); };
  16.wait;

  ~numElements.do { |i| z[i].pause; };
  ~numElements.do { |i| y[i].pause; };
  8.wait;

  ~numElements.do { |i| x[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[8,18,28].choose / 2},[0.0,0.5,0.5],50.0,{0.8+(0.15.rand)})); };
  16.wait;

  "END".postln;
  ~numElements.do { |i| x[i].stop; };

  ////////////////////////////////////////////
  ////////////////////////////////////////////

  // SECTION III ////////////////////////////
  ///////////////////////////////////////////

  z = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupD[i],~cutprocD).play(~clock); });
  4.wait;
  y = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupA[i],~cutprocA).play(~clock); });
  4.wait;
  x = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupC[i],~cutprocC).play(~clock); });
  4.wait;
  w = ~numElements.collect({ |i| if(i>0){ 16.wait; }; BBCut2(~groupB[i],~cutprocB).play(~clock); });
  4.wait;

  ~numElements.do { |i| z[i].pause; y[i].pause; x[i].pause; w[i].pause; };

  ~numElements.do { |i| z[i].resume; z[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[8,18,28].choose / 2},[0.0,0.5,0.5],50.0,{0.8+(0.15.rand)})); };
  4.wait;
  ~numElements.do { |i| y[i].resume; y[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[8,18,28].choose / 2},[0.0,0.5,0.5],50.0,{0.8+(0.15.rand)})); };
  4.wait;
  ~numElements.do { |i| x[i].resume; x[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[8,18,28].choose / 2},[0.0,0.5,0.5],50.0,{0.8+(0.15.rand)})); };
  4.wait;
  ~numElements.do { |i| w[i].resume; w[i].proc_(WarpCutProc1({[1,2,4].wchoose([0.7,0.2,0.1])},{[8,18,28].choose / 2},[0.0,0.5,0.5],50.0,{0.8+(0.15.rand)})); };
  4.wait;

  ~numElements.do { |i| z[i].stop; y[i].stop; x[i].stop; w[i].stop; };

  ////////////////////////////////////////////
  ////////////////////////////////////////////

  s.stopRecording;
  ("bash " ++ ~path ++ "/RenameFile.sh" ++ " " ++ ~path).unixCmd;

});

);
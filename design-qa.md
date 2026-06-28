# RadioPH Speaker Design QA

## Comparison target

- Source visual truth: `design-qa-assets/speaker-reference.png`
- Final implementation: `design-qa-assets/speaker-implementation-final.png`
- Full-view comparison: `design-qa-assets/speaker-full-comparison.png`
- Focused tuner comparison: `design-qa-assets/speaker-focused-comparison.png`
- Device and viewport: iPhone 17 Simulator, 402 × 874 points
- State: Tuner screen, light appearance. The reference shows an active 97.9 station
  while the implementation capture shows the saved 96.3 station in its stopped state.
  This is a data/playback-state difference; the speaker layout is the same in both states.

## Density normalization

- Source pixels: 853 × 1844
- Implementation pixels: 1206 × 2622 at 3× simulator density
- Implementation logical size: 402 × 874 points
- Full comparison normalization: implementation scaled to 853 × 1844 pixels and
  placed beside the unchanged 853 × 1844 source.
- Focused comparison normalization: both tuner-console regions were cropped from
  the normalized 853-pixel-wide images and placed side by side at 1706 × 820 pixels.

## Findings

- No actionable P0, P1, or P2 differences remain in the requested speaker area.
- Fonts and typography: unchanged app typography remains consistent with the
  reference's serif display and compact sans-serif labels.
- Spacing and layout rhythm: the two speaker cones are balanced, equal-sized, and
  vertically aligned around the centered playback control without overflow.
- Colors and visual tokens: black cones, espresso control, warm brass rims, and the
  perforated brass center grille match the selected radio palette.
- Image quality and asset fidelity: the final 768-pixel speaker asset stays sharp at
  simulator scale; concentric ridges, rubber surround, dust cap, rim, and four
  mounting screws remain legible. No white background halo remains.
- Copy and content: no app text was changed as part of the speaker treatment.

## Comparison history

1. Pass 1: `design-qa-assets/speaker-implementation-pass-1.png`
   - P2: a visible white halo surrounded each brass speaker ring because the source
     asset included a white outer margin.
   - Fix: center-cropped the generated woofer asset before its asset-catalog resize,
     preserving the brass rim while removing the white margin.
2. Pass 2: `design-qa-assets/speaker-implementation-final.png`
   - The halo is gone and the speaker rings sit directly on the brass radio face.
   - No remaining P0, P1, or P2 speaker-design issues were found.

## Focused comparison evidence

The focused comparison confirms the requested details at readable scale: paired
black woofer cones, concentric texture, glossy center caps, brass mounting rings,
four screws, and the perforated center grille around the play/pause button.

## Follow-up polish

- P3: the implementation's center grille is slightly narrower and more regular than
  the organic perforation field in the concept image. This keeps the live control
  compact and avoids reducing the speaker diameter.

## Verification

- Xcode Debug build for the booted iPhone 17 Simulator: passed
- Asset catalog compilation: passed
- App launch and final simulator capture: passed

final result: passed

# Visual QA V2 — Mix Isotopes (768×464)

| File | State |
|---|---|
| mix_initial.png | H, bucket mode, empty chamber |
| mix_element_selected.png | Carbon selected |
| mix_bucket_mode.png | Bucket + large atoms UI |
| mix_single_isotope.png | One C-12 in chamber |
| mix_two_isotopes.png | C-12 + C-13 |
| mix_slider_mode.png | Sliders + small atoms |
| mix_multiple_isotopes.png | Slider quantities |
| mix_nature.png | Nature's Mix ~1000 canvas |
| mix_my_mix_restore.png | Restore My Mix after Nature |
| mix_clear.png | Cleared chamber |
| mix_reset.png | Reset → Hydrogen |

Capture:

```bash
flutter test test/isotopes_and_atomic_mass/mix_view/mix_visual_qa_capture_manual_test.dart --timeout 300s
```

Compare against published PhET Mixtures screen at layoutBounds 768×464.

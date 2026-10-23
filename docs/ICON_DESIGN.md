# LocalScribe icon

Original artwork and the requested green recoloring were generated using the built-in imagegen tool on 2026-10-23. No CLI or external image-generation API was used. `LocalScribe-Source.png` preserves the first green bitmap; `LocalScribe-Blue-Source.png` preserves the first blue version. Since version 0.7.6, the shipped artwork is drawn from native paths and gradients in `Sources/LocalScribe/LocalScribeArtwork.swift`, shared with the menu mark. The old generated bitmaps are historical references only. `scripts/RenderBrandIcon.swift` renders each icon size with antialiasing and supersampling, plus a resolution-independent PDF for settings. `scripts/build-icon.sh` packages the representations into ICNS with iconutil.

The menu bar uses a small-size vector adaptation of the same original L/checkmark and pen-nib artwork, drawn in `Sources/LocalScribe/LocalScribeArtwork.swift` with `NSImage.isTemplate = true`. It replaces the temporary generic pen symbol. AppKit controls its light/dark and highlighted tint. It deliberately has no colored background, app-icon square or baked-in foreground color.

## Green revision prompt

Use case: precise-object-edit. Edit target: the attached LocalScribe macOS application icon. Change only the blue/cobalt/indigo background palette to a polished emerald-green gradient, lighter fresh green at top left and deeper forest emerald at bottom right. Preserve the exact white flowing L/checkmark and fountain-pen nib shape, composition, scale, rounded squircle, and restrained dimensional lighting. Keep the small mint tip accent. Preserve genuine transparent space outside the rounded square; clean antialiased outer edges with no colored speckles or stray pixels. Do not introduce any new text or symbols. One finished square app icon, no mockup, no additional variants.

## Generation prompt

Create ONE finished original macOS application icon for LocalScribe, a private on-device writing and grammar assistant. Square canvas, transparent background outside the icon. A polished cobalt-to-indigo rounded squircle with gentle dimensional lighting, occupying about 86% of the canvas and centered. Inside, a bold, beautifully simple white continuous writing stroke forms an abstract L and a confident checkmark, with a small integrated fountain-pen nib detail. The symbol should read as fluent writing and correction, with a single restrained mint accent at the end of the check. Elegant contemporary macOS design, crisp vector-like geometry, restrained depth, no photographic texture, excellent recognition at 16 to 32 pixels. Large simple silhouette, very few elements, no tiny details, no lettering or words, no wordmark, no mockup, no device, no scenery, no external shadow. This is an independent original brand, do not imitate Grammarly or any existing logo. Deliver one centered icon, not a grid.

## Installer icons

The packaged app embeds the green ICNS and vector PDF. The DMG filesystem embeds `.VolumeIcon.icns`; its root Finder custom-icon flag is set on the writable mounted volume before compression. The final DMG file receives its own custom Finder icon through `NSWorkspace.setIcon`. Finder file icons use resource-fork metadata, which some transfer services may strip; the icon inside the mounted volume is embedded in the disk-image data and survives that loss. The package verification mounts the finished image and checks its assets and Finder flag.

The companion `.dmg.zip` is created with `ditto --sequesterRsrc`, preserving the DMG file icon metadata through transfer. Extraction and Finder flags are verified with ditto and GetFileInfo.

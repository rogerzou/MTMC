MTMC
====

### Required items before using our method
- captured frames from multiple cameras.
- background subtractions for each frame (masks).
- people detections from the captured frames.
- see `config_path` and `config_exp` for more information.

### User Instructions
1. Ensure that `LargeScaleCC` in `lib` have the mex files compiled.
1. Enter information into `*.config` files for each camera (i.e. `1.config` for the first camera). See `examples/1.config` for an example.
1. open `config_path`, enter all required paths to its `USER EDIT SECTION`.
1. open `config_exp`, enter reuqired information.
1. Run `1_people_tracker` to track people within a single camera (single-camera trajectories). NOTE: this is not implemented.
1. Run `2_extract_features` to compute features for each single-camera trajectory.
1. Run `3_track_across_cameras` to assign correspondences between single-camera trajectories, outputting final MTMC results.

### Important Notes
- cameras are indexed by nonnegative integer values.
- images for camera X are indexed under the `cameraX\` folder. each `cameraX\` folder are within the main directory listed under `PATH.data_images_path` in `config_path`. The format for background masks is analogous.

### Workspace description
```
MTMC_final/
│   1_people_tracker.m        // people detections -> single-camera trajectories
│   2_extract_features.m      // single-camera trajectories -> features
│   3_track_across_cameras.m  // single-camera trajectories + features -> MTMC output
│   README.md
│   config_exp.m              // configure file paths
│   config_path.m             // configure experiment settings
│
└───src/
    │
    ├───extract_features/     // code used by 2_extract_features
    │   │   extractDetections.m
    │   │   findPatchCoords.m
    │   │   ...
    │
    ├───misc/                 // miscellaneous functions
    │   │   frameAdjust.m
    │   │   loadConfigSettings.m
    │   │   ...
    │
    ├───track_across_cameras/ // code used by 3_track_across_cameras
    │   │   computeMatrices.m
    │   │   findAppearanceGroups.m
    │   │   ...
    │
```

### TODO
1. Incorporate single-camera people tracking to pipeline by filling in `1_people_tracker`. Place functions used for this section in a new folder `people_tracker/` under `src/` (take from `PeopleTracker\` folder).
1. Verify the output of `getPositionalInformation` and `getBaselineDescriptor` in the function `2_extract_features`. Francesco says that `getPositionalInformation` "should be changed to have ground plane information.
".
1. Verify that `linkIdentities`, specifically `computeMatrices` does the right thing.
1. Verify that the libraries `LargeScaleCC` and `graph_partitioning` are actually required.

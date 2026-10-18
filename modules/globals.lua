-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

CHUNK_SIZE = 16

PHYS_BLOCK_ID = entities.def_index(PACK_ID .. ":phys_block")

GENERATED_MODEL_TYPE = 0
DEFAULT_MODEL_TYPE = 1

CONTRAPTIONS_SAVING_FILE = pack.data_file(PACK_ID, "contraptions.bjson")
GLUE_AREAS_SAVING_FILE = pack.data_file(PACK_ID, "glue_areas.bjson")

ROTATOR_MODE_ROTATION = 0
ROTATOR_MODE_ANGLE = 1

PISTON_MODE_SPEED_CONTROL = 0
PISTON_MODE_EXTENSION_CONTROL = 1

PISTON_DISCONDITION_STOP_IN_ANY_POS = 0
PISTON_DISCONDITION_STOP_IN_SRC_POS = 1
PISTON_DISCONDITION_MANUAL = 2

GLUE_AREAS_INTERACTION_DISTANCE = 10

ROTATION_MATRICES = {}
ROTATION_MATRICES.pipe = {
    [0] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 90),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
    [1] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 90),
            mat4.rotate({ 0, 1, 0 }, 270)
    ),
    [2] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 270),
            mat4.rotate({ 0, 1, 0 }, 180)
    ),
    [3] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 270),
            mat4.rotate({ 0, 1, 0 }, 90)
    ),
    [4] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 0),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
    [5] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 180),
            mat4.rotate({ 0, 1, 0 }, 180)
    ),
}

ROTATION_MATRICES.pane = {
    [0] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 0),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
    [1] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 0),
            mat4.rotate({ 0, 1, 0 }, 90)
    ),
    [2] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 0),
            mat4.rotate({ 0, 1, 0 }, 180)
    ),
    [3] = mat4.mul(
            mat4.rotate({ 0, 0, 1 }, 0),
            mat4.rotate({ 0, 1, 0 }, 270)
    ),
}

ROTATION_MATRICES.stairs = {
    [0] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 0),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
    [1] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 0),
            mat4.rotate({ 0, 1, 0 }, 90)
    ),
    [2] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 0),
            mat4.rotate({ 0, 1, 0 }, 180)
    ),
    [3] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 0),
            mat4.rotate({ 0, 1, 0 }, 270)
    ),
    [4] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 180),
            mat4.rotate({ 0, 1, 0 }, 180)
    ),
    [5] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 180),
            mat4.rotate({ 0, 1, 0 }, 90)
    ),
    [6] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 180),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
    [7] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 180),
            mat4.rotate({ 0, 1, 0 }, 270)
    ),
}

ROTATION_MATRICES.none = {
    [0] = mat4.mul(
            mat4.rotate({ 1, 0, 0 }, 0),
            mat4.rotate({ 0, 1, 0 }, 0)
    ),
}

ROTATION_FACES = {}

ROTATION_FACES.none = {
    [0] = "+X"
}

ROTATION_FACES.pane = {
    [0] = "-Z",
    [1] = "-X",
    [2] = "+Z",
    [3] = "+X"
}

ROTATION_FACES.pipe = {
    [0] = "-Z",
    [1] = "+X",
    [2] = "+Z",
    [3] = "-X",
    [4] = "-Y",
    [5] = "+Y"
}

ROTATION_FACES.stairs = {
    [0] = "-Z",
    [1] = "-X",
    [2] = "+Z",
    [3] = "+X",
    [4] = "-Z",
    [5] = "-X",
    [6] = "+Z",
    [7] = "+X",
}
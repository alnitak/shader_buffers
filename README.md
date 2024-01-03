**shader_buffers** aims to simplify the use of shaders with a focus on the ShaderToy.com website.

- [Features](#Features)
- [Getting started](#Getting-started)
- [ShaderBuffers widget Usage](#ShaderBuffers-widget-Usage)
  - [User interaction](#User-interaction)
  - [Add simple check value operations](#Add-simple-check-value-operations)
- [Additional information](#Additional-information)
  - [Writing a fragment shader](#Writing-a-fragment-shader)

## Features


- Use shader output to feed other shader textures.
- Feed shaders with asset images or any widgets as `sampler2D uniforms`.
- Capture user interaction.
- Easily add custom uniforms.
- **Please**, take a look at the [shader_presets](https://github.com/alnitak/shader_presets) package which implements some ready to use shaders, like transitions and effects (from [gl-transitions](https://gl-transitions.com/) or [ShaderToy](https://www.shadertoy.com/)).

Tested on Android Linux and web, on other desktops it should work. Cannot test on Mac and iOS.
Shaders examples are from [ShaderToy.com](https://shadertoy.com) and have been slightly modified. Credits links are in the main shaders sources.

> [!NOTE]  
> Using a shader output to feed itself, produces a memory leak: [memory leak issue](https://github.com/flutter/flutter/issues/138627). Please thumb up!

## Getting started

Since this package is not yet published on *pub.dev*, add it as a dependency in `pubspec.yaml` as shown here:

```
  shader_buffers:
    git:
      url: https://github.com/alnitak/shader_buffers.git
      ref: main
```

## ShaderBuffers widget Usage

The main widget to use is `ShaderBuffers`, which takes its size and `mainImage` as input. Optionally, you can add the `buffers`.

`mainImage` and `buffers` are of type `LayerBuffer`, which defines the fragment shader asset source and the texture channels.

`mainImage` shader must be provided. The more `buffers`, the more performaces will be affected.
Think of `mainImage` as the *Image* layer fragment in ShaderToy.com and `buffers` as *Buffer[A-D]*.

Each frame buffers are computed from the 1st to the last, then `mainImage`.

This widget provides the following uniforms to the fragment shader:
* `sampler2D iChannel[0-N]` as many as defined in `LayerBuffer.channels`
* `vec2 iResolution` the widget width and height
* `float iTime` the current time in seconds from the start of rendering
* `float iFrame` the current rendering frame number
* `vec4 iMouse` for user interaction with pointer (see `IMouse`)

To start, you can define the layers:
```dart
/// The main layer uses `shader_main.frag` as fragment shader source and some float uniforms
final mainImage = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_main.glsl',
  uniforms: Uniforms([
      Uniform(
        name: 'blur',
        range: const RangeValues(0, 1),
        defaultValue: 0.9,
        value: 0.9,
      ),
      Uniform(
        name: 'velocity',
        range: const RangeValues(0, 1),
        defaultValue: 0.2,
        value: 0.2,
      ),
    ]),
);
/// This [LayerBuffer] uses 'shader_bufferA.glsl' as the fragment shader
/// and a channel that uses an assets image.
final bufferA = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
);
/// Then you can optionally assign to it the input textures needed by the fragment
bufferA.setChannels([
  IChannel(assetsTexturePath: 'assets/bricks.jpg'),
]);
/// This [LayerBuffer] uses 'shader_bufferB.glsl' as the fragment shader
/// and `bufferA` as texture
final bufferB = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
),
bufferB.setChannels([
  IChannel(buffer: bufferA),
]);
```
Now you can use `ShaderBuffer`:
```dart
ShaderBuffer(
  mainImage: mainImage,
  buffers: [ bufferA, bufferB ],
)
```

`mainImage` and `buffers` are of type `IChannel`. The latter represent the `uniform sampler2D` texture to be passed to the *fragment shader*.

#### User interaction
**ShaderBuffer** listen to the pointer with *onPointerDown*, *onPointerMove*, *onPointerUp* which give back the controller and the position in pixels. Most of the time is more usefult to have back the normalized position (in the 0~1 range) instead of pixels. This can be achived with *onPointerDownNormalized*, *onPointerMoveNormalized*, *onPointerUpNormalized* callbacks.
With the *controller*, the one passed to *ShaderBuffer* or the one returned by the *onPointer** callbacks, is possible to do these:
- play
- pause
- rewind
- getState
- getImouse
- getImouseNormalized

#### Add simple check value operations
It's possible to check for some conditions. 
- a condition is binded to a given ***LayerBuffer***.
- the ***param*** could be:*iMouseX*, *iMouseY*, *iMouseXNormalized*, *iMouseYNormalized*, *iTime*, *iFrame*
- ***checkType*** could be: *minor*, *major*, *equal*
- ***checkValue*** is the value to check
- ***operation*** is the callback that returns true of false based on the resulting check


```dart
controller
  ..addConditionalOperation(
    (
      layerBuffer: mainImage,
      param: Param.iMouseXNormalized,
      checkType: CheckOperator.minor,
      checkValue: 0.5,
      operation: (result) {
        /// [result] == true means (iMouseXNormalized < 0.5 )
      },
    ),
  )
```

**To get something similar to this chart**

<img src="https://github.com/alnitak/shader_buffers/assets/192827/4dc0f799-6109-4489-aae8-df379298c459" width="500" />

```dart
final mainLayer = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_main.frag',
);
final bufferA = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferA.frag',
);
final bufferB = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferB.frag',
);
final bufferC = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferC.frag',
);
mainLayer.setChannels([IChannel(buffer: bufferC)])
bufferB.setChannels([IChannel(buffer: bufferA)]);
bufferC.setChannels([
  IChannel(buffer: bufferA),
  IChannel(buffer: bufferB),
  IChannel(assetsImage: 'assets/bricks.jpg'),
]);
```


## Additional information

The main drawback when willing to port ShaderToy shader buffers is that they use 4 floats per RGBA channel, while with Flutter shader we are stuck using 4 int8 RGBA.
Also, the coordinate system is slightly different: the origin in ShaderToy is *bottom-left* while in Flutter, is *top-left*. This latter issue can be easily bypassed where in the main image layer you see this:
`vec2 uv = fragCoord.xy / iResolution.xy;`
after this line you can add this to swap Y coordinates:
`uv = vec2(uv.x, 1. - uv.y);`

#### Writing a fragment shader

It's mandatory to provide to the shader the folllowing `uniforms` since **shader_buffer** always send them:

```
uniform vec2 iResolution;
uniform float iTime;
uniform float iFrame;
uniform vec4 iMouse;
```

For simplicity there is `assets/shader/common/common_header.frag` to include at the very beginning of the shader:
`#include <common/common_header.frag>` 

it provides also:
`out vec4 fragColor;`

If are experimenting with ShaderToy shaders, start your code copied from it and in the bottom of the file include `main_shadertoy.frag`:
`#include <common/main_shadertoy.frag>`



https://github.com/alnitak/shader_buffers/assets/192827/2595f3ce-3dda-4d2e-bc96-13872570dc3b



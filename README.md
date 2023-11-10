**shader_buffers** aims to simplify the use of shaders with a focus on the ShaderToy.com website.

## Features

- Use shader output to feed other shader textures.
- Feed shaders with asset images as `sampler2D uniforms`.
- Capture user interaction.

#### Issue
Tested on web and Linux, on other desktops it should work. Cannot test on Mac and iOS. On Android, I don't know why yet, it doesn't work and he blames me for passing too many uniforms!
Practically when reaching `LayerBuffer.computeLayer`, the `_shader._floats` list has one item less when running on Android.

## Getting started

Since this package is not yet published on *pub.dev*, add it as a dependency in `pubspec.yaml` as shown here:

```
  shader_buffers:
    git:
      url: https://github.com/alnitak/shader_buffers.git
      ref: main
```

## Usage

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
/// The main layer which uses `shader_main.frag` as a fragment shader source
final mainImage = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_main.glsl',
);
/// This [LayerBuffer] uses 'shader_bufferA.glsl' as the fragment shader
/// and 2 other channels: the 1st is the buffer with id=1 (`bufferB`),
/// the 2nd uses an assets image.
final bufferA = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
  channels: [
    IChannelSource(buffer: 1),
    IChannelSource(assetsImage: 'assets/noise_color.png'),
  ],
);
/// This [LayerBuffer] uses 'shader_bufferB.glsl' as the fragment shader
/// and `bufferA` with id=0
final bufferB = LayerBuffer(
  shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
  channels: [
    IChannelSource(buffer: 0),
  ],
),
```
Now you can use `ShaderBuffer`:
```dart
ShaderBuffer(
  width: 500,
  height: 300,
  mainImage: mainImage,
  buffers: [ bufferA, bufferB ],
)
```

To achieve something similar to this flow:

<img src="https://github.com/alnitak/shader_buffers/assets/192827/4dc0f799-6109-4489-aae8-df379298c459" width="500" />

```dart
final mainLayer = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_main.glsl',
    channels: [IChannelSource(buffer: 2)],
);
final bufferA = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
);
final bufferB = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
    channels: [
      IChannelSource(buffer: 0),
    ],
);
final bufferC = LayerBuffer(
    shaderAssetsName: 'assets/shaders/shader_bufferC.glsl',
    channels: [
      IChannelSource(buffer: 0),
      IChannelSource(buffer: 1),
      IChannelSource(assetsImage: 'assets/bricks.jpg'),
    ],
);
```


## Additional information

The main drawback when willing to port ShaderToy shader buffers is that they use 4 floats per RGBA channel, while with Flutter shader we are stuck using 4 int8 RGBA.
Also, the coordinate system is slightly different: the origin in ShaderToy is *bottom-left* while in Flutter, is *top-left*. This latter issue can be easily bypassed where in the main image layer you see this:
`vec2 uv = fragCoord.xy / iResolution.xy;`
after this line you can add this to swap Y coordinates:
`uv = vec2(uv.x, 1. - uv.y);`

PS: shader credits links are in the main shaders sources.


https://github.com/alnitak/shader_buffers/assets/192827/2595f3ce-3dda-4d2e-bc96-13872570dc3b



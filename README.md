# DUGco AlphaGenSAM: AI mattes in Blackmagic Fusion, powered by ComfyUI

Part of the **DUGco OFX tool pack**.

> **Beta (Windows).** A fork of [dughogan/nuke-alphagen-ofx](https://github.com/dughogan/nuke-alphagen-ofx),
> adapted to load in **Blackmagic Fusion** (the OFX plug-in is host-generic; only the
> install/build scripts and docs were retargeted). Please report issues.

https://github.com/user-attachments/assets/82008daa-31d7-46d2-810f-cc1a0f74b993

**The demo** (86 s): selecting objects with SAM 3.1, pulling LTX-2.5 Alpha-Gen mattes on Comfy
Cloud, and the premulted layers in the viewer (recorded in Nuke; the tool is the same in
Fusion). Full-quality 1080p version:
[download](https://github.com/dughogan/nuke-alphagen-ofx/raw/main/docs/dugco_alphagensam_demo.mp4).

AlphaGenSAM is a Fusion tool that pulls a clean, soft-edged matte for **one object** in a
busy shot: the car, the actor, the building. You type what you want (or click it),
press **Process**, and the matte lands in the alpha channel, with hair, glass and motion
blur intact.

Under the hood it runs **SAM 3.1** (selection and tracking), the **LTX clean-plate
IC-LoRA** (removes the other objects), **LTX-2.5 Alpha-Gen** (the matte) and **Depth
Anything 3** (who is in front). It never runs them in Fusion itself. Fusion is the whole
interface; **ComfyUI is the engine**, and you choose where that engine runs:

| | **Comfy Cloud** (default) | **Comfy Local** |
|---|---|---|
| What you need | A Comfy Cloud subscription and an API key | Your own ComfyUI and a big NVIDIA GPU (~48 GB VRAM) |
| Setup | 2 minutes: paste your API key into the node | Install ComfyUI and download ~40 GB of models |
| Where it runs | Cloud GPUs. Any laptop that runs Fusion will do. | Your machine, or another one on your network |

Same tool, same results, either way. If your workstation isn't a GPU monster, **Comfy
Cloud gives you the compute while you keep working in Fusion.**

## Install (Windows)

1. Download the latest release zip and unzip it anywhere.
2. Close Fusion, then right-click **`install.bat`** and choose **Run as administrator**.
   It copies the plug-in to `%COMMONPROGRAMFILES%\OFX\Plugins`, the standard shared
   OFX folder used by plugins such as Sapphire.
3. Start Fusion and search the OpenFX tool list for `AlphaGenSAM`.

To remove it, close Fusion and run `uninstall.bat` as administrator.

## Set up Comfy Local (the default)

1. Install [ComfyUI](https://www.comfy.org/download) 0.39 or later (core nodes only; no custom
   node packs needed) and start it.
2. In Fusion, create an AlphaGenSAM tool and open its **ComfyUI Backend** section. Leave
   **backend** set to *Comfy Local*, confirm the **local server** address is
   `http://127.0.0.1:8188`, and press **Test Connection**.
3. Download the required models into ComfyUI's model folders:

| Folder | File | Source |
|---|---|---|
| `checkpoints` | `sam3.1_multiplex_fp16.safetensors` | Comfy-Org repackage of Meta SAM 3.1 |
| `diffusion_models` | `ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors` | `Lightricks/LTX-2.5` (gated: accept the license on Hugging Face) |
| `text_encoders` | `gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors` | `Lightricks/LTX-2.5` |
| `vae` | `ltx-2.5-video-vae-bf16.safetensors`, `ltx-2.5-audio-vae-bf16.safetensors` | `Lightricks/LTX-2.5` |
| `latent_upscale_models` | `ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` | `Lightricks/LTX-2.5` |
| `loras/ltxv` | `ltx-2.5-22b-ic-lora-alpha-gen-0.9.safetensors` | `Lightricks/LTX-2.5-22b-IC-LoRA-Alpha-Gen` |
| `loras/ltxv` | `ltx-2.5-22b-ic-lora-clean-plate-1.0.safetensors` (or the 2.3 version) | `Lightricks/LTX-2.5-22b-IC-LoRA-Clean-Plate` |
| `geometry_estimation` | `depth_anything_3_mono_large.safetensors` | Comfy-Org repackage of Depth Anything 3 |

## Or set up Comfy Cloud

1. **Subscribe to Comfy Cloud** at [comfy.org](https://www.comfy.org/cloud). Running jobs
   through the API needs a paid plan; free accounts are refused.
2. In Fusion, create an AlphaGenSAM tool and open its **ComfyUI Backend** section.
3. Press **Get an API Key**. Your browser opens the
   [Comfy Developer Platform](https://platform.comfy.org). Sign in **with the same account
   that has your Cloud subscription** and create an API key.
4. Back in Fusion, press **Set API Key...**, paste the key (it stays hidden) and press Save.
   The tool tells you straight away whether Comfy Cloud accepted it, and the **API key**
   line shows `saved (...abcd)`.

That's it. Every AlphaGenSAM tool on this computer uses that key.

**Your key stays private.** It's saved in `Documents\DUGco\comfy_cloud_api_key.txt` on your
computer, never inside the Fusion composition, so you can share `.comp` files safely.
(Pipelines can set the `COMFY_CLOUD_API_KEY` environment variable instead.)

Everything the node needs is already on Comfy Cloud: SAM 3.1, LTX-2.5, the Alpha-Gen and
clean-plate IC-LoRAs, and Depth Anything 3. There's nothing to download.

If a model is missing, the node names it when you press Process.

## Try the example

The `example` folder has a short neon-diner shot (`diner_plate.mp4`). Load it in Fusion and
branch three AlphaGenSAM tools off it, typing `car`, `diner` and `person` in each tool's
`select` field. Each tool pulls its own matte, which you can preview as a cut-out over a
checkerboard.

## Standalone ComfyUI graph

`workflows/alphagen_all_in_one_api.json` is an API-format graph combining SAM 3.1 selection
and LTX-2.5 Alpha-Gen into one prompt. Change its `LoadVideo` input and the SAM text prompt
before running it through ComfyUI's `/prompt` API. It uses the model filenames listed above.
This example graph is fixed to 121 frames at 1280x704; it has not been validated end to end.

## Use

**One tool = one matte.** For several objects, branch several tools off the same plate
(not one after another), then combine their alphas with a Merge or Copy tool.

1. **Select what you want a matte of.**
   * **Type it** in `select`: `car`, `diner`. SAM 3.1 finds every instance. This is the
     primary way to select in Fusion.
   * **Or click it** in the viewer (Ctrl+click includes, Ctrl+Shift+click or Ctrl+Alt+click
     excludes, Alt+click on a dot deletes it) - where the host supports the OFX interact overlay. If the
     dots don't appear, use the typed `select` term instead.
   * If the object is lost later in the shot (it goes behind something and comes back),
     click it again on that frame. Up to 5 frames.
2. **Check the preview.** Every click or edit refreshes a coloured preview of the
   selection in a couple of seconds.
3. **Process.** It uses the input's frame range, or a custom range. Long shots are split
   into overlapping chunks and blended, so there's no limit on length. A progress bar
   shows the job; **Cancel** stops it.
4. **The matte is in the alpha channel.** `show` switches between the matte, a cut-out,
   the untouched plate (for comping) and the selection preview.

You never select what you *don't* want. Other people, cars and animals in the shot are
found and removed automatically. The list is in **Advanced > also remove**.

### How it pulls one object out of a busy shot

Alpha-Gen draws beautiful edges but mattes *everything* it thinks is foreground. So for
your object the node changes what Alpha-Gen sees:

1. **SAM 3.1** tracks your object and finds the other foreground things (**also remove**).
2. **Clean plate.** The LTX clean-plate IC-LoRA rebuilds what's behind those other
   things, only inside their area, so they disappear while your object and the rest of the
   plate stay pixel-for-pixel original.
3. **Alpha-Gen** mattes your object on that clean plate, so its edges are its own.
4. **Who's in front.** Where another object passes in front of yours, Depth Anything 3
   decides who's closer, and the hole is cut with the front object's own soft alpha (real
   hair edges, not a mask outline).
5. **Background objects** like buildings, which Alpha-Gen treats as background, use
   SAM's selection as the body plus whatever soft detail Alpha-Gen finds.

| Mode (Advanced) | What happens |
|---|---|
| clean plate (default) | The method above. |
| auto (paint out) | Faster: other objects are painted out with a fill instead of a clean plate. |
| fast (one pass) | One Alpha-Gen pass split between objects. Quickest, roughest. |
| alpha-gen only | Everything Alpha-Gen sees as foreground, no selection. |
| selection only | SAM 3.1's mask only. |

**Credit.** The isolate-then-matte idea builds on Rikin Patel's
[Comfy Pro Alpha Generator](https://github.com/rik-python/ComfyUI-Comfy-Pro-Alpha-Generator),
used with the author's permission.

### Notes

* **Colour.** Plates go to the models as sRGB (converted from linear by default). Change
  `input colour` under Advanced if your plate is already sRGB.
* **Resolution.** The models run at a working resolution (long edge 1920 by default,
  what Alpha-Gen is tuned for); the matte is resampled back to your plate.
* **Cache.** Each tool keeps its downloaded mattes in a `dugco_cache` folder **next to your
  Fusion composition**, so results travel with the shot and reopening the comp never re-runs
  (or re-pays for) processing. Unsaved comps use `%TEMP%\dugco\AlphaGenSAM` until you save.
  Change it with **cache folder** in the ComfyUI Backend section. The final matte is built
  from these layers when Fusion renders; put a Write tool after AlphaGenSAM to deliver it.

## Build from source

You need the Visual Studio Build Tools (C++ x64). `build.bat` currently points at the
VS 18 BuildTools path; edit the `vcvars64.bat` line if yours differs. Clone with the
OpenFX headers submodule:

```bat
git clone --recursive <this repo>
git submodule update --init --depth 1
build.bat
tools\make_release.bat 0.1.0
```

`build.bat` builds `build\AlphaGenSAM.ofx.bundle` and `build\agsam_selftest.exe`, a headless
test of the whole backend round trip:

```bat
agsam_selftest <frames_dir> <count> <ref> <mode> <http://127.0.0.1:8188 | cloud> x,y,+ ... text:car ...
```

`make_release.bat` packs `dist\DUGco_AlphaGenSAM_<version>_win64.zip` with the bundle,
Fusion `install.bat`, `uninstall.bat` and this README.

The OpenFX headers come from `vendor/openfx`
([AcademySoftwareFoundation/openfx](https://github.com/AcademySoftwareFoundation/openfx), BSD-3-Clause).

| File | Role |
|---|---|
| `src/AlphaGenSAM.cpp` | OFX glue: parameters, viewer clicks, API key setup, render |
| `src/engine.*`, `src/passes.inc`, `src/layers.inc` | Graph builders, jobs, clean plate, depth order, matte maths |
| `src/comfy.*` | ComfyUI / Comfy Cloud REST client (WinHTTP) |
| `src/media.*` | PNG and H.264 with Windows' own codecs (WIC, Media Foundation) |
| `install/` | `install.bat`, `uninstall.bat` |

## Licenses

* **This plug-in:** MIT.
* **Models** carry their own licenses: LTX-2.5, Alpha-Gen and the clean-plate IC-LoRA use
  the LTX-2.x Community License; SAM 3.1 uses the SAM License; Depth Anything 3 its own.
  On Comfy Cloud they're provided by Comfy; locally, each artist downloads them under
  their own account.

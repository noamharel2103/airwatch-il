"""Writes src/manifest.json listing every .luau file so Studio can pull them.

Usage: python tools/manifest.py   (then run tools/sync.luau inside Studio)
Mapping (Rojo-style):
  src/shared/X.luau          -> ReplicatedStorage.Shared.X           (ModuleScript)
  src/server/X.server.luau   -> ServerScriptService.X                (Script)
  src/server/X.luau          -> ServerScriptService.Modules.X        (ModuleScript)
  src/client/X.client.luau   -> StarterPlayerScripts.X               (LocalScript)
  src/client/X.luau          -> StarterPlayerScripts.ClientModules.X (ModuleScript)
"""
import json, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src")
files = []
for folder in ("shared", "server", "client"):
    base = os.path.join(ROOT, folder)
    for dirpath, _, names in os.walk(base):
        for n in sorted(names):
            if n.endswith(".luau"):
                rel = os.path.relpath(os.path.join(dirpath, n), ROOT).replace("\\", "/")
                files.append(rel)
with open(os.path.join(ROOT, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(files, f)
import shutil
shutil.copyfile(os.path.join(os.path.dirname(os.path.abspath(__file__)), "sync.luau"), os.path.join(ROOT, "_devsync.txt"))
shutil.copyfile(os.path.join(os.path.dirname(os.path.abspath(__file__)), "build_world.luau"), os.path.join(ROOT, "_build_world.txt"))
print(len(files), "files")

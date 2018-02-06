import bpy 
import math

far = 8
x = 0
y = 0

z = far/(math.tan(45))
between = math.sqrt((far*far)/2)

scene = bpy.data.scenes["Scene"]

scene.camera.location.z = z

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/1/"
scene.camera.location.y = -far
scene.camera.location.x = 0
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/2/"
scene.camera.location.y = -between
scene.camera.location.x = between
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/3/"
scene.camera.location.y = 0
scene.camera.location.x = far
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/4/"
scene.camera.location.x = between
scene.camera.location.y = between
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/5/"
scene.camera.location.x = 0
scene.camera.location.y = far
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/6/"
scene.camera.location.x = -between
scene.camera.location.y = between
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/7/"
scene.camera.location.x = -far
scene.camera.location.y = 0
bpy.ops.render.render(animation = True)

scene.render.filepath = "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/8/"
scene.camera.location.x = -between
scene.camera.location.y = -between
bpy.ops.render.render(animation = True)
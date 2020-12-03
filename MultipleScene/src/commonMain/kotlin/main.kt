import com.soywiz.klock.seconds
import com.soywiz.korge.*
import com.soywiz.korge.input.onClick
import com.soywiz.korge.render.RenderContext
import com.soywiz.korge.scene.Module
import com.soywiz.korge.scene.Scene
import com.soywiz.korge.scene.SceneContainer
import com.soywiz.korge.tween.*
import com.soywiz.korge.view.*
import com.soywiz.korim.bitmap.Bitmap
import com.soywiz.korim.bitmap.NativeImage
import com.soywiz.korim.bitmap.slice
import com.soywiz.korim.color.Colors
import com.soywiz.korim.color.RGBA
import com.soywiz.korim.color.RgbaArray
import com.soywiz.korim.format.*
import com.soywiz.korinject.AsyncInjector
import com.soywiz.korio.file.std.*
import com.soywiz.korma.geom.degrees
import com.soywiz.korma.interpolation.Easing

//suspend fun main() = Korge(width = 512, height = 512, bgcolor = Colors["#2b2b2b"]) {
//	val circle = circle(50.0, Colors.GREEN)
//}

suspend fun main() = Korge(Korge.Config(module = MyModule))

object MyModule : Module() {
	override val mainScene = MyScene1::class

	override suspend fun AsyncInjector.configure() {
		mapInstance(MyDependency("HELLO WORLD"))
		mapPrototype { MyScene1(get()) }
	}
}

class MyDependency(val value: String)

class MyScene1(val myDependency: MyDependency) : Scene() {
	override suspend fun Container.sceneInit() {
		text("MyScene1: ${myDependency.value}") { filtering = false }
		imageRohan = rsImage(resourcesVfs["korge.png"].readBitmap())
		circleRohan = circle(50.0 , Colors.GREEN)
	}
}

const val GL_TEXTURE_EXTERNAL_OES = 0x8D65
const val GL_TEXTURE_2D = 0x0DE1

class RSNativeImage(width: Int, height: Int, val name2: UInt, val target2: Int?) : NativeImage(width, height, null, true) {
	override val forcedTexId: Int get() = name2.toInt()
	override val forcedTexTarget: Int get() = if (target2 != null) target2 else GL_TEXTURE_2D

	override fun readPixelsUnsafe(x: Int, y: Int, width: Int, height: Int, out: RgbaArray, offset: Int) {
		TODO("Not yet implemented")
	}

	override fun writePixelsUnsafe(x: Int, y: Int, width: Int, height: Int, out: RgbaArray, offset: Int) {
		TODO("Not yet implemented")
	}
}

class RSImage(bitmap: Bitmap): Image(bitmap) {
	var foo = 0
	override fun renderInternal(ctx: RenderContext) {
		if (foo % 2 == 0) {
			mayank?.invoke()?.let {
				this.bitmap = it.slice()
			}
		}
		foo += 1

		super.renderInternal(ctx)
	}
}

inline fun Container.rsImage(
	texture: Bitmap, anchorX: Double = 0.0, anchorY: Double = 0.0, callback: @ViewDslMarker Image.() -> Unit = {}
): Image = RSImage(texture).addTo(this, callback)

var imageRohan: Image? = null
var circleRohan : Circle? = null

var mayank: (() -> RSNativeImage?)? = null

fun switchToCircle(boolean: Boolean) {
	circleRohan?.visible = boolean
	imageRohan?.visible = !boolean
}







//var scene1 : Scene ? = null
//var scene2 : Scene ? = null
//var container1 : SceneContainer ? = null
//var container2 : SceneContainer ? = null
//
//class LSScene1(val myDependency: MyDependency) : Scene() {
//
//	init {
//	    scene1 = this
//		container1 = this.sceneContainer
//	}
//	override suspend fun Container.sceneInit() {
//		val circleNode = circle(50.0 , Colors.GREEN)
//	}
//}
//
//class LSScene2(val myDependency: MyDependency) : Scene() {
//
//	override suspend fun Container.sceneInit() {
//		val circleNode = circle(50.0 , Colors.RED)
//	}
//}
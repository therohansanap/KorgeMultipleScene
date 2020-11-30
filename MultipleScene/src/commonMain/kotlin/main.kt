import com.soywiz.klock.seconds
import com.soywiz.korge.*
import com.soywiz.korge.tween.*
import com.soywiz.korge.view.*
import com.soywiz.korim.color.Colors
import com.soywiz.korim.format.*
import com.soywiz.korio.file.std.*
import com.soywiz.korma.geom.degrees
import com.soywiz.korma.interpolation.Easing

suspend fun main() = Korge(width = 512, height = 512, bgcolor = Colors["#2b2b2b"]) {
	val circle = circle(50.0, Colors.GREEN)
}

suspend fun main2() = Korge(width = 512, height = 512, bgcolor = Colors["#2b2b2b"]) {
	val circle = circle(50.0, Colors.RED)
}
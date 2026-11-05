package es.huecos

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.widget.TextView

// Pantalla única: muestra el texto "Huecos" en el centro.
class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(TextView(this).apply {
            text = "Huecos"
            setTextColor(Color.BLUE)
            textSize = 32f
            gravity = Gravity.CENTER
        })
    }
}

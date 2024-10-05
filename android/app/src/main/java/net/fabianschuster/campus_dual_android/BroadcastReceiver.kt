package net.fabianschuster.campus_dual_android

import android.content.SharedPreferences
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import net.fabianschuster.campus_dual_android.MainActivity
import android.content.BroadcastReceiver

fun setExchangeData(context: Context, exchangeData: String) {
    val mPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    mPrefs.edit().putString("flutter.widgetExchangeData", exchangeData).apply()
}

class WidgetClickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        // Call your function here
        setExchangeData(context!!, "openTimetable")

        // Now launch the MainActivity
        val mainActivityIntent = Intent(context, MainActivity::class.java)
        mainActivityIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(mainActivityIntent)
    }
}
package net.fabianschuster.campus_dual_android

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.app.PendingIntent
import android.content.Intent
import android.content.ComponentName
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.LocalDate

data class Lesson(
    val title: String,
    val start: LocalDateTime,
    val end: LocalDateTime,
    val allDay: Boolean,
    val description: String,
    val color: String, // Assuming color is stored as a hex string
    val editable: Boolean,
    val room: String,
    val sRoom: String,
    val instructor: String,
    val sInstructor: String,
    val remarks: String,
    val type: String
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Lesson {
            val formatter = DateTimeFormatter.ISO_DATE_TIME
            return Lesson(
                title = json["title"] as? String ?: "",
                start = LocalDateTime.parse(json["start"] as? String ?: "", formatter),
                end = LocalDateTime.parse(json["end"] as? String ?: "", formatter),
                allDay = json["allDay"] as? Boolean ?: false,
                description = json["description"] as? String ?: "",
                color = json["color"] as? String ?: "#FFFFFF", // Default color
                editable = json["editable"] as? Boolean ?: false,
                room = json["room"] as? String ?: "",
                sRoom = json["sRoom"] as? String ?: "",
                instructor = json["instructor"] as? String ?: "",
                sInstructor = json["sInstructor"] as? String ?: "",
                remarks = json["remarks"] as? String ?: "",
                type = json["type"] as? String ?: ""
            )
        }
    }
}

fun parseTimeTableJson(timeTableJson: String): Map<LocalDateTime, List<Lesson>> {
    val gson = Gson()
    val type = object : TypeToken<Map<String, List<Map<String, Any>>>>() {}.type
    val storedData: Map<String, List<Map<String, Any>>> = gson.fromJson(timeTableJson, type)
    
    val formatter = DateTimeFormatter.ISO_DATE_TIME
    return storedData.map { (key, value) ->
        LocalDateTime.parse(key, formatter) to value.map { Lesson.fromJson(it) }
    }.toMap()
}

/**
 * Implementation of App Widget functionality.
 */
class TimetableWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // val widgetText = context.getString(R.string.appwidget_text)

    // Get the data out of shared preferences
    var PRIVATE_MODE = 0
    val mPrefs = context.getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)
    var timeTableJson = mPrefs.getString("flutter." + "timetable", "") ?: ""
    val timeTable = parseTimeTableJson(timeTableJson)

    val currentDate = LocalDate.now()
    val lessonsForToday = timeTable[currentDate.atStartOfDay()]

    val firstLessonTitle = lessonsForToday?.firstOrNull()?.title ?: "No lessons today"

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.timetable_widget)
    views.setTextViewText(R.id.appwidget_text, firstLessonTitle)

    // Create an Intent to update the widget
    val intent = Intent(context, TimetableWidget::class.java)
    intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
    val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, TimetableWidget::class.java))
    intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
    val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    // Set the click handler to update the widget
    views.setOnClickPendingIntent(R.id.appwidget_text, pendingIntent)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
package net.fabianschuster.campus_dual_android

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.app.PendingIntent
import android.content.Intent
import android.content.ComponentName
import org.w3c.dom.Text
import android.net.Uri
import android.app.AlarmManager
import java.time.Duration
import java.time.LocalDateTime
import java.time.format.DateTimeParseException
import android.view.View
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent

// Convert a localDatetime into an time till now string
// Example: Vor 59s, Vor 1min, Vor 23h, Vor 2d...
fun timeTillNowString(localDatetime: String): String {
    val localDateTime = try {
        LocalDateTime.parse(localDatetime)
    } catch (e: DateTimeParseException) {
        println("Error parsing date: $localDatetime")
        return "Unbekannt"
    }
    val now = LocalDateTime.now()
    val duration = Duration.between(localDateTime, now)
    val seconds = duration.seconds
    if (seconds < 60) {
        return "Jetzt"
    }
    val minutes = seconds / 60
    if (minutes < 60) {
        return "Vor ${minutes}min"
    }
    val hours = minutes / 60
    if (hours < 24) {
        return "Vor ${hours}h"
    }
    val days = hours / 24
    return "Vor ${days}d"
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

    // When a broadcast is received
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // Catch the reload intent
        if (intent.action == "timetableWidget://reload") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, TimetableWidget::class.java))

            // Display an loading indicator
            for (appWidgetId in appWidgetIds) {
                setLoadingIndicator(context, appWidgetManager, appWidgetId)
            }

            // Send the actual reload intent
            val reloadIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("timetableWidget://reload")
            )
            reloadIntent.send()
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun setLoadingIndicator(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val views = RemoteViews(context.packageName, R.layout.timetable_widget)
    println("Setting loading indicator")
    views.setViewVisibility(R.id.reload_spinner, View.VISIBLE)
    views.setViewVisibility(R.id.reload_icon, View.GONE)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // Notify the AppWidgetManager to update the list view
    // This is necessary for the actual lesson data to be reloaded because it is independed from the widget
    val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(
        ComponentName(context, TimetableWidget::class.java)
    )
    AppWidgetManager.getInstance(context).notifyAppWidgetViewDataChanged(ids, R.id.lessons_list)

    val views = RemoteViews(context.packageName, R.layout.timetable_widget)

    // Set the RemoteViewsService as the adapter for the ListView
    val intent = Intent(context, TimetableWidgetService::class.java)
    views.setRemoteAdapter(R.id.lessons_list, intent)

    // Handle empty view
    views.setEmptyView(R.id.lessons_list, R.id.empty_view)

    // Reset all possible loading indicators between refreshes
    views.setViewVisibility(R.id.reload_spinner, View.GONE)
    views.setViewVisibility(R.id.reload_icon, View.VISIBLE)

    // Get the last update time from the shared preferences
    val mPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    val lastUpdate = mPrefs.getString("flutter.timetableUpdateTime", "") ?: ""
    // Set the text of the sync_time TextView to the result of calling timeTillNowString
    views.setTextViewText(R.id.sync_time, timeTillNowString(lastUpdate))

    // Schedule an update every minute
    val updateIntent = Intent(context, TimetableWidget::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
    }
    val pendingUpdateIntent = PendingIntent.getBroadcast(context, appWidgetId, updateIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    alarmManager.setRepeating(AlarmManager.RTC, System.currentTimeMillis() + 60000, 60000, pendingUpdateIntent)

    // Sent an dummy reload intent which is catched by the onReceive method and triggers the actual reload
    val reloadIntent = Intent(context, TimetableWidget::class.java).apply {
        action = "timetableWidget://reload"
    }
    val reloadPendingIntent = PendingIntent.getBroadcast(context, 0, reloadIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    views.setOnClickPendingIntent(R.id.reload_icon, reloadPendingIntent)

    // Create an Intent to open the app on click
    // This intent is triggered by each item in the list view in which the fillInIntent method is called
    val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
        context,
        MainActivity::class.java,
        Uri.parse("timetableWidget://openTimetable")
    )
    views.setPendingIntentTemplate(R.id.lessons_list, pendingIntentWithData)

    // Update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

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
    val views = RemoteViews(context.packageName, R.layout.timetable_widget)

    // Set the RemoteViewsService as the adapter for the ListView
    val intent = Intent(context, TimetableWidgetService::class.java)
    views.setRemoteAdapter(R.id.lessons_list, intent)

    // Handle empty view
    views.setEmptyView(R.id.lessons_list, R.id.empty_view)

    // Create an Intent to update the widget (refresh on click)
    val refreshIntent = Intent(context, TimetableWidget::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(
            ComponentName(context, TimetableWidget::class.java)
        )
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)

        // Notify the AppWidgetManager to update the list view
        AppWidgetManager.getInstance(context).notifyAppWidgetViewDataChanged(ids, R.id.lessons_list)
    }

    // Create a PendingIntent to broadcast the refresh Intent
    val pendingIntent = PendingIntent.getBroadcast(context, 0, refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT)

    // Assign the PendingIntent to a widget view (button, text, etc.)
    views.setOnClickPendingIntent(R.id.reload_icon, pendingIntent)

    // Create an Intent to send a broadcast to my BroadcastReceiver which opens the app after saving some exchange data
    val openAppIntent = Intent(context, WidgetClickReceiver::class.java)
    val openAppPendingIntent = PendingIntent.getBroadcast(context, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    views.setOnClickPendingIntent(R.id.appwidget_text, openAppPendingIntent)


    // Update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

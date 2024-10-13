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
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent

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

    // Create an Intent to update the widget (refresh on click)
    val reloadIntent = HomeWidgetBackgroundIntent.getBroadcast(
        context,
        Uri.parse("timetableWidget://reload")
    )
    views.setOnClickPendingIntent(R.id.reload_icon, reloadIntent)

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

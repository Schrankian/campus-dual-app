package net.fabianschuster.campus_dual_android

import android.content.Context
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.content.Intent
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.LocalDate
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import net.fabianschuster.campus_dual_android.R

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

class TimetableRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private var lessons: List<Lesson> = emptyList()

    override fun onCreate() {
        // Load initial data if necessary
    }

    override fun onDataSetChanged() {
        // Update lessons list from SharedPreferences or other data source
        val mPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val timeTableJson = mPrefs.getString("flutter.timetable", "") ?: ""
        val timeTable = parseTimeTableJson(timeTableJson)

        // Add 3 days to the current date for testing
        val currentDate = LocalDate.now().plusDays(4)
        lessons = timeTable[currentDate.atStartOfDay()] ?: emptyList()
    }

    override fun onDestroy() {
        lessons = emptyList()
    }

    override fun getCount(): Int {
        return lessons.size
    }

    override fun getViewAt(position: Int): RemoteViews? {
        if (position >= lessons.size) return null
        val lesson = lessons[position]
        val views = RemoteViews(context.packageName, R.layout.lesson_list_item)

        // Set the lesson start and end times
        views.setTextViewText(R.id.lesson_start_time, lesson.start.format(DateTimeFormatter.ofPattern("HH:mm")))
        views.setTextViewText(R.id.lesson_end_time, lesson.end.format(DateTimeFormatter.ofPattern("HH:mm")))

        // Set the lesson title to the list item
        views.setTextViewText(R.id.lesson_title, lesson.title)

        // Set the professor name
        views.setTextViewText(R.id.lesson_instructor, lesson.instructor)

        // Set the room number
        views.setTextViewText(R.id.lesson_room, lesson.room)

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}

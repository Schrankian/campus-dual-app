package net.fabianschuster.campus_dual_android

import android.content.Context
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.content.Intent
import android.graphics.Color.parseColor
import android.util.Base64
import android.app.PendingIntent
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.LocalDate
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.time.format.TextStyle
import java.util.Locale
import net.fabianschuster.campus_dual_android.R
import java.security.MessageDigest
import java.io.ByteArrayInputStream
import java.io.ObjectInputStream

fun generateColorFromString(input: String): Int {
    val salt = "Salt"  // Add a salt to the string to avoid predictable colors
    val bytes = MessageDigest.getInstance("SHA-256").digest((input + salt).toByteArray(Charsets.UTF_8))
    val hexColor = bytes.take(3).joinToString("") { "%02x".format(it) }  // Get the first 3 bytes as hex
    return parseColor("#FF$hexColor")  // Use Color.parseColor to handle the color string
}

data class EvaluationRule(
    val pattern: String,
    val color: String,
    val hide: Boolean
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): EvaluationRule {
            return EvaluationRule(
                pattern = json["pattern"] as? String ?: "",
                color = json["color"] as? String ?: "#FFFFFF", // Default color
                hide = json["hide"] as? Boolean ?: false
            )
        }
        fun getMatch(rules: List<EvaluationRule>, title: String): EvaluationRule? {
            for (rule in rules) {
                if (Regex(rule.pattern, RegexOption.IGNORE_CASE).containsMatchIn(title)) {
                    return rule
                }
            }
            return null
        }

        fun shouldHide(rules: List<EvaluationRule>, title: String): Boolean {
            val match = getMatch(rules, title)
            return match?.hide ?: false
        }
    }
}

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
    val type: String,
    val widgetDisplayColor: Int,
    val widgetHideDisplay: Boolean
) {
    companion object {
        fun fromJson(json: Map<String, Any?>, useFuzzyColor: Boolean, rules: List<EvaluationRule>): Lesson? {
            val formatter = DateTimeFormatter.ISO_DATE_TIME
            val ruleMatch = EvaluationRule.getMatch(rules, json["title"] as? String ?: "")
            var widgetDisplayColor = parseColor("#FFB7C4FF")
            if (ruleMatch != null){
                if (ruleMatch.hide) {
                    return null
                }
                widgetDisplayColor = parseColor("${ruleMatch.color}")
            } else if (useFuzzyColor) {
                widgetDisplayColor = generateColorFromString(json["title"] as? String ?: "")
            }
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
                type = json["type"] as? String ?: "",
                widgetDisplayColor = widgetDisplayColor,
                widgetHideDisplay = EvaluationRule.shouldHide(rules, json["title"] as? String ?: "")
            )
        }
    }
}

sealed class LessonItem {
    data class LessonData(val lesson: Lesson) : LessonItem()
    data class DayHeader(val day: String) : LessonItem()
    data class Empty(val message: String) : LessonItem()
}

fun parseTimeTableJson(timeTableJson: String, useFuzzyColor: Boolean, rules: List<EvaluationRule>): Map<LocalDateTime, List<Lesson>> {
    val gson = Gson()
    val type = object : TypeToken<Map<String, List<Map<String, Any>>>>() {}.type
    val storedData: Map<String, List<Map<String, Any>>> = gson.fromJson(timeTableJson, type)

    val formatter = DateTimeFormatter.ISO_DATE_TIME
    return storedData.map { (key, value) ->
        LocalDateTime.parse(key, formatter) to value.mapNotNull { Lesson.fromJson(it, useFuzzyColor, rules) }
    }.toMap()
}

fun parseEvaluationRulesJson(rulesJson: List<String>): List<EvaluationRule> {
    val gson = Gson()
    val type = object : TypeToken<Map<String, Any>>() {}.type
    return rulesJson.map { 
        val storedData: Map<String, Any> = gson.fromJson(it, type)
        EvaluationRule.fromJson(storedData)
    }
}

// Decode the base64 encode string list implemented by the Flutter SharedPreferences plugin
const val LIST_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
fun decodeStringList(input: String): List<String> {
    val actualInput = input.substring(LIST_PREFIX.length)

    val byteArray = Base64.decode(actualInput, 0)
    val stream = ObjectInputStream(ByteArrayInputStream(byteArray))
    return (stream.readObject() as List<String>).filterIsInstance<String>()
}

class TimetableRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private var lessons: List<LessonItem> = emptyList()

    override fun onCreate() {
        // Load initial data if necessary
    }

    override fun onDataSetChanged() {
        val mPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val useFuzzyColor = mPrefs.getBoolean("flutter.useFuzzyColor", false) ?: false

        val rulesJsonBase64 = mPrefs.getString("flutter.evaluationRules", "") ?: ""
        val rulesJson = decodeStringList(rulesJsonBase64)
        val rules = parseEvaluationRulesJson(rulesJson)

        val timeTableJson = mPrefs.getString("flutter.timetable", "") ?: ""
        val timeTable = parseTimeTableJson(timeTableJson, useFuzzyColor, rules)


        // Collect lessons for the next 7 days (including today)
        val startDate = LocalDate.now()
        val daysToShow = 31
        val tempLessonItems = mutableListOf<LessonItem>()

        for (i in 0 until daysToShow) {
            val currentDay = startDate.plusDays(i.toLong())
            val lessonsForDay = timeTable[currentDay.atStartOfDay()] ?: emptyList()

            // Add the day header
            tempLessonItems.add(LessonItem.DayHeader(currentDay.dayOfWeek.getDisplayName(TextStyle.FULL, Locale.GERMAN) + ", " + currentDay.format(DateTimeFormatter.ofPattern("dd.MM", Locale.GERMAN))))

            if (lessonsForDay.isEmpty()) {
                // Add an empty item if there are no lessons
                tempLessonItems.add(LessonItem.Empty("Keine Veranstaltungen"))
            } else {
                // Add all lessons for the day
                tempLessonItems.addAll(lessonsForDay.map { LessonItem.LessonData(it) })
            }
        }

        lessons = tempLessonItems
    }

    override fun onDestroy() {
        lessons = emptyList()
    }

    override fun getCount(): Int {
        return lessons.size
    }

    override fun getViewAt(position: Int): RemoteViews? {
        if (position >= lessons.size) return null

        val item = lessons[position]
        val views: RemoteViews

        when (item) {
            is LessonItem.DayHeader -> {
                // Create a RemoteViews for the day header
                views = RemoteViews(context.packageName, R.layout.day_header_item)
                views.setTextViewText(R.id.day_header, item.day)
            }
            is LessonItem.LessonData -> {
                // Create a RemoteViews for the lesson item
                val lesson = item.lesson
                views = RemoteViews(context.packageName, R.layout.lesson_list_item)

                // Set the lesson start and end times
                views.setTextViewText(R.id.lesson_start_time, lesson.start.format(DateTimeFormatter.ofPattern("HH:mm")))
                views.setTextViewText(R.id.lesson_end_time, lesson.end.format(DateTimeFormatter.ofPattern("HH:mm")))

                // Set the lesson title to the list item
                views.setTextViewText(R.id.lesson_title, lesson.title)

                // Set the professor name
                views.setTextViewText(R.id.lesson_instructor, lesson.instructor)

                // Set the room number
                views.setTextViewText(R.id.lesson_room, lesson.room)

                // Generate and apply a color based on the lesson title
                views.setInt(R.id.lesson_title, "setTextColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_instructor, "setTextColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_room, "setTextColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_divider, "setBackgroundColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_time_divider, "setBackgroundColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_start_time, "setTextColor", lesson.widgetDisplayColor)
                views.setInt(R.id.lesson_end_time, "setTextColor", lesson.widgetDisplayColor)
            }
            is LessonItem.Empty -> {
                // Create a RemoteViews for the empty item
                views = RemoteViews(context.packageName, R.layout.empty_item)
                views.setTextViewText(R.id.empty_message, item.message)
            }
            else -> {
                // If you somehow get an unknown type, return a default view or handle it
                views = RemoteViews(context.packageName, R.layout.lesson_list_item)
                views.setTextViewText(R.id.lesson_title, "Unknown Item")
            }
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 3
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}

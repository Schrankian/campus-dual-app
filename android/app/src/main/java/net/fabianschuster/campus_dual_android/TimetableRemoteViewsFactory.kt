package net.fabianschuster.campus_dual_android

import android.content.Context
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.content.Intent
import android.graphics.Color
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
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent

fun generateColorFromString(input: String): Int {
    val salt = "Salt"  // Add a salt to the string to avoid predictable colors
    val bytes = MessageDigest.getInstance("SHA-256").digest((input + salt).toByteArray(Charsets.UTF_8))
    val hexColor = bytes.take(3).joinToString("") { "%02x".format(it) }  // Get the first 3 bytes as hex
    return Color.parseColor("#FF$hexColor")  // Use Color.parseColor to handle the color string
}

fun adjustContrast(textColor: Int, baseColor: Int): Int {
    // Calculate contrast ratio
    val contrastRatio = calculateContrastRatio(textColor, baseColor)

    var newTextColor = textColor

    // If contrast ratio is below threshold, adjust the generated color
    if (contrastRatio < 3) {
        // Adjust color for contrast
        // TODO: Implement a better algorithm for adjusting the color instead of just inverting it
        newTextColor  = Color.rgb(
            255 - Color.red(textColor), 
            255 - Color.green(textColor), 
            255 - Color.blue(textColor)
        )
    }

    return newTextColor
}

fun calculateContrastRatio(color1: Int, color2: Int): Double {
    val luminance1 = calculateLuminance(color1)
    val luminance2 = calculateLuminance(color2)
    return if (luminance1 > luminance2) {
        (luminance1 + 0.05) / (luminance2 + 0.05)
    } else {
        (luminance2 + 0.05) / (luminance1 + 0.05)
    }
}

fun calculateLuminance(color: Int): Double {
    val r = Color.red(color) / 255.0
    val g = Color.green(color) / 255.0
    val b = Color.blue(color) / 255.0

    val rL = if (r <= 0.03928) r / 12.92 else Math.pow((r + 0.055) / 1.055, 2.4)
    val gL = if (g <= 0.03928) g / 12.92 else Math.pow((g + 0.055) / 1.055, 2.4)
    val bL = if (b <= 0.03928) b / 12.92 else Math.pow((b + 0.055) / 1.055, 2.4)

    return 0.2126 * rL + 0.7152 * gL + 0.0722 * bL
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
    val widgetDisplayColor: Int?,
    val widgetHideDisplay: Boolean
) {
    companion object {
        fun fromJson(json: Map<String, Any?>, useFuzzyColor: Boolean, rules: List<EvaluationRule>): Lesson? {
            val formatter = DateTimeFormatter.ISO_DATE_TIME
            val ruleMatch = EvaluationRule.getMatch(rules, json["title"] as? String ?: "")
            var widgetDisplayColor: Int? = null
            if (ruleMatch != null){
                if (ruleMatch.hide) {
                    return null
                }
                widgetDisplayColor = Color.parseColor(ruleMatch.color)
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
    if(input.isEmpty()) {
        return emptyList()
    }
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

        val timeTableJson = mPrefs.getString("flutter.timetable", "")
        if (timeTableJson == null || timeTableJson.isEmpty()) {
            lessons = listOf(LessonItem.Empty("Keine Daten vorhanden"))
            return
        }
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

                // Determine if the current theme is dark mode
                val isDarkMode = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES

                // Get the default color based on the current theme
                val defaultColor = if (isDarkMode) {
                    androidx.core.content.res.ResourcesCompat.getColor(context.resources, R.color.primary_dark, null)
                } else {
                    androidx.core.content.res.ResourcesCompat.getColor(context.resources, R.color.primary_light, null)
                }

                // Get the background color based on the current theme
                val backgroundColor = if (isDarkMode) {
                    androidx.core.content.res.ResourcesCompat.getColor(context.resources, R.color.background_dark, null)
                } else {
                    androidx.core.content.res.ResourcesCompat.getColor(context.resources, R.color.background_light, null)
                }
                views.setInt(R.id.lesson_title, "setTextColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor)) 
                views.setInt(R.id.lesson_instructor, "setTextColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor) )
                views.setInt(R.id.lesson_room, "setTextColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor))
                views.setInt(R.id.lesson_divider, "setBackgroundColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor) )
                views.setInt(R.id.lesson_time_divider, "setBackgroundColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor) )
                views.setInt(R.id.lesson_start_time, "setTextColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor) )
                views.setInt(R.id.lesson_end_time, "setTextColor", adjustContrast(lesson.widgetDisplayColor ?: defaultColor, backgroundColor) )

                // Set the intent, the acutal pending intent is sent from the widget provider
                val intentWithData = Intent()
                views.setOnClickFillInIntent(R.id.lesson_list_item, intentWithData)
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

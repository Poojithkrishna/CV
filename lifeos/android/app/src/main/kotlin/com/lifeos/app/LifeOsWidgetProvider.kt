package com.lifeos.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

// Reads whatever the Flutter side last pushed via HomeWidgetSyncService
// (see lib/core/home_widget/) and redraws the RemoteViews. Never talks
// to the database or any plugin itself — every value here is
// already-formatted text the app decided on before saving it.
class LifeOsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.lifeos_widget).apply {
                setTextViewText(R.id.widget_rank, widgetData.getString("rank_label", "Mortal"))
                setTextViewText(R.id.widget_xp, widgetData.getString("xp_label", "0 XP"))
                setTextViewText(R.id.widget_net_worth, widgetData.getString("net_worth", "—"))
                setTextViewText(
                    R.id.widget_habit_completion,
                    widgetData.getString("habit_completion", "—")
                )
                setTextViewText(R.id.widget_schedule, widgetData.getString("schedule_summary", "—"))

                // Each section carries its own `lifeos://widget/<section>` URI
                // as the launch intent's data, so the Flutter side (see
                // core/home_widget/home_widget_deep_link.dart) can route
                // straight to that module instead of always opening the
                // dashboard. Tapping padding/gaps outside any section falls
                // through to widget_root's own dashboard-bound intent.
                setOnClickPendingIntent(R.id.widget_root, launchIntentFor(context, "dashboard"))
                setOnClickPendingIntent(
                    R.id.widget_gamification_section,
                    launchIntentFor(context, "gamification")
                )
                setOnClickPendingIntent(R.id.widget_finance_section, launchIntentFor(context, "finance"))
                setOnClickPendingIntent(R.id.widget_habits_section, launchIntentFor(context, "habits"))
                setOnClickPendingIntent(R.id.widget_calendar_section, launchIntentFor(context, "calendar"))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launchIntentFor(context: Context, section: String) =
        HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("lifeos://widget/$section")
        )
}

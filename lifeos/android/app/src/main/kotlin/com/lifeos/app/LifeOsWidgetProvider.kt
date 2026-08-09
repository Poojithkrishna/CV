package com.lifeos.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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

                val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

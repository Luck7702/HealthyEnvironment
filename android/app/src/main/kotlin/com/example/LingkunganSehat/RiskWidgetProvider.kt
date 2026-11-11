package com.example.LingkunganSehat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget showing the latest risk the app loaded.
 * Data is written from Flutter by lib/services/home_widget_sync_android.dart.
 */
class RiskWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val location = widgetData.getString("location", null)
        val risk = widgetData.getString("risk_level", null)
        val color = try {
            Color.parseColor(widgetData.getString("risk_color", "#527069"))
        } catch (_: IllegalArgumentException) {
            Color.parseColor("#527069")
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.risk_widget).apply {
                setTextViewText(
                    R.id.widget_title,
                    if (location.isNullOrBlank()) "LingkunganSehat" else location,
                )
                setTextViewText(R.id.widget_risk, risk ?: "Buka aplikasi")
                setTextColor(R.id.widget_risk, color)
                setTextViewText(
                    R.id.widget_details,
                    widgetData.getString("details", null) ?: "Ketuk untuk memuat data",
                )
                setTextViewText(R.id.widget_updated, widgetData.getString("updated", "") ?: "")
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

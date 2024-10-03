package net.fabianschuster.campus_dual_android

import android.content.Intent
import android.widget.RemoteViewsService

class TimetableWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TimetableRemoteViewsFactory(this.applicationContext, intent)
    }
}

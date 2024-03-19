package tech.notifly.flutter

import tech.notifly.push.interfaces.IPushNotification
import tech.notifly.push.interfaces.INotificationClickEvent
import tech.notifly.push.interfaces.INotificationClickListener

import java.util.HashMap;

class NotiflySerializer {
    companion object {
        fun serializeNotification(notification: IPushNotification): HashMap<String, Any> {
            val map = HashMap<String, Any>()
            
            map.put("androidNotificationId", notification.androidNotificationId)
            map.put("sentTime", notification.sentTime)
            map.put("ttl", notification.ttl)
            map.put("customData", notification.customData)
            map.put("rawPayload", notification.rawPayload)

            val title = notification.title
            val body = notification.body
            val campaignId = notification.campaignId
            val notiflyMessageId = notification.notiflyMessageId
            val importance = notification.importance
            val url = notification.url
            val imageUrl = notification.imageUrl

            if (title != null) {
                map.put("title", title)
            }
            if (body != null) {
                map.put("body", body)
            }
            if (campaignId != null) {
                map.put("campaignId", campaignId)
            }
            if (notiflyMessageId != null) {
                map.put("notiflyMessageId", notiflyMessageId)
            }
            if (importance != null) {
                map.put("importance", importance.ordinal)
            }
            if (url != null) {
                map.put("url", url)
            }
            if (imageUrl != null) {
                map.put("imageUrl", imageUrl)
            }

            return map
        }

        fun serializeNotificationClickEvent(event: INotificationClickEvent): HashMap<String, Any> {
            val map = HashMap<String, Any>()

            map.put("notification", serializeNotification(event.notification))

            return map
        }
    }
}
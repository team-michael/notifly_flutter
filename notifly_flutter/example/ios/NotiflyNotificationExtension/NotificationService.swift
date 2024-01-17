import notifly_sdk

class NotificationService: NotiflyNotificationServiceExtension {
    override init() {
        super.init()
        self.setup()
    }

    func setup() {
        self.register(projectId: "b80c3f0e2fbd5eb986df4f1d32ea2871", username: "minyong")
    }
}

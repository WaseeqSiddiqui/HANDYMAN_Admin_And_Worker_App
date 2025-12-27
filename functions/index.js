const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snapshot, context) => {
        const notification = snapshot.data();
        const targetUserIds = notification.targetUserIds;

        if (!targetUserIds || targetUserIds.length === 0) {
            console.log("No target users for notification:", notification.title);
            return;
        }

        const payload = {
            notification: {
                title: notification.title,
                body: notification.message,
                // You can add image if present
            },
            data: {
                type: notification.type || "general",
                relatedId: notification.relatedId || "",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
        };

        const tokens = [];

        // 'All' broadcast logic could go here if needed.
        // For now, handling specific users.
        for (const userId of targetUserIds) {
            if (userId === "admin") {
                // ✅ UPDATED: Fetch from 'admins' collection
                const adminDoc = await admin.firestore().collection("admins").doc("admin").get();
                if (adminDoc.exists) {
                    const data = adminDoc.data();
                    if (data.fcmToken) tokens.push(data.fcmToken);
                }
            } else {
                // Check Workers
                let userDoc = await admin.firestore().collection("workers").doc(userId).get();
                if (!userDoc.exists) {
                    // Check Customers
                    userDoc = await admin.firestore().collection("customers").doc(userId).get();
                }

                if (userDoc.exists) {
                    const userData = userDoc.data();
                    if (userData.fcmToken) {
                        tokens.push(userData.fcmToken);
                    }
                }
            }
        }

        if (tokens.length === 0) {
            console.log("No tokens found for target users");
            return;
        }

        // Remove duplicates
        const uniqueTokens = [...new Set(tokens)];

        console.log(`Sending notification to ${uniqueTokens.length} devices.`);

        const response = await admin.messaging().sendMulticast({
            tokens: uniqueTokens,
            ...payload,
        });

        console.log("Successfully sent message:", response);
    });

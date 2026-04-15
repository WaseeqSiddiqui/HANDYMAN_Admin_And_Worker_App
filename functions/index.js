// Using Firebase Functions v1 API — deploys to us-central1 by default.
// v1 Firestore triggers do NOT use Eventarc/Cloud Run, so they work with
// Firestore databases in any region (including me-central2) without
// requiring App Engine to be initialized in the database's region.
const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

/**
 * Looks up the FCM token for a given userId.
 * Checks workers, admins, and customers collections.
 */
async function getFcmToken(userId) {
    const collections = ['workers', 'admins', 'customers'];
    for (const col of collections) {
        const doc = await db.collection(col).doc(userId).get();
        if (doc.exists && doc.data().fcmToken) {
            return doc.data().fcmToken;
        }
    }
    return null;
}

exports.sendNotificationOnCreate = functions.firestore
    .document('notifications/{docId}')
    .onCreate(async (snap) => {
        const data = snap.data();
        if (!data) return;

        const { title, message, targetUserIds } = data;

        const notificationPayload = {
            title: title || 'New Notification',
            body: message || 'You have a new update',
        };

        // FCM common options for high priority delivery
        const fcmOptions = {
            android: {
                priority: 'high',
                notification: {
                    channelId: 'high_importance_channel',
                },
            },
            apns: {
                payload: {
                    aps: {
                        contentAvailable: true,
                        sound: 'default',
                    },
                },
            },
        };

        // ── Targeted: send only to specific users ──────────────────────────
        if (targetUserIds && Array.isArray(targetUserIds) && targetUserIds.length > 0) {
            const specificUserIds = targetUserIds.filter(
                (id) => !['all', 'All', 'Workers', 'workers', 'Customers', 'customers'].includes(id)
            );

            if (specificUserIds.length > 0) {
                const tokenPromises = specificUserIds.map((uid) => getFcmToken(uid));
                const tokens = (await Promise.all(tokenPromises)).filter(Boolean);

                if (tokens.length > 0) {
                    const multicastMessage = {
                        tokens: tokens,
                        notification: notificationPayload,
                        data: {
                            title: notificationPayload.title,
                            message: notificationPayload.body,
                            type: data.type || 'general',
                        },
                        ...fcmOptions,
                    };
                    try {
                        const response = await admin.messaging().sendEachForMulticast(multicastMessage);
                        console.log(`✅ Targeted notification sent to ${response.successCount}/${tokens.length} devices`);
                    } catch (error) {
                        console.error('❌ Error sending targeted notification:', error);
                    }
                } else {
                    console.log('⚠️ No FCM tokens found for targetUserIds:', specificUserIds);
                }
                return;
            }
        }

        // ── Broadcast fallback: send to 'all' topic ─────────────────────────
        try {
            const broadcastMessage = {
                topic: 'all',
                notification: notificationPayload,
                data: {
                    title: notificationPayload.title,
                    message: notificationPayload.body,
                    type: data.type || 'general',
                },
                ...fcmOptions,
            };
            await admin.messaging().send(broadcastMessage);
            console.log('📢 Broadcast notification sent to all topic');
        } catch (error) {
            console.error('❌ Error sending broadcast notification:', error);
        }
    });



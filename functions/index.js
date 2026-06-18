const {
  onDocumentUpdated,
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");

const admin = require("firebase-admin");

admin.initializeApp();

// ======================================================
// CASE APPROVED
// ======================================================

exports.onCaseApproved = onDocumentUpdated(
    "cases/{caseId}",

    async (event) => {
      try {
        const before =
        event.data.before.data();

        const after =
        event.data.after.data();

        if (
          before.status ===
          "approved" ||

          after.status !==
          "approved"
        ) {
          return;
        }

        const userId =
        after.userId;

        if (!userId) {
          return;
        }

        const userDoc =
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        const userData =
        userDoc.data();

        if (!userData) {
          return;
        }

        const token =
        userData.fcmToken;

        if (!token) {
          return;
        }

        await admin.messaging().send({

          token: token,

          notification: {

            title:
            "تمت الموافقة على الطلب",

            body:
            `تمت الموافقة على طلب "${after.title}"`,
          },

          data: {

            type: "case",

            caseId:
            event.params.caseId,
          },

          android: {

            priority: "high",

            notification: {

              sound:
              "notification",
            },
          },
        });

        await admin.firestore()
            .collection(
                "notifications",
            )
            .add({

              userId: userId,

              type: "user",

              title:
              "تمت الموافقة على الطلب",

              body:
              `تمت الموافقة على طلب "${after.title}"`,

              createdAt:
              admin.firestore
                  .FieldValue
                  .serverTimestamp(),

              read: false,
            });

        console.log(
            "Notification envoyée",
        );
      } catch (e) {
        console.error(
            "Erreur function:",
            e,
        );
      }
    },
);

// ======================================================
// NEW OPERATION
// ======================================================

exports.onNewOperation = onDocumentCreated(
    "operations/{operationId}",

    async (event) => {
      try {
        const data =
        event.data.data();

        if (!data) return;

        if (
          data.status !==
          "pending"
        ) {
          return;
        }

        const treasurerQuery =
        await admin.firestore()
            .collection("users")
            .where(
                "role",
                "==",
                "treasurer",
            )
            .limit(1)
            .get();

        if (
          treasurerQuery.empty
        ) {
          return;
        }

        const treasurerDoc =
        treasurerQuery.docs[0];

        const treasurerData =
        treasurerDoc.data();

        const token =
        treasurerData.fcmToken;

        if (!token) {
          return;
        }

        console.log(
            "Notification operation envoyée",
        );
      } catch (e) {
        console.error(
            "Erreur operation:",
            e,
        );
      }
    },
);

// ======================================================
// OPERATION APPROVED
// ======================================================

exports.onOperationApproved = onDocumentUpdated(
    "operations/{operationId}",

    async (event) => {
      try {
        const before =
        event.data.before.data();

        const after =
        event.data.after.data();

        if (
          before.status ===
          "approved" ||

          after.status !==
          "approved"
        ) {
          return;
        }

        const amount =
        Number(
            after.amount || 0,
        );

        if (amount <= 0) {
          return;
        }

        const financeRef =
        admin.firestore()
            .collection(
                "finance",
            )
            .doc("main");

        await financeRef.update({

          balance:
          admin.firestore
              .FieldValue
              .increment(amount),

          updatedAt:
          admin.firestore
              .FieldValue
              .serverTimestamp(),
        });

        console.log(
            `Balance +${amount}`,
        );

        const userId =
        after.createdBy;

        if (!userId) {
          return;
        }

        const userDoc =
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        const userData =
        userDoc.data();

        if (!userData) {
          return;
        }

        const token =
        userData.fcmToken;

        if (!token) {
          return;
        }

        await admin.messaging().send({

          token: token,

          notification: {

            title:
            "تمت الموافقة على العملية",

            body:
            `تمت إضافة ${amount} أوقية جديدة إلى الرصيد`,
          },

          android: {

            priority: "high",

            notification: {

              sound:
              "notification",
            },
          },
        });

        console.log(
            "Balance updated",
        );
      } catch (e) {
        console.error(
            "Erreur balance:",
            e,
        );
      }
    },
);

// ======================================================
// NEW TRANSACTION
// ======================================================

exports.onNewTransaction = onDocumentCreated(
    "transactions/{transactionId}",

    async (event) => {
      try {
        const data =
        event.data.data();

        if (!data) {
          return;
        }

        if (
          data.paidByRole !==
          "treasurer"
        ) {
          return;
        }

        const committeeQuery =
        await admin.firestore()
            .collection("users")
            .where(
                "role",
                "==",
                "committee",
            )
            .get();

        if (
          committeeQuery.empty
        ) {
          return;
        }

        for (
          const doc
          of committeeQuery.docs
        ) {
          const userData =
          doc.data();

          const token =
          userData.fcmToken;

          if (!token) {
            continue;
          }

          // ================= MESSAGE =================

          const messageBody =

`تم دفع ${data.amount} أوقية جديدة لصالح ${data.beneficiaryName || ""}

الهاتف: ${data.beneficiaryPhone || ""}

الغرض:
${data.note || "غير محدد"}`;

          // ================= PUSH =================

          await admin.messaging().send({

            token: token,

            notification: {

              title:
              "تم تنفيذ عملية دفع",

              body:
              messageBody,
            },

            android: {

              priority: "high",

              notification: {

                sound:
                "notification",
              },
            },

            data: {

              type:
              "transaction",

              transactionId:
              event.params.transactionId,
            },
          });

          // ================= FIRESTORE =================

          await admin.firestore()
              .collection(
                  "notifications",
              )
              .add({

                userId:
                doc.id,

                title:
                "تم تنفيذ عملية دفع",

                body:
                messageBody,

                createdAt:
                admin.firestore
                    .FieldValue
                    .serverTimestamp(),

                read: false,
              });
        }

        console.log(
            "Committee notified",
        );
      } catch (e) {
        console.error(
            "Erreur transaction:",
            e,
        );
      }
    },
);
// ======================================================
// MONTHLY LATE SUMMARY - 25th
// ======================================================

exports.createMonthlyLateSummary = onSchedule(
    {
      schedule: "0 9 25 * *",
      timeZone: "Africa/Nouakchott",
    },

    async () => {
      try {
        const db = admin.firestore();

        const now = new Date();

        const month = now.getMonth() + 1;
        const year = now.getFullYear();

        const collectors = await db
            .collection("users")
            .where("role", "==", "collector")
            .get();

        for (const collector of collectors.docs) {
          const collectorId = collector.id;

          // Anti doublon

          const existing = await db
              .collection("notifications")
              .where(
                  "type",
                  "==",
                  "monthly_late_summary",
              )
              .where(
                  "userId",
                  "==",
                  collectorId,
              )
              .where(
                  "month",
                  "==",
                  month,
              )
              .where(
                  "year",
                  "==",
                  year,
              )
              .limit(1)
              .get();

          if (!existing.empty) {
            continue;
          }

          const people = await db
              .collection("people")
              .where(
                  "collectorId",
                  "==",
                  collectorId,
              )
              .get();

          let latePeople = 0;
          let missingMonths = 0;

          for (const person of people.docs) {
            const statsDoc = await db
                .collection("subscription_stats")
                .doc(person.id)
                .get();

            if (!statsDoc.exists) {
              continue;
            }

            const stats =
                statsDoc.data() || {};

            const missing =
                stats.missingMonths || [];

            if (missing.length > 0) {
              latePeople++;

              missingMonths +=
                  missing.length;
            }
          }

          if (latePeople === 0) {
            continue;
          }

          await db
              .collection("notifications")
              .add({

                userId: collectorId,

                type:
                    "monthly_late_summary",

                month: month,

                year: year,

                latePeople:
                    latePeople,

                missingMonths:
                    missingMonths,

                title:
                    "📌 تذكير شهري",

                body:
                    `عدد المتأخرين: ${latePeople}\n\n` +
                    `إجمالي الأشهر غير المسددة: ${missingMonths}`,

                read: false,

                createdAt:
                    admin.firestore
                        .FieldValue
                        .serverTimestamp(),
              });
        }

        console.log(
            "Monthly late summary created",
        );
      } catch (e) {
        console.error(
            "Monthly late summary error:",
            e,
        );
      }
    },
);
// ======================================================
// MONTHLY REPORT - 1st DAY OF MONTH
// ======================================================

exports.createMonthlyReport = onSchedule(
    {
      schedule: "0 9 1 * *",
      timeZone: "Africa/Nouakchott",
    },

    async () => {
      try {
        const db = admin.firestore();

        const now = new Date();

        const month = now.getMonth() + 1;
        const year = now.getFullYear();

        const collectors = await db
            .collection("users")
            .where("role", "==", "collector")
            .get();

        for (const collector of collectors.docs) {
          const collectorId = collector.id;

          // Anti doublon

          const existing = await db
              .collection("notifications")
              .where(
                  "type",
                  "==",
                  "monthly_report",
              )
              .where(
                  "userId",
                  "==",
                  collectorId,
              )
              .where(
                  "month",
                  "==",
                  month,
              )
              .where(
                  "year",
                  "==",
                  year,
              )
              .limit(1)
              .get();

          if (!existing.empty) {
            continue;
          }

          const people = await db
              .collection("people")
              .where(
                  "collectorId",
                  "==",
                  collectorId,
              )
              .get();

          const totalPeople = people.docs.length;

          let latePeople = 0;
          let missingMonths = 0;

          let totalExpected = 0;
          let totalPaid = 0;

          for (const person of people.docs) {
            const statsDoc = await db
                .collection("subscription_stats")
                .doc(person.id)
                .get();

            if (!statsDoc.exists) {
              continue;
            }

            const stats = statsDoc.data() || {};

            const missing =
                stats.missingMonths || [];

            if (missing.length > 0) {
              latePeople++;
              missingMonths += missing.length;
            }

            totalExpected +=
                Number(
                    stats.expectedAmount || 0,
                );

            totalPaid +=
                Number(
                    stats.totalPaid || 0,
                );
          }

          const coverageRate =
              totalPeople === 0 ?
              0 :
              (
                (
                  totalPeople -
                  latePeople
                ) /
                totalPeople
              ) * 100;

          const collectionRate =
    totalExpected === 0 ?
    0 :
    Math.min(
        100,
        (totalPaid / totalExpected) * 100,
    );
          await db
              .collection("notifications")
              .add({
                userId: collectorId,

                type:
                    "monthly_report",

                month,
                year,

                coverageRate:
                    coverageRate
                        .toFixed(1),

                collectionRate:
                    collectionRate
                        .toFixed(1),

                latePeople,

                missingMonths,

                title:
                    "📊 حصيلة الشهر",

                body:
                    `نسبة التغطية: ${coverageRate.toFixed(1)}%\n\n` +
                    `نسبة التحصيل السنوية: ${collectionRate.toFixed(1)}%\n\n` +
                    `عدد المتأخرين: ${latePeople}\n\n` +
                    `إجمالي الأشهر غير المسددة: ${missingMonths}`,

                read: false,

                createdAt:
                    admin.firestore
                        .FieldValue
                        .serverTimestamp(),
              });
        }

        console.log(
            "Monthly report created",
        );
      } catch (e) {
        console.error(
            "Monthly report error:",
            e,
        );
      }
    },
);
// ======================================================
// CLEAN READ NOTIFICATIONS
// ======================================================

exports.cleanReadNotifications = onSchedule(
    {
      schedule: "0 * * * *",
      timeZone: "Africa/Nouakchott",
    },

    async () => {
      try {
        const db = admin.firestore();

        const limitDate = new Date(
            Date.now() -
            24 * 60 * 60 * 1000,
        );

        const snapshot = await db
            .collection("notifications")
            .where("read", "==", true)
            .where(
                "readAt",
                "<=",
                limitDate,
            )
            .get();

        if (snapshot.empty) {
          console.log(
              "No notifications to delete",
          );
          return;
        }

        const batch = db.batch();

        for (const doc of snapshot.docs) {
          batch.delete(doc.ref);
        }

        await batch.commit();

        console.log(
            `${snapshot.size} notifications deleted`,
        );
      } catch (e) {
        console.error(
            "Clean notifications error:",
            e,
        );
      }
    },
);
// ======================================================
// REFRESH SUBSCRIPTION STATS - DAILY
// ======================================================

exports.refreshSubscriptionStats = onSchedule(
    {
      schedule: "5 0 * * *",
      timeZone: "Africa/Nouakchott",
    },

    async () => {
      try {
        const db = admin.firestore();

        const currentMonth =
            new Date().getMonth() + 1;

        const currentYear =
            new Date().getFullYear();

        const peopleSnapshot =
            await db
                .collection("people")
                .get();

        let updated = 0;

        for (const person of peopleSnapshot.docs) {
          const personId = person.id;

          const statsDoc =
              await db
                  .collection(
                      "subscription_stats",
                  )
                  .doc(personId)
                  .get();

          if (!statsDoc.exists) {
            continue;
          }

          const stats =
              statsDoc.data() || {};

          const paidMonths =
              stats.paidMonthsList || [];

          const monthlyAmount =
              Number(
                  person.data()
                      .monthlyAmount || 500,
              );

          const missingMonths = [];

          for (
            let i = 1;
            i <= currentMonth;
            i++
          ) {
            if (
              !paidMonths.includes(i)
            ) {
              missingMonths.push(i);
            }
          }

          const futureMonths =
              paidMonths.filter(
                  (m) =>
                    m > currentMonth,
              );

          await db
              .collection(
                  "subscription_stats",
              )
              .doc(personId)
              .update({

                expectedAmount:
                    currentMonth *
                    monthlyAmount,

                debt:
                    missingMonths.length *
                    monthlyAmount,

                advance:
                    futureMonths.length *
                    monthlyAmount,

                missingMonths:
                    missingMonths,

                futureMonths:
                    futureMonths,

                lateMonths:
                    missingMonths.length,

                updatedAt:
                    admin.firestore
                        .FieldValue
                        .serverTimestamp(),

                year:
                    currentYear,
              });

          updated++;
        }

        console.log(
            `${updated} subscription stats refreshed`,
        );
      } catch (e) {
        console.error(
            "Refresh subscription stats error:",
            e,
        );
      }
    },
);

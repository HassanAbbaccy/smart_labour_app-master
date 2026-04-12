const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Note: Ensure your stripe test secret key is placed here. Typically it starts with 'sk_test_...'
// In production, use Firebase Secrets Manager to store this securely.
const stripe = require("stripe")("sk_test_51OlXN3CL14HqKZfzLA6z7q3bkjdmir4aqBkraOq5dJQylSyg76axGtaPumzz1MRJRuUAYO3Rk9l5L8mL7glxCl1J00M9wS0uKJ");

admin.initializeApp();

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can initiate payments"
    );
  }

  const amount = data.amount;
  const currency = data.currency || "pkr"; // Assuming PKR by default, Stripe handles PKR. Note: Stripe might require amount in smallest currency unit (e.g. paisa for PKR = amount * 100).
  const jobId = data.jobId;

  if (!amount) {
    throw new functions.https.HttpsError("invalid-argument", "Amount is required");
  }

  try {
    // Note: If you want to save card details for future payments, create a customer first.
    // We will do a generic ephemeral payment intent.

    const paymentIntent = await stripe.paymentIntents.create({
      amount: parseInt(amount, 10), // e.g., 500000 for 5000 PKR
      currency: currency,
      metadata: {
        userId: context.auth.uid,
        jobId: jobId || "unknown",
      },
      // You can add automatic_payment_methods: { enabled: true }
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error("Stripe Error:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

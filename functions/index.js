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
  const currency = (data.currency || "pkr").toLowerCase();
  const jobId = data.jobId;

  console.log(`Payment Request: Amount=${amount}, Currency=${currency}, JobID=${jobId}, UserID=${context.auth.uid}`);

  if (!amount || isNaN(amount)) {
    throw new functions.https.HttpsError("invalid-argument", "Valid amount is required");
  }

  // Stripe Minimum Amount Check (approx $0.50 USD equivalent)
  if (currency === "pkr" && amount < 15000) {
    throw new functions.https.HttpsError("invalid-argument", "The minimum amount for PKR is Rs. 150");
  } else if (currency === "usd" && amount < 50) {
    throw new functions.https.HttpsError("invalid-argument", "The minimum amount for USD is 50 cents");
  }

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: parseInt(amount, 10),
      currency: currency,
      metadata: {
        userId: context.auth.uid,
        jobId: jobId || "unknown",
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    console.log(`PaymentIntent Created Success: ID=${paymentIntent.id}`);

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error("Stripe API Error Details:", JSON.stringify(error, null, 2));
    
    // Return the professional Stripe error message back to the client
    throw new functions.https.HttpsError(
      "internal", 
      error.message || "An error occurred while creating the payment intent",
      error.raw ? error.raw.code : null
    );
  }
});

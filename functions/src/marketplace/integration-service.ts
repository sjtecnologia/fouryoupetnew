import { FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import {
  MercadoPagoOAuthCredentials,
  refreshOAuthCredentials,
} from "./mercado-pago-client";
import {
  decryptJson,
  encryptJson,
  MP_CLIENT_ID,
  MP_CLIENT_SECRET,
} from "./security";

const REFRESH_BEFORE_EXPIRY_MS = 7 * 24 * 60 * 60 * 1000;

function integrationRef(db: Firestore, companyId: string) {
  return db
    .collection("companys")
    .doc(companyId)
    .collection("private_integrations")
    .doc("mercado_pago");
}

export async function saveSellerCredentials(
  db: Firestore,
  companyId: string,
  credentials: MercadoPagoOAuthCredentials,
): Promise<void> {
  await integrationRef(db, companyId).set(
    {
      provider: "MERCADO_PAGO",
      encryptedCredentials: encryptJson(credentials),
      sellerId: credentials.sellerId,
      liveMode: credentials.liveMode,
      scope: credentials.scope ?? null,
      expiresAt: Timestamp.fromMillis(credentials.expiresAt),
      status: "CONNECTED",
      connectedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  await db.collection("companys").doc(companyId).set(
    {
      mercadoPago: {
        connected: true,
        sellerId: credentials.sellerId,
        liveMode: credentials.liveMode,
        status: "CONNECTED",
        updatedAt: FieldValue.serverTimestamp(),
      },
    },
    { merge: true },
  );
}

export async function getSellerCredentials(
  db: Firestore,
  companyId: string,
): Promise<MercadoPagoOAuthCredentials> {
  const reference = integrationRef(db, companyId);
  const snapshot = await reference.get();
  const encrypted = snapshot.data()?.encryptedCredentials;
  if (!snapshot.exists || typeof encrypted !== "string") {
    throw new Error("Mercado Pago is not connected for this seller");
  }

  let credentials = decryptJson<MercadoPagoOAuthCredentials>(encrypted);
  if (credentials.expiresAt - Date.now() > REFRESH_BEFORE_EXPIRY_MS) {
    return credentials;
  }

  credentials = await refreshOAuthCredentials({
    clientId: MP_CLIENT_ID.value(),
    clientSecret: MP_CLIENT_SECRET.value(),
    refreshToken: credentials.refreshToken,
  });
  await saveSellerCredentials(db, companyId, credentials);
  return credentials;
}

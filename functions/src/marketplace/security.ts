import {
  createCipheriv,
  createDecipheriv,
  createHmac,
  randomBytes,
  timingSafeEqual,
} from "node:crypto";
import { Firestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { defineSecret, defineString } from "firebase-functions/params";

export const MP_CLIENT_ID = defineString("MERCADO_PAGO_CLIENT_ID");
export const MP_REDIRECT_URI = defineString("MERCADO_PAGO_REDIRECT_URI");
export const MP_WEBHOOK_URL = defineString("MERCADO_PAGO_WEBHOOK_URL");
export const MP_APP_RETURN_URL = defineString("MERCADO_PAGO_APP_RETURN_URL", {
  default: "https://www.4youpet.app/pagamento",
});
export const MP_ENVIRONMENT = defineString("MERCADO_PAGO_ENVIRONMENT", {
  default: "sandbox",
});

export const MP_CLIENT_SECRET = defineSecret("MERCADO_PAGO_CLIENT_SECRET");
export const MP_OAUTH_STATE_SECRET = defineSecret("MERCADO_PAGO_OAUTH_STATE_SECRET");
export const MP_TOKEN_ENCRYPTION_KEY = defineSecret(
  "MERCADO_PAGO_TOKEN_ENCRYPTION_KEY",
);
export const MP_WEBHOOK_SECRET = defineSecret("MERCADO_PAGO_WEBHOOK_SECRET");

export interface OAuthStatePayload {
  uid: string;
  companyId: string;
  nonce: string;
  expiresAt: number;
}

function base64UrlJson(value: unknown): string {
  return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function safeEqual(a: string, b: string): boolean {
  const first = Buffer.from(a);
  const second = Buffer.from(b);
  return first.length === second.length && timingSafeEqual(first, second);
}

export function createOAuthState(uid: string, companyId: string): string {
  const payload: OAuthStatePayload = {
    uid,
    companyId,
    nonce: randomBytes(18).toString("base64url"),
    expiresAt: Date.now() + 10 * 60 * 1000,
  };
  const encoded = base64UrlJson(payload);
  const signature = createHmac("sha256", MP_OAUTH_STATE_SECRET.value())
    .update(encoded)
    .digest("base64url");
  return `${encoded}.${signature}`;
}

export function verifyOAuthState(state: string): OAuthStatePayload {
  const [encoded, receivedSignature] = state.split(".");
  if (!encoded || !receivedSignature) {
    throw new Error("Invalid OAuth state");
  }

  const expectedSignature = createHmac(
    "sha256",
    MP_OAUTH_STATE_SECRET.value(),
  )
    .update(encoded)
    .digest("base64url");
  if (!safeEqual(receivedSignature, expectedSignature)) {
    throw new Error("Invalid OAuth state signature");
  }

  const payload = JSON.parse(
    Buffer.from(encoded, "base64url").toString("utf8"),
  ) as OAuthStatePayload;
  if (
    !payload.uid ||
    !payload.companyId ||
    !payload.nonce ||
    !Number.isFinite(payload.expiresAt) ||
    payload.expiresAt < Date.now()
  ) {
    throw new Error("Expired or malformed OAuth state");
  }
  return payload;
}

function encryptionKey(): Buffer {
  const key = Buffer.from(MP_TOKEN_ENCRYPTION_KEY.value(), "base64");
  if (key.length !== 32) {
    throw new Error(
      "MERCADO_PAGO_TOKEN_ENCRYPTION_KEY must be 32 bytes encoded as base64",
    );
  }
  return key;
}

export function encryptJson(value: unknown): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", encryptionKey(), iv);
  const encrypted = Buffer.concat([
    cipher.update(JSON.stringify(value), "utf8"),
    cipher.final(),
  ]);
  const authTag = cipher.getAuthTag();
  return [iv, authTag, encrypted]
    .map((part) => part.toString("base64url"))
    .join(".");
}

export function decryptJson<T>(encryptedValue: string): T {
  const [ivPart, authTagPart, dataPart] = encryptedValue.split(".");
  if (!ivPart || !authTagPart || !dataPart) {
    throw new Error("Malformed encrypted credential");
  }
  const decipher = createDecipheriv(
    "aes-256-gcm",
    encryptionKey(),
    Buffer.from(ivPart, "base64url"),
  );
  decipher.setAuthTag(Buffer.from(authTagPart, "base64url"));
  const decrypted = Buffer.concat([
    decipher.update(Buffer.from(dataPart, "base64url")),
    decipher.final(),
  ]);
  return JSON.parse(decrypted.toString("utf8")) as T;
}

export async function requireCompanyAdmin(
  db: Firestore,
  uid: string,
  companyId: string,
): Promise<void> {
  const [adminSnapshot, userSnapshot] = await Promise.all([
    db.collection("admins").doc(uid).get(),
    db.collection("users").doc(uid).get(),
  ]);
  const admin = adminSnapshot.data();
  const user = userSnapshot.data();
  const isPlatformAdmin = admin?.platformAdmin === true;
  const adminCompanyId = admin?.companyID ?? user?.companyID;

  if (!adminSnapshot.exists || (!isPlatformAdmin && adminCompanyId !== companyId)) {
    throw new HttpsError(
      "permission-denied",
      "Usuario sem permissao para administrar este petshop",
    );
  }
}

export function validateWebhookSignature(input: {
  dataId: string;
  requestId: string;
  signatureHeader: string;
}): boolean {
  const signatureParts = Object.fromEntries(
    input.signatureHeader.split(",").map((part) => {
      const [key, value] = part.trim().split("=");
      return [key, value];
    }),
  );
  const timestamp = signatureParts.ts;
  const received = signatureParts.v1;
  if (!timestamp || !received) return false;

  const timestampNumber = Number(timestamp);
  if (!Number.isFinite(timestampNumber)) return false;
  const timestampMs = timestampNumber < 10_000_000_000
    ? timestampNumber * 1000
    : timestampNumber;
  if (Math.abs(Date.now() - timestampMs) > 10 * 60 * 1000) return false;

  const manifest =
    `id:${input.dataId};request-id:${input.requestId};ts:${timestamp};`;
  const expected = createHmac("sha256", MP_WEBHOOK_SECRET.value())
    .update(manifest)
    .digest("hex");
  return safeEqual(received, expected);
}

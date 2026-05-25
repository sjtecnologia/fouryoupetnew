/**
 * Logger profissional para Cloud Functions (Firebase / Google Cloud).
 *
 * Funcionalidades:
 *  - Saída em JSON estruturado compatível com Cloud Logging (severity, message, time)
 *  - Sanitização automática de dados sensíveis (data masking) em TODOS os campos
 *  - Suporte a contexto por requisição via .child({ uid, action, requestId })
 *  - Níveis: trace | debug | info | warn | error | fatal
 *  - API compatível com firebase-functions/v2 logger (drop-in replacement)
 */

import pino from "pino";
import { randomUUID } from "crypto";

// ─── Campos sensíveis — NUNCA devem aparecer nos logs ─────────────────────────
// A verificação é feita como substring no nome da chave (case-insensitive).
const SENSITIVE_PATTERNS = [
  "password",
  "senha",
  "token",
  "authorization",
  "secret",
  "apikey",
  "api_key",
  "encrypted",
  "security_code",
  "cvv",
  "card_number",
  "cardnumber",
  "cpf",
  "tax_id",
  "private_key",
  "access_token",
  "refresh_token",
  "id_token",
  "credential",
  "bearer",
  "webhook",
  "private",
];

/**
 * Mascara recursivamente todos os campos sensíveis em qualquer objeto.
 * Retorna um novo objeto — nunca muta o original.
 *
 * @param value  Qualquer valor a ser sanitizado
 * @param depth  Controle interno de profundidade (evita loops em objetos circulares)
 */
export function sanitize<T>(value: T, depth = 0): T {
  // Proteção contra objetos profundos / circulares
  if (depth > 8) return "[MAX_DEPTH]" as unknown as T;

  if (value === null || value === undefined) return value;

  // Primitivos são sempre seguros
  if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {
    return value;
  }

  if (Array.isArray(value)) {
    return (value as unknown[]).map((item) => sanitize(item, depth + 1)) as unknown as T;
  }

  if (value instanceof Error) {
    // Extrai apenas os campos seguros de erros
    return {
      errorName: value.name,
      errorMessage: value.message,
      // stack é útil para debugging mas omitido em produção — descomente se necessário
      // errorStack: value.stack,
    } as unknown as T;
  }

  if (typeof value === "object") {
    const result: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      const keyLower = k.toLowerCase();
      const isSensitive = SENSITIVE_PATTERNS.some((pattern) =>
        keyLower.includes(pattern)
      );
      result[k] = isSensitive ? "[REDACTED]" : sanitize(v, depth + 1);
    }
    return result as unknown as T;
  }

  return value;
}

// ─── Mapeamento pino level → Cloud Logging severity ──────────────────────────
// https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#LogSeverity
const GCP_SEVERITY: Record<number, string> = {
  10: "DEBUG",    // trace
  20: "DEBUG",    // debug
  30: "INFO",     // info
  40: "WARNING",  // warn
  50: "ERROR",    // error
  60: "CRITICAL", // fatal
};

// ─── Instância base do Pino ───────────────────────────────────────────────────
const _pino = pino({
  // Remove pid e hostname (sem utilidade em Cloud Functions)
  base: null,
  // Cloud Logging lê o campo "message" por padrão
  messageKey: "message",
  // ISO 8601 no campo "time" (Cloud Logging indexa automaticamente)
  timestamp: () => `,"time":"${new Date().toISOString()}"`,
  formatters: {
    level(_label: string, numericLevel: number) {
      return {
        severity: GCP_SEVERITY[numericLevel] ?? "INFO",
      };
    },
  },
});

// ─── Tipagem do contexto de log ───────────────────────────────────────────────
export interface LogContext {
  uid?: string;       // ID do usuário autenticado
  action?: string;    // Nome da ação / função executada
  requestId?: string; // UUID gerado por geração para rastrear toda a requisição
  companyId?: string; // ID da empresa (quando aplicável)
  [key: string]: unknown;
}

// ─── Classe principal do logger ───────────────────────────────────────────────
/**
 * AppLogger — wrapper sobre Pino com:
 *   1. Sanitização automática de dados sensíveis em todos os caminhos
 *   2. Contexto estruturado via .child()
 *   3. API compatível com firebase-functions logger (msg, data?)
 *   4. Níveis: log/info | warn | error | fatal
 */
export class AppLogger {
  private readonly _logger: pino.Logger;
  private readonly _ctx: LogContext;

  constructor(context: LogContext = {}) {
    this._ctx = sanitize(context) as LogContext;
    this._logger = _pino.child(this._ctx);
  }

  /** Retorna um novo logger com contexto adicional mesclado (imutável). */
  child(ctx: LogContext): AppLogger {
    return new AppLogger({
      ...this._ctx,
      ...ctx,
    });
  }

  /** Serializa qualquer valor para objeto seguro antes de enviar ao pino */
  private _toObj(data: unknown): Record<string, unknown> {
    if (data === null || data === undefined) return {};
    if (data instanceof Error) {
      return sanitize({
        error: {
          name: data.name,
          message: data.message,
        },
      });
    }
    if (typeof data === "object") {
      return sanitize(data as Record<string, unknown>);
    }
    // Primitivo — não deve ser um campo sensível, mas protege por garantia
    return { _value: String(data) };
  }

  /** info / log — eventos normais de operação */
  log(msg: string, data?: unknown): void {
    data !== undefined
      ? this._logger.info(this._toObj(data), msg)
      : this._logger.info(msg);
  }

  info(msg: string, data?: unknown): void {
    data !== undefined
      ? this._logger.info(this._toObj(data), msg)
      : this._logger.info(msg);
  }

  /** warn — situação inesperada mas recuperável */
  warn(msg: string, data?: unknown): void {
    data !== undefined
      ? this._logger.warn(this._toObj(data), msg)
      : this._logger.warn(msg);
  }

  /** error — falha em operação específica */
  error(msg: string, data?: unknown): void {
    data !== undefined
      ? this._logger.error(this._toObj(data), msg)
      : this._logger.error(msg);
  }

  /** fatal — erro irrecuperável; processo deve ser reiniciado */
  fatal(msg: string, data?: unknown): void {
    data !== undefined
      ? this._logger.fatal(this._toObj(data), msg)
      : this._logger.fatal(msg);
  }
}

// ─── Instância raiz ───────────────────────────────────────────────────────────
/** Logger raiz da aplicação. Use .child({ uid, action, requestId }) para contexto. */
export const appLogger = new AppLogger();

/**
 * Gera um ID único de requisição para rastrear todos os logs
 * de uma mesma invocação de Cloud Function.
 */
export function generateRequestId(): string {
  return randomUUID();
}

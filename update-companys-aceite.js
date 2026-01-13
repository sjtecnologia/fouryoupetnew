// update-companys-aceite.js
// Define aceite_contrato = true em todos os documentos da coleção "companys".

const admin = require('firebase-admin');

async function main() {
  // Inicializa usando a credencial definida em GOOGLE_APPLICATION_CREDENTIALS
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  }

  const db = admin.firestore();
  const writer = db.bulkWriter();

  let updatedCount = 0;
  writer.onWriteResult(() => {
    updatedCount += 1;
  });

  const pageSize = 500;
  let lastId = null;

  // Paginação por ID do documento para evitar carregar tudo de uma vez
  while (true) {
    let q = db
      .collection('companys')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);

    if (lastId) {
      q = q.startAfter(lastId);
    }

    const snap = await q.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      // merge:true garante que só esse campo é atualizado, sem sobrescrever o documento inteiro
      writer.set(doc.ref, { device: '' }, { merge: 'true' });
    }

    lastId = snap.docs[snap.docs.length - 1].id;
  }

  await writer.close();
  console.log(`Concluído. Documentos atualizados: ${updatedCount}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Falha ao atualizar documentos:', err);
    process.exit(1);
  });
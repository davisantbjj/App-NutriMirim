// Testes das regras do Firestore. Rodam contra o emulador:
//   npm test   (dentro da pasta firebase/)
// O host do emulador vem da variável FIRESTORE_EMULATOR_HOST (definida pelo
// `firebase emulators:exec`).
import { readFileSync } from 'node:fs';
import { describe, it, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch,
  collection, collectionGroup, query, where, serverTimestamp, Timestamp,
} from 'firebase/firestore';

let env;

const minutosAtras = (m) => Timestamp.fromMillis(Date.now() - m * 60 * 1000);
const DATA = Timestamp.fromDate(new Date('2026-01-10T12:00:00Z'));
const INDIC = {
  pi: { zScore: -0.5, situacao: 'normal' },
  ei: { zScore: 0.2, situacao: 'normal' },
  pe: { zScore: -0.1, situacao: 'normal' },
  imci: { zScore: 0.0, situacao: 'normal' },
};
const RESP = { nome: 'Joana Teste', cpf: '11144477735', telefone: '11999990000', email: 'j@exemplo.test' };
const NOMES = {
  pedro: 'Pedro', ana: 'Ana', bia: 'Bia', carlos: 'Carlos', ines: 'Ines', mestre: 'Mestre', xavier: 'Xavier',
};

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-nutrimirim',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => {
  await env.cleanup();
});

// ---- Dados já gravados (Timestamp fixo em vez de serverTimestamp) ----
function criancaBase(ubsId, uid, ts, extra = {}) {
  return {
    ubsId, nome: 'Maria Teste', nomeBusca: 'maria teste', sexo: 'feminino',
    bairro: 'Centro', endereco: 'Rua Ficticia, 10', nascimento: '2023-05-10',
    cadastradoEm: '2025-01-15', responsavel: RESP,
    ativa: true, versao: 0, criadoPor: uid, criadoEm: ts, atualizadoEm: ts, ...extra,
  };
}

function avaliacaoBase(ubsId, criancaId, uid, criadoEm) {
  return {
    ubsId, criancaId, profissionalId: uid, profissionalNome: NOMES[uid], data: DATA,
    pesoKg: 12.5, alturaCm: 90, situacao: 'normal', indicadores: INDIC,
    desnutricao: false, versaoTabelaOms: 'oms-2006', excluida: false, versao: 0,
    criadoEm, atualizadoEm: criadoEm,
  };
}

// Cenário base (gravado sem regras).
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    const agora = Timestamp.now();
    const ubs = (nome, ativa = true) => ({ nome, municipio: 'Cidade Ficticia', ativa, criadoEm: agora, atualizadoEm: agora });
    await setDoc(doc(d, 'ubs/ubsA'), ubs('UBS A'));
    await setDoc(doc(d, 'ubs/ubsB'), ubs('UBS B'));
    await setDoc(doc(d, 'ubs/ubsC'), ubs('UBS C'));
    await setDoc(doc(d, 'ubs/ubsX'), ubs('UBS X (inativa)', false));

    const prof = (uid, papel, ubsIds, ativo = true) => ({
      nome: NOMES[uid], email: `${uid}@exemplo.test`, papel, ubsIds, microarea: '01', ativo,
    });
    await setDoc(doc(d, 'profissionais/pedro'), prof('pedro', 'medico', ['ubsA']));
    await setDoc(doc(d, 'profissionais/ana'), prof('ana', 'acs', ['ubsA']));
    await setDoc(doc(d, 'profissionais/bia'), prof('bia', 'nutricionista', ['ubsB']));
    await setDoc(doc(d, 'profissionais/carlos'), prof('carlos', 'medico', ['ubsA', 'ubsB']));
    await setDoc(doc(d, 'profissionais/ines'), prof('ines', 'acs', ['ubsA'], false));
    await setDoc(doc(d, 'profissionais/mestre'), prof('mestre', 'master', []));
    await setDoc(doc(d, 'profissionais/xavier'), prof('xavier', 'medico', ['ubsX']));

    await setDoc(doc(d, 'criancas/cA'), criancaBase('ubsA', 'pedro', agora));
    await setDoc(doc(d, 'criancas/cB'), criancaBase('ubsB', 'bia', agora));
    await setDoc(doc(d, 'criancas/cC'), criancaBase('ubsC', 'mestre', agora));
    await setDoc(doc(d, 'criancas/cInativa'), criancaBase('ubsA', 'pedro', agora, { ativa: false }));
    await setDoc(doc(d, 'criancas/cX'), criancaBase('ubsX', 'xavier', agora));

    await setDoc(doc(d, 'avaliacoes/recente'), avaliacaoBase('ubsA', 'cA', 'pedro', minutosAtras(5)));
    await setDoc(doc(d, 'avaliacoes/antiga'), avaliacaoBase('ubsA', 'cA', 'pedro', minutosAtras(20)));
    await setDoc(doc(d, 'avaliacoes/deB'), avaliacaoBase('ubsB', 'cB', 'bia', minutosAtras(5)));
    await setDoc(doc(d, 'avaliacoes/recente/alteracoes/0'), { motivo: 'semente' });
  });
});

// ---- Dados enviados pelo app (serverTimestamp = request.time) ----
const novaCrianca = (ubsId, uid, extra = {}) => {
  const c = criancaBase(ubsId, uid, serverTimestamp(), extra);
  return c;
};
const novaAvaliacao = (ubsId, criancaId, uid, extra = {}) => {
  const a = {
    ...avaliacaoBase(ubsId, criancaId, uid, serverTimestamp()),
    data: Timestamp.now(), pesoKg: 13, alturaCm: 92, situacao: 'atencao', ...extra,
  };
  return a;
};

const db = (uid) => env.authenticatedContext(uid).firestore();

const mudAval = (uid, extra = {}) => ({
  pesoKg: 12.8, versao: 1, atualizadoEm: serverTimestamp(), alteradoPor: uid,
  alteradoEm: serverTimestamp(), motivoAlteracao: 'Digitei errado', ...extra,
});
const logAval = (uid, extra = {}) => ({
  alteradoPor: uid, alteradoEm: serverTimestamp(), motivo: 'Digitei errado', versao: 1,
  acao: 'correcao', pesoKgAnterior: 12.5, alturaCmAnterior: 90, dataAnterior: DATA,
  situacaoAnterior: 'normal', indicadoresAnterior: INDIC, desnutricaoAnterior: false, ...extra,
});
// Correção + log no mesmo lote.
function corrigirAval(uid, id, mud = {}, log = {}, altId = '1') {
  const d = db(uid);
  const b = writeBatch(d);
  b.update(doc(d, 'avaliacoes', id), mudAval(uid, mud));
  b.set(doc(d, 'avaliacoes', id, 'alteracoes', altId), logAval(uid, log));
  return b.commit();
}

const mudCrianca = (uid, extra = {}) => ({
  bairro: 'Vila Nova', versao: 1, atualizadoEm: serverTimestamp(), alteradoPor: uid,
  alteradoEm: serverTimestamp(), motivoAlteracao: 'Mudou de bairro', ...extra,
});
const logCrianca = (uid, extra = {}) => ({
  alteradoPor: uid, alteradoEm: serverTimestamp(), motivo: 'Mudou de bairro', versao: 1,
  nomeAnterior: 'Maria Teste', responsavelAnterior: RESP, ativaAnterior: true,
  nascimentoAnterior: '2023-05-10', sexoAnterior: 'feminino', bairroAnterior: 'Centro',
  enderecoAnterior: 'Rua Ficticia, 10', ...extra,
});
function editarCrianca(uid, id, mud = {}, log = {}, altId = '1') {
  const d = db(uid);
  const b = writeBatch(d);
  b.update(doc(d, 'criancas', id), mudCrianca(uid, mud));
  b.set(doc(d, 'criancas', id, 'alteracoes', altId), logCrianca(uid, log));
  return b.commit();
}

const novaUbs = () => ({
  nome: 'UBS Nova', municipio: 'Cidade Ficticia', endereco: 'Rua 1', ativa: true,
  criadoEm: serverTimestamp(), atualizadoEm: serverTimestamp(),
});
const novoPerfil = (extra = {}) => ({
  nome: 'Novo Profissional', email: 'novo@exemplo.test', papel: 'medico',
  ubsIds: ['ubsA', 'ubsB'], ativo: true, ...extra,
});

// =====================================================================
describe('sem login', () => {
  it('nega leitura e escrita em todas as coleções', async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, 'criancas/cA')));
    await assertFails(getDoc(doc(anon, 'avaliacoes/recente')));
    await assertFails(getDoc(doc(anon, 'profissionais/pedro')));
    await assertFails(getDoc(doc(anon, 'ubs/ubsA')));
    await assertFails(setDoc(doc(anon, 'criancas/x'), novaCrianca('ubsA', 'pedro')));
  });

  it('nega logado sem perfil de profissional', async () => {
    await assertFails(getDoc(doc(db('estranho'), 'criancas/cA')));
    await assertFails(getDoc(doc(db('estranho'), 'ubs/ubsA')));
  });
});

// =====================================================================
describe('profissionais', () => {
  it('lê o próprio perfil, mas não o de outro', async () => {
    await assertSucceeds(getDoc(doc(db('pedro'), 'profissionais/pedro')));
    await assertFails(getDoc(doc(db('pedro'), 'profissionais/ana')));
  });

  it('não-master não altera ubsIds, papel, ativo, e-mail nem nome', async () => {
    const ref = doc(db('pedro'), 'profissionais/pedro');
    await assertFails(updateDoc(ref, { ubsIds: ['ubsA', 'ubsB'] }));
    await assertFails(updateDoc(ref, { papel: 'master' }));
    await assertFails(updateDoc(ref, { ativo: false }));
    await assertFails(updateDoc(ref, { email: 'outro@exemplo.test' }));
    await assertFails(updateDoc(ref, { nome: 'Ana' }));
  });

  it('setDoc sobre o próprio perfil é negado', async () => {
    await assertFails(setDoc(doc(db('pedro'), 'profissionais/pedro'),
      { ...novoPerfil(), ubsIds: ['ubsA', 'ubsC'] }));
    await assertFails(setDoc(doc(db('pedro'), 'profissionais/pedro'),
      { nome: 'Outro Nome', email: 'pedro@exemplo.test', papel: 'medico', ubsIds: ['ubsA'], microarea: '01', ativo: true }));
  });

  it('pode ajustar a própria microárea', async () => {
    await assertSucceeds(updateDoc(doc(db('pedro'), 'profissionais/pedro'), { microarea: '07' }));
  });

  it('não cria nem apaga perfil', async () => {
    await assertFails(setDoc(doc(db('novo'), 'profissionais/novo'), novoPerfil()));
    await assertFails(setDoc(doc(db('pedro'), 'profissionais/novo'), novoPerfil()));
    await assertFails(deleteDoc(doc(db('pedro'), 'profissionais/pedro')));
    await assertFails(deleteDoc(doc(db('mestre'), 'profissionais/pedro')));
  });
});

// =====================================================================
describe('master', () => {
  it('lê e grava dados de qualquer UBS', async () => {
    const m = db('mestre');
    await assertSucceeds(getDoc(doc(m, 'criancas/cA')));
    await assertSucceeds(getDoc(doc(m, 'criancas/cB')));
    await assertSucceeds(getDoc(doc(m, 'avaliacoes/deB')));
    await assertSucceeds(getDocs(collection(m, 'criancas')));
    await assertSucceeds(getDocs(collection(m, 'avaliacoes')));
    await assertSucceeds(setDoc(doc(m, 'criancas/nova'), novaCrianca('ubsB', 'mestre')));
    await assertSucceeds(setDoc(doc(m, 'avaliacoes/nova'), novaAvaliacao('ubsB', 'cB', 'mestre')));
  });

  it('lê alteracoes de qualquer UBS, também por collectionGroup', async () => {
    await assertSucceeds(getDoc(doc(db('mestre'), 'avaliacoes/recente/alteracoes/0')));
    await assertSucceeds(getDocs(collectionGroup(db('mestre'), 'alteracoes')));
  });

  it('cadastra, edita, desativa e reativa profissionais', async () => {
    const m = db('mestre');
    await assertSucceeds(setDoc(doc(m, 'profissionais/novo'), novoPerfil()));
    await assertSucceeds(updateDoc(doc(m, 'profissionais/ana'), { ubsIds: ['ubsA', 'ubsC'], papel: 'nutricionista' }));
    await assertSucceeds(updateDoc(doc(m, 'profissionais/ana'), { ativo: false }));
    await assertSucceeds(updateDoc(doc(m, 'profissionais/ana'), { ativo: true }));
    await assertSucceeds(getDoc(doc(m, 'profissionais/ana')));
  });

  it('cadastra e edita UBS, mas não apaga', async () => {
    const m = db('mestre');
    await assertSucceeds(setDoc(doc(m, 'ubs/ubsNova'), novaUbs()));
    await assertSucceeds(updateDoc(doc(m, 'ubs/ubsNova'), { ativa: false, atualizadoEm: serverTimestamp() }));
    await assertFails(deleteDoc(doc(m, 'ubs/ubsNova')));
  });

  it('não se desativa nem perde o papel de master', async () => {
    const ref = doc(db('mestre'), 'profissionais/mestre');
    await assertFails(updateDoc(ref, { ativo: false }));
    await assertFails(updateDoc(ref, { papel: 'acs' }));
    await assertSucceeds(updateDoc(ref, { nome: 'Mestre Renomeado' }));
  });

  it('dados de perfil e UBS inválidos são negados mesmo para o master', async () => {
    const m = db('mestre');
    await assertFails(setDoc(doc(m, 'profissionais/n1'), novoPerfil({ papel: 'pediatra' })));
    await assertFails(setDoc(doc(m, 'profissionais/n2'), novoPerfil({ ubsIds: [] })));
    await assertFails(setDoc(doc(m, 'profissionais/n3'), novoPerfil({ extra: 1 })));
    await assertFails(setDoc(doc(m, 'ubs/u1'), { ...novaUbs(), extra: 1 }));
  });
});

describe('não-master e o cadastro de UBS/profissionais', () => {
  it('não cria nem edita UBS', async () => {
    await assertFails(setDoc(doc(db('pedro'), 'ubs/ubsNova'), novaUbs()));
    await assertFails(updateDoc(doc(db('pedro'), 'ubs/ubsA'), { nome: 'Outro', atualizadoEm: serverTimestamp() }));
  });

  it('lê só as UBS da própria lista', async () => {
    await assertSucceeds(getDoc(doc(db('pedro'), 'ubs/ubsA')));
    await assertFails(getDoc(doc(db('pedro'), 'ubs/ubsB')));
    await assertSucceeds(getDoc(doc(db('carlos'), 'ubs/ubsB')));
  });
});

// =====================================================================
describe('várias UBS e consultas', () => {
  it('médico com 2 UBS lê crianças de ambas e não da terceira', async () => {
    const c = db('carlos');
    await assertSucceeds(getDoc(doc(c, 'criancas/cA')));
    await assertSucceeds(getDoc(doc(c, 'criancas/cB')));
    await assertFails(getDoc(doc(c, 'criancas/cC')));
  });

  it('consultas com == e in sobre as UBS da lista funcionam', async () => {
    const c = db('carlos');
    const col = collection(c, 'criancas');
    await assertSucceeds(getDocs(query(col, where('ubsId', '==', 'ubsA'))));
    await assertSucceeds(getDocs(query(col, where('ubsId', '==', 'ubsB'))));
    await assertSucceeds(getDocs(query(col, where('ubsId', 'in', ['ubsA', 'ubsB']))));
    await assertSucceeds(getDocs(query(col, where('ubsId', 'in', ['ubsA', 'ubsB']), where('ativa', '==', true))));
    await assertSucceeds(getDocs(query(collection(c, 'avaliacoes'), where('ubsId', 'in', ['ubsA', 'ubsB']))));
  });

  it('consulta com UBS fora da lista, sem filtro ou com != é negada', async () => {
    const c = db('carlos');
    const col = collection(c, 'criancas');
    await assertFails(getDocs(query(col, where('ubsId', 'in', ['ubsA', 'ubsC']))));
    await assertFails(getDocs(query(col, where('ubsId', '==', 'ubsC'))));
    await assertFails(getDocs(col));
    await assertFails(getDocs(query(col, where('ubsId', '!=', 'ubsC'))));
  });

  it('consulta só por criancaId ou só por CPF é negada', async () => {
    const p = db('pedro');
    await assertFails(getDocs(query(collection(p, 'avaliacoes'), where('criancaId', '==', 'cA'))));
    await assertFails(getDocs(query(collection(p, 'criancas'), where('responsavel.cpf', '==', '11144477735'))));
    await assertSucceeds(getDocs(query(collection(p, 'criancas'),
      where('ubsId', '==', 'ubsA'), where('responsavel.cpf', '==', '11144477735'))));
    await assertSucceeds(getDocs(query(collection(p, 'avaliacoes'),
      where('ubsId', '==', 'ubsA'), where('criancaId', '==', 'cA'), where('excluida', '==', false))));
  });

  it('collectionGroup(alteracoes) é negado para não-master', async () => {
    await assertFails(getDocs(collectionGroup(db('pedro'), 'alteracoes')));
    await assertFails(getDocs(query(collectionGroup(db('pedro'), 'alteracoes'))));
  });

  it('lê o log da própria UBS, mas não de outra', async () => {
    await assertSucceeds(getDoc(doc(db('pedro'), 'avaliacoes/recente/alteracoes/0')));
    await assertFails(getDoc(doc(db('bia'), 'avaliacoes/recente/alteracoes/0')));
  });
});

// =====================================================================
describe('criancas', () => {
  it('lê criança da própria UBS e lista filtrando por ubsId', async () => {
    await assertSucceeds(getDoc(doc(db('pedro'), 'criancas/cA')));
    await assertSucceeds(getDocs(query(collection(db('pedro'), 'criancas'), where('ubsId', '==', 'ubsA'))));
  });

  it('não lê criança de outra UBS', async () => {
    await assertFails(getDoc(doc(db('pedro'), 'criancas/cB')));
    await assertFails(getDocs(query(collection(db('pedro'), 'criancas'), where('ubsId', '==', 'ubsB'))));
  });

  it('acs, médico e nutricionista cadastram na própria UBS', async () => {
    await assertSucceeds(setDoc(doc(db('ana'), 'criancas/n1'), novaCrianca('ubsA', 'ana')));
    await assertSucceeds(setDoc(doc(db('pedro'), 'criancas/n2'), novaCrianca('ubsA', 'pedro')));
    await assertSucceeds(setDoc(doc(db('bia'), 'criancas/n3'), novaCrianca('ubsB', 'bia')));
    await assertSucceeds(setDoc(doc(db('carlos'), 'criancas/n4'), novaCrianca('ubsB', 'carlos')));
  });

  it('cria sem nascimento e sem responsável', async () => {
    const d = novaCrianca('ubsA', 'ana', { nascimento: null });
    delete d.responsavel;
    await assertSucceeds(setDoc(doc(db('ana'), 'criancas/nova'), d));
  });

  it('não cria em UBS fora da lista nem em UBS inativa', async () => {
    await assertFails(setDoc(doc(db('pedro'), 'criancas/n1'), novaCrianca('ubsB', 'pedro')));
    await assertFails(setDoc(doc(db('xavier'), 'criancas/n2'), novaCrianca('ubsX', 'xavier')));
    await assertFails(setDoc(doc(db('mestre'), 'criancas/n3'), novaCrianca('ubsX', 'mestre')));
  });

  it('nega chave extra, tipo errado, sexo, CPF, telefone e e-mail inválidos', async () => {
    const ref = (id) => doc(db('pedro'), 'criancas', id);
    const nova = (extra) => novaCrianca('ubsA', 'pedro', extra);
    await assertFails(setDoc(ref('a'), nova({ campoExtra: 1 })));
    await assertFails(setDoc(ref('b'), nova({ nome: 123 })));
    await assertFails(setDoc(ref('c'), nova({ sexo: 'x' })));
    await assertFails(setDoc(ref('e'), nova({ responsavel: { nome: 'Joana', cpf: '111.444.777-35' } })));
    await assertFails(setDoc(ref('f'), nova({ criadoPor: 'ana' })));
    await assertFails(setDoc(ref('g'), nova({ responsavel: { ...RESP, telefone: '123' } })));
    await assertFails(setDoc(ref('h'), nova({ responsavel: { ...RESP, email: 'sem-arroba' } })));
    await assertFails(setDoc(ref('i'), nova({ nomeBusca: 'Maria Teste' })));
    await assertFails(setDoc(ref('j'), nova({ ativa: false })));
    await assertFails(setDoc(ref('k'), nova({ versao: 5 })));
  });

  it('nega chave extra e map aninhado em responsavel', async () => {
    const ref = (id) => doc(db('pedro'), 'criancas', id);
    const nova = (extra) => novaCrianca('ubsA', 'pedro', extra);
    await assertFails(setDoc(ref('a'), nova({ responsavel: { ...RESP, rg: '123' } })));
    await assertFails(setDoc(ref('b'), nova({ responsavel: { ...RESP, telefone: { ddd: '11' } } })));
    await assertFails(setDoc(ref('c'), nova({ responsavel: { ...RESP, extra: { a: 1 } } })));
  });

  it('nega datas inválidas, no futuro ou muito antigas', async () => {
    const ref = (id) => doc(db('pedro'), 'criancas', id);
    const nova = (extra) => novaCrianca('ubsA', 'pedro', extra);
    await assertFails(setDoc(ref('a'), nova({ nascimento: '9999-99-99' })));
    await assertFails(setDoc(ref('b'), nova({ nascimento: '2099-01-01' })));
    await assertFails(setDoc(ref('c'), nova({ nascimento: '1970-01-01' })));
    await assertFails(setDoc(ref('d'), nova({ nascimento: '10/05/2023' })));
    await assertFails(setDoc(ref('e'), nova({ nascimento: '2023-13-01' })));
    await assertFails(setDoc(ref('f'), nova({ cadastradoEm: '2099-01-01' })));
    await assertFails(setDoc(ref('g'), nova({ cadastradoEm: '2026-00-10' })));
  });

  it('criação já com campos de alteração é negada', async () => {
    const ref = (id) => doc(db('pedro'), 'criancas', id);
    await assertFails(setDoc(ref('a'), novaCrianca('ubsA', 'pedro', { alteradoPor: 'pedro' })));
    await assertFails(setDoc(ref('b'), novaCrianca('ubsA', 'pedro', { alteradoEm: serverTimestamp() })));
    await assertFails(setDoc(ref('c'), novaCrianca('ubsA', 'pedro', { motivoAlteracao: 'abc' })));
    await assertFails(setDoc(ref('d'), novaCrianca('ubsA', 'pedro', { ultimaSituacao: 'normal' })));
  });

  it('edita dados com motivo e log no mesmo lote', async () => {
    await assertSucceeds(editarCrianca('ana', 'cA'));
    await assertSucceeds(editarCrianca('carlos', 'cB'));
  });

  it('edição sem log, sem motivo ou com log falso é negada', async () => {
    await assertFails(updateDoc(doc(db('pedro'), 'criancas/cA'), mudCrianca('pedro')));
    await assertFails(editarCrianca('pedro', 'cA', { motivoAlteracao: '' }, { motivo: '' }));
  });

  it('edição com motivo curto, versão errada ou autor falso é negada', async () => {
    await assertFails(editarCrianca('pedro', 'cA', { motivoAlteracao: 'ab' }, { motivo: 'ab' }));
    await assertFails(editarCrianca('pedro', 'cA', { versao: 2 }, { versao: 2 }, '2'));
    await assertFails(editarCrianca('pedro', 'cA', { alteradoPor: 'ana' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { alteradoPor: 'ana' }));
  });

  it('log da criança com valores anteriores falsos é negado', async () => {
    await assertFails(editarCrianca('pedro', 'cA', {}, { nomeAnterior: 'Outro Nome' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { ativaAnterior: false }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { responsavelAnterior: null }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { nascimentoAnterior: '2020-01-01' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { nascimentoAnterior: null }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { sexoAnterior: 'masculino' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { bairroAnterior: 'Outro' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { enderecoAnterior: null }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { motivo: 'Outro motivo' }));
    await assertFails(editarCrianca('pedro', 'cA', {}, { extra: 1 }));
  });

  it('log da criança sozinho (sem edição) é negado e não pode ser alterado depois', async () => {
    const d = db('pedro');
    await assertFails(setDoc(doc(d, 'criancas/cA/alteracoes/1'), logCrianca('pedro')));
    await assertSucceeds(editarCrianca('pedro', 'cA'));
    await assertFails(updateDoc(doc(d, 'criancas/cA/alteracoes/1'), { motivo: 'trocado' }));
    await assertFails(deleteDoc(doc(d, 'criancas/cA/alteracoes/1')));
  });

  it('não altera ubsId, criadoPor, criadoEm nem cadastradoEm', async () => {
    await assertFails(editarCrianca('pedro', 'cA', { ubsId: 'ubsB' }));
    await assertFails(editarCrianca('pedro', 'cA', { criadoPor: 'ana' }));
    await assertFails(editarCrianca('pedro', 'cA', { criadoEm: serverTimestamp() }));
    await assertFails(editarCrianca('pedro', 'cA', { cadastradoEm: '2025-02-01' }));
  });

  it('profissional de outra UBS não edita', async () => {
    await assertFails(editarCrianca('bia', 'cA'));
  });

  it('não apaga; desativar exige motivo e log', async () => {
    await assertFails(deleteDoc(doc(db('pedro'), 'criancas/cA')));
    await assertFails(updateDoc(doc(db('pedro'), 'criancas/cA'), mudCrianca('pedro', { ativa: false })));
    await assertSucceeds(editarCrianca('pedro', 'cA', { ativa: false, bairro: 'Centro' }, { ativaAnterior: true }));
  });

  it('atualiza só o resumo da última avaliação, sem motivo', async () => {
    const ref = doc(db('pedro'), 'criancas/cA');
    const resumo = { ultimaSituacao: 'risco', ultimaAvaliacaoEm: Timestamp.now(), atualizadoEm: serverTimestamp() };
    await assertSucceeds(updateDoc(ref, resumo));
    await assertFails(updateDoc(ref, { ...resumo, nome: 'Outro Nome' }));
    await assertFails(updateDoc(ref, { ...resumo, ultimaSituacao: 'otima' }));
    await assertFails(updateDoc(doc(db('bia'), 'criancas/cA'), resumo));
  });
});

// =====================================================================
describe('avaliacoes', () => {
  it('lê só da própria UBS', async () => {
    await assertSucceeds(getDoc(doc(db('pedro'), 'avaliacoes/recente')));
    await assertFails(getDoc(doc(db('pedro'), 'avaliacoes/deB')));
    await assertFails(getDocs(query(collection(db('pedro'), 'avaliacoes'), where('ubsId', '==', 'ubsB'))));
  });

  it('acs, médico e nutricionista criam avaliação na própria UBS', async () => {
    await assertSucceeds(setDoc(doc(db('ana'), 'avaliacoes/n1'), novaAvaliacao('ubsA', 'cA', 'ana')));
    await assertSucceeds(setDoc(doc(db('carlos'), 'avaliacoes/n2'), novaAvaliacao('ubsB', 'cB', 'carlos')));
    await assertSucceeds(setDoc(doc(db('bia'), 'avaliacoes/n3'),
      novaAvaliacao('ubsB', 'cB', 'bia', { tipoMedida: 'deitado', retornoSugerido: '2026-12-01', microarea: '01' })));
  });

  it('cria a avaliação e atualiza o resumo da criança no mesmo lote', async () => {
    const d = db('ana');
    const b = writeBatch(d);
    b.set(doc(d, 'avaliacoes/n1'), novaAvaliacao('ubsA', 'cA', 'ana'));
    b.update(doc(d, 'criancas/cA'),
      { ultimaSituacao: 'atencao', ultimaAvaliacaoEm: Timestamp.now(), atualizadoEm: serverTimestamp() });
    await assertSucceeds(b.commit());
  });

  it('não cria com UBS fora da lista, criança alheia, autor ou nome falso', async () => {
    const ref = (id) => doc(db('pedro'), 'avaliacoes', id);
    await assertFails(setDoc(ref('n1'), novaAvaliacao('ubsB', 'cB', 'pedro')));
    await assertFails(setDoc(ref('n2'), novaAvaliacao('ubsA', 'cB', 'pedro')));
    await assertFails(setDoc(ref('n3'), novaAvaliacao('ubsA', 'cA', 'ana')));
    await assertFails(setDoc(ref('n4'), novaAvaliacao('ubsA', 'inexistente', 'pedro')));
    await assertFails(setDoc(ref('n5'), novaAvaliacao('ubsA', 'cA', 'pedro', { profissionalNome: 'Outra Pessoa' })));
  });

  it('não cria para criança inativa nem em UBS inativa', async () => {
    await assertFails(setDoc(doc(db('pedro'), 'avaliacoes/n1'), novaAvaliacao('ubsA', 'cInativa', 'pedro')));
    await assertFails(setDoc(doc(db('xavier'), 'avaliacoes/n2'), novaAvaliacao('ubsX', 'cX', 'xavier')));
    await assertFails(setDoc(doc(db('mestre'), 'avaliacoes/n3'), novaAvaliacao('ubsX', 'cX', 'mestre')));
  });

  it('nega campos extras, tipos errados e valores fora da faixa', async () => {
    const ref = (id) => doc(db('pedro'), 'avaliacoes', id);
    const nova = (extra) => novaAvaliacao('ubsA', 'cA', 'pedro', extra);
    await assertFails(setDoc(ref('a'), nova({ extra: true })));
    await assertFails(setDoc(ref('b'), nova({ pesoKg: '13' })));
    await assertFails(setDoc(ref('c'), nova({ pesoKg: 0.2 })));
    await assertFails(setDoc(ref('d'), nova({ pesoKg: 61 })));
    await assertFails(setDoc(ref('e'), nova({ alturaCm: 39 })));
    await assertFails(setDoc(ref('f'), nova({ alturaCm: 131 })));
    await assertFails(setDoc(ref('g'), nova({ situacao: 'otima' })));
    await assertFails(setDoc(ref('h'), nova({ data: '2026-11-11' })));
    await assertFails(setDoc(ref('i'), nova({ criadoEm: minutosAtras(60) })));
    await assertFails(setDoc(ref('j'), nova({ tipoMedida: 'sentado' })));
    await assertFails(setDoc(ref('k'), nova({ retornoSugerido: '2026-13-40' })));
    await assertFails(setDoc(ref('l'), nova({ excluida: true })));
  });

  it('nega data da medição antiga demais ou muito no futuro', async () => {
    const ref = (id) => doc(db('pedro'), 'avaliacoes', id);
    await assertFails(setDoc(ref('a'), novaAvaliacao('ubsA', 'cA', 'pedro', { data: Timestamp.fromDate(new Date('1970-01-01')) })));
    await assertFails(setDoc(ref('b'), novaAvaliacao('ubsA', 'cA', 'pedro', { data: Timestamp.fromMillis(Date.now() + 3 * 86400000) })));
  });

  it('valida o resultado: indicadores, zScore e chaves fixas', async () => {
    const ref = (id) => doc(db('pedro'), 'avaliacoes', id);
    const nova = (extra) => novaAvaliacao('ubsA', 'cA', 'pedro', extra);
    await assertSucceeds(setDoc(ref('ok'), nova({ indicadores: { pi: { zScore: -2.1, situacao: 'risco' } } })));
    await assertFails(setDoc(ref('a'), nova({ indicadores: {} })));
    await assertFails(setDoc(ref('b'), nova({ indicadores: { xx: { zScore: 0, situacao: 'normal' } } })));
    await assertFails(setDoc(ref('c'), nova({ indicadores: { pi: { zScore: '1', situacao: 'normal' } } })));
    await assertFails(setDoc(ref('d'), nova({ indicadores: { pi: { zScore: 99, situacao: 'normal' } } })));
    await assertFails(setDoc(ref('e'), nova({ indicadores: { pi: { zScore: 0, situacao: 'otima' } } })));
    await assertFails(setDoc(ref('f'), nova({ indicadores: { pi: { zScore: 0, situacao: 'normal', x: 1 } } })));
    await assertFails(setDoc(ref('g'), nova({ desnutricao: 'sim' })));
    await assertFails(setDoc(ref('h'), nova({ versaoTabelaOms: 5 })));
  });

  it('criação já com campos de alteração é negada', async () => {
    const ref = (id) => doc(db('pedro'), 'avaliacoes', id);
    await assertFails(setDoc(ref('a'), novaAvaliacao('ubsA', 'cA', 'pedro', { alteradoPor: 'pedro' })));
    await assertFails(setDoc(ref('b'), novaAvaliacao('ubsA', 'cA', 'pedro', { motivoAlteracao: 'abc' })));
    await assertFails(setDoc(ref('c'), novaAvaliacao('ubsA', 'cA', 'pedro', { versao: 1 })));
  });
});

// =====================================================================
describe('avaliacoes: correção, exclusão e log (RF14, RNF11)', () => {
  it('autor corrige dentro de 15 min, com log no mesmo lote', async () => {
    await assertSucceeds(corrigirAval('pedro', 'recente'));
  });

  it('correção sem log é negada', async () => {
    await assertFails(updateDoc(doc(db('pedro'), 'avaliacoes/recente'), mudAval('pedro')));
  });

  it('autor não corrige depois de 15 min', async () => {
    await assertFails(corrigirAval('pedro', 'antiga'));
  });

  it('outro profissional (mesma UBS ou outra) não corrige', async () => {
    await assertFails(corrigirAval('ana', 'recente'));
    await assertFails(corrigirAval('bia', 'recente'));
  });

  it('master corrige mesmo depois de 15 min', async () => {
    await assertSucceeds(corrigirAval('mestre', 'antiga'));
  });

  it('log por não-autor, fora da janela ou isolado é negado', async () => {
    const ana = db('ana');
    // log forjado por quem não é o autor, sozinho
    await assertFails(setDoc(doc(ana, 'avaliacoes/recente/alteracoes/1'), logAval('ana')));
    // log do autor, sozinho (sem a alteração no lote)
    await assertFails(setDoc(doc(db('pedro'), 'avaliacoes/recente/alteracoes/1'), logAval('pedro')));
    // fora da janela
    await assertFails(setDoc(doc(db('pedro'), 'avaliacoes/antiga/alteracoes/1'), logAval('pedro')));
  });

  it('log com valores anteriores falsos, motivo ou versão divergentes é negado', async () => {
    await assertFails(corrigirAval('pedro', 'recente', {}, { pesoKgAnterior: 99 }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { alturaCmAnterior: 70 }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { dataAnterior: Timestamp.now() }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { situacaoAnterior: 'risco' }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { indicadoresAnterior: { pi: { zScore: 9, situacao: 'normal' } } }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { desnutricaoAnterior: true }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { motivo: 'Outro motivo' }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { acao: 'exclusao' }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { alteradoPor: 'ana' }));
    await assertFails(corrigirAval('pedro', 'recente', {}, { versao: 2 }));
    await assertFails(corrigirAval('pedro', 'recente', {}, {}, '2'));
    await assertFails(corrigirAval('pedro', 'recente', {}, { extra: 1 }));
  });

  it('log é imutável e não pode ser apagado', async () => {
    await assertSucceeds(corrigirAval('pedro', 'recente'));
    const ref = doc(db('pedro'), 'avaliacoes/recente/alteracoes/1');
    await assertFails(updateDoc(ref, { motivo: 'trocado' }));
    await assertFails(deleteDoc(ref));
    await assertFails(deleteDoc(doc(db('mestre'), 'avaliacoes/recente/alteracoes/1')));
  });

  it('correção exige auditoria e não troca campos imutáveis', async () => {
    await assertFails(corrigirAval('pedro', 'recente', { ubsId: 'ubsB' }));
    await assertFails(corrigirAval('pedro', 'recente', { criancaId: 'cB' }));
    await assertFails(corrigirAval('pedro', 'recente', { profissionalId: 'ana' }));
    await assertFails(corrigirAval('pedro', 'recente', { profissionalNome: 'Ana' }));
    await assertFails(corrigirAval('pedro', 'recente', { criadoEm: serverTimestamp() }));
    await assertFails(corrigirAval('pedro', 'recente', { pesoKg: 99 }));
    await assertFails(corrigirAval('pedro', 'recente', { alteradoPor: 'ana' }));
    await assertFails(corrigirAval('pedro', 'recente', { motivoAlteracao: '' }, { motivo: '' }));
    await assertFails(corrigirAval('pedro', 'recente', { versao: 2 }, { versao: 2 }, '2'));
  });

  it('autor exclui dentro de 15 min (exclusão lógica) e depois não', async () => {
    const mud = { excluida: true, motivoExclusao: 'Criança errada' };
    await assertSucceeds(corrigirAval('pedro', 'recente', mud, { acao: 'exclusao' }));
    await assertFails(corrigirAval('pedro', 'antiga', mud, { acao: 'exclusao' }));
  });

  it('exclusão sem motivo ou sem a ação exclusao no log é negada', async () => {
    await assertFails(corrigirAval('pedro', 'recente', { excluida: true }, { acao: 'exclusao' }));
    await assertFails(corrigirAval('pedro', 'recente', { excluida: true, motivoExclusao: 'Criança errada' }));
  });

  it('não apaga fisicamente nem edita avaliação já excluída', async () => {
    await assertFails(deleteDoc(doc(db('pedro'), 'avaliacoes/recente')));
    await assertFails(deleteDoc(doc(db('mestre'), 'avaliacoes/recente')));
    await assertSucceeds(corrigirAval('pedro', 'recente', { excluida: true, motivoExclusao: 'Criança errada' }, { acao: 'exclusao' }));
    const d = db('pedro');
    const b = writeBatch(d);
    b.update(doc(d, 'avaliacoes/recente'), mudAval('pedro', { versao: 2, excluida: false, motivoExclusao: null }));
    b.set(doc(d, 'avaliacoes/recente/alteracoes/2'), logAval('pedro', { versao: 2 }));
    await assertFails(b.commit());
  });
});

// =====================================================================
describe('log pré-existente e microárea', () => {
  it('correção/edição é negada se o log da versão já existia antes do lote', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'avaliacoes/recente/alteracoes/1'), logAval('pedro'));
      await setDoc(doc(ctx.firestore(), 'criancas/cA/alteracoes/1'), logCrianca('pedro'));
    });
    await assertFails(updateDoc(doc(db('pedro'), 'avaliacoes/recente'), mudAval('pedro')));
    await assertFails(corrigirAval('pedro', 'recente'));
    await assertFails(updateDoc(doc(db('pedro'), 'criancas/cA'), mudCrianca('pedro')));
    await assertFails(editarCrianca('pedro', 'cA'));
  });

  it('microarea da avaliação: ausente, igual à do perfil ou (master) livre', async () => {
    const ref = (d, id) => doc(db(d), 'avaliacoes', id);
    await assertSucceeds(setDoc(ref('pedro', 'a'), novaAvaliacao('ubsA', 'cA', 'pedro', { microarea: '01' })));
    await assertSucceeds(setDoc(ref('pedro', 'b'), novaAvaliacao('ubsA', 'cA', 'pedro', { microarea: null })));
    await assertFails(setDoc(ref('pedro', 'c'), novaAvaliacao('ubsA', 'cA', 'pedro', { microarea: '99' })));
    await assertSucceeds(setDoc(ref('mestre', 'd'), novaAvaliacao('ubsA', 'cA', 'mestre', { microarea: '99' })));
  });
});

describe('profissional inativo', () => {
  it('não lê nem grava nada', async () => {
    const d = db('ines');
    await assertFails(getDoc(doc(d, 'criancas/cA')));
    await assertFails(getDoc(doc(d, 'avaliacoes/recente')));
    await assertFails(getDoc(doc(d, 'ubs/ubsA')));
    await assertFails(setDoc(doc(d, 'criancas/nova'), novaCrianca('ubsA', 'ines')));
    await assertFails(setDoc(doc(d, 'avaliacoes/nova'), novaAvaliacao('ubsA', 'cA', 'ines')));
    await assertFails(updateDoc(doc(d, 'profissionais/ines'), { microarea: '09' }));
  });
});

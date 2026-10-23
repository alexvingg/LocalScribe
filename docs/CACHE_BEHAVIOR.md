# Retomar revisões ao trocar ou minimizar janelas

## Evidência do Grammarly e limite da comparação

A análise anterior registra armazenamento geral em `LocalStorage/{scope}.db`, com colunas `maxAgeSeconds`, `creationDate` e `expirationDate` (**CLONE_SPEC.md, PS-05**, evidências `OBS-SQL-02` e `E-SQLITE`). Isso comprova o esquema observado, não que esse banco armazene correções. O nome `documentIDMap.json` foi observado (**PS-03 / OBS-SUPPORT-01**), mas seu conteúdo e sua associação a campos/documentos não foram inspecionados.

**UNKNOWN:** cache específico de sugestões do Grammarly, chave, prazo, invalidação e comportamento interno ao minimizar/restaurar. Não houve um ensaio controlado desse ciclo que permitisse atribuir o resultado a cache. A solução abaixo é uma escolha independente para o LocalScribe; não deriva de código ou ativos do Grammarly.

## Comportamento atual — versão 0.7

- A perda de foco oculta marcas/cartão e descarta apresentações antigas. Uma revisão automática já iniciada pode concluir para guardar o resultado do texto congelado no cache. Nada é desenhado ou aplicado sobre outro app. Fila, contexto e época continuam impedindo publicar uma resposta desatualizada. Reformulações antigas são canceladas; pausa, bloqueio, troca de política e encerramento cancelam também a análise automática e impedem seu armazenamento.
- Ao voltar, uma revisão concluída do mesmo processo, campo, texto completo, parágrafo, janela de frases e configuração de idioma é restaurada sem outra geração. Um resultado sem erros também é uma revisão concluída.
- Sugestões ignoradas e histórico de alternativas são restaurados somente nessa mesma revisão/campo. Não são transferidos para um campo diferente só porque o texto é igual.
- Os retângulos de tela nunca são armazenados: a leitura atual de Acessibilidade recalcula as posições. Uma correção ainda depende da validação do destino/texto atual antes de escrever.
- Uma alteração de texto não reutiliza intervalos da versão anterior. Frases idênticas ainda podem aproveitar correções/clareza já geradas, com separação por aplicativo, idioma e tipo de revisão. Respostas sem alteração também são reutilizadas.
- Se o editor recriar a identidade AX do campo, a restauração completa pode falhar; resultados das frases idênticas ainda podem ser reaproveitados. Não há tentativa de adivinhar a identidade do documento por título ou conteúdo.
- Somente gerações novas de clareza aguardam a pausa adicional. Uma resposta de clareza já armazenada não espera mais 1,5 segundo.
- **Revisar agora** força uma nova revisão e limpa os caches. Mudar preferências, pausar ou bloquear um app também limpa os caches. Fechar o processo apaga tudo; abrir a janela de configurações não equivale a encerrar o processo.

## Limites e retenção

Cache exclusivamente na memória do processo: até **12 revisões de campos** e **64 resultados de frases**, com prazo de **10 minutos** por gravação. Os orçamentos de texto são respectivamente 400.000 e 64.000 unidades UTF-16; não representam uma medição total da memória do processo. Ao atingir um limite, a entrada menos recentemente consultada é removida.

A expiração é verificada em cada consulta, e uma limpeza periódica ocorre no máximo a cada 15 segundos enquanto o monitor roda. Regravar uma revisão após uma interação pode renovar seu prazo. O estado atualmente exibido é separado do cache; a expiração não obriga uma nova geração enquanto se permanece na mesma revisão ativa.

Não há serialização de texto, arquivo de cache ou sincronização. A análise de um app bloqueado continua sendo impedida antes da leitura do conteúdo.

## Evidência da implementação e validação

- `WritingCoordinator.receive`, `saveCurrentRevision`, `finishRevision`: preservação/retomada da revisão, incluindo vazio e decisões de ignorar.
- `ReviewSessionCache.key`: identidade AX/processo e texto/configuração exatos; nenhum retângulo salvo.
- `ReviewMemoryCache`: expiração, LRU, orçamento e limpeza.
- `WritingCoordinator.reviewNow`, observação de preferências e `stop`: invalidação explícita e limpeza.
- `WritingCoreChecks`: testes de positivo/vazio, isolamento de chave, prazo, LRU, orçamento e limpeza.
- `--cache-smoke`: usa o armazenamento real e uma chamada ao modelo local com snapshots artificiais. Confere restauração, ignorar/histórico, texto/campo/idioma diferentes, resultado vazio e limpeza. Não lê nem edita um aplicativo externo; não substitui o teste real de minimizar/restaurar.
- Versão 0.7.0, build 16: execução normal registrou `editor-review phase=cached-after-context-change bundle=com.google.Chrome`, confirmando conclusão e gravação após mudar o contexto. Esse evento não identifica o texto e, sozinho, não comprova todo o ciclo de minimizar/restaurar, retomada ou alinhamento visual.

Para conferir no editor: abra o exemplo TextEdit, aguarde concluir, minimize/restaure ou alterne para outro aplicativo e volte. A revisão concluída deve retornar sem nova geração. No diagnóstico, os contadores de retomadas/frases reutilizadas devem aumentar sem aumentar o contador de chamadas de revisão automática. Depois edite uma frase: somente resultados com texto ainda idêntico podem ser reaproveitados.

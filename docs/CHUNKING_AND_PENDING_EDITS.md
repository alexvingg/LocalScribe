# Correções pendentes e revisão por blocos — versão 0.4

## Uma proposta não é uma alteração aceita

`SuggestionLedger.proposing` mantém todas as correções pendentes, com os mesmos identificadores e intervalos, ao adicionar uma reformulação. Uma nova versão substitui apenas propostas de estilo sobrepostas; não remove as correções de palavras. O desenho coloca as marcas vermelhas por cima das marcas opcionais, caso coincidam.

Gerar uma frase, exibir seu cartão ou fechar esse cartão não modifica o texto de origem. Aceitar continua exigindo validação do texto/campo e escrita por Acessibilidade; depois disso as propostas compatíveis são reposicionadas sobre o texto confirmado. Na versão 0.5, aceitar uma correção de palavra de revisão concluída não exige nova geração. Na versão 0.7.5, a frase proposta é conferida antes da exibição. Após aceitação confirmada, blocos inteiramente cobertos por essa revisão são reutilizados, sem iniciar nova geração; propostas independentes são preservadas. Fallback parcial ou alteração de contexto ainda pode exigir conferência. Detalhes e evidências em [PROPOSAL_STABILITY.md](PROPOSAL_STABILITY.md). Ignorar uma proposta remove apenas aquela proposta. Edição manual, troca de campo e perda de foco podem invalidar/ocultar marcas; a retomada usa o cache quando aplicável. A regra de manter marcas pendentes não autoriza aplicar intervalos de um texto que já mudou.

## Limites oficiais: grandezas distintas

Consulta em 23/10/2026:

- [Apple: geração com Foundation Models](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models) e [gerenciamento de contexto](https://developer.apple.com/documentation/foundationmodels/managing-the-context-window): o modelo no dispositivo tem janela de 4.096 tokens por sessão. Instruções, prompts, esquemas, ferramentas/histórico e respostas consomem o contexto. A Apple recomenda dividir dados grandes em blocos e sessões separadas.
- [Grammarly: limitações](https://support.grammarly.com/hc/en-us/articles/115000090911-What-are-the-limitations-when-using-Grammarly): o editor web aceita até 100.000 caracteres com espaços; para Grammarly no Mac/Windows, a página diz que o limite é o imposto pelo editor de origem. Isso é um limite de produto/documento, não a janela de um LLM. A janela do modelo e o algoritmo interno de segmentação do Grammarly continuam UNKNOWN.

Tokens não correspondem a uma quantidade fixa de palavras/caracteres. O LocalScribe usa contagem real do modelo instalado, em vez de converter caracteres em tokens por uma proporção fixa.

## Política implementada

1. Captura limitada a 200.000 unidades UTF-16 por campo, como limite operacional do protótipo, independente do limite de tokens.
2. Extração de uma região do parágrafo próximo do cursor, limitada a 6.000 unidades UTF-16. Um parágrafo maior seleciona uma janela de blocos próxima do cursor, em vez de recusar o parágrafo inteiro.
3. Segmentação por frases. Frases longas são divididas em separações entre palavras, em blocos de até 800 unidades UTF-16. Um token/palavra/URL enorme sem separação é mantido inteiro e excluído da geração, com aviso; não é corrigido em pedaços.
4. Até quatro blocos perto do cursor por revisão, em sequência. Não há varredura automática de todo o documento. Cada pedido usa uma sessão nova; os blocos não acumulam histórico no modelo.
5. Frases/blocos idênticos com mesmo app/idioma/tipo de revisão usam o cache. Somente entradas sem resultado válido armazenado exigem nova geração. Não é possível saber se um bloco contém erro antes de avaliá-lo.
6. A reformulação explícita de um bloco parcial é rotulada **Reformular trecho**, evitando apresentá-la como revisão da frase inteira. Na versão 0.5, gramática e estrutura são avaliadas na mesma chamada. Reformulação de estilo é explícita; não há segunda geração automática de estilo.
7. `tokenCount(for:)` mede instruções, prompt e esquema antes da geração. O orçamento reserva 900 tokens para saída e 256 para enquadramento/overhead e consulta `contextSize` do modelo. A margem é uma escolha do protótipo, não uma garantia sobre overhead privado. O erro de contexto também é tratado defensivamente; propostas existentes são preservadas.
8. O histórico enviado para pedir outra versão é limitado a até duas versões inteiras que caibam em 600 unidades UTF-16. A rejeição de repetição continua considerando o histórico em memória, não só o subconjunto enviado.
9. Espaços, recuos e quebras de linha nas bordas do bloco são preservados pelo aplicativo. O modelo não pode transformar o separador entre frases em uma correção de exclusão de espaço.

Não há garantia de análise de dependências gramaticais entre blocos. Fatiar frases muito longas reduz contexto linguístico; por isso o app distingue trecho de frase e aplica apenas mediante aceitação. Os intervalos retornados são convertidos para a região original; o texto inteiro não é substituído para aceitar uma correção local.

## Validação

`WritingCoreChecks` inclui regressões de preservação de correções ao propor e trocar uma reformulação, fragmento longo próximo do cursor, segmentação com Unicode, palavra enorme sem corte, janela próxima do cursor, orçamento de saída e separadores entre frases.

`--chunk-smoke` usa um documento artificial longo, seleciona a região/blocos ativos, consulta o modelo local e o cache reais, pede uma alternativa e verifica se as correções de palavras continuam presentes. Ele mede os tokens das entradas e não lê/escreve um editor externo. Resultados observados estão em `VALIDATION.md`.

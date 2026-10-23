# Grammarly Desktop — análise das funcionalidades

Análise da instalação local 1.203.0.0, em 23 de outubro de 2026. Complementa o [relatório técnico](grammarly-rea-report.md).

O produto reúne revisão de escrita, reescrita e geração com IA, personalização, registro de autoria e integrações com outros aplicativos. O pacote também contém funcionalidades de Superhuman Go e voz/reuniões. Essas partes têm condições de disponibilidade diferentes.

## O que foi verificado

O REA interpretou os recursos de interface instalados, incluindo 1.056 entradas de texto do núcleo, 182 entradas de interface de voz/reuniões e 26 de ditado. Também foram examinadas as telas de configurações do aplicativo aberto com automação de interface.

Há dois níveis de comprovação neste relatório:

- **Observado na interface:** um controle ou estado estava visível nesta instalação. Um checkbox marcado confirma a configuração exibida, não o funcionamento de todo o serviço.
- **Descrito no pacote:** textos de interface distribuídos com o app descrevem a função. Podem corresponder a outra modalidade, plano, experimento, recurso migrado ou estado indisponível.

O teste inicial no TextEdit foi inconclusivo. Em um teste posterior no Chrome, o Grammarly apresentou cinco sugestões e a aceitação de uma delas alterou corretamente o texto do editor, conforme registrado ao final. Geração, tradução e verificações de originalidade não foram testadas de ponta a ponta.

## 1. Revisão de escrita

| Função | O que oferece ao usuário | Evidência nesta instalação |
|---|---|---|
| Ortografia, gramática e pontuação | Identificar problemas e apresentar correções durante a escrita | Textos do pacote descrevem as três categorias; o agrupamento dessas sugestões aparece ativado nas configurações |
| Aceitar ou descartar sugestões | Manter controle sobre cada alteração; consultar explicações e adicionar palavras ao dicionário | Entradas `Accept suggestion`, `Dismiss suggestion`, `Add to dictionary` e explicações parametrizadas |
| Clareza e concisão | Propor texto mais claro, curto e fácil de ler | Categorias `Clarity`, `Correctness`, `Delivery`; descrição explícita de clareza/concisão |
| Tom | Mostrar como a mensagem pode soar ao destinatário | `Detect tone in my writing` aparece ativado; pacote contém `Tone Insights` |
| Linguagem inclusiva | Sugerir alternativas para determinados termos | Texto `Consider a more inclusive term`; cobertura e critérios não testados |
| Nota do documento | Exibir avaliação geral de 0 a 100 | Textos de score; recurso informa mínimo de 30 palavras para cálculo |

O fluxo previsto é escrever no editor, consultar uma sugestão e decidir se aceita ou ignora. Sugestões agrupadas podem reunir alterações de ortografia, gramática e pontuação da mesma frase. Essa abordagem preserva revisão humana, mas a conveniência real depende de como o editor expõe seu texto ao Grammarly.

**Idioma:** a configuração observada usa **British English**. Os recursos listam também American, Canadian, Australian e Indian English. A presença de traduções de interface e do recurso de tradução não demonstra correção gramatical em português.

## 2. Reescrita e IA generativa

| Função | Uso prático | Situação observada |
|---|---|---|
| Melhorar e reformular | Produzir outra versão de um trecho | Opções `Improve` e `Rephrase` descritas no pacote |
| Encurtar | Reduzir a extensão do texto | Opção `Shorten` |
| Ajustar o tom | Tornar uma mensagem mais amigável ou formal | Opções `Friendly` e `Formal` |
| Gerar por instrução | Brainstorm, redação e transformações solicitadas em prompt livre | Textos para entrada de prompt, acrescentar parágrafo e formatar em tópicos |
| Auxílio na seleção | Exibir entrada de IA ao selecionar um trecho | `Show on text selection` aparece ativado |
| Respostas a e-mail | Oferecer entrada de IA no contexto de respostas | `Show for email replies` aparece ativado; não foi aberto nem enviado e-mail |
| Estilo pessoal | Usar uma amostra para orientar o estilo do texto gerado | Configuração `Manage writing style` visível; pacote solicita amostra de pelo menos 200 palavras e descreve gestão/exclusão de estilos |

A revisão pontual e a reescrita são experiências diferentes: uma apresenta problemas e alterações específicas; a outra propõe uma nova formulação. Não foi testado se uma reescrita preserva todos os fatos ou a intenção de um texto, nem a qualidade das sugestões.

O pacote inclui avisos de cota diária para reescritas gratuitas, upgrade para reescritas ilimitadas e quotas parametrizadas de IA. Portanto, a presença das opções não permite concluir que todas estejam liberadas no plano atual. Não foram determinados preços, limites contratuais ou saldo da conta.

## 3. Autoria, originalidade e citações

**Authorship:** o controle aparece ativado nas configurações. A própria interface o descreve como registro do que se digita e das fontes usadas, com escolha de compartilhamento. Os recursos também descrevem relatório de atividade, texto colado de origem desconhecida, pausa do acompanhamento e limites parametrizados por número de páginas. A ativação exibida não prova que um documento específico esteja sendo acompanhado; compatibilidade e permissões podem influenciar o fluxo.

**Plágio:** há interface para verificar correspondências com referências e gerar citações. Não foi avaliada a cobertura das fontes, a precisão ou o funcionamento da verificação na conta.

**Padrões de texto de IA:** os rótulos falam em “possível” texto de IA e em padrões frequentemente associados a IA. A função apresenta uma estimativa; não é comprovação de quem escreveu um texto. Não foi medida a taxa de acerto.

Essas funções respondem a perguntas diferentes. Authorship registra o processo de composição quando há acompanhamento. A verificação de plágio procura correspondências. A detecção de IA procura padrões no resultado. O relatório não trata uma como substituta das outras.

## 4. Tradução, snippets e trabalho em equipe

| Função | Descrição encontrada | Disponibilidade |
|---|---|---|
| Tradução | Interface anuncia tradução entre mais de 15 idiomas e troca de idioma de destino | Descrita no pacote; lista completa, pares de idiomas e qualidade não testados |
| Snippets | Criar, guardar, buscar e inserir trechos reutilizáveis; biblioteca/coleções e atalhos | Descritos no pacote; há variantes de limites divergentes, então nenhum teto foi assumido |
| Guia de estilo da organização | Seguir regras de escrita da equipe | Descrito no pacote; depende da configuração da organização |
| Brand tones | Orientar o tom da marca | Descrito no pacote; não confirmado na conta |
| Knowledge Share | Destacar termos internos e apresentar contexto compartilhado | Descrito no pacote; não foi acessado conteúdo de equipe |
| Estatísticas de escrita | Informações periódicas e dicas sobre escrita | Descritas no pacote; histórico e métricas não consultados |

Snippets atendem a conteúdo padronizado que se repete. Estilo pessoal e tom orientam novas formulações. Guias e glossários da organização servem à consistência entre pessoas. Essas funções se complementam, mas não foi verificado quais estão provisionadas para esta conta.

## 5. Grammarly e Superhuman Go

A tela de configurações oferece `Use Superhuman Go`, com a descrição de uma experiência com agentes de IA que inclui Grammarly. **O controle apareceu desmarcado**, diferentemente dos checkboxes cujo valor era explicitamente `on`.

O pacote compartilhado contém ainda:

- Chat sobre texto selecionado.
- Anexação de arquivos e referência a uma janela na conversa.
- Sugestões de resumo e outras operações sobre contexto.
- Histórico de conversas com renomeação/exclusão.
- Textos de conexão com e-mail, calendário, Google Drive e outros serviços para uso por agentes.

As evidências não permitem atribuir cada uma dessas funções à modalidade Grammarly clássica ou garantir acesso na conta. Os textos de transição apresentam os agentes como parte do Go. Por isso, elas são registradas como **capacidades descritas no pacote compartilhado**, sem presumir que estejam ativadas no modo observado.

## 6. Ditado e anotações de reuniões

**Ditado:** os recursos descrevem iniciar, finalizar, cancelar e reiniciar gravação; estado de processamento; texto copiado para a área de transferência; seleção de entrada de áudio e mensagens de erro de permissão, streaming e transcrição. Isso sustenta um fluxo previsto de fala → processamento → texto. O recurso não foi encontrado ativo nas telas examinadas e não foi gravado áudio.

**Notetaker:** os recursos descrevem captura do som do computador sem um bot entrando na chamada, transcrição, resumo, notas, itens de ação, cópia e regeneração de resumo. Há também associação a calendário, início automático, avisos de reunião e compartilhamento por e-mail/evento/chat. Nenhuma reunião foi capturada, conexão criada ou mensagem enviada.

**Migração relevante:** o pacote contém `Notetaker has moved. Download the new one…` e `Please switch to the new standalone Notetaker. Your existing notes will still be available.` Portanto, seria incorreto prometer que essas funções de reunião estão disponíveis dentro do Grammarly Desktop atual apenas porque seus recursos continuam no pacote.

## 7. Integração e configuração de uso

A tela `Block List` foi aberta e confirmou a lista de aplicativos excluídos da verificação. A interface permite remover itens; nenhuma exclusão foi alterada. O pacote também descreve exclusões por site e bloqueios definidos por administradores, sem validar os controles administrativos desta conta.

Outros controles observados:

- Inicialização com o sistema: ativada.
- Atalho exibido para abrir o Grammarly: Control+G, com opção de edição.
- Escolha da variante de inglês.
- Detecção de tom.
- Gestão de estilo pessoal.
- Authorship.
- Agrupamento de sugestões.
- Entrada de IA em seleção de texto e respostas de e-mail.

A análise técnica anterior encontrou APIs de acessibilidade que permitem ler/alterar atributos e observar foco/seleção. Isso explica um mecanismo possível para oferecer revisão em diferentes aplicativos. A integração não foi demonstrada em todos os editores. O recurso de configuração instalado também contém regra de Google Docs que solicita extensão do navegador.

## Avaliação funcional

O conjunto mais claramente exposto na interface observada é o de **assistência à escrita em inglês**, com personalização de tom e estilo, IA contextual e controle de onde atuar. Os recursos distribuídos ampliam esse conjunto para originalidade, conteúdo reutilizável, colaboração e outras modalidades do produto.

Os principais limites da avaliação são:

- Opção visível ou texto de interface não confirma acesso pelo plano nem resposta do backend.
- O pacote reúne modalidades diferentes e recursos em migração.
- Tradução e localização não comprovam revisão gramatical em cada idioma.
- Qualidade geral, latência e consumo de recursos não foram medidos. O teste no Chrome confirmou cinco sugestões em uma amostra pequena, sem estabelecer precisão geral.
- Não foi validado o comportamento de envio/armazenamento de texto ou áudio.

## Teste com texto fictício

Foi criado um documento vazio no TextEdit com uma amostra artificial em inglês contendo erros intencionais, iniciada por `She go to school every days.`. Nenhuma sugestão ou controle do Grammarly foi observado na captura do editor. O atalho também não abriu um novo painel nas observações realizadas.

Depois, a automação da interface apresentou timeouts, impedindo concluir o fluxo. Esse resultado é **inconclusivo**: não demonstra falha geral do Grammarly, pois não foi estabelecida a causa, a integração efetiva com o editor ou o estado de todos os serviços/permissões.

O TextEdit salvou automaticamente o documento sintético. Seu arquivo foi movido da pasta do TextEdit para [grammarly-textedit-test.rtf](grammarly-textedit-test.rtf), preservando a amostra junto ao relatório. A tentativa de limpar/fechar a janela não pôde ser confirmada devido ao timeout. Nenhum documento preexistente foi editado.

## Evidências e rastreabilidade

### Atualização: teste real no Chrome

O usuário forneceu a página `https://www.ilovenote.net/?edit-id=cuf4cvIr56689e40ab` como editor para demonstração. O navegador interno abriu um editor vazio e não apresentou controles do Grammarly. No Chrome, o link manteve o identificador da nota, que continha o texto de teste `he ho a`. Esse texto foi preservado e recebeu uma amostra artificial em inglês.

O Grammarly exibiu marcações no texto, um botão de acesso e o painel `Grammarly Assistant`, com cinco sugestões:

| Trecho | Sugestão observada | Categoria mostrada |
|---|---|---|
| `he` no início | `He` | Correctness · Capitalize the word |
| `She go` | `She goes` | Correctness · Correct subject-verb agreement |
| `every days` | `every day` | Correctness · Check wording |
| `I has` | `I have` | Correctness · Correct subject-verb agreement |
| `your advise` | `your advice` | Correctness · Replace the word |

Foi acionado `Accept` apenas para `I has → I have`. O conteúdo do editor passou a conter `I have an important meeting tomorrow`, e o contador diminuiu de cinco para quatro sugestões. Isso confirma neste cenário a detecção contextual, a navegação entre sugestões e a aplicação de uma alteração diretamente no editor. O painel também ofereceu `Learn more`, `Dismiss`, mais ações e navegação anterior/próxima; nem todas essas ações foram executadas.

O painel foi deixado aberto na sugestão `advise → advice`, com as demais sugestões ainda pendentes, para inspeção pelo usuário. Não foi isolado se o comportamento foi entregue pela extensão do Chrome, pela integração do Desktop com o navegador ou por ambas; o teste confirma o Grammarly atuando naquele campo, sem atribuir exclusivamente a um componente.

Evidências desta atualização vieram da observação e interação via Computer Use, não de descompilação REA:

- [referência visual local; veja o inventário](ARTIFACTS.md).
- [Snapshot textual da página ao final do teste](grammarly-live-observation.txt).

### Evidências estáticas anteriores

[Evidências funcionais do REA](evidence/grammarly-functional-evidence.json): quatro registros `inspect_plist`, interpretando os arquivos `.strings` como property lists, sem executá-los.

| Registro | Arquivo no aplicativo | Uso nesta análise |
|---|---|---|
| `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984` | `Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Resources/en-US.lproj/Localizable.strings` | Escrita, IA, Authorship, originalidade, tradução, snippets, Go, limites e migração |
| `ev_fe2ef7f8230f2aa37ff195db8cbc7959e6cc7acf7e8ab880586dd4ac2c7d3c7c` | `Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Frameworks/GRLlamaUI.framework/Versions/A/Resources/en-US.lproj/Localizable.strings` | Recursos auxiliares de interface |
| `ev_7d7df9cfe1d8b64333deb4348691723b2666f44b6d294a912ba54607d614f511` | `Contents/Resources/AVIFeatures_Dictation.bundle/Contents/Resources/en-US.lproj/Localizable.strings` | Ditado e estados de gravação/transcrição |
| `ev_8cd034bcbc2ccb6a85e6c596742ea0cd99f9a466702eef0342548595c0edb70b` | `Contents/Resources/AVIDesign_AVIUI.bundle/Contents/Resources/en-US.lproj/Localizable.strings` | Reuniões, resumo, transcrição, calendário e aviso de migração |

Os caminhos da tabela são relativos a `/Applications/Grammarly Desktop.app`. As observações das telas Settings/Customization/Block List e do teste no TextEdit vieram de Computer Use e não fazem parte desses quatro registros REA. A [evidência técnica anterior](evidence/grammarly-rea-evidence.json) contém o inventário, imports/exports e demais registros usados na análise de arquitetura.

# Integração comum com os campos de escrita

Atualizado em 23/10/2026, versão 0.7.4. Escopo pedido: WhatsApp, Slack, Teams, Chrome, Firefox, Safari e demais campos de texto do Mac. Compatibilidade é avaliada por campo, não por uma lista de aplicativos permitidos.

## O que o estudo do Grammarly permite afirmar

REA reconferido diretamente no framework instalado `GRAccessibilityKit`, ARM64, SHA-256 `19f3aaae3c41c95a90adac4f628ddd01cb2893be5a134a501dac05ea060866a5`. Evidência `ev_6e5ea4070363a9497fe8ca79fc0c581f281fccb8b4bd2f8720d0dec45cb599e3`, operação `inspect_macho`; índice de evidências em [grammarly-integration-evidence.json](grammarly-integration-evidence.json).

| Evidência estática | Implicação e limite |
| --- | --- |
| Imports `AXUIElementCopyAttributeValue`, `AXUIElementSetAttributeValue`, `AXUIElementIsAttributeSettable`, `AXUIElementCopyParameterizedAttributeValue` | O componente dispõe de leitura, escrita e consulta de capacidades de Acessibilidade. Não comprova qual chamada atende cada editor em execução. |
| Imports `AXObserverAddNotification`, `AXObserverCreateWithInfoCallback`; getter `focusedUIElementChanged` em `0x1931c`, `selectedTextChanged` em `0x1a4d8` | Dispõe de observação de foco/seleção. Política de debounce/reconexão em cada app: UNKNOWN. |
| Getter `editableAncestor` em `0xec10`; `selectedTextRange` em `0x4a54`, `selectedTextRanges` em `0x4ae4` | Dispõe de referências a ancestrais editáveis e seleções singulares/múltiplas. Algoritmo de resolução: UNKNOWN. |
| Getter `boundsForRange` em `0xa224`; `selectedTextMarkerRange` em `0x9460`; frase em `0xb9cc`, parágrafo em `0xb5dc` | Dispõe de geometria e marcadores textuais, incluindo frase/parágrafo. Não estabelece a classificação linguística nem a API usada em cada campo. |
| Imports `CGEventKeyboardSetUnicodeString`, `CGEventPostToPid` | Dispõe de entrada de teclado. Momento e critérios de uso: UNKNOWN. |

A configuração instalada `ProjectLlamaContent.framework/Versions/A/Frameworks/GRLlamaCore.framework/Versions/A/Resources/IntegrationOptions.json`, relativa a `/Applications/Grammarly Desktop.app/Contents/Frameworks`, foi examinada somente para descrever contratos. SHA-256 `d9a1d238f3c791ec2fb179f5ae3b993ec94a814097b95d7e8cadd170112c85f2`; evidência histórica `OBS-CONFIG-01` de `../CLONE_SPEC.md`. Exemplos reconferidos: Slack desktop nas linhas 128–130 (posicionamento), Slack web nas linhas 144–153 (marcação/posicionamento), Teams web nas linhas 429–435 (editor de chat), `RequiresBrowserExtension` na linha 62. Isso comprova políticas específicas empacotadas, sem comprovar aplicação efetiva, precedência ou compatibilidade atual. Nenhum código ou conjunto de regras do produto foi copiado para o aplicativo.

Conclusão de arquitetura, por inferência: base comum de Acessibilidade e mecanismos auxiliares, com ajustes para campos específicos. Não há evidência de uma única operação capaz de atender qualquer campo. As observações anteriores no Chrome não isolavam extensão e app desktop do Grammarly.

## Implementação independente no LocalScribe

1. Respeitar pausa e apps bloqueados antes de consultar o campo. Resolver o foco do sistema/app e um ancestral editável. Se o foco for um contêiner, procurar apenas um campo explicitamente focado, com limites de profundidade/nós; não escolher arbitrariamente o primeiro editor.
2. Solicitar a árvore acessível por `AXManualAccessibility` no processo de destino; quando essa solicitação falhar e o provedor anunciar `AXEnhancedUserInterface` como gravável, solicitar essa alternativa. O diagnóstico real do Teams está em [TEAMS_INTEGRATION.md](TEAMS_INTEGRATION.md). Esse mecanismo é documentado pelo [Electron](https://raw.githubusercontent.com/electron/electron/main/docs/tutorial/accessibility.md); apps sem esse atributo podem rejeitá-lo. Esta decisão vem da documentação pública, não de execução observada do Grammarly.
3. Ler texto e seleção UTF-16, incluindo texto atribuído e `AXSelectedTextRanges`. Usar notificações com verificação periódica do campo ativo. Texto protegido não entra na revisão.
4. Segmentar, detectar idioma automaticamente, revisar com o modelo local e manter propostas/cache por contexto. Quando a identificação rápida falha em um trecho com contexto suficiente, consultar uma sessão curta do modelo; guardar inclusive o resultado desconhecido para evitar repetição contínua. Não assumir inglês para conteúdo ambíguo.
5. Posicionar sublinhados somente quando existem coordenadas reais do texto. Quando há texto/seleção, mas falta geometria de caracteres, apresentar um indicador azul com contagem junto ao campo/janela, sem inventar posições de palavras. Esse fallback ainda precisa de teste em um editor real sem geometria.
6. Escolher a escrita pelas capacidades: campos web identificados por ancestral `AXWebArea` ou parâmetros de marcadores textuais usam entrada nativa; campos nativos com escrita de seleção usam AX. Confirmar fonte, seleção e destino antes de escrever; confirmar resultado antes de retirar a proposta. Não reenviar automaticamente uma escrita sem confirmação.
7. Expor status e “Revisar agora”. Falhas transitórias de revisão têm até duas novas tentativas limitadas; aplicar correções não tem retry automático. Destino alterado cancela a publicação da resposta antiga.

O seletor de estratégia está em `WritingCore/EditorCompatibility.swift`; não consulta bundle IDs. A ausência de leitura/seleção acessível continua sendo uma limitação real. Um plugin ou extensão é uma alternativa futura para editores que não expõem essas capacidades; não foi implementado nesta versão.

## Cobertura efetivamente verificada

| Destino | Evidência atual | Estado |
| --- | --- | --- |
| WhatsApp no Chrome | 0.6.0: `She go to school every days.` gerou duas propostas; aplicação de `go → goes` manteve `days → day`; segunda aplicação confirmou a frase correta. Um Desfazer restaurou `days` e recuperou a proposta pelo cache. Reaplicação confirmada. Nenhuma mensagem enviada | Aplicação de palavras e Desfazer CONFIRMADOS; frase inteira nesta versão PENDENTE |
| TextEdit | Aplicação incremental na 0.5; 0.6.0: campo AXTextArea, seleção e geometria disponíveis, estratégia AX | Aplicação na versão 0.6.0 PENDENTE |
| ChatGPT desktop | Após ativar a árvore acessível, o monitor gerou uma proposta no campo ativo | Leitura/revisão observadas; aplicação UNKNOWN |
| Slack desktop | Campo de mensagem real: leitura/idioma/seleção e 23 glifos posicionados; aplicações verificadas na 0.6.1 e uma colagem maior na 0.7.0 build 15 | CONFIRMADO nesse compositor; Desfazer/rolagem e outros compositores PENDENTES |
| Slack web | Nenhum campo real validado nesta versão | UNKNOWN |
| Teams desktop | 0.7.4: ponte AXEnhancedUserInterface, compositor AXTextArea, seleção/idioma/geometria; cartão real; cinco escritas verificadas e leitura final da frase corrigida. Evidências em TEAMS_INTEGRATION.md | Leitura/cartão/aplicação CONFIRMADOS nesse compositor; aparência das marcas, Desfazer e outros campos PENDENTES |
| Teams web | Nenhum campo real validado nesta versão | UNKNOWN |
| Firefox e Safari | Base comum implementada; nenhum campo real validado nesta versão | UNKNOWN |
| Sublime Text, exemplo artificial | Árvore expôs janela/controles, sem editor AX, mesmo após solicitar acessibilidade | Sem suporte nesse teste |

Critério para aprovar cada editor: localizar o campo ativo; obter texto/seleção/idioma; posicionar marcas ou indicador; abrir cartão sem perder o destino; aplicar palavra e frase uma vez; verificar resultado e Desfazer; preservar outras propostas; acompanhar rolagem/foco; respeitar bloqueio. Um teste em textarea não aprova automaticamente contenteditable nem editores ricos do mesmo navegador.

Limite observado da identificação: o rascunho curto `holo my fruedm` continuou aguardando contexto mesmo com o fallback. A frase inglesa controlada passou pelo fluxo completo. Identificar idioma em texto muito corrompido permanece sujeito a ambiguidades; o modelo não resolveu todos os casos.

Outro limite confirmado na 0.6.1: um campo pode estar acessível e ainda assim o modelo recusar a revisão do conteúdo. A Apple descreve essas recusas e os limites da geração estruturada em [Improving the safety of generative model output](https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output). O LocalScribe agora encerra esses pedidos sem retry e mantém propostas do dicionário local quando disponíveis. Essa cobertura é indicada como somente ortográfica; não equivale a uma avaliação concluída de gramática ou sentido. A política do modelo não foi alterada.

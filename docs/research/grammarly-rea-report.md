# Análise do Grammarly Desktop com REA

Data: 23 de outubro de 2026. Alvo: `/Applications/Grammarly Desktop.app`.

Complemento: [análise das funcionalidades, configurações observadas e limitações](grammarly-functional-analysis.md).

O REA 6.5.0 foi usado para inventariar o aplicativo instalado, interpretar metadados Mach-O e plists, examinar assinatura e entitlements, analisar JavaScript e modelar a resolução de bibliotecas. A análise é estática: não iniciou o Grammarly, não capturou texto do usuário e não observou tráfego de rede.

O índice de metadados das evidências está em [grammarly-rea-evidence.json](evidence/grammarly-rea-evidence.json). Os identificadores abaixo permitem localizar os registros nesse arquivo.

## Resultado principal

O Grammarly Desktop é um aplicativo macOS nativo com componentes Swift/Objective-C e JavaScript embarcado. A biblioteca `GRAccessibilityKit` contém referências concretas às APIs de acessibilidade do macOS e de geração de eventos de teclado e mouse. Isso sustenta a interpretação de que a integração com campos de outros aplicativos pode usar acessibilidade e eventos sintéticos. Não estabelece quais chamadas ocorreram nesta máquina nem reconstrói a sequência completa de uma correção.

O executável principal carrega `ProjectLlamaContent.framework`, que concentra dependências de interface, rede, acessibilidade e outros módulos. Há serviços auxiliares separados para conteúdo web, onboarding, login, atualização e desinstalação.

## Identidade e assinatura

| Item | Observação |
|---|---|
| Versão declarada | 1.203.0, build 1.203.0.0 |
| Bundle ID | `com.grammarly.ProjectLlama` |
| Arquiteturas | `arm64` e `x86_64`; inspeção Mach-O selecionou `arm64` |
| macOS mínimo declarado | 11.0 |
| Classe principal declarada | `LlamaApplication` |
| Modo de apresentação | `LSUIElement: true`, compatível com aplicativo agente |
| Assinatura exibida | Developer ID Application: Grammarly, Inc |
| Team ID | `W8F64X92K3` |
| Hardened Runtime | Presente |

SHA-256 do executável principal: `d882a5217ae0bfd9d56605646c95ec1047684b3ea49b8b733539329492edb6cb`.

O exame da assinatura leu metadados de uma cópia de bytes verificada por digest. Não realizou validação completa de confiança, notarização ou integridade de toda a instalação. A assinatura observada não é, por si só, uma conclusão sobre segurança.

Evidências: `ev_8b129f2388c6887b517012be4cc4f535a654c204a31cb6fb2ee50d8811f4c5e3`, `ev_cce9cbcf2a4af4cde9a5615a7c1cae1cb976ff74a52688f6777c57ecb21ca8be`, `ev_f77c7d64f632ca01c45e0ca3f933cc2667e4c2dfe79512d49c7fbc7ae8a72756`.

## Estrutura do pacote

O inventário registrou 504 arquivos, 458 diretórios e 161 links simbólicos, com 1.123 ocorrências no grafo. A projeção Apple encontrou 53 ocorrências de bundles de frameworks, incluindo componentes repetidos em subaplicativos; isso não significa 53 bibliotecas distintas carregadas em uma execução.

Componentes identificados:

| Componente | Evidência e interpretação |
|---|---|
| `ProjectLlamaContent.framework` | Dependência direta do executável principal; concentra outros frameworks |
| `GRAccessibilityKit.framework` | APIs de acessibilidade e eventos; símbolos Swift para foco e seleção de texto |
| `GRNetwork.framework` | Camada de rede nativa com referências a HTTP e TLS |
| `Grammarly Desktop Web Content.xpc` | Plist confirma serviço XPC `com.grammarly.DesktopWebContent` |
| `GRLlamaOnboarding.xpc` | Serviço XPC identificado pelo inventário; função exata não foi rastreada |
| `GRLoginHelper.app` | Item em `Contents/Library/LoginItems`; plist declara execução apenas em segundo plano |
| `Grammarly Desktop Update Service.app` | Serviço separado, versão declarada 1.0.9; pacote também inclui Sparkle e Autoupdate |
| `Grammarly Desktop Helper.app` e Uninstaller | Aplicativos auxiliares presentes; execução e registro no sistema não verificados |
| `WebUI.framework` / `Superhuman Web UI.app` | Componentes de interface presentes; tecnologia interna não foi determinada |
| `AviNotetaker`, `Starwhisper`, recursos Dictation | Indícios por nomes de componentes de recursos de voz/anotações; disponibilidade e ativação não verificadas |

O pacote também contém módulos com nomes de autenticação, telemetria e armazenamento, como GROAuth2, GRPassport, GRAnalytics, Sentry e SQLite. A presença desses arquivos não determina o conteúdo coletado, enviado ou persistido.

Evidências: `ev_a3a261538c7ed50e89b55a8cdd719a3c022d6b64d2055bc1a76f3b8c12ef13e6`, `ev_02511de206fbbb2965645181811197676ec765bd3b1435999be545a277f48a31`, `ev_ea0099d887d85eacadb3ed72c5701aa46863dd41629ffd37d3454c08f9689626`, `ev_6fbdec0f1ba6308c78ecc080d40b70dd7d4ca6c41027e54cb06901cb5410ca63`, `ev_ab0dc338cae9ea1e97ef094b22477db7e925ed728fd7e576e63d248b4130a6aa`.

## Integração com texto e outros aplicativos

O REA encontrou no `GRAccessibilityKit` imports para:

- Verificar autorização de acessibilidade: `AXIsProcessTrusted`.
- Criar referências a aplicativos e elementos: `AXUIElementCreateApplication`, `AXUIElementCreateSystemWide`.
- Ler e alterar atributos: `AXUIElementCopyAttributeValue`, `AXUIElementSetAttributeValue`.
- Registrar notificações: `AXObserverAddNotification` e `AXObserverCreateWithInfoCallback`.
- Gerar e publicar eventos: `CGEventCreateKeyboardEvent`, `CGEventKeyboardSetUnicodeString`, `CGEventPost`, `CGEventPostToPid` e APIs de mouse/event taps.

Símbolos exportados incluem `focusedUIElement`, `selectedText` e `selectedTextChanged`. O demangler do REA confirmou assinaturas Swift para leitura do elemento em foco e notificação de seleção.

Interpretação: há suporte binário para observar elementos e seleções e atuar sobre a interface. Sem rastrear funções e execução, não é possível afirmar qual mecanismo é escolhido em cada editor, se a permissão está concedida ou quando os eventos são produzidos.

Uma leitura complementar do recurso instalado `GRLlamaCore.framework/Versions/A/Resources/IntegrationOptions.json` mostrou regras declarativas por domínio/campo. Exemplos incluem prevenção de integração duplicada com o SDK, marcadores `grammarly-desktop-enable` e `grammarly-desktop-disable`, e uma regra para Google Docs com `RequiresBrowserExtension: true`. O arquivo possui sintaxe que o parser JSON estrito rejeitou; os exemplos foram lidos como texto. A precedência e aplicação dessas regras não foram demonstradas.

Evidências REA: `ev_6e5ea4070363a9497fe8ca79fc0c581f281fccb8b4bd2f8720d0dec45cb599e3`, `ev_47c0708bf6163c3a5a774d57445d94baf75d026df9348a4b0ba09a22d6677679`, `ev_c36c55bdf07f0b560edc828e0821f8952070de02776b312782ba3f803ef8145d`.

## JavaScript embarcado

O REA analisou três arquivos em `ProjectLlamaContent.framework/Versions/A/Resources`: `runtime.js`, `GOSJavaScriptCoreMessageTransport.js` e `GOSJavaScriptNativeMethods.js`, totalizando 71.060 bytes. Os três foram interpretados sem falhas de parsing.

A leitura dos scripts de ponte mostra que:

- Mensagens são encaminhadas a `globalThis.gos_message_bridge.postMessage`.
- Mensagens recebidas são distribuídas a listeners com origem declarada `grammarly-message-handler://grammarly`.
- A ponte é exposta com os nomes `grammarlyMessagingBridge` e `grammarlyMessageBridge`.
- Console e timers são adaptados para chamadas em `gos_native_methods`.

Isso mostra uma interface entre JavaScript e funções fornecidas pelo host nativo. Não determina a implementação nativa da ponte, suas garantias de isolamento ou validação das mensagens. O escopo analisado não recuperou estruturas Electron; esse resultado limitado não classifica todos os subprocessos de interface.

A cobertura semântica do REA permaneceu parcial, com 1.525 lacunas de análise. Esses números descrevem limitações de reconstrução estática, não vulnerabilidades detectadas.

Evidência: `ev_b130351875bb3ef03ffd31e7708c8dc03629f6bf5f66f1eec9ced57df8dab556`.

## Rede, permissões e atualização

`GRNetwork` referencia Foundation, Network e Security. Seus exports incluem construção/manipulação de `URLRequest`, cabeçalhos HTTP e uma função `NWProtocolTLS.Options.setVerifier`. Isso indica infraestrutura para comunicação e verificação TLS; não prova pinning de certificados, a política de confiança efetiva ou os destinos usados.

O plist principal declara descrições de uso de microfone, captura de áudio e Apple Events. A assinatura contém entitlements de entrada de áudio e automação Apple Events, além de grupos de aplicação e Keychain. Não contém `com.apple.security.app-sandbox` nem `com.apple.security.get-task-allow` no conjunto retornado. Declarações e entitlements não mostram os consentimentos atualmente concedidos pelo usuário nem provam gravação ou automação em andamento.

O pacote inclui Sparkle, um atualizador separado e uma chave pública `SUPublicEDKey`. Isso é compatível com infraestrutura de atualização assinada. O fluxo completo de download, validação e instalação não foi reconstruído.

A resolução estática de bibliotecas encontrou candidatos anteriores de `@rpath` ausentes antes de caminhos de fallback presentes. São observações da ordem de busca modelada. Não constituem, isoladamente, uma vulnerabilidade confirmada: permissões do pacote, library validation e comportamento efetivo de dyld não foram validados.

Evidências: `ev_ac41a53ddc8a4492576944a6a8f6ded87dc815e025b31eef5880f9fdc1fa3077`, `ev_55f0953fe2ecff3c7dce4fb65a2eb4fcd8f1d3c29b233fdd1f575413bf571b26`, além dos registros de plist e assinatura citados acima.

## Cobertura e perguntas pendentes

| Pergunta | Estado |
|---|---|
| Qual aplicativo/versão está instalado? | Respondida para Grammarly Desktop |
| Quais componentes e bibliotecas o pacote contém? | Inventário completo dentro do escopo reportado pelo REA |
| Como pode integrar-se com campos de texto? | Parcialmente respondida por imports, exports e recursos; fluxo de execução pendente |
| Há JavaScript integrado ao host nativo? | Confirmado pelos scripts; implementação do host pendente |
| Quais permissões são declaradas? | Respondida para o aplicativo principal; consentimentos atuais desconhecidos |
| Quais textos/áudios são transmitidos e aonde? | Não determinado; não houve captura de execução ou rede |
| Como cada função implementa correção e políticas? | Não determinado; descompilação indisponível |
| O aplicativo é seguro ou malicioso? | Nenhuma conclusão global; esta análise não é uma auditoria de segurança completa |

O REA reportou Hopper ausente e Ghidra não configurado. Nenhuma ferramenta foi instalada e nenhuma configuração foi alterada. Assim, esta entrega não inclui pseudocódigo, grafos de chamadas de funções ou recuperação do código-fonte nativo.

Também foi localizado `/Applications/Grammarly for Safari.app`; a extensão ficou fora desta análise do Desktop.

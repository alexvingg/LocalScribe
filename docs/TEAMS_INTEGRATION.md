# Teams desktop: diagnóstico e ajuste

23/10/2026 · LocalScribe 0.7.4 · Teams `com.microsoft.teams2`, versão `26276.505.5234.9924`.

## Falha reproduzida

Com o Teams em primeiro plano, o diagnóstico da versão anterior não recebeu `AXFocusedUIElement` (erro `-25212`). Solicitar `AXManualAccessibility`, a ponte usada para Electron, devolveu `-25205` (atributo não suportado). O modelo local estava pronto e a permissão de Acessibilidade do LocalScribe estava válida.

O processo do Teams anuncia `AXEnhancedUserInterface` como gravável. A implementação agora tenta essa alternativa quando a solicitação manual falha e a capacidade está anunciada. A política de pausa/apps bloqueados continua sendo verificada antes dessa solicitação. Não há allowlist por nome de app.

## Evidência de leitura após ativação

O diagnóstico passou a observar `enhancedAccessibility=true` e um compositor `AXTextArea` com texto de 16 posições UTF-16, seleção `{16, 0}`, seleção e texto selecionado graváveis. A estratégia identificada foi `nativeInput`, por ser conteúdo web. Os 12 caracteres não brancos examinados tiveram geometria resolvida nos elementos internos; a geometria direta do campo não estava disponível. Nenhum conteúdo de conversa foi incluído neste registro.

A chamada que solicitou o atributo avançado devolveu `-25208`, embora a leitura seguinte mostrasse o atributo ligado; o diagnóstico conserva tanto o retorno bruto quanto o valor observado. O retorno isolado não é tratado como prova de sucesso. A evidência relevante é a capacidade efetivamente disponível depois.

Referências de implementação: `AXAccess.enableAccessibility(on:)` e `AccessibilityEditor.refresh()` em `Sources/LocalScribe/AccessibilityEditor.swift`; `EditorCapabilityCheck.run(bundleID:)` e `watch()` em `Sources/LocalScribe/EditorCapabilityCheck.swift`. Os diagnósticos registram capacidades, comprimentos e metadados, sem registrar o texto do campo.

## Cartão e aplicação confirmados

No rascunho de teste `hi my fryen ! how are u ?`, o cartão real apresentou `hi my friend ! How are you?`, com aplicação habilitada. Durante o teste, o processo GUI registrou cinco escritas no bundle do Teams: duas com `native-paste` e três com `native-text-input`, cada uma precedida de `selection-confirmed` e concluída com `verified`. A leitura final do compositor confirmou `hi my friend ! How are you?`, 27 posições UTF-16. Nenhuma tecla de envio foi usada pelo teste.

O diagnóstico final encontrou o Teams em primeiro plano, idioma inglês identificado e geometria interna disponível para 21 de 21 caracteres não brancos. O retorno do editor foi confirmado depois das aplicações.

## Limite da validação

Leitura, seleção, geometria, cartão de sugestão e aplicação foram verificados no compositor real. Aparência dos sublinhados, qualidade de reformulação gerada, Desfazer e outros compositores do Teams ainda precisam de validação específica. A automação de interface pode selecionar o campo em segundo plano; isso não equivale ao foco real exigido pelo monitor e pela aplicação segura de sugestões. Nenhuma mensagem de teste foi enviada.

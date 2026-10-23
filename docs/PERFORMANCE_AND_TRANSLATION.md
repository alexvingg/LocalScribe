# Revisão incremental, estrutura e tradução — 0.5

## Aceitar uma palavra

`WritingCoordinator.accept` confirma a escrita no editor e captura a continuação do mesmo campo. `SuggestionLedger.rebasing` verifica que o texto novo corresponde exatamente à alteração aceita, remove propostas sobrepostas, desloca os intervalos posteriores pela diferença UTF-16 e confirma o conteúdo de cada proposta preservada. Identificadores permanecem estáveis. Decisões de ignorar compatíveis também são reposicionadas.

Se a revisão anterior estava concluída e a aceitação foi de palavra, o novo estado é considerado concluído sem geração adicional. O resultado final da frase anterior alimenta o cache da frase parcialmente corrigida. Aceitar uma frase, editar um contexto incompleto ou falhar na confirmação do destino pode exigir análise; propostas compatíveis continuam presentes durante essa conferência. Uma mudança manual não verificada não recebe intervalos antigos por suposição.

## Uma chamada automática por bloco

Após pausa de 400 ms, o modelo retorna o texto corrigido e `issueScope` (`none`, `word`, `sentence`) em uma única resposta estruturada. Erros locais viram cartões por palavra; problemas claros de sintaxe ou sentido viram propostas de frase. Não há segunda geração automática de estilo. Reformulação e outra versão continuam explícitas. Um resultado ambíguo sem substituição segura pode mostrar um aviso sem permitir aplicar texto idêntico.

Blocos idênticos usam cache, inclusive resultados sem erros. Somente blocos sem resultado válido precisam do modelo. As instruções e o esquema têm suas contagens de tokens reutilizadas por idioma/tarefa; cada prompt continua sendo contado. A sessão é nova por geração e o orçamento de contexto permanece obrigatório. O app prepara o modelo ao iniciar. Esses ajustes reduzem trabalho; não tornam a geração instantânea nem garantem qualidade semântica.

## Tradução por clique

Preferência independente `translationLanguage`, padrão `pt`. Não altera o idioma automático de revisão nem invalida seu cache. O cartão de palavra traduz o trecho atual escrito; o cartão de frase traduz a proposta exibida. O menu permite traduzir o trecho atual sem uma proposta de correção.

O framework Apple Translation usa estratégia `.lowLatency` e `TranslationSession(installedSource:target:preferredStrategy:)`. O par é resolvido entre variantes regionais efetivamente instaladas (por exemplo, en-US/pt-BR), evitando depender da preferência regional do processo. Antes de traduzir, consulta `LanguageAvailability`: idioma instalado permite executar; idioma apenas suportado pede preparação; par incompatível informa a limitação. **Preparar idiomas** usa `prepareTranslation()` pelo fluxo oficial da Apple para instalar os recursos necessários. Um monitor verifica a instalação e evita deixar o botão preso em preparação indefinidamente.

A janela separada mostra progresso, resultado, copiar e fechar/Escape. Não existe ação de aplicar tradução ao editor. Idioma de origem igual ao destino exibe o original. Cancelamento, troca de campo e respostas tardias são controlados por identidade de pedido, com prazo de 25 segundos para a tradução. O cache é apenas em memória: 32 entradas, 10 minutos, orçamento de 32.000 unidades de texto, chave por texto/origem/destino/app. Bloqueios e mudanças de preferências limpam esse cache.

Recursos de idioma podem precisar de download pelo macOS. Texto traduzido e revisado não é enviado a um backend do LocalScribe. Copiar grava deliberadamente na área de transferência do sistema.

## Fontes e limites de evidência

- [Apple Translation](https://developer.apple.com/documentation/translation) e [tradução dentro do app](https://developer.apple.com/documentation/translation/translating-text-within-your-app).
- [Sessão com idiomas instalados](https://developer.apple.com/documentation/translation/translationsession/init(installedsource:target:)): tradução com recursos já presentes, sem depender de uma tarefa de view para executar cada tradução.
- O comportamento implementado é próprio. O algoritmo interno de cache, classificação ou inferência do Grammarly permanece **UNKNOWN**; nenhuma implementação ou recurso proprietário foi copiado.
- Resultados reais e pendências estão em [VALIDATION.md](VALIDATION.md). Detecção de incoerência é uma sugestão do modelo, sujeita a falsos positivos e omissões; não é prova de ausência de sentido.

# LocalScribe

MVP nativo de revisão de texto nos aplicativos do macOS. Swift + AppKit/SwiftUI, Natural Language para identificação de idioma e `SystemLanguageModel` para correção e melhoria local. Tradução sob demanda com o framework Apple Translation, usando idiomas instalados no dispositivo. Sem backend, conta do aplicativo, chaves de API ou serviços pagos.

## Requisitos

- macOS 26.4 ou posterior, Mac compatível com Apple Intelligence e modelo pronto no sistema.
- Command Line Tools/SDK com FoundationModels. Não há dependências de terceiros nem macros de geração.
- Permissão de Acessibilidade para **LocalScribe**, concedida pela pessoa nos Ajustes do Sistema. O app não concede essa permissão a si mesmo.

## Compilar e abrir

```sh
./scripts/build-app.sh
open dist/LocalScribe.app
```

O script produz um app com assinatura ad hoc em `dist/`. É uma distribuição local de desenvolvimento, ainda sem notarização. Atualizar a compilação pode exigir autorizar novamente o app em Acessibilidade, dependendo de como o macOS reconhecer a assinatura.

Para compartilhar a compilação existente, execute `./scripts/package-dmg.sh`. O pacote `dist/LocalScribe-0.7.6-arm64.dmg` inclui o app, um atalho para Aplicativos e `LEIA-ME.txt`. Para enviar mantendo também o ícone do arquivo, prefira `dist/LocalScribe-0.7.6-arm64.dmg.zip`, que preserva os metadados Finder. O instalador é para Apple Silicon; não inclui caches, preferências ou documentos do usuário. O Mac de destino precisa do modelo local da Apple disponível e de sua própria permissão de Acessibilidade. A imagem é de testes, sem assinatura Developer ID/notarização.

Na versão 0.7.6, o ícone verde é renderizado a partir de caminhos vetoriais, com representações próprias para cada tamanho e Retina. As configurações usam um PDF vetorial. O DMG recebe um ícone verde para o arquivo e um ícone embutido para o volume montado. Na barra de menus, uma versão vetorial monocromática do mesmo L com pena usa a renderização template do AppKit para acompanhar o tema e o destaque do sistema. A arte, o prompt e o processo de geração estão em [Support/Assets/DESIGN.md](ICON_DESIGN.md).

Na primeira abertura, use **Permitir Acessibilidade…** e habilite o app em Ajustes do Sistema → Privacidade e Segurança → Acessibilidade. Depois volte a um campo de escrita. O ícone de revisão fica na barra de menu.

## Uso

1. Mantenha Idioma em **Automático** e escreva em um campo compatível.
2. Após uma pausa, aguarde a revisão local. Passe o ponteiro sobre a marca vermelha para abrir uma correção. Marcas azuis indicam melhorias opcionais.
3. Para uma palavra, clique diretamente na correção no cartão compacto. Para frases, confira o original resumido e a proposta completa, sem palavras antigas intercaladas, e use **Aplicar sugestão**. O ícone de menos ignora; o menu **…** permite copiar.
4. **Control + Option + R** abre a primeira proposta para uso pelo teclado; Return aceita e Escape fecha. O atalho é fixo nesta versão.
5. Em Configurações → **Onde não revisar**, adicione/remova apps. O menu também permite **Desativar em [aplicativo]**. O bloqueio precede a leitura de conteúdo e vale para o navegador inteiro. O interruptor **Revisão durante a escrita** ligado indica revisão ativa.

**Reformular frase** considera a mensagem inteira quando ela tem até 800 posições UTF-16; para mensagens maiores, usa um contexto próximo da correção dentro desse limite. A versão inicial reúne as correções pendentes. O modelo tenta melhorar essa base com mudanças pequenas, preservando a ideia e a maior parte do texto. Se não houver outra versão segura, o cartão **Sugestão de texto** apresenta a base corrigida; se não houver mudança alguma, mostra o texto preservado com Aplicar desabilitado. O resultado não fica vazio apenas por faltar uma paráfrase. A proposta completa passa por conferência de gramática, maiúsculas e pontuação antes de ser exibida, inclusive quando não há paráfrase nova. O cartão explica quando mostra uma versão sem geração nova. **Outra versão** mantém a mesma regra e não exige novidade artificial. Há verificações adicionais de proximidade de palavras, pessoas mencionadas, negação, números/links e gírias; elas reduzem alguns riscos, mas não provam equivalência de sentido. Nenhuma sugestão é aplicada automaticamente.

Problemas claros de estrutura ou sentido são avaliados automaticamente junto com a gramática. Eles abrem um cartão **Revisar sentido e estrutura**, com comparação da frase e aplicação explícita. Erros locais continuam em cartões por palavra. O modelo pode errar essa classificação; uma mensagem de possível ambiguidade não equivale a uma correção comprovada.

A versão 0.6.1 oferece uma primeira camada de ortografia pelo dicionário do macOS, usando o idioma identificado. Correções locais aparecem enquanto o modelo avalia a frase. Recusas de conteúdo da Apple encerram a revisão de frases daquele trecho, sem repetir a chamada automaticamente; as sugestões ortográficas continuam disponíveis e o status informa a cobertura limitada. Isso não garante correção de todos os erros nem reformulação de conteúdo recusado. O cache guarda o resultado combinado para preservar correções aceitas. Nomes com inicial maiúscula não recebem propostas dessa camada rápida; links, e-mails e números são protegidos.

Na versão 0.7.5, aceitar uma proposta inteiramente revisada reutiliza o resultado exato, sem iniciar outra geração para o mesmo texto. Propostas independentes permanecem; as sobrepostas e a pontuação já coberta pela frase são consumidas. Fallbacks por erro/timeout continuam parciais e não recebem essa cobertura. Os detalhes e testes estão em [PROPOSAL_STABILITY.md](PROPOSAL_STABILITY.md).

Uma reformulação mantém as correções de palavras pendentes. Gerar uma proposta não significa aceitá-la; as marcas são reavaliadas quando o texto é realmente alterado. **Ignorar** remove apenas a proposta escolhida.

Ao concluir a reformulação, o cartão original deixa o estado de carregamento e a proposta completa fica protegida contra o hover residual sobre a palavra antiga. Fila e geração têm limite de 25 segundos cada. Se a geração expirar, o cartão apresenta a base com as correções já disponíveis, com aviso. Uma resposta tardia não substitui esse resultado. Um cartão fechado não é reaberto por uma resposta em segundo plano. O framework pode levar tempo para encerrar uma geração cancelada; outra reformulação aguarda esse encerramento.

O app nunca aceita uma proposta automaticamente. Ao aplicar, mostra **Aplicando no editor…**, confirma seleção/texto/destino e bloqueia cliques repetidos. Falhas permanecem no cartão. Correções independentes mantêm marcas e identidades após aceitar uma palavra; propostas sobrepostas são invalidadas. Uma análise automática já iniciada pode concluir e guardar o resultado exato em cache após mudar de foco ou texto, mas não publica uma resposta antiga nem escreve no editor. Pausa, bloqueio, troca de política e encerramento cancelam o trabalho e impedem esse armazenamento. Só uma geração de revisão é executada por vez; a próxima revisão usa o contexto mais recente. A tradução solicitada por clique tem uma sessão separada.

**Traduzir** expande a tradução dentro do próprio cartão, abaixo da sugestão, usando Configurações → **Traduzir para** (Português por padrão). Traduz exatamente a palavra corrigida ou a frase proposta que você está vendo. O cartão mantém Aplicar e as correções pendentes; mostra progresso e falhas no mesmo lugar, com copiar, ocultar e tentar novamente. Nenhuma tradução começa ao passar o ponteiro. O menu da barra de status também permite traduzir o trecho atual, mesmo sem erro; esse fluxo mantém sua janela independente. A tradução só acontece ao clicar e não substitui o texto. A versão 0.8.0 usa o modelo local da Apple Intelligence para traduzir, sem pacotes adicionais por idioma. Veja [LOCAL_TRANSLATION_AND_LOCALIZATION.md](LOCAL_TRANSLATION_AND_LOCALIZATION.md). Um idioma indisponível não impede as correções.

## Escopo e limites

A arquitetura comum, as evidências REA e a cobertura por aplicativo estão em [INTEGRATION_ARCHITECTURE.md](INTEGRATION_ARCHITECTURE.md). A versão 0.7.0 confirma leitura e aplicações nativas no Slack durante esta sessão. No Teams desktop, a versão 0.7.4 solicita a ponte AXEnhancedUserInterface quando AXManualAccessibility não é suportado; leitura, seleção, geometria, cartão e aplicação foram verificados no compositor real, com leitura final do texto corrigido. Desfazer e outros campos do Teams continuam pendentes; Safari e Firefox ainda precisam de validação real. A busca de foco contempla contêineres HTML com um único editor explicitamente focado, sem escolher arbitrariamente o primeiro campo da página.

- O protótipo lê o campo focado por Acessibilidade, observa notificações e usa verificação periódica como complemento. Não intercepta todas as teclas, não usa OCR e não injeta código em outros apps.
- A região ativa tem até 6.000 posições UTF-16. Parágrafos maiores selecionam uma região próxima do cursor. Até quatro blocos de até 800 posições são revisados por vez, preferindo frases completas e separações entre palavras. Campos acima de 200.000 posições são recusados pelo protótipo. A revisão se concentra na escrita ativa, sem examinar todo o documento automaticamente.
- Cada bloco usa uma sessão nova e contagem real de tokens de instruções, prompt e esquema, com reserva para resposta. Um token sem separações que exceda o tamanho do bloco é excluído da geração. Blocos parciais usam o rótulo **Reformular trecho**, e a revisão gramatical entre blocos tem limitações. Veja [CHUNKING_AND_PENDING_EDITS.md](CHUNKING_AND_PENDING_EDITS.md) para limites e fontes oficiais.
- Português e inglês são os alvos iniciais de avaliação. O modelo instalado pode aceitar outros idiomas; suporte informado pelo sistema não comprova qualidade linguística. Texto curto ou ambíguo aguarda contexto. Frases de idiomas diferentes são analisadas separadamente; mistura dentro da mesma frase continua sendo uma limitação.
- Os sublinhados dependem de coordenadas e texto disponibilizados pelo editor. Campos web ricos do Chrome podem exigir coordenadas dos elementos internos de texto; o app valida a correspondência desses segmentos antes de desenhar. A aplicação nativa depende de atributos de seleção/texto graváveis. A estratégia agora depende das capacidades do campo: conteúdo web em qualquer aplicativo usa entrada nativa verificada; campos nativos graváveis usam Acessibilidade. O setter de texto selecionado não foi suficiente no WhatsApp Web. O ensaio real confirmou aplicação de palavra e frase nesse editor. O monitor também ativa a ponte de Acessibilidade de apps Electron. Outros aplicativos ainda precisam de validação real; a seleção de estratégia não é uma certificação de compatibilidade.
- Nos campos que usam o adaptador de entrada nativa, propostas curtas usam Unicode do macOS; propostas que exigiriam mais de um evento usam uma única colagem para preservar uma operação de Desfazer. A colagem salva os formatos existentes da área de transferência, publica temporariamente a proposta e restaura o conteúdo anterior se nenhuma outra cópia ocorreu. Texto com quebras de linha ou caracteres de controle é recusado nesse adaptador; nenhuma tecla Return é enviada. Não há substituição cega do campo inteiro. Se o host não permite escrita ou a confirmação falha, o app informa isso e oferece copiar a proposta.
- O resultado do modelo pode conter falsos positivos ou reescritas inadequadas. As verificações de intervalos, idioma e números/URLs reduzem alguns riscos, mas não garantem preservação semântica. Nenhuma porcentagem de confiança gramatical é apresentada.
- Quando a posição exata dos caracteres não é fornecida pelo aplicativo, aparece um indicador azul com a quantidade de propostas no canto do campo/janela. Passe o ponteiro para abrir os cartões; o indicador não representa um sublinhado estimado sobre uma palavra. Sem texto/seleção acessíveis não é possível revisar/aplicar com segurança.
- O estado da revisão aparece nas configurações junto de **Revisar agora**. Falhas transitórias recebem até duas novas tentativas, sem repetir uma escrita já enviada. Identificação rápida de idioma inconclusiva pode consultar o modelo local quando há contexto suficiente, com cache em memória e sem escolher um idioma padrão.
- A geração demora segundos e não ocorre a cada tecla. A análise automática usa uma chamada por bloco para gramática e estrutura, com pausa de 400 ms antes de iniciar; a duração do modelo continua sendo de segundos. Reformulações de estilo são pedidas explicitamente, sem uma segunda geração automática. A geração de alternativas continua sujeita à capacidade e disponibilidade do modelo local.
- Desfazer e preservação de formatação dependem do aplicativo de origem e precisam de validação por editor. O app não fornece um histórico próprio de desfazer.

## Dados

Preferências locais em `UserDefaults`, domínio `dev.localscribe.mac`: modo de idioma (Automático por padrão), idioma de tradução (Português por padrão), pausa, lista de apps bloqueados e indicação de primeira abertura. Texto, propostas e sessões não são gravados pelo app nem enviados a um backend. A geração usa explicitamente o modelo no dispositivo, sem ferramentas de rede ou provedor de nuvem. Download/atualização do modelo é responsabilidade do macOS. Copiar coloca deliberadamente o texto na área de transferência compartilhada do sistema.

Uma geração já em execução pode levar tempo para cancelar. Bloquear um app impede novas leituras/análises, oculta sua interface e invalida a resposta pendente; o framework pode manter recursos até o encerramento dessa chamada.

Ao minimizar/restaurar ou alternar de aplicativo, o cache em memória preserva revisões concluídas, resultados sem erros, decisões de ignorar e alternativas da mesma revisão. O prazo é de **10 minutos**, com limites de **12 revisões de campos** e **64 resultados de frases**, além de um orçamento de texto. A restauração completa exige o mesmo campo, texto e configuração; posições na tela são recalculadas. Texto alterado não reutiliza intervalos antigos, mas frases ainda idênticas podem aproveitar os resultados anteriores. Fechar o processo, mudar a política de revisão, pausar ou bloquear um app apaga os caches de revisão. Alterar apenas o destino de tradução preserva as revisões e limpa o cache de tradução. Traduções têm cache separado de 32 entradas por até 10 minutos, limitado por custo de texto, sem persistência em disco. **Revisar agora** também limpa o cache e força nova análise. Não há cache de texto em disco.

Se o editor recriar a identidade de Acessibilidade do campo, a restauração completa pode não ser possível; resultados de frases idênticas ainda podem ser reutilizados. A política e a distinção das evidências do Grammarly estão em [CACHE_BEHAVIOR.md](CACHE_BEHAVIOR.md).

## Verificação

```sh
swift run --disable-sandbox --build-system native -debug-info-format none WritingCoreChecks
dist/LocalScribe.app/Contents/MacOS/LocalScribe --diagnose
dist/LocalScribe.app/Contents/MacOS/LocalScribe --language-fallback-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --spelling-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --rewrite-message-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --model-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --model-matrix
dist/LocalScribe.app/Contents/MacOS/LocalScribe --cache-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --chunk-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --word-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --experience-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --translation-smoke
```

Os 60 testes do núcleo incluem Unicode, intervalos, idiomas, bloqueios, alternativas, cache, preservação de correções pendentes, blocos longos, orçamento, separadores entre frases, agrupamento de palavra/pontuação aceitação incremental de correções e o ciclo dos cartões: resultado, hover residual, fechamento, falha, cancelamento e resposta tardia. A matriz executa seis casos artificiais no modelo instalado, incluindo duas alternativas consecutivas. Os ensaios `--cache-smoke`, `--chunk-smoke`, `--word-smoke`, `--experience-smoke` e `--translation-smoke` usam armazenamento/modelo reais e dados artificiais; não testam um editor externo. Não medem uma qualidade geral de gramática; sugestões opcionais podem variar entre execuções.

Em **Exemplos e diagnóstico**, os botões **TextEdit**, **Sublime Text** e **Chrome** criam arquivos temporários artificiais. **Ver cartões** abre uma prévia dos componentes reais com exemplos estáticos de palavra, frase, carregamento e ausência de alternativa; essa prévia não escreve em outros apps e não testa a integração com o editor. A opção `--preview-cards` abre a prévia sem iniciar a captura de editores. `--preview-translation` exercita o serviço e a janela reais de tradução com uma frase artificial, também sem capturar editores. Também é possível usar `Fixtures/demo.txt` e `Fixtures/editor.html`. Confirme sublinhados, cartão, aceitação, rolagem, mudança de foco e desfazer. Bloqueie TextEdit durante uma geração: as marcas devem desaparecer e a resposta antiga não pode reaparecer. Remova o bloqueio e faça uma nova revisão. Teste o mesmo ciclo em um `textarea` do Chrome. Diferencie as marcas do LocalScribe das de outros corretores instalados.

Os resultados efetivamente obtidos nesta sessão estão em `VALIDATION.md`. O ciclo real de cartão e aceitação incremental foi confirmado no exemplo do TextEdit na versão 0.5. A versão 0.5.1 confirmou coordenadas de caracteres e cartão/tradução no WhatsApp Web/Chrome, incluindo o caminho de geometria para contenteditable. Aceitação de palavra/frase e Desfazer foram confirmados no WhatsApp na versão 0.5.3; cada nova integração precisa de seu próprio ensaio. O app é um protótipo e ainda não deve ser apresentado como compatível com todos os aplicativos.

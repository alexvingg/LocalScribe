# Correção pontual e sugestão de frase — análise da evidência REA

Data: 23/10/2026. Objetivo: explicar a distinção vista nas duas capturas fornecidas pelo usuário e traduzi-la em requisitos independentes para o MVP local. Não houve cópia de implementação ou assets.

## Conclusão

As evidências sustentam **correções de texto, melhorias/reformulações e uma capacidade descrita de agrupar correções da mesma frase**. Elas não revelam a regra interna que seleciona uma dessas rotas.

O tamanho do cartão não determina o tipo linguístico. Um cartão pode mostrar uma frase como contexto para uma alteração pequena ou para várias correções agrupadas. Uma correção gramatical pode envolver mais de uma palavra; uma melhoria opcional pode alterar só uma palavra.

Por isso, precisamos separar:

1. **Intenção:** corrigir um problema ou oferecer uma melhoria opcional.
2. **Alvo de substituição:** uma ocorrência, trecho, conjunto relacionado de alterações ou frase.
3. **Contexto mostrado:** palavra/trecho compacto ou frase com comparação.

Essa separação é uma conclusão de projeto a partir das evidências, não um esquema de dados recuperado do Grammarly.

## O que está confirmado e o que permanece aberto

| Achado | Status | Evidência e limite |
|---|---|---|
| Correção pontual `ola → Olá` junto à palavra em texto português | OBSERVADO na imagem | V2 em `APPLE_INTELLIGENCE_PLAN.md`. A imagem é estática: não comprova a aceitação, a detecção de idioma nem o algoritmo. |
| Cartão com frase, remoções riscadas e inserções destacadas | OBSERVADO na imagem | V1 no plano. O contexto visível é uma frase e há alterações distribuídas. Não comprova que a operação substitua a frase inteira internamente. |
| Correções por capitalização, concordância e escolha de palavra | OBSERVADO em execução anterior | `CLONE_SPEC.md`, BB-002–005 / O-CHROME. Inclui `I has → I have`, aceito com mudança do texto e contagem 5 → 4. |
| Categorias distintas de correção e clareza | RESOURCE-CONFIRMED | R-WR, chaves `Correctness (writing category tab)` e `Clarity (writing category tab)`. Não fornece regra de classificação nem limiar. |
| Agrupamento de correções na mesma frase | RESOURCE-CONFIRMED | R-WR, chave `Suggestion bundles` e descrição que nomeia ortografia, pontuação e gramática na mesma frase. O agrupamento e a aceitação parcial não foram exercitados. |
| Ações de reformular e reescrever | RESOURCE-CONFIRMED | R-WR, chaves `Rephrase (suggestion card button)`, `Rewrite (suggestion card button)`, `Accept this rewrite` e `Rewrites for clarity`. A existência dessas ações não prova que V1 use essa mesma rota. |
| Recursos para obter intervalos de frase e parágrafo no texto acessível | SÍMBOLOS CONFIRMADOS | E-AX e nova demangling D-SEG, descritas abaixo. São evidência de capacidade da camada de Acessibilidade, não do classificador linguístico. |
| Decisão automática entre as rotas e seleção do cartão | UNKNOWN | Não há requisição/resposta capturada nem função de decisão decompilada. |

V1 é compatível com uma melhoria estilística, considerando a frase antes/depois, mas atribuí-la a uma categoria interna específica seria INFERÊNCIA. O selo comercial não identifica o algoritmo e não deverá existir no MVP.

## Evidência técnica com localizadores

**R-WR:** REA `ev_6733be18d1dc3d8e919d444ddc4facdbdf9013707e01d5f56c426ef84e17d984`, operação `inspect_plist`, recurso:

`/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Resources/en-US.lproj/Localizable.strings`.

Foram reconferidas nesta análise as chaves de categorias, agrupamento e reescrita listadas acima. A identidade retornada é a mesma do levantamento anterior. A descrição de bundles é especialmente relevante: demonstra que “cartão de frase” e “reescrita de frase” não podem ser tratados como sinônimos só pela aparência.

**E-AX:** REA `ev_6e5ea4070363a9497fe8ca79fc0c581f281fccb8b4bd2f8720d0dec45cb599e3`, operação `inspect_macho`, exportações da fatia ARM64 de GRAccessibilityKit:

| Endereço registrado | Símbolo demangled |
|---|---|
| `0xb9cc` | `GRAccessibilityKit.AccessibilityParameterizedAttributeKey.sentenceTextMarkerRangeForTextMarker.getter` |
| `0xb5dc` | `GRAccessibilityKit.AccessibilityParameterizedAttributeKey.paragraphTextMarkerRangeForTextMarker.getter` |

Os endereços são os registrados pelo inspetor para essa imagem/fatia, não endereços absolutos de um processo em execução. Os getters representam chaves de atributos, não funções de classificação de erros.

**D-SEG:** nova operação REA `demangle_swift`, Evidence `ev_d305534ae6725eece7d42d468b6607d0b82e2fd12c13f0259dbe10ceca491403`, confirmou os nomes acima. O executável principal do alvo continua com SHA-256 `d882a5217ae0bfd9d56605646c95ec1047684b3ea49b8b733539329492edb6cb` ao reabrir o pacote.

**Limite de cobertura:** a sessão REA antiga não estava retida no servidor; os registros exportados foram reutilizados, os recursos foram reconferidos e os dois símbolos foram demangled novamente. Não houve nova análise dinâmica de sugestões, interceptação de rede ou recuperação da implementação do motor. O executável principal identificado na demangling não significa que os getters pertençam a ele: a localização das exportações vem do registro de GRAccessibilityKit, E-AX.

## Leitura dos dois exemplos

No exemplo `ola eu sou tesx`, o alvo visível é `ola`; o cartão propõe `Olá`. A língua precisa ser inferida do contexto. A correção é pontual, mas a análise linguística não precisa se restringir àquela palavra. A imagem não autoriza corrigir `tesx`, que pode representar um nome ou outro termo desconhecido.

Na imagem com a frase sobre atalho e botão Copiar, o cartão mostra o contexto completo e distribui remoções/inserções dentro dele. Isso estabelece uma apresentação por frase. Não estabelece se o resultado veio de uma sugestão de clareza, de uma geração de reescrita ou de um grupo de propostas, nem se a escrita de volta é uma substituição única ou várias operações.

Um contraexemplo observado é `I has → I have`: a proposta contém mais de uma palavra na apresentação, mas é uma correção de concordância. Logo, uma regra como “mudou várias palavras, então é estilo/reformulação” seria inadequada.

## Tradução para o MVP: regra própria proposta

### 1. Entender a unidade antes de escolher o cartão

Detectar a língua do trecho com contexto próximo, identificar frase/parágrafo e preservar a identidade da revisão do campo. Sempre separar contexto usado para compreender o texto do alvo que será substituído. Acesso ao intervalo da frase não significa que toda ela deva ser modificada.

### 2. Gerar propostas com intenções separadas

O caminho de **correção** pede mudanças mínimas de ortografia, concordância e pontuação. O caminho de **melhoria opcional** pede uma reformulação útil, preservando língua, fatos e intenção, e pode retornar nenhuma proposta. Não gerar uma reescrita obrigatória para toda frase correta.

Para corresponder à experiência solicitada, correções são avaliadas automaticamente após pausa; uma candidata de melhoria pode ser avaliada em segundo plano quando a frase estiver estável, com prioridade menor. A solicitação de mais alternativas permanece explícita. Esse agendamento é decisão do novo produto; o gatilho original continua UNKNOWN. Medir desempenho antes de ativar uma segunda chamada frequente.

### 3. Determinar o alvo e a apresentação

O aplicativo calcula o diff e vincula as alterações ao snapshot, sem aceitar offsets inventados pelo modelo. Manter intenção, alvo e contexto como propriedades independentes:

| Proposta | Intenção | Substituição | Apresentação proposta |
|---|---|---|---|
| `ola → Olá` no contexto português | Correção | Uma ocorrência | Cartão compacto junto à palavra |
| `I has → I have` | Correção | Trecho mínimo necessário | Cartão compacto com contexto suficiente |
| Várias correções independentes na mesma frase | Correção | Ocorrências individuais; agrupamento de revisão opcional | Marcas individuais; o cartão pode mostrar a frase |
| Concordância com mudanças relacionadas em pontos diferentes | Correção | Grupo de alterações dependentes | Cartão de frase com diff e aceitação do grupo |
| Reformulação para clareza/concisão | Melhoria opcional | Frase/trecho aprovado | Cartão de frase com diff |

O tamanho do diff pode ajudar a selecionar uma apresentação legível, mas **não define se algo está gramaticalmente errado**. Categoria e justificativa do modelo também precisam de avaliação; não constituem prova linguística.

### 4. Resolver conflitos e aceitar

Priorizar correções sobre melhorias opcionais que se sobreponham ao mesmo trecho. Quando o texto for corrigido, invalidar/recalcular a melhoria baseada na versão anterior. Não mostrar propostas contraditórias como se fossem independentes.

Aceitar uma proposta aplica somente seu alvo e suas alterações relacionadas. Um agrupamento não deve permitir aceitação parcial quando isso quebra uma correção que depende de outras mudanças. Revalidar texto, idioma e destino antes da escrita; suprimir a aplicação se essa correspondência não for confiável. Definir e testar explicitamente a política de dependências do novo produto: o comportamento original não foi recuperado.

## Questões que o levantamento ainda não responde

- Qual função, modelo, servidor ou regra do Grammarly decide categoria, alvo, agrupamento e layout.
- Se há um único motor com metadados ou caminhos independentes de correção e geração.
- Quais limites de tamanho, pontuação de clareza, confiança, preferência e contexto mudam o cartão.
- Qual rota produziu V1 e como ela foi disparada.
- Os campos, offsets, unidades e tipos reais de mensagens de sugestões.
- Se o idioma é decidido antes do envio, no serviço, por trecho ou por documento.

Para resolver essas questões seria necessário observar um teste controlado com texto sintético e dados de sugestão correlacionados à interface, ou localizar uma função de decisão com análise nativa disponível. O presente relatório não afirma que isso já aconteceu. O modelo Apple também terá de ser avaliado para as duas intenções; a classificação proposta ainda não foi implementada.

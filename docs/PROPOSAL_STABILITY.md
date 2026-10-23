# Propostas completas e revisão após aceitar

23/10/2026 · LocalScribe 0.7.5, build 21.

## Falha observada

O cartão podia apresentar `hi my friend ! How are you?` como combinação das correções disponíveis, sem revisar essa combinação por inteiro. Aceitar uma proposta de estilo invalidava a revisão anterior e iniciava outra análise. Essa segunda chamada encontrava ajustes de maiúscula, vírgula e espaçamento que deveriam ter sido considerados antes de oferecer a frase. Inserções de pontuação no limite final de uma passagem também podiam sobreviver à substituição da passagem inteira.

## Alteração

- `LocalModelService.preparedAlternative` revisa a proposta completa, inclusive quando o gerador não oferece uma paráfrase. Essa conferência mantém os limites de tamanho, idioma, fidelidade, conteúdo protegido e registro. A instrução de correção inclui maiúsculas, vocativos e espaçamento de pontuação apropriados ao idioma.
- Somente uma proposta que concluiu essa revisão recebe `hasReviewedReplacement`. Respostas parciais por erro ou timeout não recebem essa cobertura. O limite total de espera continua em 25 segundos.
- Após escrita confirmada, `ReviewSessionCache.rememberReviewedReplacement` guarda o resultado exato dos blocos inteiramente cobertos pela proposta aceita. Um trecho no meio de uma frase não certifica o contexto ao redor. Alterar texto, idioma ou aplicativo não reutiliza essa identidade indevidamente.
- Se a revisão anterior estava concluída e a substituição cobre os blocos afetados, a aplicação termina sem outra geração. Propostas independentes permanecem com os mesmos identificadores; propostas sobrepostas são consumidas pela aceitação. Uma frase inteira também consome inserções de pontuação nos seus limites; aceitar uma palavra continua preservando pontuação independente.
- O comando explícito **Revisar agora** pode solicitar nova avaliação. O cache é temporário e não constitui prova de perfeição linguística do modelo.

## Validação

`WritingCoreChecks`: 62 verificações, zero falhas. Inclui aceitação de passagem com correções independentes, cobertura preservada no reposicionamento e pontuação no limite de palavra versus passagem.

`--proposal-stability-smoke`, modelo local real:

| Entrada da proposta | Resultado antes da exibição |
| --- | --- |
| `hi my friend ! How are you?` | `Hi, my friend! How are you?` |
| `She goes to school every day.` | `She attends school every day.` |
| `Olá, meu amigo ! Como você está ?` | `Olá, meu amigo, como você está?` |

Nos três casos, os blocos aceitos foram reutilizados sem chamada adicional ao modelo. O teste também rejeitou cobertura de um fallback não revisado e de um contexto maior que o trecho substituído. Esses testes de serviço não escrevem em um editor externo.

No teste assistido no compositor real do Teams, o processo GUI da versão 0.7.5 registrou:

```text
editor-write phase=selection-confirmed bundle=com.microsoft.teams2
editor-write phase=verified adapter=native-paste bundle=com.microsoft.teams2
editor-review phase=reused-reviewed-proposal bundle=com.microsoft.teams2 remaining=0
```

Esse registro confirma escrita e reutilização da revisão com zero propostas pendentes naquele caso. A verificação usou os registros do próprio app e diagnósticos restritos ao campo focado; não exige inspecionar o histórico de conversas.

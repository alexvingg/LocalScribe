# Documentação do LocalScribe

Os documentos preservam a evolução do projeto. Relatos e planos antigos descrevem a versão indicada em cada arquivo; o [README principal](../README.md) resume a versão do código, 0.8.1 (ainda não publicada em release).

## Especificação e planejamento

- [CLONE_SPEC.md](CLONE_SPEC.md): levantamento de referência, requisitos observáveis e evidências; itens não confirmados permanecem UNKNOWN.
- [APPLE_INTELLIGENCE_PLAN.md](APPLE_INTELLIGENCE_PLAN.md): viabilidade, desenho do MVP, idioma automático e integração transparente.
- [GRAMMARLY_SUGGESTION_ANALYSIS.md](GRAMMARLY_SUGGESTION_ANALYSIS.md): diferença entre correções de palavra, frase e reformulação.
- [IMPLEMENTATION.md](IMPLEMENTATION.md): notas detalhadas de implementação, configuração, testes e limites.

## Arquitetura e comportamento

- [TEXTEDIT_SHOWCASE.md](TEXTEDIT_SHOWCASE.md): teste real de um texto inglês de 112 palavras e evidências das capturas do README.

- [LOCAL_TRANSLATION_AND_LOCALIZATION.md](LOCAL_TRANSLATION_AND_LOCALIZATION.md): tradução com o modelo geral local e interface no idioma do macOS.

- [INTEGRATION_ARCHITECTURE.md](INTEGRATION_ARCHITECTURE.md): integração comum de Acessibilidade e cobertura por editor.
- [TEAMS_INTEGRATION.md](TEAMS_INTEGRATION.md): diagnóstico e ativação da ponte de Acessibilidade do Teams.
- [CACHE_BEHAVIOR.md](CACHE_BEHAVIOR.md): cache em memória, retomada e invalidação.
- [CHUNKING_AND_PENDING_EDITS.md](CHUNKING_AND_PENDING_EDITS.md): orçamento do modelo, revisão por trechos e preservação de propostas.
- [PERFORMANCE_AND_TRANSLATION.md](PERFORMANCE_AND_TRANSLATION.md): revisão incremental e tradução sob demanda.
- [PROPOSAL_STABILITY.md](PROPOSAL_STABILITY.md): revisão da proposta antes de exibir e reutilização após aceitar.
- [ICON_DESIGN.md](ICON_DESIGN.md): evolução do ícone, desenho vetorial, marca da barra de menus e empacotamento.
- [VALIDATION.md](VALIDATION.md): histórico de ensaios e limitações observadas.

## Pesquisa e evidências

- [Relatório técnico REA](research/grammarly-rea-report.md).
- [Análise funcional](research/grammarly-functional-analysis.md).
- [Inventário dos artefatos](research/ARTIFACTS.md).
- [Índice de evidências técnicas](research/evidence/grammarly-rea-evidence.json).
- [Índice de evidências funcionais](research/evidence/grammarly-functional-evidence.json).
- [Observações estruturadas](research/evidence/grammarly-clone-observations.json).
- [Índice de evidências de integração](grammarly-integration-evidence.json).
- [Snapshot textual do teste sintético](research/grammarly-live-observation.txt).
- [Documento sintético do TextEdit](research/grammarly-textedit-test.rtf).
- [Experimento inicial com Apple Intelligence](experiments/apple-intelligence-writing-probe.swift).

Os índices conservam identificadores, operações, hashes e localizadores. Os payloads brutos que contêm implementação, catálogos originais ou dados internos da ferramenta não são redistribuídos. Capturas da interface própria ficam em [images/](images/).

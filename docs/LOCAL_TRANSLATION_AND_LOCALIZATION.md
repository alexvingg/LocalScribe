# Tradução e idioma da interface — 0.8.0

## Tradução pela Apple Intelligence

`LocalTranslationEngine` usa explicitamente `SystemLanguageModel.default` e uma `LanguageModelSession` nova por bloco. O app não importa mais `Translation`, não consulta `LanguageAvailability`, não prepara sessões de tradução e não pede pacotes adicionais por idioma. O modelo geral da Apple Intelligence ainda precisa estar habilitado, baixado e disponível no Mac.

O botão **Traduzir** continua opcional. Em um cartão ele traduz `WritingSuggestion.translationText`, isto é, a proposta mostrada; no menu pode traduzir o trecho escrito. Mostra carregamento, resultado selecionável, copiar, ocultar e tentar novamente no mesmo fluxo. A tradução não escreve no editor nem aceita a proposta.

O idioma de destino é a preferência `translationLanguage`, independente do idioma da interface e da detecção do texto. Valores salvos são preservados. O destino padrão continua português; mudar o idioma da interface não muda essa preferência. Os seletores exibem os idiomas informados pelo modelo instalado, com nomes no idioma da interface. Suporte do modelo não é uma certificação da qualidade das traduções.

Entradas têm até 6.000 posições UTF-16; são divididas em frases/blocos de até 800, com até 32 blocos e contagem real de tokens antes de cada chamada. Tokens sem separação que excedem esse limite são recusados. A resposta é estruturada, com amostragem greedy, e deve preservar números, URLs e e-mails. O app preserva os separadores do texto original e recusa respostas vazias, expansão exagerada e idioma claramente incompatível. As instruções pedem fidelidade ao sentido, tom, negação, nomes e perguntas, mas essas características não têm garantia semântica automática.

O prazo total é 45 segundos. Fechar, trocar de contexto, mudar preferências ou bloquear um app cancela/invalida o pedido; respostas tardias não reabrem um cartão nem substituem o estado atual. O cache continua apenas em memória, por texto/origem/destino/app, 32 entradas, até 10 minutos e custo de 32.000 unidades. Não há download de tradutor ou fallback de nuvem escondido.

## Arquivos de localização

- `Sources/WritingCore/Resources/en.lproj/Localizable.strings`: inglês e fallback.
- `Sources/WritingCore/Resources/pt.lproj/Localizable.strings`: português, também usado para pt-BR e pt-PT.
- `Sources/WritingCore/L10n.swift`: consulta o bundle, formata mensagens e localiza nomes dos idiomas.
- `scripts/check-localizations.py`: verifica cobertura das chaves e correspondência dos placeholders.

Menus AppKit, configurações SwiftUI, cartões, acessibilidade, status e mensagens de erro usam `L10n.text`/`L10n.format`. Os arquivos usam as mensagens portuguesas como chaves estáveis. Argumentos variáveis (nomes de apps, texto original e contagens) são parâmetros, sem construir uma chave a partir de dados do usuário. Nomes próprios e textos de teste/revisão não são traduzidos como interface.

O Swift Package tem `defaultLocalization: "en"`; `Info.plist` anuncia inglês e português. A preferência de idioma do macOS (inclusive uma escolha por aplicativo) seleciona os recursos. O primeiro idioma preferido com catálogo é usado; se nenhum estiver disponível, usa inglês. Mudar o idioma requer reabrir o app, como em outros aplicativos nativos; o LocalScribe não altera ajustes do sistema. A configuração de idioma da região não precisa coincidir com o idioma preferido da interface.

O script de build copia `LocalScribe_WritingCore.bundle` para `Contents/Resources`. `L10n` procura primeiro esse recurso no app distribuído e usa `Bundle.module` nas execuções de desenvolvimento. Assim, o DMG não depende do caminho de compilação desta máquina.

Para adicionar outra interface, crie `xx.lproj/Localizable.strings`, traduza as mesmas chaves preservando `%@` e `%ld`, anuncie `xx` em `CFBundleLocalizations` e execute o verificador. Tradução de interface é estática e revisável, sem usar a IA em tempo de execução.

## Verificação

```sh
python3 scripts/check-localizations.py
.build/release/WritingCoreChecks
dist/LocalScribe.app/Contents/MacOS/LocalScribe --translation-smoke
dist/LocalScribe.app/Contents/MacOS/LocalScribe --localization-smoke -AppleLanguages '(en)'
dist/LocalScribe.app/Contents/MacOS/LocalScribe --localization-smoke -AppleLanguages '(pt-BR)'
dist/LocalScribe.app/Contents/MacOS/LocalScribe --localization-smoke -AppleLanguages '(pt-PT)'
dist/LocalScribe.app/Contents/MacOS/LocalScribe --localization-smoke -AppleLanguages '(ja)'
```

As flags `AppleLanguages` valem apenas para o processo de teste, sem mudar a preferência do usuário. O ensaio de tradução usa textos sintéticos, testa o modelo real em en→pt, pt→en e en→es, além de cache e estados de cancelamento/timeout. Não lê nem escreve em editores externos. Resultados e limites estão em [VALIDATION.md](VALIDATION.md).

Fontes: [idiomas e locales em Foundation Models](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models), [preparação de texto localizável](https://developer.apple.com/documentation/xcode/preparing-your-apps-text-for-translation).

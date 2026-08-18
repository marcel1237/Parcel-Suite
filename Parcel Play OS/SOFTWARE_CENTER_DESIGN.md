# Design de Interface: Parcel Software Center (Híbrido)

O **Parcel Software Center** é a central de comando de software do Parcel Play OS, unificando os 4 motores de pacotes (APT, Pacman, DNF e OBS) em uma única interface baseada em **Qt 6 / Kirigami**.

## 1. Arquitetura da Interface (UX)

### A. Busca Unificada (Nitro-Search)
Ao buscar um termo (ex: "Visual Studio Code"), a loja apresenta os resultados categorizados por origem:
- **Resultados APT (Sistema)**: Versão estável, recomendada para uso geral.
- **Resultados Pacman (AUR)**: Versão de vanguarda, recomendada para desenvolvedores.
- **Resultados DNF (COPR)**: Pacotes específicos da comunidade Fedora.
- **Resultados Flatpak/Snap**: Versões isoladas (Sandboxed).

### B. O Selo "Nitro-Optimized"
Aplicativos que possuem integração nativa com o **NitroCore** ou **OmniLock** receberão um selo visual verde, indicando que o OS aplicará automaticamente otimizações de RAM e CPU para aquele app.

## 2. Protótipo Visual (Conceito QML)

```qml
Kirigami.CardsListView {
    model: unifiedSearchModel
    delegate: Kirigami.AbstractCard {
        contentItem: RowLayout {
            Kirigami.Icon { source: model.appIcon }
            ColumnLayout {
                Label { text: model.appName; font.bold: true }
                Label { 
                    text: "Origem: " + model.sourceName 
                    color: model.sourceColor // Azul (Ubuntu), Ciano (Arch), Azul Escuro (Fedora)
                }
            }
            // Botão de Instalação Inteligente
            Button { 
                text: "Instalar"
                highlighted: model.isRecommended
            }
        }
    }
}
```

## 3. Gestão de Repositórios
Uma aba avançada permitirá ligar/desligar as "Zonas de Agilidade" (Arch, Fedora, openSUSE), garantindo que o usuário tenha controle total sobre quais ecossistemas deseja consumir.

---
*Status: Design Conceitual finalizado. Próximo: Implementação do Mockup em QML.*

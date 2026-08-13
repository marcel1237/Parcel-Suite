# LICENSE

## ⚖️ Licenciamento Conjunto Obrigatório (Triple Co-Licensing)

Este projeto adota uma abordagem de licenciamento robusta e inovadora para garantir a máxima proteção do código-fonte, incentivar a colaboração industrial e impedir o fechamento do ecossistema em ambientes de nuvem.

Para utilizar, modificar ou distribuir este software (no todo ou em parte), você **DEVE cumprir os termos e obrigações de três licenças simultaneamente**:

1. **Eclipse Public License v2.0 (EPL-2.0)** - Garante a proteção dos arquivos centrais e facilita a criação de um ecossistema de plugins comerciais/proprietários em arquivos separados.
2. **Mozilla Public License v2.0 (MPL-2.0)** - Protege os arquivos de código-fonte originais, exigindo que qualquer modificação neles permaneça pública.
3. **GNU Affero General Public License v3.0 (AGPL-3.0-only)** - Atua como *Licença Secundária e Combinada*, garantindo o "copyleft de rede" (se a IDE for modificada e executada na nuvem como serviço/SaaS, o código modificado deve ser liberado).

---

### 📦 Especificidades do Ecossistema Java

Como o **ProjectWizard** é desenvolvido em **Java**, as seguintes regras de conformidade se aplicam à estrutura do projeto:

* **Arquivos de Código (`.java`):** Todo arquivo criado no projeto deve conter o cabeçalho SPDX padrão nas primeiras linhas para fins de auditoria automática.
* **Pacotes (`package`):** A separação lógica por pacotes Java é utilizada para delimitar o que faz parte do núcleo do ProjectWizard (sujeito ao co-licenciamento estrito) e o que são extensões ou drivers externos através de APIs.
* **Compilação e Artefatos (`.jar` / `.war`):** A distribuição do binário compilado não isenta o distribuidor de fornecer o código-fonte correspondente sob os termos da AGPL-3.0 e MPL-2.0 caso o software seja modificado.

---

### 🔍 Identificadores SPDX
Nos termos da Seção 1.13 da EPL 2.0 e da Seção 3.3 da MPL 2.0, a conformidade é rastreada através da seguinte tag padrão de mercado:

```text
SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
```

---

## 📄 Termo Integral de Outorga Conjunta

```text
===============================================================================
TERMO DE OUTORGA DE LICENÇA CONJUNTA E OBRIGATÓRIA (TRIPLE CO-LICENSING)
===============================================================================

Projeto: ProjectWizard
Linguagem Principal: Java
Detentor dos Direitos Autorais: Marcel Aparecido de Andrade

Copyright (C) 2026 Marcel Aparecido de Andrade. Todos os direitos reservados.

Este software e seu código-fonte são distribuídos de forma conjunta e obrigatória 
sob os termos de três licenças de software livre distintas. Para qualquer tipo de 
uso, cópia, modificação, fusão, publicação, distribuição ou sublicenciamento 
deste software, o usuário DEVE cumprir cumulativamente e simultaneamente todas as 
obrigações, restrições e termos contidos nas seguintes licenças:

1. ECLIPSE PUBLIC LICENSE - v 2.0 (EPL-2.0)
   Disponível em: https://eclipse.org

2. MOZILLA PUBLIC LICENSE - v 2.0 (MPL-2.0)
   Disponível em: https://mozilla.org

3. GNU AFFERO GENERAL PUBLIC LICENSE - v 3.0 (AGPL-3.0-only)
   Disponível em: https://gnu.org

-------------------------------------------------------------------------------
CLÁUSULA DE COMPATIBILIDADE E COMBINAÇÃO (ESTRUTURA JURÍDICA)
-------------------------------------------------------------------------------

Nos termos da Seção 1.13 ("Secondary License") da Eclipse Public License v 2.0 e 
da Seção 3.3 ("Larger Works") da Mozilla Public License v 2.0, o outorgante original 
deste software, Marcel Aparecido de Andrade, declara formalmente a GNU Affero General 
Public License v 3.0 como "Licença Secundária" e aplicável. 

Isso garante que:
a) O código permanece sob a proteção de arquivos da EPL-2.0 e MPL-2.0.
b) Qualquer trabalho maior, derivado ou disponibilizado via rede/nuvem herda de 
   forma mandatória o copyleft de rede estabelecido pela AGPL-3.0-only.

A falha em cumprir os termos de qualquer uma das três licenças listadas acima 
resultará na revogação automática e imediata de todos os direitos concedidos por este 
termo, constituindo violação de direitos autorais (copyright).

===============================================================================
```

---

### ☕ Cabeçalho Padrão para Arquivos de Código Java

Copie e cole este bloco no topo de **todos** os novos arquivos `.java` criados no projeto **ProjectWizard**:

```java
/*
 * Copyright (C) 2026 Marcel Aparecido de Andrade.
 * ProjectWizard - Java IDE
 *
 * SPDX-License-Identifier: EPL-2.0 AND MPL-2.0 AND AGPL-3.0-only
 *
 * Este código-fonte é sujeito aos termos conjuntos da Eclipse Public License v. 2.0, 
 * da Mozilla Public License v. 2.0, e da GNU Affero General Public License v. 3.0.
 * A conformidade com todas as três licenças é obrigatória para uso e distribuição.
 */
```


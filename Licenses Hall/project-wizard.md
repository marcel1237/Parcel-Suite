# LICENSE

## ⚖️ Licenciamento Híbrido e Condicional (Conditional Hexa-Licensing)

Este projeto adota uma arquitetura de licenciamento inteligente para garantir a liberdade do usuário final e a integridade do código aberto em modificações industriais. O conjunto de licenças aplicáveis é determinado pela forma de interação com o Software:

### 1. 🛡️ Uso Final e Distribuições Oficiais
Para usuários que executam o software em sua forma original fornecida pelo Autor (**Marcel Aparecido de Andrade**) ou para fins de desenvolvimento interno, aplicam-se os termos permissivos e industriais:
*   **[ProjectWizard License v3.0 (PWL-3.0)](#-projectwizard-license-v30-pwl-30)** - Termos Gerais.
*   **[Apache License v2.0](https://www.apache.org/licenses/LICENSE-2.0)** - Proteção de Patentes.
*   **[Eclipse Public License v2.0](https://www.eclipse.org/legal/epl-2.0/)** - Estrutura de Arquivos.
*   **[Mozilla Public License v2.0](https://www.mozilla.org/en-US/MPL/2.0/)** - Resiliência de Código.
*   **[Universal Permissive License v1.0 (UPL)](https://opensource.org/license/upl/)** - Interoperabilidade.

### 2. 🛠️ Modificação, Redistribuição e Obras Derivadas
Para qualquer pessoa ou entidade que exerça o direito de **modificar o código-fonte, criar obras derivadas ou redistribuir o software**, as obrigações de reciprocidade e atribuição são ativadas, adicionando-se cumulativamente:
*   **[BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause)** - Atribuição e Integridade de Nome.
*   **[GNU Affero General Public License v3.0 (AGPL-3.0)](https://www.gnu.org/licenses/agpl-3.0.html)** - Copyleft de Rede (Obrigação de compartilhar modificações se oferecido via nuvem/SaaS).

---

### 🔍 Identificador SPDX (Auditável)
```text
SPDX-License-Identifier: BSD-3-Clause AND Apache-2.0 AND EPL-2.0 AND MPL-2.0 AND UPL-1.0 AND AGPL-3.0-only AND LicenseRef-PWL-3.0
```

---

## 📄 ProjectWizard License v3.0 (PWL-3.0)

**Versão 3.0 - Julho de 2026**  
**Autor e Detentor Original:** Marcel Aparecido de Andrade  
**Conformidade:** 100% Open Source Definition (OSD) Compliant.

### 1. Concessão de Direitos
O Detentor concede a você uma licença mundial, isenta de royalties, não exclusiva e perpétua para usar, reproduzir, modificar, exibir, executar e distribuir o Software. Esta concessão é plena e garante todas as liberdades fundamentais do software livre.

### 2. Condições de Exercício (Reciprocidade)
O exercício dos direitos de **modificação** ou **redistribuição** deste Software está condicionado à aceitação e cumprimento simultâneo das seguintes obrigações:
*   **Compartilhamento de Melhorias**: Modificações no Core (`com.projectwizard.*`) devem ter seu código-fonte disponibilizado sob os termos da AGPL-3.0, incluindo em casos de interação via rede (SaaS).
*   **Preservação de Crédito**: Toda redistribuição deve manter os avisos de copyright originais e o crédito ao Autor conforme exigido pela BSD 3-Clause.

### 3. Independência de Extensões e Plugins
Em conformidade com a arquitetura modular da IDE, módulos que interajam com o Software exclusivamente através de suas APIs públicas ou interfaces de plugins não são considerados "Obras Derivadas" para fins de reciprocidade forçada. Seus autores mantêm o direito de licenciá-los sob quaisquer termos, inclusive comerciais ou proprietários.

### 4. Defesa de Patentes
A licença concedida sob a PWL-3.0 inclui uma licença de patente automática de todos os contribuidores. Esta licença será rescindida se você iniciar um litígio de patentes contra o Autor alegando infração por parte deste Software.

### 5. Isenção de Garantia
O SOFTWARE É FORNECIDO "COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPLÍCITA.

---

## 📄 Termo Integral de Outorga Conjunta

```text
===============================================================================
TERMO DE OUTORGA DE LICENÇA CONJUNTA E OBRIGATÓRIA (HEXA CO-LICENSING)
===============================================================================

Projeto: ProjectWizard
Detentor dos Direitos Autorais: Marcel Aparecido de Andrade
Identificador SPDX: BSD-3-Clause AND Apache-2.0 AND EPL-2.0 AND MPL-2.0 AND UPL-1.0 AND AGPL-3.0-only AND LicenseRef-PWL-3.0

Este software e seu código-fonte são distribuídos sob um modelo de outorga 
conjunta, escalonável e obrigatória para garantir a integridade do ecossistema.

A. ESTRUTURA JURÍDICA DE COMPATIBILIDADE:
   Nos termos da Seção 1.13 da Eclipse Public License v2.0 e da Seção 3.3 da 
   Mozilla Public License v2.0, o outorgante declara a UPL-1.0 e a AGPL-3.0 
   como licenças integralmente compatíveis e aplicáveis ao conjunto da obra.

B. ESCOPO DE APLICAÇÃO CONDICIONAL:
   1. USO OFICIAL: Versões originais distribuídas pelo autor são regidas pelos 
      termos da PWL-3.0, Apache-2.0, EPL-2.0, MPL-2.0 e UPL-1.0.
   2. OBRAS DERIVADAS: Qualquer modificação ou redistribuição ativa, de forma
      mandatória e indissociável, as obrigações de atribuição da BSD-3-Clause 
      e o copyleft de rede da AGPL-3.0.

C. PROTEÇÃO E MARCAS:
   A concessão de direitos sobre o código-fonte não transfere direitos sobre 
   a marca "ProjectWizard" ou a identidade visual do projeto, cuja utilização
   para fins comerciais por terceiros exige autorização prévia por escrito.

A falha em cumprir as obrigações de reciprocidade (AGPL) ou atribuição (BSD) 
ao exercer o direito de modificação resultará na revogação automática de 
todos os direitos concedidos por esta outorga.
===============================================================================
```

---

### ☕ Cabeçalho de Conformidade (Topo dos arquivos .java)

```java
/*
 * Copyright (C) 2026 Marcel Aparecido de Andrade.
 * ProjectWizard IDE - Industrial Development Toolkit
 *
 * SPDX-License-Identifier: BSD-3-Clause AND Apache-2.0 AND EPL-2.0 AND MPL-2.0 AND UPL-1.0 AND AGPL-3.0-only AND LicenseRef-PWL-3.0
 *
 * Este código-fonte é regido pelo modelo Hexa Co-Licensing híbrido.
 * Uso oficial segue termos simplificados. Modificações ou redistribuições
 * ativam as obrigações da BSD-3-Clause e AGPL-3.0 conforme a PWL-3.0.
 */
```

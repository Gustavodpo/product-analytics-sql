# Análise de produto com SQL e Python

[English](README.md) · [**Português (Brasil)**](README.pt-BR.md)

Em que etapa os usuários abandonam o fluxo antes de criar o primeiro projeto? Quantos voltam nas semanas seguintes? Este estudo responde a essas perguntas para um aplicativo fictício de gestão de projetos com **2.400 usuários sintéticos**, três canais de aquisição e oito coortes de cadastro.

## O que as consultas medem

- [Funil de ativação](funnel.sql) conta cadastros, conclusões do onboarding e primeiros projetos por canal de aquisição. As etapas precisam ocorrer em ordem, em até sete dias corridos, incluindo o dia do cadastro. A consulta inclui usuários cuja janela de sete dias foi observada por inteiro.
- [Retenção por coorte](retention.sql) agrupa usuários pela semana de cadastro (segunda a domingo). Um usuário conta como retido se usar um projeto pelo menos uma vez na semana analisada. A base de cálculo inclui todos os cadastrados na coorte. O resultado inclui as semanas completas observadas até 9 de março de 2025.

## Resultados

| Canal de aquisição | Cadastros | Concluíram o onboarding | Ativados | Cadastro → ativação |
| --- | ---: | ---: | ---: | ---: |
| Indicação | 800 | 685 | 487 | 60,9% |
| Busca orgânica | 800 | 602 | 367 | 45,9% |
| Busca paga | 800 | 542 | 250 | 31,3% |

Na busca paga, 258 usuários saem antes de concluir o onboarding e 292 saem depois de concluí-lo. Em um produto real, a segunda queda motivaria uma investigação do fluxo entre o onboarding e a criação do primeiro projeto. Indicação e busca paga têm uma diferença de 29,6 pontos percentuais na conversão de cadastro em ativação nesta amostra.

Entre as cinco coortes com uma quarta semana completa, a retenção na semana 4 varia de **11,7% a 17,7%**. As probabilidades de conversão e retorno são parâmetros da simulação, então esses resultados ilustram o fluxo de análise.

## Como reproduzir

Execute `python run.py` com Python 3.11 ou superior. O script gera os eventos com uma semente fixa, carrega o [esquema SQLite](schema.sql) em memória e grava [funnel.csv](results/funnel.csv) e [retention.csv](results/retention.csv). Usa apenas a biblioteca padrão do Python.

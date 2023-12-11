Em meu último artigo demonstrei uma abordagem que permite o rápido desenvolvimento de APIs REST em apenas um minuto. O primeiro template de API REST publicado atende a demandas de uma API pública (sem autenticação). Neste artigo, abordaremos de uma forma bastante simples como acrescentar uma camada de autenticação/autorização nesta solução. O incrível ganho de produtividade que nos permite implantar uma API REST em apenas um minuto se deve a uma feliz combinação de dois pilares fundamentais:

Infraestrutura Definida por Código (IaC)
Backend como serviço (BaaS) utilizando PostgREST

O primeiro pilar consiste no IaC com Docker-compose que nos permite em apenas 1 minuto implantar uma infraestrutura de microserviços composta pelos seguintes componentes: (i) Postgres; (ii) PostgREST; e (iii) Swagger. Toda a complexidade de instalação e configuração desses componentes é escrita em arquivos Dockerfiles de cada um dos containers, bem como o barramento de rede que permite a interoperabilidade entre tais componentes. Para mais detalhes sobre as vantagens de IaC e Docker acesse (link).

O segundo pilar consiste no BaaS, que tem por objetivo simplificar a tarefa de desenvolvimento de aplicações que necessitem de um backend (quase a totalidade). Uma parte expressiva das funções desempenhadas por backends consiste nas operações CRUD (create, read, update and delete). Um arquiteto e engenheiro de software deve estar atento a não investir muitos recursos na escrita de código boiler plate que pode ser evitado através de estratégias de reúso de código. Esse nível de maturidade do time técnico permite que os recursos (sobretudo humanos) sejam concentrados nas funções mais complexas que estão mais ligadas ao core business de produto. As vantagens do emprego do PostgREST como uma solução de BaaS podem ser vistas no seguinte artigo (link). 

Uma vez aberto o caminho para que tenhamos uma arquitetura de API REST funcional em apenas um minuto, vamos investir o próximo minuto na camada de autenticação. A leitura do artigo a partir deste ponto é recomendada apenas após a leitura do primeiro artigo da série (link).

O template criado para facilitar a execução na prática do conceito proposto nesse post, contém a seguinte estrutura de arquivos SQL que são executados em sequência quando o container do Postgres é iniciado pela primeira vez (somente no primeiro boot).

* 000 - configuração inicial do PostgREST, que permite que o "código" da API REST seja atualizando automaticamente a cada vez que ocorra uma mudança da estrutura do banco de dados

* 001 - criação do usuário anônimo, que é utilizado para acesso a endpoints públicos. O endpoint de login por exemplo deve ser acessível para usuários não autenticados.

* 002 - criação das tabelas utilizadas no modelo

* 003 a 007 - inserção de dados mock nas tabelas apenas para deixar nosso template mais funcional

* 008 - criação do esquema que abriga as principais funcionalidades da autenticação e autorização

* 009 - criação do esquema JWT (JSON Web Tokens) que contém funções utilizadas pelo esquema basic auth

* 010 - criação da funções pública de login

* 011 - criação de mock de usuários na base de dados


# Criando e publicando uma imagem Docker do GLPI

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GLPI](https://img.shields.io/badge/GLPI-11B5E5?style=for-the-badge&logo=glpi&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![Apache](https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

Case apresentado no DockerDay Região Metropolitana de Piracicaba sobre a criação e publicação de uma imagem Docker personalizada do GLPI.

## Sobre o projeto

O projeto nasceu de uma necessidade prática: durante o desenvolvimento de automações com GLPI, qualquer falha no ambiente exigia uma nova instalação do Apache, PHP, extensões, banco de dados, GLPI e plugins.

Para reduzir esse trabalho repetitivo, foi criada uma imagem Docker do GLPI, inicialmente como um laboratório pessoal e depois publicada no Docker Hub.

O repositório mostra a evolução entre duas abordagens:

- **Versão 1:** imagem criada para o case original;
- **Versão 2:** imagem mais reproduzível, com plugins baixados durante o build, volumes Docker e versões parametrizadas.

## Tecnologias

- Docker
- Docker Compose
- Debian 12
- Apache 2
- PHP 8.2
- MySQL 8.3
- GLPI 10.0.18
- GLPI Inventory 1.5.8
- Behaviors

## Estrutura

```text
.
├── Dockerfile.v1
├── Dockerfile.v2
├── glpi-compose-v1.yml
├── glpi-compose-v2.yml
├── .env.example
└── README.md
```

## Build da versão 1

```bash
docker build \
  -f Dockerfile.v1 \
  -t rosnertech/glpi:10.0.18-v1 .
```

## Build da versão 2

A versão 2 recebe as versões durante o build por meio de argumentos:

```bash
docker build \
  -f Dockerfile.v2 \
  --build-arg GLPI_VERSION=10.0.18 \
  --build-arg GLPI_INVENTORY_VERSION=1.5.8 \
  --build-arg BEHAVIORS_REF=master \
  -t rosnertech/glpi:10.0.18-v2 .
```

Os valores podem ser alterados sem editar o Dockerfile:

```bash
docker build \
  -f Dockerfile.v2 \
  --build-arg GLPI_VERSION=10.0.19 \
  --build-arg GLPI_INVENTORY_VERSION=1.5.8 \
  --build-arg BEHAVIORS_REF=master \
  -t rosnertech/glpi:10.0.19-v2 .
```

## Execução com Docker Compose

Copie o arquivo de ambiente:

```bash
cp .env.example .env
```

Suba os serviços:

```bash
docker compose -f glpi-compose-v2.yml up -d
```

Verifique o ambiente:

```bash
docker compose -f glpi-compose-v2.yml ps
docker compose -f glpi-compose-v2.yml logs -f
```

Acesse o GLPI em:

```text
http://localhost
```

## Persistência

A versão 2 utiliza volumes administrados pelo Docker para preservar os dados do GLPI e do MySQL:

- `glpi_files`
- `glpi_config`
- `glpi_marketplace`
- `mysql_data`

O container pode ser recriado sem perder os dados armazenados nesses volumes.

## O que evitar em produção

Esta configuração serve para laboratório e demonstração. Em um ambiente real, evite:

- Colocar senhas diretamente no `docker-compose.yml`;
- Versionar o arquivo `.env` com credenciais reais;
- Usar as tags `latest` ou `master` sem validação;
- Montar um volume sobre todo o diretório da aplicação, escondendo os arquivos da imagem;
- Executar a aplicação sem testar backup e restauração dos volumes;
- Usar plugins sem confirmar a compatibilidade com a versão do GLPI;
- Publicar a imagem sem revisar vulnerabilidades, permissões e conteúdo das camadas.

Para produção, prefira versões fixas, commits ou digests conhecidos, secrets, backups automatizados e uma política de atualização.

## Docker Hub

A imagem original está disponível em:

https://hub.docker.com/r/rosnertech/glpi

## Aviso

Este projeto foi criado para fins educacionais, de laboratório e demonstração. Antes de utilizar qualquer imagem em produção, valide versões, segurança, permissões, persistência, backups e compatibilidade dos plugins.

## Autor

**RosnerTech**  
Rosner Pelaes Nascimento  
E-mail: [rosner@rosnertech.com.br](mailto:rosner@rosnertech.com.br)

## Licença

Material disponibilizado para fins educacionais e de compartilhamento com a comunidade.

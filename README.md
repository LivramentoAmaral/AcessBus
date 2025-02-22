# AcessBus

**Transporte Escolar Acessível e Inclusivo para Estudantes com Deficiência Visual e Motora**

## 📌 Sobre o Projeto
O **AcessBus** é um aplicativo móvel que permite o monitoramento em **tempo real** do transporte escolar, garantindo acessibilidade para estudantes com deficiência visual e motora. A aplicação visa proporcionar maior autonomia e segurança no transporte, utilizando tecnologias modernas para rastreamento e integração com recursos de acessibilidade.

## 🚀 Tecnologias Utilizadas
O sistema AcessBus é construído utilizando as seguintes tecnologias:

### 🖥️ **Front-End**
- **Flutter** (Dart) - Framework para desenvolvimento de aplicativos móveis multiplataforma.
- **OpenStreetMap** - API para visualização do mapa e rastreamento do ônibus em tempo real.

### 🌐 **API Utilizada**
- [https://api-location-teal.vercel.app/api/location](https://api-location-teal.vercel.app/api/location)

### 🔧 **Hardware**
- **Raspberry Pi 3** - Microcomputador para processamento dos dados do GPS.
- **Módulo GPS NEO-6M** - Coleta de coordenadas geográficas em tempo real.
- **Modem 4G LTE** - Comunicação de dados sem necessidade de Wi-Fi.
- **Power Bank** - Fornecimento de energia para autonomia do sistema.

## 📱 Funcionalidades
✅ **Monitoramento em Tempo Real** - Exibe a localização dos ônibus em um mapa interativo.
✅ **Leitura em Voz Alta** - Transformação de informações em áudio para acessibilidade.
✅ **Comando de Voz** - Usuários podem solicitar informações sobre o ônibus sem precisar tocar na tela.
✅ **Zoom Automático** - Ajuste automático para melhor visualização da localização do veículo.
✅ **Avisos Sonoros** - Alertas sobre a chegada do ônibus na parada.

## 🎯 Objetivos
- Desenvolver uma **solução acessível** para o transporte escolar.
- Garantir **inclusão digital** para pessoas com deficiência.
- Utilizar tecnologias **Open Source** para escalabilidade e flexibilidade.
- Criar um **rastreamento eficiente** com atualização contínua dos dados.

## 📊 Arquitetura do Sistema
1. O **Raspberry Pi 3** recebe as coordenadas do **módulo GPS**.
2. Os dados são enviados para a **API em Node.js**, hospedada na **Vercel**.
3. As informações são armazenadas no **MongoDB** e disponibilizadas para o aplicativo.
4. O **Flutter** exibe a posição dos ônibus em tempo real no mapa interativo do **OpenStreetMap**.
5. Recursos de **voz e acessibilidade** garantem interação inclusiva.

## 🏗️ Instalação e Execução
### 📌 Requisitos
- Node.js e npm instalados.
- MongoDB configurado.
- Flutter instalado.

### 📦 Clonando o Repositório
```bash
$ git clone https://github.com/LivramentoAmaral/AcessBus.git
$ cd AcessBus
```

### 🔧 Configuração do Back-End
```bash
$ cd backend
$ npm install
$ npm start
```

### 📲 Configuração do Front-End
```bash
$ cd AcessTrans
$ flutter pub get
$ flutter run
```

## 📌 Trabalhos Futuros
- Integração com inteligência artificial para **otimização de rotas**.
- Expansão do projeto para **novas cidades e redes de ensino**.
- **Notificações personalizadas** sobre atrasos e mudanças de rota.


## 📬 Contato
📧 Email: marcosdoamaral2002@gmail.com  
📌 Repositório: [GitHub - AcessBus](https://github.com/LivramentoAmaral/AcessBus)

---
Desenvolvido por **Marcos do Livramento Amaral** 

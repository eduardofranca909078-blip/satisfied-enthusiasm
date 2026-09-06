const {
  Client,
  GatewayIntentBits,
  PermissionsBitField,
  EmbedBuilder
} = require("discord.js");

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMembers,
    GatewayIntentBits.GuildMessageReactions
  ]
});

// ===============================
// CONFIGURAÇÕES
// ===============================

const PREFIX = "!";

// Canal de logs
const LOG_CHANNEL = "1534808396891426918";

// Cargo necessário para promover/rebaixar
const CARGO_AUTORIZADO = "1533206202626867381";

// Cargo entregue no registro
const CARGO_REGISTRO = "1456788476354625643";

// Anti-spam
const spamAtivo = new Map();
const spamContagem = new Map();

// ===============================
// BOT ONLINE
// ===============================

client.once("ready", () => {
  console.log(`✅ Bot conectado como ${client.user.tag}`);
  console.log(`📡 Servidores: ${client.guilds.cache.size}`);

  client.user.setActivity("RPBR | !ajuda");
});

// ===============================
// MENSAGENS
// ===============================

client.on("messageCreate", async (message) => {
  if (message.author.bot) return;

  // ===============================
  // ANTI-SPAM
  // ===============================

  if (spamAtivo.get(message.guild?.id) === true) {
    const userId = message.author.id;

    let quantidade = spamContagem.get(userId) || 0;
    quantidade++;

    spamContagem.set(userId, quantidade);

    if (quantidade >= 6) {
      try {
        await message.member.timeout(10 * 60 * 1000, "Spam");

        const embed = new EmbedBuilder()
          .setTitle("🚫 AntiSpam")
          .setDescription(
            `<@${userId}> foi silenciado automaticamente por enviar muitas mensagens seguidas.`
          )
          .setColor(0xff0000);

        await message.channel.send({ embeds: [embed] });

        spamContagem.set(userId, 0);
      } catch (error) {
        console.log("Erro no timeout:", error.message);
      }
    }

    setTimeout(() => {
      spamContagem.set(userId, 0);
    }, 5000);
  }

  // ===============================
  // PREFIXO
  // ===============================

  if (!message.content.startsWith(PREFIX)) return;

  const args = message.content.slice(PREFIX.length).trim().split(/\s+/);
  const comando = args.shift().toLowerCase();

  // ===============================
  // AJUDA
  // ===============================

  if (comando === "ajuda") {
    const embed = new EmbedBuilder()
      .setTitle("📖 Central de Comandos")
      .setDescription(`
**📋 Comandos disponíveis**

\`!votacao @usuário punição motivo\`
\`!antispam on\`
\`!antispam off\`
\`!registro\`
\`!avaliacao\`
\`!promover @usuário @cargo motivo\`
\`!rebaixar @usuário @cargo motivo\`
\`!enquete pergunta | opção 1 | opção 2\`
\`!aviso mensagem\`
\`!ia pergunta\`
      `)
      .setColor(0x7800ff);

    return message.channel.send({ embeds: [embed] });
  }

  // ===============================
  // ANTI-SPAM ON/OFF
  // ===============================

  if (comando === "antispam") {
    if (
      !message.member.permissions.has(
        PermissionsBitField.Flags.ManageGuild
      )
    ) {
      return message.reply(
        "❌ Você precisa da permissão **Gerenciar Servidor**."
      );
    }

    const opcao = args[0]?.toLowerCase();

    if (opcao === "on") {
      spamAtivo.set(message.guild.id, true);

      const embed = new EmbedBuilder()
        .setTitle("✅ AntiSpam")
        .setDescription("Sistema de AntiSpam ativado.")
        .setColor(0x00ff00);

      return message.channel.send({ embeds: [embed] });
    }

    if (opcao === "off") {
      spamAtivo.set(message.guild.id, false);

      const embed = new EmbedBuilder()
        .setTitle("❌ AntiSpam")
        .setDescription("Sistema de AntiSpam desativado.")
        .setColor(0xff0000);

      return message.channel.send({ embeds: [embed] });
    }

    return message.reply(
      "📖 Uso:\n`!antispam on`\n`!antispam off`"
    );
  }

  // ===============================
  // REGISTRO
  // ===============================

  if (comando === "registro") {
    try {
      const cargo = message.guild.roles.cache.get(CARGO_REGISTRO);

      if (!cargo) {
        return message.reply("❌ Cargo de registro não encontrado.");
      }

      await message.member.roles.add(cargo);

      const log = message.guild.channels.cache.get(LOG_CHANNEL);

      if (log) {
        await log.send(
          `📋 **LOG DE REGISTRO**

👤 Usuário: <@${message.author.id}>
🆔 ID: ${message.author.id}
📅 Data: ${new Date().toLocaleDateString("pt-BR")}
🕒 Hora: ${new Date().toLocaleTimeString("pt-BR")}

✅ O usuário realizou o registro.`
        );
      }

      return message.reply("✅ Seu registro foi realizado com sucesso!");
    } catch (error) {
      console.log(error);
      return message.reply(
        "❌ Não consegui entregar o cargo. Verifique as permissões do bot."
      );
    }
  }

  // ===============================
  // AVALIAÇÃO
  // ===============================

  if (comando === "avaliacao") {
    const embed = new EmbedBuilder()
      .setTitle("⭐ Avaliação da Equipe")
      .setDescription(`
Obrigado por utilizar nosso atendimento!

Sua opinião é muito importante.

**Avalie a equipe:**

⭐ Excelente
👍 Muito Bom
😊 Bom
😐 Regular
👎 Ruim

Reaja com um dos emojis para registrar sua avaliação.
      `)
      .setColor(0x3498db)
      .setFooter({
        text: "Agradecemos pelo seu feedback."
      });

    const msg = await message.channel.send({
      embeds: [embed]
    });

    await msg.react("⭐");
    await msg.react("👍");
    await msg.react("😊");
    await msg.react("😐");
    await msg.react("👎");

    return;
  }

  // ===============================
  // PROMOVER
  // ===============================

  if (comando === "promover") {
    const usuario = message.mentions.members.first();
    const cargo = message.mentions.roles.first();
    const motivo = args
      .filter((arg) => !arg.startsWith("<@"))
      .filter((arg) => !arg.startsWith("<@&"))
      .join(" ");

    if (!usuario) {
      return message.reply(
        "❌ **Uso incorreto!**\n\nUtilize:\n`!promover @usuário @cargo motivo`"
      );
    }

    if (!cargo) {
      return message.reply(
        "❌ Você precisa mencionar o cargo da promoção!"
      );
    }

    if (!message.member.roles.cache.has(CARGO_AUTORIZADO)) {
      return message.reply(
        "❌ **Acesso negado!**\n\nVocê não possui o cargo necessário para realizar promoções."
      );
    }

    if (usuario.id === message.author.id) {
      return message.reply(
        "❌ Você não pode promover a si mesmo!"
      );
    }

    try {
      await usuario.roles.add(cargo);

      const embed = new EmbedBuilder()
        .setTitle("🎖️ PROMOÇÃO REALIZADA")
        .setDescription(`
👤 **Promovido:** <@${usuario.id}>

🎖️ **Novo cargo:** <@&${cargo.id}>

👮 **Responsável:** <@${message.author.id}>

📝 **Motivo:** ${motivo || "Não informado"}
        `)
        .setColor(0x5865f2)
        .setTimestamp();

      await message.channel.send({
        embeds: [embed]
      });

      const log = message.guild.channels.cache.get(LOG_CHANNEL);

      if (log) {
        await log.send({
          embeds: [
            new EmbedBuilder()
              .setTitle("📋 Registro de Promoção")
              .setDescription(`
👤 **Promovido:** <@${usuario.id}>

🎖️ **Novo cargo:** <@&${cargo.id}>

👮 **Responsável:** <@${message.author.id}>

📝 **Motivo:** ${motivo || "Não informado"}
              `)
              .setColor(0x5865f2)
              .setTimestamp()
          ]
        });
      }
    } catch (error) {
      console.log(error);
      return message.reply(
        "❌ Não consegui adicionar o cargo. Verifique a hierarquia de cargos do bot."
      );
    }

    return;
  }

  // ===============================
  // REBAIXAR
  // ===============================

  if (comando === "rebaixar") {
    const usuario = message.mentions.members.first();
    const cargo = message.mentions.roles.first();
    const motivo = args
      .filter((arg) => !arg.startsWith("<@"))
      .filter((arg) => !arg.startsWith("<@&"))
      .join(" ");

    if (!usuario) {
      return message.reply(
        "❌ **Uso incorreto!**\n\nUtilize:\n`!rebaixar @usuário @cargo motivo`"
      );
    }

    if (!cargo) {
      return message.reply(
        "❌ Você precisa mencionar o cargo que será removido!"
      );
    }

    if (!message.member.roles.cache.has(CARGO_AUTORIZADO)) {
      return message.reply(
        "❌ **Acesso negado!**\n\nVocê não possui autorização para realizar rebaixamentos."
      );
    }

    if (usuario.id === message.author.id) {
      return message.reply(
        "❌ Você não pode rebaixar a si mesmo!"
      );
    }

    try {
      await usuario.roles.remove(cargo);

      const embed = new EmbedBuilder()
        .setTitle("🔻 REBAIXAMENTO REALIZADO")
        .setDescription(`
👤 **Militar:** <@${usuario.id}>

🔻 **Cargo removido:** <@&${cargo.id}>

👮 **Responsável:** <@${message.author.id}>

📝 **Motivo:** ${motivo || "Não informado"}
        `)
        .setColor(0xed4245)
        .setTimestamp();

      await message.channel.send({
        embeds: [embed]
      });

      const log = message.guild.channels.cache.get(LOG_CHANNEL);

      if (log) {
        await log.send({
          embeds: [
            new EmbedBuilder()
              .setTitle("📋 Registro de Rebaixamento")
              .setDescription(`
👤 **Militar:** <@${usuario.id}>

🔻 **Cargo removido:** <@&${cargo.id}>

👮 **Responsável:** <@${message.author.id}>

📝 **Motivo:** ${motivo || "Não informado"}
              `)
              .setColor(0xed4245)
              .setTimestamp()
          ]
        });
      }
    } catch (error) {
      console.log(error);
      return message.reply(
        "❌ Não consegui remover o cargo. Verifique a hierarquia de cargos do bot."
      );
    }

    return;
  }

  // ===============================
  // ENQUETE
  // ===============================

  if (comando === "enquete") {
    const texto = args.join(" ");

    if (!texto) {
      return message.reply(
        "❌ Uso incorreto!\n\nUtilize:\n`!enquete pergunta | opção 1 | opção 2`"
      );
    }

    const partes = texto.split("|");

    const pergunta = partes[0]?.trim();
    const opcao1 = partes[1]?.trim() || "Opção 1";
    const opcao2 = partes[2]?.trim() || "Opção 2";

    const embed = new EmbedBuilder()
      .setTitle("📊 ENQUETE")
      .setDescription(`
📌 **Pergunta:**
${pergunta}

🅰️ **Opção 1:** ${opcao1}

🅱️ **Opção 2:** ${opcao2}

━━━━━━━━━━━━━━━━━━━━

👍 = Opção 1
👎 = Opção 2

👤 **Criada por:** <@${message.author.id}>
      `)
      .setColor(0x5865f2)
      .setTimestamp();

    const msg = await message.channel.send({
      embeds: [embed]
    });

    await msg.react("👍");
    await msg.react("👎");

    return;
  }

  // ===============================
  // AVISO
  // ===============================

  if (comando === "aviso") {
    if (
      !message.member.permissions.has(
        PermissionsBitField.Flags.Administrator
      )
    ) {
      return message.reply(
        "❌ Você precisa ser **Administrador**."
      );
    }

    const aviso = args.join(" ");

    if (!aviso) {
      return message.reply(
        "❌ Digite a mensagem do aviso."
      );
    }

    const embed = new EmbedBuilder()
      .setTitle("📢 AVISO DA PRESIDÊNCIA")
      .setDescription(aviso)
      .setColor(0x5865f2)
      .setTimestamp();

    await message.channel.send({
      embeds: [embed]
    });

    const log = message.guild.channels.cache.get(LOG_CHANNEL);

    if (log) {
      await log.send(
        `📋 **LOG — AVISO GLOBAL**

👤 Responsável: <@${message.author.id}>
🆔 ID: ${message.author.id}
📝 Mensagem: ${aviso}
📍 Canal: <#${message.channel.id}>`
      );
    }

    return;
  }

  // ===============================
  // VOTAÇÃO DE PUNIÇÃO
  // ===============================

  if (comando === "votacao") {
    const usuario = message.mentions.users.first();

    if (!usuario) {
      return message.reply(
        "❌ Uso incorreto!\n\nUtilize:\n`!votacao @usuário punição motivo`"
      );
    }

    const semMencao = message.content
      .replace(/<@!?\d+>/, "")
      .replace(/^!votacao\s*/i, "")
      .trim();

    const partes = semMencao.split(" ");
    const punicao = partes.shift() || "punição";
    const motivo = partes.join(" ") || "Não informado";

    const embed = new EmbedBuilder()
      .setTitle("📊 VOTAÇÃO")
      .setDescription(`
Vote para <@${usuario.id}> receber a punição de **${punicao}**.

📝 **Motivo:** ${motivo}

🔻 = Contra
🔺 = A favor
      `)
      .setColor(0x7800ff)
      .setFooter({
        text: `Criador: ${message.author.tag}`
      })
      .setTimestamp();

    const msg = await message.channel.send({
      embeds: [embed]
    });

    await msg.react("🔻");
    await msg.react("🔺");

    return;
  }

  // ===============================
  // INTELIGÊNCIA ARTIFICIAL
  // ===============================

  if (comando === "ia") {
    const pergunta = args.join(" ");

    if (!pergunta) {
      return message.reply(
        "❌ Digite uma pergunta.\n\nExemplo: `!ia o que é Discord?`"
      );
    }

    if (!process.env.OPENROUTER_API_KEY) {
      return message.reply(
        "❌ A chave da IA ainda não foi configurada no Railway."
      );
    }

    try {
      const resposta = await fetch(
        "https://openrouter.ai/api/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${process.env.OPENROUTER_API_KEY}`
          },
          body: JSON.stringify({
            model: "openai/gpt-oss-20b",
            messages: [
              {
                role: "user",
                content:
                  `Responda em português, de forma clara, objetiva e fácil de entender. Pergunta: ${pergunta}`
              }
            ]
          })
        }
      );

      const dados = await resposta.json();

      if (!resposta.ok) {
        console.log(dados);
        return message.reply(
          "❌ Ocorreu um erro ao consultar a inteligência artificial."
        );
      }

      const conteudo =
        dados.choices?.[0]?.message?.content ||
        "Não consegui obter uma resposta.";

      const embed = new EmbedBuilder()
        .setTitle("🤖 Resposta")
        .setDescription(conteudo.slice(0, 4000))
        .setColor(0x7800ff);

      return message.channel.send({
        embeds: [embed]
      });
    } catch (error) {
      console.log(error);

      return message.reply(
        "❌ Não foi possível conectar à inteligência artificial."
      );
    }
  }
});

// ===============================
// LOGIN
// ===============================

client.login(process.env.DISCORD_TOKEN);

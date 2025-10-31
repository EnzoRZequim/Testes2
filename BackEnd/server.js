const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const Diretorio = require("./diretorioSchema");

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 3000;

// Inicializa servidor
app.listen(PORT, () =>
  console.log(`✅ Servidor rodando em http://localhost:${PORT}`)
);

// Conexão com o MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ Conectado ao MongoDB"))
  .catch((err) => console.error("❌ MongoDB erro de conexão:", err));

// Teste de status da API
app.get("/test", async (req, res) => {
  try {
    const dbStatus = mongoose.connection.readyState; // 1 = conectado
    res.json({
      message: "API funcionando!",
      mongoStatus: dbStatus === 1 ? "Conectado ao MongoDB" : "Desconectado",
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Criar novo item
app.post("/diretorio", async (req, res) => {
  try {
    console.log("📝 Tentando criar item no diretório...");
    const item = new Diretorio(req.body);
    const respMongo = await item.save();
    console.log("✅ Item criado com sucesso:", respMongo);
    res.status(201).json(respMongo);
  } catch (erro) {
    console.log("❌ Erro ao criar item:", erro.message);
    res.status(400).json({ erro: erro.message });
  }
});

// Listar todos os itens
app.get("/diretorio", async (req, res) => {
  try {
    const itens = await Diretorio.find();
    res.status(200).json(itens);
  } catch (erro) {
    console.log("❌ Erro ao listar itens:", erro.message);
    res.status(500).json({ erro: erro.message });
  }
});

// Buscar item pelo ID
app.get("/diretorio/:id", async (req, res) => {
  try {
    const item = await Diretorio.findById(req.params.id);
    if (!item) return res.status(404).json({ erro: "Item não encontrado" });
    res.status(200).json(item);
  } catch (erro) {
    console.log("❌ Erro ao buscar item:", erro.message);
    res.status(500).json({ erro: erro.message });
  }
});

// 🗑️ Remover item pelo ID
app.delete("/diretorio/:id", async (req, res) => {
  try {
    const item = await Diretorio.findByIdAndDelete(req.params.id);
    if (!item)
      return res
        .status(404)
        .json({ erro: "Item não encontrado para exclusão" });

    console.log("🗑️ Item removido com sucesso:", item._id);
    res.status(200).json({
      message: "Item removido com sucesso",
      item,
    });
  } catch (erro) {
    console.log("❌ Erro ao remover item:", erro.message);
    res.status(500).json({ erro: erro.message });
  }
});

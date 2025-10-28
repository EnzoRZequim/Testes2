const mongoose = require('mongoose')

const diretorioSchema = new mongoose.Schema({
 titulo: { type: String, required: true },
 descricao: { type: String, required: true },
 listIMG: { type: [String], required: false },
});

module.exports = mongoose.model('Diretorio', diretorioSchema);
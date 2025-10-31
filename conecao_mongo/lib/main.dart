import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // URL do seu backend Node.js
  final String apiUrl = 'http://localhost:3000/diretorio';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diretório MongoDB',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Itens do Diretório')),
        body: FutureBuilder<List<Diretorio>>(
          future: fetchDiretorios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum item encontrado'));
            }

            final itens = snapshot.data!;
            return ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(item.titulo),
                    subtitle: Text(item.descricao),
                    trailing: item.listIMG.isNotEmpty
                        ? Image.network(
                            item.listIMG.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Diretorio>> fetchDiretorios() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => Diretorio.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar diretórios');
    }
  }
}

class Diretorio {
  final String id;
  final String titulo;
  final String descricao;
  final List<String> listIMG;

  Diretorio({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.listIMG,
  });

  factory Diretorio.fromJson(Map<String, dynamic> json) {
    return Diretorio(
      id: json['_id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      listIMG: List<String>.from(json['listIMG'] ?? []),
    );
  }
}

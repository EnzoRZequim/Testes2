import 'dart:convert';  //Converte Json em obj Dart 
import 'package:flutter/material.dart';  //Widgets de design
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Diretório MongoDB', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async { //Pegar itens
    try {
      final response = await http.get( // mexer no caminho depois
        Uri.parse('http://192.168.0.3:3000/diretorio'),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body); 
          loading = false; //Verificar qunado add img
        });
      } else {
        throw Exception('Erro ao carregar itens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diretório MongoDB')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['titulo'] ?? 'Sem título',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item['descricao'] ?? 'Sem descrição'),
                        if (item['listIMG'] != null &&
                            item['listIMG'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Imagens:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List<Widget>.from(
                            item['listIMG'].map<Widget>(
                              (img) => Text('- $img'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchItems,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

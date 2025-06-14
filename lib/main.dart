import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';

void main() {
  runApp(const Qual_CEP());
}

class Qual_CEP extends StatelessWidget {
  const Qual_CEP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CEP no flutter Map",
      home: const TelaMapa(),
    );
  }
}

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final TextEditingController _cepController = TextEditingController();
  latlong.LatLng _centroAtual = const latlong.LatLng(-15.7942, -47.8825);
  double _zoomAtual = 4.0;
  final MapController _mapController = MapController();

  String _logradouro = '';
  String _bairro = '';
  String _localidade = '';
  String _uf = '';
  

  bool _isLoading = false;

Future<void> _buscaCep() async {
  final String cepInput = _cepController.text;
  final String cep = cepInput.replaceAll(RegExp("[^0-9]"), "");

  if (cep.length != 8) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CEP inválido. Informe 8 dígitos.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final response = await http.get(Uri.parse("https://viacep.com.br/ws/$cep/json/"));
    final data = json.decode(response.body);

    if (data['erro'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _logradouro = data['logradouro'] ?? '';
      _bairro = data['bairro'] ?? '';
      _localidade = data['localidade'] ?? '';
      _uf = data['uf'] ?? '';
    });

    final endereco = "${_logradouro},${_bairro},${_localidade},${_uf}";

    final locais = await locationFromAddress(endereco);

    if (locais.isNotEmpty) {
      final loc = locais.first;
      final novaPos = latlong.LatLng(loc.latitude, loc.longitude);

      setState(() {
        _centroAtual = novaPos;
        _zoomAtual = 16.0;
      });

      _mapController.move(novaPos, _zoomAtual);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao buscar CEP: $cep')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QUAL_CEP?",
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade400,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _cepController,
                  decoration: const InputDecoration(
                    labelText: "Informe o CEP Para consultar",
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal, // pode mudar a cor também, se quiser
              ),
                    hintText: "EX:59598000",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
             ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _buscaCep,
                  icon: const Icon(Icons.search),
                  label: const Text("Buscar CEP"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Indicador de carregamento ou exibição dos dados
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: Colors.teal)),

                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_logradouro.isNotEmpty || _bairro.isNotEmpty || _localidade.isNotEmpty || _uf.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text("Logradouro: $_logradouro", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Bairro: $_bairro", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Localidade: $_localidade", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("UF: $_uf", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centroAtual,
                initialZoom: _zoomAtual,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.map_cep',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _centroAtual,
                      child:
                          const Icon(Icons.location_on, size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectTopicPage extends StatefulWidget {
  @override
  _SelectTopicPageState createState() => _SelectTopicPageState();
}

class _SelectTopicPageState extends State<SelectTopicPage> {
  String _selectedTopic = 'SinNotificacion';

  @override
  void initState() {
    super.initState();
    _loadInitialTopic();
  }

  // Cargar el topic guardado inicialmente
  Future<void> _loadInitialTopic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTopic = prefs.getString('selectedTopic') ?? 'SinNotificacion';
    setState(() {
      _selectedTopic = savedTopic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Topic'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 120, // Ajusta la posición vertical
            left: 120,
            right: 120,
            child: Container(
              color:
                  const Color.fromARGB(255, 124, 23, 99), // Solo como ejemplo
              height: 100,
            ),
          ),
          _fondopantalla(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _comboboxTopics(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Espaciado lateral
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.2, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(174, 255, 255, 255),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _getDetailsForTopic(_selectedTopic),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 28, 52, 100),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Regresar sin guardar
                    },
                    child: const Text(
                      'Regresar',
                      style:
                          TextStyle(color: Color.fromARGB(255, 158, 197, 58)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 158, 197, 58),
                    ),
                    onPressed: () {
                      saveTopicPreference(_selectedTopic);
                      Navigator.pop(
                          context, _selectedTopic); // Regresar y guardar
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Color.fromARGB(255, 28, 52, 100)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // Obtener detalles del topic seleccionado
  String _getDetailsForTopic(String topic) {
    switch (topic) {
      case 'SinNotificacion':
        return 'sin notificaciones.';
      case 'Comercial':
        return 'notificaciones de Balanza, Muestras y Laboratorio Quimico';
      case 'Muestras':
        return 'notificaciones de Balanza';
      case 'LabQuimico':
        return 'notificaciones de Muestras';
      case 'Tesoreria':
        return 'notificaciones de Comercial';
      default:
        return '';
    }
  }

  // Fondo de pantalla
  Widget _fondopantalla() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/fondoverde.jpg?alt=media&token=fd4e91e5-d3df-457f-aca7-d1f0c2384a67'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ComboBox para seleccionar el topic
  Widget _comboboxTopics() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 158, 197, 58),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 28, 52, 100).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: _selectedTopic,
        onChanged: (String? newValue) {
          setState(() {
            _selectedTopic = newValue!;
          });
        },
        items: <String>[
          'SinNotificacion',
          'Comercial',
          'Muestras',
          'LabQuimico',
          'Tesoreria'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          );
        }).toList(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color.fromARGB(255, 28, 52, 100),
        ),
        dropdownColor: const Color.fromARGB(255, 158, 197, 58),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        underline: Container(
          height: 2,
          color: const Color.fromARGB(255, 28, 52, 100),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // Guardar el topic seleccionado en SharedPreferences
  Future<void> saveTopicPreference(String topic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTopic', topic);
    print('Topic guardado: $topic');
  }
}

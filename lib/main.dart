import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'paginas/selecciontopic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Inicializa Firebase

  // Solicitar permisos de notificaciones
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Configurar mensaje en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Handler para recibir notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje recibido en segundo plano: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _selectedTopic = '';

  @override
  void initState() {
    super.initState();
    setupNotifications();
    loadTopicPreference();

    // Escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');
      showNotification(message);
    });

    // Escuchar cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Notificación abierta por el usuario: ${message.notification?.title}');
    });
  }

  // Configuración de notificaciones locales y canal
  void setupNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Mostrar notificación local al recibir mensaje en primer plano
  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: 'ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  // Cargar el topic guardado
  Future<void> loadTopicPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTopic = prefs.getString('selectedTopic');
    if (savedTopic != null) {
      setState(() {
        _selectedTopic = savedTopic;
      });
    }
  }

  //............... Cambiar suscripción al topic......................
  //.......................................................v..................
  Future<void> changeTopicSubscription(String newTopic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Lista de todos los topics posibles
    List<String> topics = [
      'SinNotificacion',
      'Comercial',
      'Muestras',
      'LabQuimico',
      'Tesoreria'
    ];

    // Desuscribirse de todos los topics
    for (String topic in topics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print("Desuscrito de: $topic");
    }

    // Suscribirse al nuevo topic
    await FirebaseMessaging.instance.subscribeToTopic(newTopic);
    print("Suscrito a: $newTopic");

    // Guardar el nuevo topic en SharedPreferences
    await prefs.setString('selectedTopic', newTopic);
    print("Topic guardado: $newTopic");

    // Actualizar el estado de la UI
    setState(() {
      _selectedTopic = newTopic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //......fondo de imagen.........
          _fondoConImagen(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //.......imagen de logo..........
                _imagenLogoEIL(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 220.0, left: 25.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              '¡Bienvenido de vuelta!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Diseñando y calzando soluciones para los procesos empresariales',
                                style: TextStyle(
                                  color: Color.fromARGB(138, 0, 0, 0),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Portal corporativo',
                                style: TextStyle(
                                  color: Color.fromARGB(138, 0, 0, 0),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _botonEilcorp(),
                            const SizedBox(height: 10),
                            _botonSeleccionarTopic(),
                            const SizedBox(height: 25),
                            Text(
                              'Modulo: $_selectedTopic',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Diseñado por el área de T.I.',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonEilcorp() {
    return ElevatedButton.icon(
      onPressed: () {
        _launchURL('https://gestion.grupoeilcorp.com/');
      },
      icon: const Icon(Icons.public, color: Color.fromARGB(255, 28, 52, 100)),
      label: const Text(
        ' WEB EILCORP',
        style: TextStyle(color: Color.fromARGB(255, 28, 52, 100)),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        backgroundColor: const Color.fromARGB(255, 158, 197, 58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
      ),
    );
  }

  Widget _botonSeleccionarTopic() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 28, 52, 100),
      ),
      onPressed: () async {
        // Llama a _loginCambios antes de navegar a la nueva página
        bool loginSuccessful = await _loginCambios(context);

        // Solo navega si el inicio de sesión fue exitoso
        if (loginSuccessful) {
          final newTopic = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectTopicPage()),
          );

          if (newTopic != null && newTopic != _selectedTopic) {
            await changeTopicSubscription(newTopic);
          }
        }
      },
      child: const Text(
        'Seleccionar Modulo',
        style: TextStyle(
          color: Color.fromARGB(255, 158, 197, 58),
        ),
      ),
    );
  }

  Widget _imagenLogoEIL() {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: Image.network(
        'https://firebasestorage.googleapis.com/v0/b/cajaimagnes.appspot.com/o/grupo-eilcorp.png?alt=media&token=4c1e193a-531d-457d-932e-7e7142e6dc0c',
        height: 55,
      ),
    );
  }

  Widget _fondoConImagen() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://gestion.grupoeilcorp.com/assets/images/background/background-1.jpg'),
          fit: BoxFit.fitWidth,
          alignment: Alignment(1.5, 1.7),
        ),
      ),
    );
  }

  Future<bool> _loginCambios(BuildContext context) async {
    String username = '';
    String password = '';

    bool loginSuccess = false;

    // Muestra la alerta de inicio de sesión
    await Alert(
      context: context,
      title: "LOGIN",
      content: Column(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              username = value;
            },
            decoration: InputDecoration(
              icon: Icon(Icons.account_circle),
              labelText: 'Username',
            ),
          ),
          TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: 'Password',
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            // Aquí va la lógica de verificación
            if (_verificarCredenciales(username, password)) {
              loginSuccess = true;
              Navigator.pop(context); // Cierra la alerta
            } else {
              _mostrarAlerta(
                  context); // Muestra alerta si las credenciales son incorrectas
            }
          },
          color: Color.fromARGB(255, 158, 197, 58), // Cambia el color aquí

          child: Text(
            "LOGIN",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();

    return loginSuccess; // Devuelve el resultado
  }

// Función que verifica las credenciales (aquí debes agregar tu lógica)
  bool _verificarCredenciales(String username, String password) {
    // Lógica de validación (ejemplo: comparar con valores fijos)
    return username == "usuario" && password == "contraseña";
  }

// Función para mostrar la alerta de error
//.................................................................................cAMBIAR ACA
//.................................................................................cAMBIAR ACA
  void _mostrarAlerta(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.black, fontSize: 20),
        descStyle: TextStyle(color: Colors.black54),
        // Agrega más personalizaciones si lo deseas
      ),
      type: AlertType.error,
      title: "AVISO DE ALERTA",
      desc: "SU IP ESTA SIENDO REGISTRADA",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
          child: Text(
            "ACEPTAR",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(Uri.encodeFull(url));
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error al intentar abrir la URL: $e');
    }
  }
}

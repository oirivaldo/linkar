import 'package:flutter/material.dart';
import '../classes/usuario.dart';
import '../main.dart';

class TelaGerirUsuarios extends StatefulWidget {
  @override
  _TelaGerirUsuariosState createState() => _TelaGerirUsuariosState();
}

class _TelaGerirUsuariosState extends State<TelaGerirUsuarios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerir Usuarios'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: _buildLayout(3),
              );
            } else {
              return _buildLayout(3);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLayout(int crossAxisCount) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: FutureBuilder<List<Usuario>>(
              future: transformarUsuarioToList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  final double progressSize = 40.0;
                  return Center(
                    child: Container(
                      width: progressSize,
                      height: progressSize,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4.0,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum dado encontrado.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final usuario = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detalhesUsuario',
                            arguments: usuario,
                          );
                        },
                        child: ListTile(
                          trailing: Icon(Icons.person,),
                          title: Text(
                              '${usuario.nomeUsuario}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(usuario.nomeTipoPerfil),
                              Text('ID: ${usuario.idUsuario}'),
                            ],),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        _buildButtons(crossAxisCount),
      ],
    );
  }

  Widget _buildButtons(int crossAxisCount) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: EdgeInsets.all(8.0),
      shrinkWrap: true,
      children: [
        _buildActionButton("Cadastrar Usuário", Icons.add, () {
          // Não implementado
        }),
        _buildActionButton("Editar Usuário", Icons.edit, () {
          // Não implementado
        }),
        _buildActionButton("Alterar Perfil de Acesso", Icons.bolt, () {
          // Não implementado
        }),
        _buildActionButton("Pesquisar Usuários", Icons.search, () {
          // Não implementado
        }),
        _buildActionButton("Relatório de Utilização", Icons.analytics, () {
          // Não implementado
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Function() onPressed) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38.0),
            SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unasp_ht/app/app_bloc.dart';
import 'package:unasp_ht/app/app_module.dart';
import 'package:unasp_ht/app/pages/login/signup/enums/category_enum.dart';
import 'package:unasp_ht/app/shared/components/labeled.dart';
import 'package:unasp_ht/app/shared/utils/string_extensions.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

   @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }
  
  Color get primaryColor => Theme.of(context).primaryColor;
  AppBloc bloc = AppModule.to.getBloc();
  File imagem;
  bool statusUpload = false;
  String idUsuarioLogado;
  String url;
  String urlImagemRecuperada;
  
/*__________________SELECIONAR IMAGEM DA GALERIA OU DA CÂMERA______________________________ */
  Future recuperarImagem(bool daCamera) async {
    File imagemSelecionada;
    if (daCamera) {
      imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);} //camera
    else {
      imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);}//galeria
    setState(() {
      imagem = imagemSelecionada;
      if( imagem != null ){
        statusUpload = true;
        uploadImagem();
      }
    });
  }

/*___________________________ENVIAR IMAGEM______________________________ */
  Future uploadImagem() async {
    //Referenciar arquivo
   FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child('fotos').child(idUsuarioLogado + '.jpg');

    //Fazer upload da imagem
    StorageUploadTask task = arquivo.putFile(imagem);

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {

      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          statusUpload = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          statusUpload = false;
        });
      }
    });
    await task.onComplete.then((StorageTaskSnapshot snap) {
      recuperarUrlImagem(snap);
    });

    //Recuperar url da imagem
    await task.onComplete.then((StorageTaskSnapshot snapshot) {
      recuperarUrlImagem(snapshot);
    });
  }

  /*_____________________RECUPERAR URL IMAGEM____________________________ */
  Future recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = (await snapshot.ref.getDownloadURL()) as String;    
    atualizarUrlImagemFirestore( url );
    setState(() {
      urlImagemRecuperada = url;
      print('++++++++++++++ url: ' + url);
    });
  }
  
  void atualizarUrlImagemFirestore(String url) {
    Firestore db = Firestore.instance;
    final Map<String, dynamic> dadosAtualizar = <String, dynamic>{};
     dadosAtualizar['url'] = url;
     db.collection('users')
     .document(idUsuarioLogado)
     .updateData(dadosAtualizar);
  }

  void recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    idUsuarioLogado = usuarioLogado.uid;
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection('users')
      .document( idUsuarioLogado )
      .get();
      
    Map<String, dynamic> dados = snapshot.data;    
    if( dados['url'] != null ){
      urlImagemRecuperada = dados['url'] as String;
    }
  }

 

  @override
  Widget build(BuildContext context) {
    String genre =
        bloc.currentUser.value.genre == 'F' ? 'Feminino' : 'Masculino';

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: Column(             
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                  urlImagemRecuperada != null
                      ? NetworkImage(urlImagemRecuperada)
                      : null
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      label: Text('Câmera',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                      ),
                      elevation: 10,
                      padding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                      onPressed: () {
                        recuperarImagem(true);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      textColor: Colors.white,
                      splashColor: Colors.red,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 35),
                    RaisedButton.icon(
                      label: Text('Galeria  ',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.photo_library,
                        color: Colors.white,
                      ),
                      elevation: 10,
                      padding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                      onPressed: () {
                        recuperarImagem(false);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      textColor: Colors.white,
                      splashColor: Colors.red,
                      color: Colors.lightBlue[600],
                    ),

                  ],
                ),
                Container(
                  //padding: EdgeInsets.only(top: 10),                 
                  child: statusUpload 
                  ? CircularProgressIndicator() 
                  : Container(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                  child: Column(
                    children: <Widget>[
                      Labeled(
                        label: 'nome',
                        text: bloc.currentUser.value.name,
                        icon: FontAwesomeIcons.userAlt,
                        inline: false,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Visibility(
                        visible: !bloc.currentUser.value.ra.isNullOrEmpty,
                        child: Column(
                          children: <Widget>[
                            Labeled(
                              label: 'ra',
                              text: bloc.currentUser.value.ra,
                              icon: FontAwesomeIcons.idCard,
                              inline: false,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                      Labeled(
                        label: 'email',
                        text: bloc.currentUser.value.email.toLowerCase(),
                        icon: FontAwesomeIcons.solidEnvelope,
                        inline: false,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Labeled(
                        label: 'gênero: ',
                        text: genre,
                        icon: FontAwesomeIcons.venusMars,
                        inline: false,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Labeled(
                        label: 'categorias',
                        text:
                            '${stringValue(bloc.currentUser.value.mainCategory.index)} \n${stringValue(bloc.currentUser.value.secondaryCategory?.index)}',
                        icon: FontAwesomeIcons.infoCircle,
                        inline: false,
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

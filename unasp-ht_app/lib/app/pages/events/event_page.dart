import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unasp_ht/app/app_bloc.dart';
import 'package:unasp_ht/app/app_module.dart';
import 'package:unasp_ht/app/pages/events/event_bloc.dart';
import 'package:unasp_ht/app/pages/events/event_card.dart';
import 'package:unasp_ht/app/pages/events/event_model.dart';
import 'package:unasp_ht/app/pages/events/event_module.dart';
import 'package:unasp_ht/app/pages/events/new_event_page.dart';
import 'package:unasp_ht/app/pages/login/signup/components/loading_widget.dart';
import 'package:unasp_ht/app/pages/login/signup/enums/category_enum.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final EventBloc _bloc = EventModule.to.getBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lista eventos'.toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              StreamBuilder<List<Eventos>>(
                stream: _bloc.eventos,
                builder: (c,s) {
                  if (!s.hasData) {
                    return Center(
                      child: LoadingWidget(),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.vertical,
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemBuilder: (c, i) => EventCard(eventos: s.data[i]),
                    itemCount: s.data.length,
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: AppModule.to.getBloc<AppBloc>().currentUser.value.mainCategory != CategoryEnum.Admin
          ? null
          : FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(FontAwesomeIcons.plus),
              onPressed: () => Navigator.of(context).push<CupertinoPageRoute>(
                CupertinoPageRoute(builder: (context) => NewEventPage())))
      );
  }
}

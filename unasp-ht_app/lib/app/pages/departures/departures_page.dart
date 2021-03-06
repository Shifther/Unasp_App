import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unasp_ht/app/app_bloc.dart';
import 'package:unasp_ht/app/app_module.dart';
import 'package:unasp_ht/app/pages/departures/components/departure_card.dart';
import 'package:unasp_ht/app/pages/departures/departures_bloc.dart';
import 'package:unasp_ht/app/pages/departures/departures_module.dart';
import 'package:unasp_ht/app/pages/departures/models/departure_model.dart';
import 'package:unasp_ht/app/pages/departures/pages/new_departure/new_departure_page.dart';
import 'package:unasp_ht/app/pages/login/signup/components/loading_widget.dart';
import 'package:unasp_ht/app/pages/login/signup/enums/category_enum.dart';

class DeparturesPage extends StatefulWidget {
  @override
  _DeparturesPageState createState() => _DeparturesPageState();
}

class _DeparturesPageState extends State<DeparturesPage> {
  final DeparturesBloc _bloc = DeparturesModule.to.getBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saídas'.toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            StreamBuilder<List<Departure>>(stream: _bloc.departures,
              builder: (c, s) {
                if (!s.hasData) {
                  return Center(
                    child: LoadingWidget(),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (c, i) => DepartureCard(departure: s.data[i]),
                  itemCount: s.data.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: AppModule.to.getBloc<AppBloc>()
      .currentUser.value.mainCategory != CategoryEnum.Admin
          ? null
          : FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(FontAwesomeIcons.plus),
              onPressed: () => Navigator.of(context).push<CupertinoPageRoute>(
                CupertinoPageRoute(builder: (context) => NewDeparturePage(),
                ),
              ),
            ),
    );
  }
}

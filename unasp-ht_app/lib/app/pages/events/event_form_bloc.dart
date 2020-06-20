import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unasp_ht/app/shared/utils/string_extensions.dart';

class EventFormBloc extends BlocBase {
  TextEditingController tituloController = TextEditingController();
  TextEditingController inicioDateController = TextEditingController();
  TextEditingController inicioTimeController = TextEditingController();
  TextEditingController terminoDateController = TextEditingController();
  TextEditingController terminoTimeController = TextEditingController();
  TextEditingController obsController = TextEditingController();
  TextEditingController localController = TextEditingController();
  TextEditingController zraController = TextEditingController();

  BehaviorSubject<DateTime> inicioDateC = BehaviorSubject<DateTime>();
  BehaviorSubject<DateTime> terminoDateC = BehaviorSubject<DateTime>();

  EventFormBloc() {
    tituloController.addListener(validate);
    inicioDateController.addListener(validate);
    inicioTimeController.addListener(validate);
    terminoDateController.addListener(validate);
    terminoTimeController.addListener(validate);
    obsController.addListener(validate);
    localController.addListener(validate);
    inicioDateC.listen((onData) {if (onData != null) {
        inicioDateController.text = DateFormat('dd/MM/yyyy').format(onData);
        inicioTimeController.text = DateFormat('HH:mm').format(onData) + ' h';
      }});
    terminoDateC.listen((onData) {if (onData != null) {
        terminoDateController.text = DateFormat('dd/MM/yyyy').format(onData);
        terminoTimeController.text = DateFormat('HH:mm').format(onData) + ' h';
      }});
       zraController.addListener(validate);
  }

  void clearFields() {
    tituloController.clear();
    inicioDateController.clear();
    inicioTimeController.clear();
    terminoDateController.clear();
    terminoTimeController.clear();
    obsController.clear();
    localController.clear();
    inicioDateC.add(null);
    terminoDateC.add(null);
  }

  final BehaviorSubject<bool> isValidFormController =
      BehaviorSubject<bool>.seeded(false);

  void validate() => isValidFormController.add(inicioDateC.value != null &&
      terminoDateC.value != null &&
      !tituloController.text.isNullOrEmpty &&
      !localController.text.isNullOrEmpty &&
      !obsController.text.isNullOrEmpty);

  @override
  void dispose() {
    inicioDateC.close();
    terminoDateC.close();
    super.dispose();
  }
}

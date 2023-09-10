import 'package:excel_example/button_widget.dart';
import 'package:excel_example/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gamepage.dart';

class UserFormWidget extends StatefulWidget {
  // const UserFormWidget({super.key});

  final ValueChanged<User> onSavedUser;

  const UserFormWidget({
    Key? key,
    required this.onSavedUser,
  }) : super(key: key);

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

late String name;
late int type;
// late final age;

class _UserFormWidgetState extends State<UserFormWidget> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController controllerChildName;
  late bool isBoy;
  late bool rightHanded;
  late TextEditingController controllerAge;
  late TextEditingController controllerTesterName;
  late TextEditingController controllerKinderGardenName;
  late TextEditingController controllerTestType;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  void initUser() {
    controllerChildName = TextEditingController();
    isBoy = true;
    rightHanded = true;
    controllerAge = TextEditingController();
    controllerTesterName = TextEditingController();
    controllerKinderGardenName = TextEditingController();
    controllerTestType = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildName(),
            const SizedBox(
              height: 16,
            ),
            buildAge(),
            const SizedBox(
              height: 16,
            ),
            buildTesterName(),
            const SizedBox(
              height: 16,
            ),
            buildKinderGardenName(),
            const SizedBox(
              height: 16,
            ),
            buildTestType(),
            const SizedBox(
              height: 16,
            ),
            buildIsBoy(),
            const SizedBox(
              height: 16,
            ),
            buildRightHanded(),
            const SizedBox(
              height: 16,
            ),
            buildSubmit(),
          ],
        ),
      );

  Widget buildName() => TextFormField(
      controller: controllerChildName,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        value != null && value.isEmpty ? 'Enter Child Name' : null;
        name = value!;
        return null;
      });

  Widget buildAge() => TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        controller: controllerAge,
        decoration: const InputDecoration(
          labelText: 'Age',
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value != null && value.isEmpty ? 'Enter Age' : null,
      );

  Widget buildTesterName() => TextFormField(
        controller: controllerTesterName,
        decoration: const InputDecoration(
          labelText: 'Tester Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value != null && value.isEmpty ? 'Enter Tester Name' : null,
      );

  Widget buildKinderGardenName() => TextFormField(
        controller: controllerKinderGardenName,
        decoration: const InputDecoration(
          labelText: 'School Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value != null && value.isEmpty ? 'Enter Kinder Garden Name' : null,
      );

  Widget buildTestType() => TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[12]')),
        LengthLimitingTextInputFormatter(1),
      ],
      controller: controllerTestType,
      decoration: const InputDecoration(
        labelText: 'Test Type(1-MainTest, 2-Inhibition)',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        value != null && value.isEmpty ? 'Enter Test Type' : null;
        type = int.parse(value!);
        return null;
      });

  Widget buildIsBoy() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: isBoy,
        title: const Text('Is Boy?'),
        onChanged: (value) => setState(() {
          isBoy = value;
        }),
      );

  Widget buildRightHanded() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: rightHanded,
        title: const Text('Right Handed?'),
        onChanged: (value) => setState(() {
          rightHanded = value;
        }),
      );

  Widget buildSubmit() => ButtonWidget(
        text: 'Start',
        onClicked: () {
          final form = formKey.currentState!;
          final isValid = form.validate();

          if (isValid) {
            final user = User(
              childName: controllerChildName.text,
              age: controllerAge.text,
              isBoy: isBoy,
              rightHanded: rightHanded,
              testerName: controllerTesterName.text,
              kinderGardenName: controllerKinderGardenName.text,
              testType: controllerTestType.text,
              correctAnswers: 0,
              wrongAnswers: 0,
            );
            widget.onSavedUser(user);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => GamePage()));
          }
        },
      );
}

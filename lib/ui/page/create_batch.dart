import 'package:filter_list/filter_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/helper/utility.dart';
import 'package:flutter_pensil_app/model/batch_time_slot_model.dart';
import 'package:flutter_pensil_app/resources/contact_service.dart';
import 'package:flutter_pensil_app/states/create_batch_state.dart';
import 'package:flutter_pensil_app/ui/kit/alert.dart';
import 'package:flutter_pensil_app/ui/page/create_batch/add_students_widget.dart';
import 'package:flutter_pensil_app/ui/page/create_batch/batch_time_slots.dart';
import 'package:flutter_pensil_app/ui/theme/light_color.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';
import 'package:flutter_pensil_app/ui/widget/form/p_textfield.dart';
import 'package:flutter_pensil_app/ui/widget/p_button.dart';
import 'package:flutter_pensil_app/ui/widget/p_chiip.dart';
import 'package:flutter_pensil_app/ui/widget/secondary_app_bar.dart';
import 'package:provider/provider.dart';

class CreateBatch extends StatefulWidget {
  CreateBatch({Key key}) : super(key: key);

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<CreateBatchStates>(
        create: (context) => CreateBatchStates(),
        child: CreateBatch(),
      ),
    );
  }

  @override
  _CreateBatchState createState() => _CreateBatchState();
}

class _CreateBatchState extends State<CreateBatch> {
  TextEditingController _contactController;
  TextEditingController _name;
  TextEditingController _description;
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _contactController = TextEditingController();
    _name = TextEditingController();
    _description = TextEditingController();
    super.initState();
  }

  Widget _subjects(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CreateBatchStates>(
      builder: (context, state, child) {
        return state.availableSubjects == null
            ? SizedBox.shrink()
            : SizedBox(
                width: AppTheme.fullWidth(context),
                child: Wrap(
                    children: state.availableSubjects
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8) +
                                EdgeInsets.only(right: 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: e.isSelected
                                      ? PColors.green
                                      : theme.dividerColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                e.name,
                                style: theme.textTheme.bodyText1.copyWith(
                                    fontSize: 10,
                                    color: !e.isSelected
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ).ripple(() {
                              Provider.of<CreateBatchStates>(context,
                                      listen: false)
                                  .setSelectedSubjects = e.name;
                            }, borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                        .toList()),
              );
      },
    );
  }

  Widget _title(context, String name) {
    return Text(name,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _secondaryButton(BuildContext context,
      {String label, Function onPressed}) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Icon(Icons.add_circle, color: PColors.primary, size: 17),
        SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.button
              .copyWith(color: PColors.primary, fontWeight: FontWeight.bold),
        )
      ],
    ).vP8.ripple(onPressed);
  }

  void displayStudentsList() async {
    await FilterListDialog.display(context,
        allTextList: Provider.of<CreateBatchStates>(context, listen: false)
            .studentsList
            .map((e) => e.name)
            .toList(),
        height: 480,
        borderRadius: 20,
        headlineText: "Select Students",
        searchFieldHintText: "Search Here",
        hidecloseIcon: true,
        selectedTextList: Provider.of<CreateBatchStates>(context, listen: false)
            .selectedStudentsListTemp, onApplyButtonClick: (list) {
      if (list != null && list.isNotEmpty) {
        Provider.of<CreateBatchStates>(context, listen: false)
            .setStudentsFromList = list;
      }
      Navigator.pop(context);
    });
  }

  void createBatch() async {
      final state = Provider.of<CreateBatchStates>(context, listen: false);
      // validate batch name and batch description
      final isTrue = _formKey.currentState.validate();
      //validate timeSlots
      var isValidTimeSlots = state.checkSlotsVAlidations();
      if (!isTrue) {
        return;
      }
      if (!isValidTimeSlots) {
        return;
      }
      //validate Subjects
     if(state.selectedSubjects == null){
       Utility.displaySnackbar(context,msg: "Please select a subject",key:scaffoldKey);
       return;
     }
      //validate Students
     if(state.selectedStudentsListTemp == null && state.contactList == null){
       Utility.displaySnackbar(context,msg: "Please Add students to batch",key:scaffoldKey);
       return;
     }

      isLoading.value = true;
      state.setBatchName = _name.text;
      state.setBatchdescription = _description.text;
      final isBatchCreated = await state.createBatch();
      isLoading.value = false;
    if (isBatchCreated) {
      Alert.sucess(context,
          message: "Batch is sucessfully created!!", title: "Message");
    } else {
      Alert.sucess(context,
          message: "Some error occured. Please try again in some time!!",
          title: "Message", height:170);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar("Create Batch"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PTextField(
                  type: Type.text,
                  controller: _name,
                  label: "Batch Name",
                  hintText: "Enter batch name",
                ),
                PTextField(
                  type: Type.text,
                  controller: _description,
                  label: "Description",
                  hintText: "Description",
                ),
                _title(context, "Pick Subject"),
                _subjects(context),
                SizedBox(height: 10),
                _title(context, "Add Class"),
                // SizedBox(height: 10),
                // BatchTimeSlotWidget(model: BatchTimeSlotModel.initial()),
                SizedBox(height: 10),
                Consumer<CreateBatchStates>(
                  builder: (context, state, child) {
                    return state.timeSlots == null
                        ? SizedBox()
                        : Column(
                            children: state.timeSlots
                                .map((e) => BatchTimeSlotWidget(
                                      model: state.timeSlots[e.index],
                                    ).vP5)
                                .toList());
                  },
                ),
                _secondaryButton(context, label: "Add Class", onPressed: () {
                  Provider.of<CreateBatchStates>(context, listen: false)
                      .setTimeSlots(BatchTimeSlotModel.initial());
                }),
                SizedBox(height: 10),
                _title(context, "Add Students"),
                SizedBox(height: 10),
                AddStudentsWidget(
                  controller: _contactController,
                ),
                Text(
                  "An SMS & whatsapp invite will be sent to the above number",
                  style: theme.textTheme.bodyText2.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.subtitle2.color),
                ).vP8,
                SizedBox(height: 4),
                Consumer<CreateBatchStates>(
                  builder: (context, state, child) {
                    return state.selectedStudentsList == null
                        ? SizedBox()
                        : Wrap(
                            children: state.selectedStudentsList
                                .map((e) => CircleAvatar(
                                    radius: 15,
                                    child: Text(
                                      e.name.substring(0, 2).toUpperCase(),
                                      style: theme.textTheme.caption.copyWith(
                                          fontSize: 12,
                                          color: theme.colorScheme.onPrimary),
                                    )).p(5))
                                .toList());
                  },
                ),
                // SizedBox(height: 10),
                _secondaryButton(context,
                    label: "PIck Student", onPressed: displayStudentsList),
                SizedBox(height: 10),
                PFlatButton(
                  label: "Create",
                  isLoading: isLoading,
                  onPressed: createBatch,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

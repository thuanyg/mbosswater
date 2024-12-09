import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mbosswater/core/constants/constants.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/styles/app_assets.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/function_utils.dart';
import 'package:mbosswater/core/utils/image_helper.dart';
import 'package:mbosswater/core/widgets/custom_button.dart';
import 'package:mbosswater/core/widgets/filter_dropdown.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/agency/presentation/page/agency_staff_management.dart';
import 'package:mbosswater/features/customer/presentation/widgets/customer_card_item_shimmer.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/create_agency_bloc.dart';
import 'package:mbosswater/features/mboss/presentation/bloc/fetch_agencies_bloc.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossAgencyManagement extends StatefulWidget {
  const MbossAgencyManagement({super.key});

  @override
  State<MbossAgencyManagement> createState() => _MbossAgencyManagementState();
}

class _MbossAgencyManagementState extends State<MbossAgencyManagement> {
  // Value Notifier
  ValueNotifier<bool> isFabVisible = ValueNotifier<bool>(true);
  ValueNotifier<String?> selectedDateFilter = ValueNotifier(null);
  ValueNotifier<String?> selectedSortFilter = ValueNotifier(null);

  // Bloc
  late FetchAgenciesBloc fetchAgenciesBloc;
  late CreateAgencyBloc createAgencyBloc;

  // Text editing controller
  final agencyNameController = TextEditingController();
  final agencyAddressController = TextEditingController();
  final agencyBossNameController = TextEditingController();
  final agencyBossPhoneController = TextEditingController();
  final agencyBossEmailController = TextEditingController();

  // FocusNode
  final agencyNameFocusNode = FocusNode();
  final agencyAddressFocusNode = FocusNode();
  final agencyBossNameFocusNode = FocusNode();
  final agencyBossPhoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    createAgencyBloc = BlocProvider.of<CreateAgencyBloc>(context);
    fetchAgenciesBloc = BlocProvider.of<FetchAgenciesBloc>(context);
    fetchAgenciesBloc.fetchAllAgencies();
  }

  @override
  void dispose() {
    super.dispose();
    agencyNameController.dispose();
    agencyAddressController.dispose();
    agencyBossNameController.dispose();
    agencyBossPhoneController.dispose();
    agencyBossEmailController.dispose();
    agencyNameFocusNode.dispose();
    agencyAddressFocusNode.dispose();
    agencyBossNameFocusNode.dispose();
    agencyBossPhoneFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: isFabVisible,
        builder: (context, value, child) {
          return Visibility(
            visible: value,
            child: GestureDetector(
              onTap: () async => await showAgencyCreation(),
              child: Container(
                margin: const EdgeInsets.only(right: 10, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              isFabVisible.value = true;
            } else if (notification.direction == ScrollDirection.reverse) {
              isFabVisible.value = false;
            }

            return true;
          },
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  scrolledUnderElevation: 0,
                  title: null,
                  snap: true,
                  centerTitle: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  expandedHeight: 190,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 4, right: 16),
                          child: Stack(
                            children: [
                              Container(
                                height: kToolbarHeight - 4,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  "Danh Sách Đại Lý",
                                  style: AppStyle.appBarTitle.copyWith(
                                    color: const Color(0xff820a1a),
                                  ),
                                ),
                              ),
                              Container(
                                height: kToolbarHeight,
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => context.pop(),
                                  icon: ImageHelper.loadAssetImage(
                                    AppAssets.icArrowLeft,
                                    tintColor: const Color(0xff111827),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Phần buildSliverAppBarContent
                        buildSliverAppBarContent(),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                const SizedBox(height: 10),

                BlocBuilder<FetchAgenciesBloc, List<Agency>>(
                  bloc: fetchAgenciesBloc,
                  builder: (context, state) {
                    if (fetchAgenciesBloc.isLoading) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: const CustomerCardShimmer(),
                          ),
                        ),
                      );
                    }

                    if (!fetchAgenciesBloc.isLoading && state.isNotEmpty) {
                      List<Agency> agencyOriginal =
                          fetchAgenciesBloc.getAgenciesOriginal;
                      List<Agency> agencyFiltered =
                          List.from(state); // Initialize with search result

                      // Apply sort filter
                      if (selectedSortFilter.value != null) {
                        if (selectedSortFilter.value == "Mới nhất") {
                          agencyFiltered.sort((a, b) => b.createdAt
                              .toDate()
                              .compareTo(a.createdAt.toDate()));
                        } else {
                          agencyFiltered.sort((a, b) => a.createdAt
                              .toDate()
                              .compareTo(b.createdAt.toDate()));
                        }
                      }

                      // Apply date filter
                      if (selectedDateFilter.value != null) {
                        final now = DateTime.now()
                            .toUtc()
                            .add(const Duration(hours: 7));
                        if (selectedDateFilter.value ==
                            filterByDateItems.first) {
                          agencyFiltered = agencyFiltered.where((item) {
                            final createdAt = item.createdAt.toDate();
                            return createdAt.year == now.year &&
                                createdAt.month == now.month;
                          }).toList();
                        } else if (selectedDateFilter.value ==
                            filterByDateItems.elementAt(1)) {
                          final last30Days =
                              now.subtract(const Duration(days: 30));
                          agencyFiltered = agencyFiltered.where((item) {
                            final createdAt = item.createdAt.toDate();
                            return createdAt.isAfter(last30Days) &&
                                createdAt.isBefore(now);
                          }).toList();
                        } else if (selectedDateFilter.value ==
                            filterByDateItems.elementAt(2)) {
                          final last90Days =
                              now.subtract(const Duration(days: 90));
                          agencyFiltered = agencyFiltered.where((item) {
                            final createdAt = item.createdAt.toDate();
                            return createdAt.isAfter(last90Days) &&
                                createdAt.isBefore(now);
                          }).toList();
                        } else if (selectedDateFilter.value ==
                            filterByDateItems.elementAt(3)) {
                          agencyFiltered = agencyFiltered.where((item) {
                            final createdAt = item.createdAt.toDate();
                            return createdAt.year == now.year;
                          }).toList();
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          itemCount: agencyFiltered.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: buildAgencyBox(agencyFiltered[index]),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Listener for create
                BlocListener<CreateAgencyBloc, bool>(
                  listener: (context, state) async {
                    if (createAgencyBloc.isLoading == false && state == true) {
                      DialogUtils.hide(context);
                      DialogUtils.hide(context);
                      agencyNameController.text = "";
                      agencyAddressController.text = "";
                      agencyBossNameController.text = "";
                      agencyBossPhoneController.text = "";
                      agencyBossEmailController.text = "";
                      await fetchAgenciesBloc.fetchAllAgencies();
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSliverAppBarContent() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xffEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SearchField(
            onSearch: (value) {
              fetchAgenciesBloc.searchAgency(value.trim().toLowerCase());
            },
          ),
        ),
        Divider(
          color: Colors.grey.shade400,
          height: 40,
          thickness: .2,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                valueListenable: selectedSortFilter,
                builder: (context, value, child) {
                  return FilterDropdown(
                    selectedValue: selectedSortFilter.value ?? "Mới nhất",
                    options: const ["Mới nhất", "Cũ nhất"],
                    onChanged: (value) {
                      setState(() {
                        selectedSortFilter.value = value;
                      });
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: selectedDateFilter,
                builder: (context, value, child) {
                  return FilterDropdown(
                    selectedValue: selectedDateFilter.value ?? "Tháng",
                    options: filterByDateItems,
                    onChanged: (value) {
                      setState(() {
                        selectedDateFilter.value = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAgencyBox(Agency agency) {
    return GestureDetector(
      onTap: () {
        context.push(
          "/mboss-edit-agency",
          extra: agency,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xffDADADA),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: FractionalOffset.centerLeft,
              child: Text(
                agency.name,
                style: const TextStyle(
                  fontFamily: "BeVietnam",
                  color: Color(0xff820a1a),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            buildRowInfoItem(
              label: "Mã đại lý",
              value: agency.code,
            ),
            buildRowInfoItem(
              label: "Địa chỉ",
              value: agency.address,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 2,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "BeVietnam",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAgencyCreation() async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, _, __) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 70,
              padding: const EdgeInsets.only(bottom: 50, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Đại Lý",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Tên đại lý",
                            isRequired: true,
                            controller: agencyNameController,
                            focusNode: agencyNameFocusNode,
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Địa chỉ chi tiết",
                            isRequired: true,
                            controller: agencyAddressController,
                            focusNode: agencyAddressFocusNode,
                          ),
                          const SizedBox(height: 23),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thông Tin Chủ Đại Lý",
                              style: AppStyle.heading2.copyWith(
                                color: AppColors.appBarTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Họ và tên",
                            isRequired: true,
                            controller: agencyBossNameController,
                            focusNode: agencyBossNameFocusNode,
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Số điện thoại",
                            isRequired: true,
                            controller: agencyBossPhoneController,
                            focusNode: agencyBossPhoneFocusNode,
                            keyboardType: TextInputType.phone,
                            formatter: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 23),
                          BoxFieldItem(
                            hintValue: "Email",
                            isRequired: false,
                            controller: agencyBossEmailController,
                          ),
                          const SizedBox(height: 36),
                          CustomButton(
                            onTap: () async => handleCreateAgency(),
                            height: 40,
                            textButton: "THÊM ĐẠI LÝ",
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  handleCreateAgency() async {
    String agencyName = agencyNameController.text.trim();
    String agencyAddress = agencyAddressController.text.trim();

    String bossName = agencyBossNameController.text.trim();
    String bossPhone = agencyBossPhoneController.text.trim();
    String bossEmail = agencyBossEmailController.text.trim();

    if (agencyName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập tên đại lý",
        onClickOutSide: () {},
      );
      agencyNameFocusNode.requestFocus();
      return;
    }

    if (agencyAddress.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập địa chỉ đại lý",
        onClickOutSide: () {},
      );
      agencyAddressFocusNode.requestFocus();
      return;
    }

    if (bossName.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập họ tên chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossNameFocusNode.requestFocus();
      return;
    }

    if (bossPhone.isEmpty) {
      DialogUtils.showWarningDialog(
        context: context,
        title: "Hãy nhập số điện thoại chủ đại lý",
        onClickOutSide: () {},
      );
      agencyBossPhoneFocusNode.requestFocus();
      return;
    }

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xác nhận thêm mới đại lý này?",
      textCancelButton: "HỦY",
      textAcceptButton: "XÁC NHẬN",
      cancelPressed: () => Navigator.pop(context),
      acceptPressed: () async {
        DialogUtils.hide(context);
        DialogUtils.showLoadingDialog(context);

        // Check phoneNumber of agency boss
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("phoneNumber", isEqualTo: bossPhone)
            .limit(1)
            .get();

        if (userDoc.docs.isEmpty) {
          // Add agency

          final agency = Agency(
            generateRandomId(8),
            "",
            agencyName,
            agencyAddress,
            Timestamp.now(),
            false,
          );

          agency.code = agency.generateAgencyCode(
              fetchAgenciesBloc.getAgenciesOriginal.length + 1);

          // Add agency boss
          String newPassword = "123456";
          String passwordEncrypted = EncryptionHelper.encryptData(
            newPassword,
            dotenv.env["SECRET_KEY_PASSWORD_HASH"]!,
          );

          // Get text field value
          final user = UserModel(
            id: generateRandomId(8),
            fullName: bossName,
            dob: null,
            email: bossEmail,
            gender: "Male",
            phoneNumber: bossPhone,
            role: Roles.AGENCY_BOSS,
            createdAt: Timestamp.now(),
            address: agencyAddress,
            agency: agency.id,
            password: passwordEncrypted,
            isDelete: false,
          );

          await createAgencyBloc.createAgency(agency: agency, boss: user);
        } else {
          DialogUtils.hide(context);
          agencyBossPhoneFocusNode.requestFocus();
          DialogUtils.showWarningDialog(
            context: context,
            title: "Số điện thoại đã được đăng ký!",
            onClickOutSide: () {},
          );
        }
      },
    );
  }
}

class BoxFieldItem extends StatefulWidget {
  final String hintValue;
  final bool isRequired;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatter;

  const BoxFieldItem({
    Key? key,
    required this.hintValue,
    this.isRequired = false,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.formatter = const [],
  }) : super(key: key);

  @override
  _BoxFieldItemState createState() => _BoxFieldItemState();
}

class _BoxFieldItemState extends State<BoxFieldItem> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff757575)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.formatter,
            style: AppStyle.bodyText.copyWith(
              color: const Color(0xffB3B3B3),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: InputBorder.none, // Remove the underline border
              hintText: widget.isRequired ? "" : widget.hintValue,
              hintStyle: widget.isRequired
                  ? null
                  : AppStyle.bodyText.copyWith(
                      color: const Color(0xffB3B3B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
          if (widget.isRequired && widget.controller.text.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: widget.hintValue,
                      style: AppStyle.bodyText.copyWith(
                        color: const Color(0xffB3B3B3),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text: ' * ',
                          style: TextStyle(
                            fontFamily: "BeVietnam",
                            color: Color(0xff820a1a),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

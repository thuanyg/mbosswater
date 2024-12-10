import 'package:flutter/material.dart';
import 'package:mbosswater/core/styles/app_colors.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCarePage extends StatefulWidget {
  const CustomerCarePage({super.key});

  @override
  State<CustomerCarePage> createState() => _CustomerCarePageState();
}

class _CustomerCarePageState extends State<CustomerCarePage> {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
  late ValueNotifier<DateTime> focusDayNotifier;

  final List<DateTime> specialDays = [
    DateTime.utc(2024, 12, 10),
    DateTime.utc(2024, 12, 15),
    DateTime.utc(2024, 12, 20),
  ];

  @override
  void initState() {
    super.initState();
    focusDayNotifier = ValueNotifier(now);
  }

  onDaySelected(DateTime day, DateTime focusDay) {
    focusDayNotifier.value = day;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      throw 'Không thể thực hiện cuộc gọi đến $phoneNumber';
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusDayNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Text(
          "Chăm Sóc Khách Hàng",
          style: AppStyle.appBarTitle.copyWith(
            color: AppColors.appBarTitleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: focusDayNotifier,
            builder: (context, value, child) {
              return TableCalendar(
                locale: 'vi_VN',
                focusedDay: value,
                firstDay: DateTime.utc(2023, 01, 01),
                lastDay: now.add(const Duration(days: 365 * 3)),
                rowHeight: 50,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerMargin: EdgeInsets.symmetric(vertical: 6),
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                daysOfWeekHeight: 24,
                calendarStyle: CalendarStyle(
                  todayTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueGrey.shade50,
                  ),
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableGestures: AvailableGestures.all,
                onDaySelected: onDaySelected,
                selectedDayPredicate: (day) =>
                    isSameDay(day, focusDayNotifier.value),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, events) {
                    // Kiểm tra nếu ngày trong danh sách specialDays thì thêm indicator
                    if (specialDays
                        .any((specialDay) => isSameDay(date, specialDay))) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 26,
                            bottom: 0,
                            child: Badge(
                              smallSize: 8,
                              backgroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    }
                    return null; // Không hiển thị gì nếu không phải ngày đặc biệt
                  },
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
enum Period { morning, evening }
enum ScheduleStatus { available, waiting_approval, scheduled }

class ScheduledEvent {
  int scheduledDate;
  Period period;
  String userId;
  ScheduleStatus status;

  ScheduledEvent({
    this.scheduledDate,
    this.period,
    this.userId,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        'scheduledDate': scheduledDate,
        'period': period.toString(),
        'userId': userId,
        'status': status.toString(),
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return ScheduledEvent(
      scheduledDate: parsedJson['scheduledDate'],
      period: periodFromString(parsedJson['period']),
      userId: parsedJson['userId'],
      status: scheduleStatusFromString(parsedJson['status']),
    );
  }

  static String periodToString(Period period) {
    switch (period) {
      case Period.morning:
        return "Período diurno";
      case Period.evening:
        return "Período noturno";
      default:
        return "Período diurno";
    }
  }

  static Period periodFromString(String period) {
    switch (period) {
      case "Period.morning":
        return Period.morning;
      case "Period.evening":
        return Period.evening;
      default:
        return Period.morning;
    }
  }

  static String scheduleStatusToString(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.available:
        return "Disponível";
      case ScheduleStatus.waiting_approval:
        return "Aguardando aprovação";
      case ScheduleStatus.scheduled:
        return "Agendado";
      default:
        return "Disponível";
    }
  }

  static ScheduleStatus scheduleStatusFromString(String status) {
    switch (status) {
      case "ScheduleStatus.available":
        return ScheduleStatus.available;
      case "ScheduleStatus.waiting_approval":
        return ScheduleStatus.waiting_approval;
      case "ScheduleStatus.scheduled":
        return ScheduleStatus.scheduled;
      default:
        return ScheduleStatus.available;
    }
  }
}

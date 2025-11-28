enum AppointmentStatus {
  scheduled('AGENDADO'),
  late('ATRASADO'),
  inProgress('EM ANDAMENTO'),
  completed('CONCLUÍDO'),
  cancelled('CANCELADO');

  final String description;
  
  const AppointmentStatus(this.description);
}

class Appointment {
  final String id;
  final DateTime dateTime;
  final String serviceName;
  final double price;
  final AppointmentStatus status;
  final String? vehiclePlate;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.serviceName,
    required this.price,
    required this.status,
    this.vehiclePlate,
  });
}

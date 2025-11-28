import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/features/appointments/domain/models/appointment_model.dart';

class AppointmentsPage extends StatelessWidget {
  final List<Appointment> appointments = [
    Appointment(
      id: '1',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      serviceName: 'Lavagem Completa',
      price: 80.0,
      status: AppointmentStatus.scheduled,
      vehiclePlate: 'ABC-1234',
    ),
    Appointment(
      id: '2',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      serviceName: 'Lavagem Simples',
      price: 50.0,
      status: AppointmentStatus.late,
      vehiclePlate: 'XYZ-5678',
    ),
    // Adicione mais agendamentos de exemplo conforme necessário
  ];

  AppointmentsPage({super.key});

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.late:
        return Colors.orange;
      case AppointmentStatus.inProgress:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                appointment.serviceName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}',
                  ),
                  Text('Veículo: ${appointment.vehiclePlate ?? 'Não informado'}'),
                  Text(
                    'Valor: R\${appointment.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getStatusColor(appointment.status)),
                ),
                child: Text(
                  appointment.status.description,
                  style: TextStyle(
                    color: _getStatusColor(appointment.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de novo agendamento
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

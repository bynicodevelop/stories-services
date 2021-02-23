import 'package:equatable/equatable.dart';

enum ReservationStatus {
  initial,
  slugAlreadyExists,
  phoneAlreadyExists,
  started,
  complete
}

class ReservationState extends Equatable {
  final ReservationStatus status;

  const ReservationState({
    this.status = ReservationStatus.initial,
  });

  ReservationState copyWith({ReservationStatus status}) {
    return ReservationState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}

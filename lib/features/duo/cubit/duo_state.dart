import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';
import '../models/partner_model.dart';

abstract class DuoState extends Equatable {
  const DuoState();

  @override
  List<Object?> get props => [];
}

class DuoInitial extends DuoState {}

class DuoLoading extends DuoState {}

class DuoLoaded extends DuoState {
  final DuoSession? session;
  final PartnerModel? partner;
  final Map<String, List<double>> weeklyReport;

  const DuoLoaded({
    this.session,
    this.partner,
    required this.weeklyReport,
  });

  @override
  List<Object?> get props => [session, partner, weeklyReport];
}

class DuoError extends DuoState {
  final String message;

  const DuoError(this.message);

  @override
  List<Object?> get props => [message];
}

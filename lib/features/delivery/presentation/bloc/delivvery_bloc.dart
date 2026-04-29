import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'delivvery_event.dart';
part 'delivvery_state.dart';

class DelivveryBloc extends Bloc<DelivveryEvent, DelivveryState> {
  DelivveryBloc() : super(DelivveryInitial()) {
    on<DelivveryEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

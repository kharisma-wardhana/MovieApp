import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class TrailerBloc extends Bloc<TrailerEvent, TrailerState> {
  final Repository repository;

  TrailerBloc({this.repository}) : super(InitialTrailer());

  @override
  Stream<TrailerState> mapEventToState(TrailerEvent event) async* {
    if (event is LoadTrailer) {
      yield* _mapLoadTrailerToState(event.movieId);
    }
  }

  Stream<TrailerState> _mapLoadTrailerToState(int movieId) async* {
    try {
      yield TrailerLoading();
      var movies = await repository.getMovieTrailer(
          movieId, ApiConstant.apiKey, ApiConstant.language);
      if (movies.trailer.isEmpty) {
        yield TrailerNoData();
      } else {
        yield TrailerHasData(movies);
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT ||
          e.type == DioErrorType.RECEIVE_TIMEOUT) {
        yield TrailerNoInternetConnection();
      } else if (e.type == DioErrorType.DEFAULT) {
        yield TrailerNoInternetConnection();
      } else {
        yield TrailerError(e.toString());
      }
    }
  }
}
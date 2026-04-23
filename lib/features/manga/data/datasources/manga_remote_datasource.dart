import 'package:appmanga/core/constants/api_constants.dart';
import 'package:appmanga/core/network/dio_client.dart';
import '../models/home_data_model.dart';
import '../models/manga_list_model.dart';

abstract class MangaRemoteDataSource {
  Future<HomeDataModel> getHomeData();
  Future<MangaListModel> getMangaList({
    int page = 1,
    int limit = 20,
    String? genre,
    String? status,
    String sort = 'latest',
    String? search,
  });
}

class MangaRemoteDataSourceImpl implements MangaRemoteDataSource {
  final DioClient _dioClient;

  MangaRemoteDataSourceImpl(this._dioClient);

  @override
  Future<HomeDataModel> getHomeData() async {
    final response = await _dioClient.dio.get(ApiConstants.home);
    return HomeDataModel.fromJson(response.data['data']);
  }

  @override
  Future<MangaListModel> getMangaList({
    int page = 1,
    int limit = 20,
    String? genre,
    String? status,
    String sort = 'latest',
    String? search,
  }) async {
    final response = await _dioClient.dio.get(
      search != null ? ApiConstants.mangaSearch : ApiConstants.manga,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (genre != null) 'genre': genre,
        if (status != null) 'status': status,
        'sort': sort,
        if (search != null) 'search': search,
      },
    );
    return MangaListModel.fromJson(response.data);
  }
}

import 'package:appmanga/core/constants/api_constants.dart';
import 'package:appmanga/core/network/dio_client.dart';
import '../models/home_data_model.dart';
import '../models/manga_list_model.dart';
import '../models/manga_detail_model.dart';

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
  Future<MangaDetailModel> getMangaDetail(String id);
  // Đổi từ Map thành dynamic để chấp nhận cả List và Object
  Future<dynamic> getChapterPages(String id);
  Future<void> likeManga(String mangaId);
  Future<void> unlikeManga(String mangaId);
  Future<void> followManga(String mangaId);
  Future<void> unfollowManga(String mangaId);
  Future<void> updateReadingHistory(String chapterId, int lastPage);
  Future<Map<String, dynamic>> unlockChapter(String chapterId);
  Future<int> getPointBalance();
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

  @override
  Future<MangaDetailModel> getMangaDetail(String id) async {
    final response = await _dioClient.dio.get('${ApiConstants.manga}/$id');
    return MangaDetailModel.fromJson(response.data['data']);
  }

  @override
  Future<dynamic> getChapterPages(String id) async {
    final response = await _dioClient.dio.get('/chapters/$id/pages');
    // Trả về toàn bộ data (có thể là List hoặc Map)
    return response.data['data'];
  }

  @override
  Future<void> likeManga(String mangaId) async {
    await _dioClient.dio.post('${ApiConstants.manga}/$mangaId/like');
  }

  @override
  Future<void> unlikeManga(String mangaId) async {
    await _dioClient.dio.delete('${ApiConstants.manga}/$mangaId/like');
  }

  @override
  Future<void> followManga(String mangaId) async {
    await _dioClient.dio.post('${ApiConstants.manga}/$mangaId/follow');
  }

  @override
  Future<void> unfollowManga(String mangaId) async {
    await _dioClient.dio.delete('${ApiConstants.manga}/$mangaId/follow');
  }

  @override
  Future<void> updateReadingHistory(String chapterId, int lastPage) async {
    await _dioClient.dio.post(ApiConstants.readingHistory, data: {
      'chapter_id': chapterId,
      'last_page': lastPage,
    });
  }

  @override
  Future<Map<String, dynamic>> unlockChapter(String chapterId) async {
    final response = await _dioClient.dio.post('/chapters/$chapterId/unlock');
    return response.data['data'];
  }

  @override
  Future<int> getPointBalance() async {
    final response = await _dioClient.dio.get(ApiConstants.pointsBalance);
    return response.data['data']['balance'];
  }
}

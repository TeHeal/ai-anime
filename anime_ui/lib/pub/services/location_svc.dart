import 'package:anime_ui/pub/models/location.dart';
import 'api.dart';

class LocationService {
  /// projectId 支持 int 或 String（UUID）
  Future<Location> create(Object projectId, {
    required String name,
    String time = '',
    String interiorExterior = '',
    String atmosphere = '',
    String colorTone = '',
    String layout = '',
    String style = '',
    bool styleOverride = false,
    String styleNote = '',
  }) async {
    final resp = await dio.post('/projects/${projectId.toString()}/locations', data: {
      'name': name,
      'time': time,
      'interior_exterior': interiorExterior,
      'atmosphere': atmosphere,
      'color_tone': colorTone,
      'layout': layout,
      'style': style,
      'style_override': styleOverride,
      'style_note': styleNote,
    });
    return extractDataObject(resp, Location.fromJson);
  }

  Future<List<Location>> list(Object projectId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/locations');
    return extractDataList(resp, Location.fromJson);
  }

  Future<Location> get(Object projectId, Object locId) async {
    final resp = await dio.get('/projects/${projectId.toString()}/locations/${locId.toString()}');
    return extractDataObject(resp, Location.fromJson);
  }

  Future<Location> update(Object projectId, Object locId, {
    String? name,
    String? time,
    String? interiorExterior,
    String? atmosphere,
    String? colorTone,
    String? layout,
    String? style,
    bool? styleOverride,
    String? styleNote,
    String? referenceImagesJson,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (time != null) body['time'] = time;
    if (interiorExterior != null) body['interior_exterior'] = interiorExterior;
    if (atmosphere != null) body['atmosphere'] = atmosphere;
    if (colorTone != null) body['color_tone'] = colorTone;
    if (layout != null) body['layout'] = layout;
    if (style != null) body['style'] = style;
    if (styleOverride != null) body['style_override'] = styleOverride;
    if (styleNote != null) body['style_note'] = styleNote;
    if (referenceImagesJson != null) body['reference_images_json'] = referenceImagesJson;
    final resp = await dio.put('/projects/${projectId.toString()}/locations/${locId.toString()}', data: body);
    return extractDataObject(resp, Location.fromJson);
  }

  Future<Location> confirm(Object projectId, Object locId) async {
    final resp = await dio.post('/projects/${projectId.toString()}/locations/${locId.toString()}/confirm');
    return extractDataObject(resp, Location.fromJson);
  }

  Future<void> delete(Object projectId, Object locId) async {
    await dio.delete('/projects/${projectId.toString()}/locations/${locId.toString()}');
  }

  Future<Location> generateImage(Object projectId, Object locId, {String? provider, String? model}) async {
    final body = <String, dynamic>{};
    if (provider != null) body['provider'] = provider;
    if (model != null) body['model'] = model;
    final resp = await dio.post(
      '/projects/${projectId.toString()}/locations/${locId.toString()}/generate-image',
      data: body,
    );
    return extractDataObject(resp, Location.fromJson);
  }
}

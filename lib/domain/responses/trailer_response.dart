
import 'package:emovie/domain/models/trailer.dart';

class TrailersResponse {
    int id;
    List<Trailer> results;

    TrailersResponse({
        required this.id,
        required this.results,
    });

    factory TrailersResponse.fromJson(Map<String, dynamic> json) => TrailersResponse(
        id: json["id"],
        results: List<Trailer>.from(json["results"].map((x) => Trailer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

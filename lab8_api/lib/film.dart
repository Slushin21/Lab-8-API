// Film model used by Tab A
class Film {
  final String? id;
  final String? title;
  final String? originalTitle;
  final String? director;
  final String? producer;
  final String? releaseDate;
  final String? runningTime;
  final String? rtScore;

  const Film({
    this.id,
    this.title,
    this.originalTitle,
    this.director,
    this.producer,
    this.releaseDate,
    this.runningTime,
    this.rtScore,
  });

  factory Film.fromJson(Map<String, dynamic> json) => Film(   // Constructor to build a film from a JSON map
        id: json['id'] as String?,
        title: json['title'] as String?,
        originalTitle: json['original_title'] as String?,
        director: json['director'] as String?,
        producer: json['producer'] as String?,
        releaseDate: json['release_date']?.toString(),
        runningTime: json['running_time']?.toString(),
        rtScore: json['rt_score']?.toString(),
      );
}

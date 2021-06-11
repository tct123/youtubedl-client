enum Status { PENDING, DOWNLOADING, FINISHED }

class Download {
  final String url;
  final Metadata metadata;
  Status status = Status.PENDING;

  Download(this.url, this.metadata);

  bool operator ==(o) => o is Download && url == o.url;
  int get hashCode => url.hashCode;
}

class Metadata {
  final String title;
  final String thumbnail;

  Metadata(this.title, this.thumbnail);

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      json['title'],
      json['thumbnail_url'],
    );
  }
}

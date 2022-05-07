class News {
  String type;
  String key;
  String title_en;
  String title_ar;
  String text_en;
  String text_ar;
  String category;
  String url;
  String img;
  int timestamp;
  String src_en;
  String src_ar;
  String score;
  String readtime;

  News({
    this.type,
    this.key,
    this.title_en,
    this.title_ar,
    this.text_en,
    this.text_ar,
    this.category,
    this.url,
    this.img,
    this.timestamp,
    this.src_en,
    this.src_ar,
    this.score,
    this.readtime
  });

  factory News.fromJson(Map<String, dynamic> json){
    return News(
        timestamp: json['t'],
        title_en: json['te'],
        // title_ar: json['ta'],
        text_en: json['se'],
        // text_ar: json['aa'],
        url: json['u'],
        img: json['i'],
        src_en: json['s'],
        // src_ar: json['sa'],
        category: json['c'],
        score: json['h'],
        readtime: json['r']
    );
  }

  toJson() {
    return {
      key:
      {
        "t": timestamp,
        "te": title_en,
        "ta": title_ar,
        "ae": text_en,
        "aa": text_ar,
        "u": url,
        "i": img,
        "se": src_en,
        "sa": src_ar,
        "c": category,
        "h": score
      }
    };
  }

}

class TextAd {
  String type;
  String key;
  String title_en;
  String title_ar;
  String text_en;
  String text_ar;
  String url;
  String mediaUrl;
  int priority;
  String sponsor;

  TextAd({
    this.type,
    this.key,
    this.title_en,
    this.title_ar,
    this.text_en,
    this.text_ar,
    this.url,
    this.mediaUrl,
    this.priority,
    this.sponsor,
  });

  factory TextAd.fromJson(Map<String, dynamic> json){
    return TextAd(
        type: 'textad',
        priority: json['p'],
        title_en: json['te'],
        title_ar: json['ta'],
        text_en: json['ae'],
        text_ar: json['aa'],
        url: json['u'],
        mediaUrl: json['i'],
        sponsor: json['se'],
    );
  }
  /*TextAd.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        priority = snapshot.value["t"],
        title_en = snapshot.value["te"],
        title_ar = snapshot.value["ta"],
        text_en = snapshot.value["ae"],
        text_ar = snapshot.value["aa"],
        url = snapshot.value["u"],
        mediaUrl = snapshot.value["i"],
        source_en = snapshot.value["se"],
        source_ar = snapshot.value["sa"],
        adtype = snapshot.value["c"];*/

  toJson() {
    return {
      key:
      {
        "p": priority,
        "te": title_en,
        "ta": title_ar,
        "ae": text_en,
        "aa": text_ar,
        "u": url,
        "i": mediaUrl,
        "se": sponsor,
      }
    };
  }

}
